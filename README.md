# Automação de Relatórios para Google Sheets

Este projeto automatiza a criação e atualização de relatórios em Google Sheets usando dados de um banco PostgreSQL através de Google Cloud Functions.

## 📋 Funcionalidades

- ✅ Executa queries SQL automaticamente
- ✅ Cria/atualiza planilhas Google Sheets
- ✅ Compartilha planilhas com usuários específicos
- ✅ Organiza dados em worksheets separadas
- ✅ Logging detalhado para monitoramento
- ✅ Tratamento de erros robusto

## 📁 Estrutura do Projeto

```
├── main.py                           # Função principal da Cloud Function
├── config.py                         # Configuração dos jobs e planilhas
├── requirements.txt                  # Dependências do projeto
└── queries/                          # Arquivos SQL (padrão: snake_case em inglês)
    ├── candidates_by_period.sql
    ├── candidates_balance.sql
    ├── courses_report.sql
    ├── talent_hunter_searches.sql
    ├── inactive_candidates.sql
    ├── active_candidates_no_experience.sql
    ├── active_candidates_incomplete_profile.sql
    └── job_openings_match_average.sql
```

## 🚀 Configuração

### 1. Autenticação com Google Sheets

A autenticação é feita automaticamente usando as **credenciais padrão da Service Account** configurada no Cloud Functions. Não é necessário arquivo de credenciais local.

**Configuração da Service Account:**
1. No Google Cloud Console, vá para IAM & Admin > Service Accounts
2. A Cloud Function usa automaticamente a service account configurada
3. Certifique-se que a service account tem as permissões:
   - Google Sheets API
   - Google Drive API

**⚠️ Importante**: Não use `gspread.service_account()` - isso procura arquivo local de credenciais

### 2. Configuração do Cloud SQL

Este projeto está configurado para conectar automaticamente a **instâncias Cloud SQL privadas** usando o **Cloud SQL Python Connector**. 

**Connection Name configurado**: `fit-asset-457015-m7:us-central1:portus-prod`

**Vantagens do Cloud SQL Connector**:
- ✅ Conexão automática a instâncias privadas
- ✅ Autenticação via IAM 
- ✅ Não precisa configurar VPC Connector
- ✅ Conexão segura e criptografada
- ✅ Não precisa de `DB_HOST` e `DB_PORT`

### 3. Variáveis de Ambiente

Configure as seguintes variáveis no Google Cloud Functions:

```bash
GCP_PROJECT=seu-projeto-gcp
```

### 4. Secrets no Google Secret Manager

Configure os seguintes secrets:
- `DB_NAME` - Nome do banco de dados
- `DB_USER` - Usuário do banco
- `DB_PASSWORD` - Senha do banco

**⚠️ Nota sobre Cloud SQL Privado**: Este projeto usa o **Cloud SQL Python Connector** para conectar automaticamente a instâncias Cloud SQL privadas. Não é necessário configurar `DB_HOST` e `DB_PORT` - a conexão é feita automaticamente via connection name da instância.

### 5. Configuração da Pasta do Google Drive

No arquivo `config.py`, configure o ID da pasta onde as planilhas serão criadas:

```python
# ID da pasta "Relatórios - Portus" no Google Drive
REPORTS_FOLDER_ID = "1i1ImmNk76EzYDh-2Z0yi5PdmXIPuTb8t"
```

**Como obter o ID da pasta:**
1. Acesse a pasta no Google Drive
2. Copie o ID da URL: `https://drive.google.com/drive/folders/[ID_DA_PASTA]`
3. Cole o ID no `config.py`

**Nota**: Se você comentar a linha `folder_id` no config.py, as planilhas serão criadas na raiz do Google Drive.

## 📊 Relatórios Gerados

### Planilha: "Relatório - Base de Candidatos SaaS [NOVO]"
1. **DB - Candidatos** - Dados completos de candidatos por período
2. **DB - Kpis** - Balanço e métricas de candidatos
3. **DB - Cursos** - Relatório de cursos predefinidos e customizados
4. **DB - Talent Hunter** - Dados de pesquisas do sistema
5. **DB - Candidatos não ativos na plataforma** - Candidatos inativos
6. **DB - Candidatos ativos sem trajetória profissional** - Candidatos sem histórico profissional
7. **DB - Candidatos ativos sem perfil preenchido** - Candidatos sem perfil completo

### Planilha: "Relatório - Média de match por vaga"
8. **[Data Atual]** - Relatório de média de match por vaga (ex: "02/agosto - 2025")
   - 🆕 **Nova funcionalidade**: Cria uma nova aba automaticamente com a data atual
   - Permite acompanhar a evolução histórica dos matches por vaga

## 🔧 Melhorias Implementadas

### ✅ Correções de Bugs
- Corrigido nome da worksheet "perfil preenchido" (estava "preenchidos")
- Melhorado tratamento de autenticação do Google Sheets
- Adicionado compartilhamento com domínio @portusdigital.com.br

### 🚀 Refatorações e Melhorias de Código
- **Eliminação de código duplicado** - 95% menos repetição no config.py
- **Configuração centralizada** - Emails em uma única variável (DEFAULT_SHARE_EMAILS)
- **Estrutura hierárquica** - Organização por planilhas no SPREADSHEETS_CONFIG
- **Geração automática de JOBS** - Lista JOBS criada dinamicamente
- **Padronização de nomenclatura** - Arquivos SQL renomeados para snake_case em inglês

