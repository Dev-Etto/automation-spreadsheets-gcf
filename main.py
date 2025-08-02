import os
import logging
import pandas as pd
import gspread
import psycopg2
import functions_framework
from google.cloud import secretmanager
from config import JOBS
from datetime import datetime

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

PROJECT_ID = os.environ.get('GCP_PROJECT')
DB_HOST_SECRET = "DB_HOST"
DB_PORT_SECRET = "DB_PORT"
DB_NAME_SECRET = "DB_NAME"
DB_USER_SECRET = "DB_USER"
DB_PASS_SECRET = "DB_PASSWORD"

def get_secret(secret_name):
    """Busca um segredo no Google Secret Manager."""
    if not PROJECT_ID:
        raise ValueError("Variável de ambiente GCP_PROJECT não definida.")
    client = secretmanager.SecretManagerServiceClient()
    name = f"projects/{PROJECT_ID}/secrets/{secret_name}/versions/latest"
    response = client.access_secret_version(request={"name": name})
    return response.payload.data.decode("UTF-8")

def get_db_connection():
    """Retorna um objeto de conexão com o banco de dados."""
    try:
        conn = psycopg2.connect(
            host=get_secret(DB_HOST_SECRET),
            port=get_secret(DB_PORT_SECRET),
            dbname=get_secret(DB_NAME_SECRET),
            user=get_secret(DB_USER_SECRET),
            password=get_secret(DB_PASS_SECRET)
        )
        return conn
    except Exception as e:
        logging.error(f"❌ Falha na conexão com o banco de dados: {e}")
        raise

def read_query_from_file(query_file):
    """Lê um arquivo .sql da pasta /queries."""
    try:
        path = os.path.join('queries', query_file)
        with open(path, 'r', encoding='utf-8') as f:
            return f.read()
    except FileNotFoundError:
        logging.error(f"❌ Arquivo de query não encontrado: {query_file}")
        raise

def generate_dynamic_worksheet_name(worksheet_name):
    """Gera nome dinâmico da worksheet baseado na data atual."""
    if worksheet_name == "DYNAMIC_DATE":
        now = datetime.now()
        meses = {
            1: 'janeiro', 2: 'fevereiro', 3: 'março', 4: 'abril',
            5: 'maio', 6: 'junho', 7: 'julho', 8: 'agosto',
            9: 'setembro', 10: 'outubro', 11: 'novembro', 12: 'dezembro'
        }
        mes_nome = meses[now.month]
        return f"{now.day:02d}/{mes_nome} - {now.year}"
    return worksheet_name

def get_or_create_spreadsheet(gc, job_config):
    """Tenta abrir uma planilha. Se não existir, cria e compartilha."""
    sheet_name = job_config["sheet_name"]
    try:
        spreadsheet = gc.open(sheet_name)
        logging.info(f"✅ Planilha '{sheet_name}' encontrada.")
        return spreadsheet
    except gspread.exceptions.SpreadsheetNotFound:
        logging.warning(f"⚠️ Planilha '{sheet_name}' não encontrada. Criando uma nova...")
        spreadsheet = gc.create(sheet_name)
        logging.info(f"✅ Planilha '{sheet_name}' criada.")
        
        emails_to_share = job_config.get("share_with", [])
        for email in emails_to_share:
            try:
                spreadsheet.share(email, perm_type='user', role='writer')
                logging.info(f"Compartilhada com {email}.")
            except Exception as e:
                logging.error(f"Falha ao compartilhar com {email}: {e}")
        
        try:
            spreadsheet.share('portusdigital.com.br', perm_type='domain', role='writer')
            logging.info("Compartilhada com domínio @portusdigital.com.br.")
        except Exception as e:
            logging.error(f"Falha ao compartilhar com domínio: {e}")
            
        return spreadsheet

@functions_framework.http
def handler(request):
    """Função principal que itera sobre todos os JOBS definidos em config.py."""
    logging.info(f"🚀 Iniciando execução. {len(JOBS)} jobs para processar.")
    
    try:
        gc = gspread.service_account(filename='credentials.json')
    except FileNotFoundError:
        gc = gspread.service_account()
    
    conn = get_db_connection()
    if not conn:
        return "Falha ao conectar no banco de dados.", 500

    success_count = 0
    for job in JOBS:
        query_file = job["query_file"]
        logging.info(f"--- Processando Job: {query_file} ---")
        try:
            query = read_query_from_file(query_file)
            df = pd.read_sql_query(query, conn)
            logging.info(f"Query executada. {len(df)} linhas retornadas.")
            
            spreadsheet = get_or_create_spreadsheet(gc, job)
            
            # Gerar nome dinâmico da worksheet se necessário
            worksheet_name = generate_dynamic_worksheet_name(job["worksheet_name"])
            logging.info(f"Nome da worksheet: {worksheet_name}")
            
            try:
                worksheet = spreadsheet.worksheet(worksheet_name)
                logging.info(f"Worksheet '{worksheet_name}' encontrada. Dados serão sobrescritos.")
            except gspread.exceptions.WorksheetNotFound:
                worksheet = spreadsheet.add_worksheet(title=worksheet_name, rows="100", cols="20")
                logging.info(f"Nova worksheet '{worksheet_name}' criada.")

            worksheet.clear()
            worksheet.update([df.columns.values.tolist()] + df.values.tolist(), value_input_option='USER_ENTERED')
            logging.info(f"✅ Job '{query_file}' concluído com sucesso.")
            success_count += 1
        except Exception as e:
            logging.error(f"❌ Falha ao processar o job '{query_file}': {e}")
    
    conn.close()
    logging.info("ℹ️ Conexão com o banco de dados fechada.")
    msg = f"🏁 Processo finalizado. {success_count} de {len(JOBS)} jobs concluídos."
    logging.info(msg)
    return msg, 200