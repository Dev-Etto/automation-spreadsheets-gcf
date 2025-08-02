import os
import logging
import pandas as pd
import gspread
import psycopg2
import functions_framework
from google.cloud import secretmanager
from google.auth import default
from google.cloud.sql.connector import Connector
from config import JOBS
from datetime import datetime

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Configuração de secrets
DB_NAME_SECRET = "DB_NAME"
DB_USER_SECRET = "DB_USER"
DB_PASS_SECRET = "DB_PASSWORD"

def get_secret(secret_name):
    """Busca um segredo no Google Secret Manager."""
    try:
        # Obter project_id automaticamente
        project_id = os.environ.get('GCP_PROJECT') or os.environ.get('GOOGLE_CLOUD_PROJECT')
        if not project_id:
            import requests
            response = requests.get(
                'http://metadata.google.internal/computeMetadata/v1/project/project-id',
                headers={'Metadata-Flavor': 'Google'},
                timeout=5
            )
            project_id = response.text
        
        logging.info(f"🔍 Buscando secret '{secret_name}' no projeto: {project_id}")
        client = secretmanager.SecretManagerServiceClient()
        name = f"projects/{project_id}/secrets/{secret_name}/versions/latest"
        response = client.access_secret_version(request={"name": name})
        secret_value = response.payload.data.decode("UTF-8").strip()
        logging.info(f"✅ Secret '{secret_name}' obtido com sucesso")
        return secret_value
    except Exception as e:
        logging.error(f"❌ Erro ao buscar secret '{secret_name}': {e}")
        raise

def get_db_connection():
    """Retorna um objeto de conexão com o banco de dados usando Cloud SQL Connector."""
    try:
        logging.info("🔄 Conectando ao banco de dados via Cloud SQL Connector...")
        
        # Connection name da instância Cloud SQL
        instance_connection_name = "fit-asset-457015-m7:us-central1:portus-prod"
        
        # Buscar credenciais do Secret Manager
        dbname = get_secret(DB_NAME_SECRET)
        user = get_secret(DB_USER_SECRET)
        password = get_secret(DB_PASS_SECRET)
        
        logging.info(f"🔗 Conectando à instância: {instance_connection_name}")
        logging.info(f"🔗 Banco: {dbname} | Usuário: {user}")
        
        # Inicializar Cloud SQL Connector
        connector = Connector()
        
        def getconn():
            conn = connector.connect(
                instance_connection_name,
                "pg8000",
                user=user,
                password=password,
                db=dbname,
            )
            return conn
        
        # Criar conexão
        conn = getconn()
        logging.info("✅ Conexão com Cloud SQL estabelecida via Cloud SQL Connector")
        return conn
    except Exception as e:
        logging.error(f"❌ Falha na conexão com o banco de dados: {e}")
        raise

def read_query_from_file(query_file):
    """Lê um arquivo .sql da pasta /queries."""
    try:
        path = os.path.join('queries', query_file)
        logging.info(f"📄 Lendo query do arquivo: {path}")
        with open(path, 'r', encoding='utf-8') as f:
            query = f.read()
        logging.info(f"✅ Query lida com sucesso ({len(query)} caracteres)")
        return query
    except FileNotFoundError:
        logging.error(f"❌ Arquivo de query não encontrado: {query_file}")
        raise
    except Exception as e:
        logging.error(f"❌ Erro ao ler arquivo {query_file}: {e}")
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
    """Tenta abrir uma planilha. Se não existir, cria na pasta correta."""
    sheet_name = job_config["sheet_name"]
    
    try:
        logging.info(f"🔍 Procurando planilha existente: '{sheet_name}'")
        spreadsheet = gc.open(sheet_name)
        logging.info(f"✅ Planilha '{sheet_name}' encontrada (ID: {spreadsheet.id})")
        return spreadsheet
        
    except gspread.exceptions.SpreadsheetNotFound:
        logging.info(f"📊 Planilha '{sheet_name}' não encontrada. Criando nova...")
        
        try:
            # Tentar criar na pasta "Relatórios - Portus" se especificada
            folder_id = job_config.get("folder_id")
            if folder_id:
                logging.info(f"📁 Criando planilha na pasta ID: {folder_id}")
                spreadsheet = gc.create(sheet_name, folder_id=folder_id)
            else:
                logging.info("📁 Criando planilha na raiz do Drive")
                spreadsheet = gc.create(sheet_name)
                
            logging.info(f"✅ Planilha '{sheet_name}' criada com sucesso (ID: {spreadsheet.id})")
            
            # Compartilhar com emails específicos se definidos
            emails_to_share = job_config.get("share_with", [])
            for email in emails_to_share:
                try:
                    spreadsheet.share(email, perm_type='user', role='writer')
                    logging.info(f"📤 Compartilhada com {email}")
                except Exception as e:
                    logging.error(f"❌ Falha ao compartilhar com {email}: {e}")
            
            # Compartilhar com domínio se especificado
            domain = job_config.get("domain_share")
            if domain:
                try:
                    spreadsheet.share(domain, perm_type='domain', role='writer')
                    logging.info(f"📤 Compartilhada com domínio: {domain}")
                except Exception as e:
                    logging.error(f"❌ Falha ao compartilhar com domínio {domain}: {e}")
                    
            return spreadsheet
            
        except Exception as e:
            logging.error(f"❌ Erro ao criar planilha '{sheet_name}': {e}")
            raise

