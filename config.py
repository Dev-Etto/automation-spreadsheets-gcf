"""
Arquivo de configuração para mapear queries a planilhas Google.
"""

# Lista de emails padrão para compartilhamento
DEFAULT_SHARE_EMAILS = [
    "igor@portusdigital.com.br",
    "laila@portusdigital.com.br",
    "joao.neto@portusdigital.com.br"
]

# Configuração de planilhas
SPREADSHEETS_CONFIG = {
    "candidates_reports": {
        "sheet_name": "Relatório - Base de Candidatos SaaS [NOVO]",
        "queries": [
            {"file": "candidates_by_period.sql", "worksheet": "DB - Candidatos"},
            {"file": "candidates_balance.sql", "worksheet": "DB - Kpis"},
            {"file": "courses_report.sql", "worksheet": "DB - Cursos"},
            {"file": "talent_hunter_searches.sql", "worksheet": "DB - Talent Hunter"},
            {"file": "inactive_candidates.sql", "worksheet": "DB - Candidatos não ativos na plataforma"},
            {"file": "active_candidates_no_experience.sql", "worksheet": "DB - Candidatos ativos sem trajetória profissional"},
            {"file": "active_candidates_incomplete_profile.sql", "worksheet": "DB - Candidatos ativos sem perfil preenchido"}
        ]
    },
    "job_match_reports": {
        "sheet_name": "Relatório - Média de match por vaga",
        "queries": [
            {"file": "job_openings_match_average.sql", "worksheet": "DYNAMIC_DATE"}
        ]
    }
}

# Gerar JOBS dinamicamente
JOBS = []
for config in SPREADSHEETS_CONFIG.values():
    for query in config["queries"]:
        JOBS.append({
            "query_file": query["file"],
            "sheet_name": config["sheet_name"],
            "worksheet_name": query["worksheet"],
            "share_with": DEFAULT_SHARE_EMAILS
        })