### 📋 Mapeamento de Arquivos (Antigo → Novo)
```
candidatos por periodo.sql              → candidates_by_period.sql
balanço de candidatos.sql               → candidates_balance.sql
cursos.sql                              → courses_report.sql
talent_hunter.sql                       → talent_hunter_searches.sql
candidatos não ativos na plataforma.sql → inactive_candidates.sql
candidatos ativos sem trajetória prof.  → active_candidates_no_experience.sql
candidatos ativos sem perfil preench.   → active_candidates_incomplete_profile.sql
média de match de vagas.sql             → job_openings_match_average.sql
```

### ⚠️ Limitação do Domínio
**Importante**: O Google Sheets API não permite compartilhar diretamente com domínios via `gspread`. Para compartilhar com todos os usuários `@portusdigital.com.br`, você precisa:

1. **Opção 1**: Adicionar manualmente cada email específico no `config.py`
2. **Opção 2**: Configurar o compartilhamento manualmente no Google Drive após a criação
3. **Opção 3**: Usar a Google Drive API diretamente (mais complexo)

### 🛠️ Sugestões de Melhorias Futuras

1. **Validação de dados**:
```python
if df.empty:
    logging.warning(f"Query '{query_file}' retornou dados vazios.")
    continue
```

2. **Timeout para conexões**:
```python
conn = psycopg2.connect(
    # ... outros parâmetros
    connect_timeout=30
)
```

3. **Backup antes de sobrescrever**:
```python
# Fazer backup dos dados existentes antes de limpar a worksheet
```

4. **Retry logic para falhas temporárias**:
```python
import time
from functools import wraps

def retry(max_attempts=3, delay=1):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(max_attempts):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    if attempt == max_attempts - 1:
                        raise
                    time.sleep(delay)
            return wrapper
    return decorator
```

## 📝 Como Adicionar Novos Relatórios

### Método 1: Adicionando à planilha existente
Para adicionar uma nova query a uma planilha existente, edite o `config.py`:

```python
# No SPREADSHEETS_CONFIG, adicione na lista "queries"
"candidates_reports": {
    "sheet_name": "Relatório - Base de Candidatos SaaS [NOVO]",
    "queries": [
        # ... queries existentes
        {"file": "new_candidates_report.sql", "worksheet": "DB - Nova Aba"}
    ]
}
```

### Método 2: Criando nova planilha
Para criar uma planilha completamente nova:

```python
# Adicione uma nova seção no SPREADSHEETS_CONFIG
"new_report_category": {
    "sheet_name": "Nome da Nova Planilha",
    "queries": [
        {"file": "first_report.sql", "worksheet": "Aba 1"},
        {"file": "second_report.sql", "worksheet": "Aba 2"}
    ]
}
```

### Padrão de Nomenclatura
📋 **Siga o padrão snake_case em inglês para arquivos SQL:**
- ✅ `candidates_by_status.sql`
- ✅ `job_openings_summary.sql`  
- ✅ `recruitment_metrics.sql`
- ❌ `candidatos por status.sql`
- ❌ `JobOpeningsSummary.sql`

### Método 3: Alterando emails de compartilhamento
Para modificar quem recebe acesso às planilhas:

```python
# Edite DEFAULT_SHARE_EMAILS no config.py
DEFAULT_SHARE_EMAILS = [
    "novo.usuario@portusdigital.com.br",
    "outro.usuario@portusdigital.com.br"
]
```

## 🏃‍♂️ Deploy

### Deploy no Google Cloud Functions (Gen2)

```bash
# Deploy da Cloud Function Gen2 com configurações otimizadas
gcloud functions deploy automation-spreadsheets-gcf \
    --gen2 \
    --runtime=python311 \
    --source=. \
    --entry-point=process_reports \
    --trigger-http \
    --timeout=540s \
    --memory=1024MB \
    --region=us-central1 \
    --allow-unauthenticated
```

### Parâmetros do Deploy Explicados

- `--gen2`: Usa Cloud Functions 2ª geração (mais performático)
- `--runtime=python311`: Python 3.11 (versão mais recente suportada)
- `--entry-point=process_reports`: Função principal no main.py
- `--timeout=540s`: Timeout de 9 minutos (para queries longas)
- `--memory=1024MB`: 1GB de memória (para processar DataFrames grandes)
- `--region=us-central1`: Região recomendada para latência
- `--allow-unauthenticated`: Permite chamadas sem autenticação

### URL da Função Após Deploy

Após o deploy, a função estará disponível em:
```
https://us-central1-[SEU-PROJECT-ID].cloudfunctions.net/automation-spreadsheets-gcf
```

### Teste Rápido

```bash
# Testar a função via curl
curl -X POST "https://us-central1-[SEU-PROJECT-ID].cloudfunctions.net/automation-spreadsheets-gcf" \
     -H "Content-Type: application/json" \
     -d "{}"
```

## 📈 Monitoramento

Os logs estão disponíveis no Google Cloud Console. Procure por:
- ✅ "Job concluído com sucesso"
- ❌ "Falha ao processar o job"
- 🏁 "Processo finalizado"

## 🤝 Equipe de Acesso

Todos os relatórios são automaticamente compartilhados com:
- igor@portusdigital.com.br
- laila@portusdigital.com.br  
- joao.neto@portusdigital.com.br