@functions_framework.http
def process_reports(request):
    """Função principal que processa todos os jobs definidos em config.py."""
    logging.info(f"🚀 Iniciando processamento de relatórios...")
    logging.info(f"📋 Total de jobs configurados: {len(JOBS)}")
    
    # Autenticação com Google Sheets
    try:
        logging.info("🔐 Autenticando com Google Sheets...")
        # Usar credenciais padrão do Cloud Function (service account configurada)
        credentials, project = default(scopes=[
            'https://www.googleapis.com/auth/spreadsheets',
            'https://www.googleapis.com/auth/drive'
        ])
        gc = gspread.authorize(credentials)
        logging.info("✅ Autenticação com Google Sheets realizada")
    except Exception as e:
        logging.error(f"❌ Falha na autenticação com Google Sheets: {e}")
        return f"❌ Erro de autenticação: {e}", 500
    
    # Conexão com banco de dados
    try:
        conn = get_db_connection()
    except Exception as e:
        return f"❌ Falha ao conectar no banco de dados: {e}", 500

    # Processamento dos jobs
    success_count = 0
    total_jobs = len(JOBS)
    
    for i, job in enumerate(JOBS, 1):
        query_file = job["query_file"]
        sheet_name = job["sheet_name"]
        
        logging.info(f"\n{'='*60}")
        logging.info(f"📊 JOB {i}/{total_jobs}: {query_file}")
        logging.info(f"📄 Planilha: {sheet_name}")
        logging.info(f"{'='*60}")
        
        try:
            # 1. Ler query
            query = read_query_from_file(query_file)
            
            # 2. Executar query
            logging.info("🔄 Executando query no banco de dados...")
            df = pd.read_sql_query(query, conn)
            logging.info(f"✅ Query executada com sucesso - {len(df)} linhas, {len(df.columns)} colunas")
            
            if df.empty:
                logging.warning("⚠️ Query retornou resultado vazio")
                continue
            
            # 3. Obter/criar planilha
            spreadsheet = get_or_create_spreadsheet(gc, job)
            
            # 4. Processar worksheet
            worksheet_name = generate_dynamic_worksheet_name(job["worksheet_name"])
            logging.info(f"📝 Nome da worksheet: '{worksheet_name}'")
            
            try:
                worksheet = spreadsheet.worksheet(worksheet_name)
                logging.info(f"✅ Worksheet '{worksheet_name}' encontrada - dados serão atualizados")
            except gspread.exceptions.WorksheetNotFound:
                rows = max(len(df) + 10, 100)
                cols = max(len(df.columns) + 5, 20)
                worksheet = spreadsheet.add_worksheet(title=worksheet_name, rows=rows, cols=cols)
                logging.info(f"✅ Nova worksheet '{worksheet_name}' criada ({rows}x{cols})")

            # 5. Atualizar dados
            logging.info("📤 Enviando dados para a planilha...")
            worksheet.clear()
            
            # Preparar dados (cabeçalho + linhas)
            data_to_update = [df.columns.values.tolist()] + df.values.tolist()
            worksheet.update(data_to_update, value_input_option='USER_ENTERED')
            
            logging.info(f"✅ JOB {i}/{total_jobs} CONCLUÍDO: '{query_file}' -> '{sheet_name}'")
            success_count += 1
            
        except Exception as e:
            logging.error(f"❌ FALHA no JOB {i}/{total_jobs} '{query_file}': {e}")
            import traceback
            logging.error(f"🔍 Detalhes do erro: {traceback.format_exc()}")
    
    # Fechamento
    try:
        conn.close()
        logging.info("🔒 Conexão com banco de dados fechada")
    except:
        pass
    
    # Resultado final
    msg = f"🏁 Processamento finalizado: {success_count}/{total_jobs} jobs concluídos com sucesso"
    logging.info(f"\n{'='*60}")
    logging.info(msg)
    logging.info(f"{'='*60}")
    
    if success_count == total_jobs:
        return msg, 200
    else:
        return f"⚠️ {msg} - Verifique os logs para detalhes dos erros", 206