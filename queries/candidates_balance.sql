WITH dias AS (
  SELECT generate_series(
    (SELECT MIN(created_at::date) FROM candidate."user"),
    CURRENT_DATE,
    INTERVAL '1 day'
  )::date AS dia
)
SELECT
  dias.dia,
  (SELECT COUNT(*) FROM candidate."user" u WHERE u.created_at::date <= dias.dia) AS "total candidatos",
  (SELECT COUNT(*) FROM candidate."user" u WHERE u.created_at::date <= dias.dia AND u.status = 'INACTIVE') AS "candidatos inativos",
  (SELECT COUNT(*) FROM candidate."user_details" ud WHERE ud.created_at::date <= dias.dia) AS "candidatos com perfil preenchido",
  (SELECT COUNT(*) FROM candidate."user" u WHERE u.created_at::date <= dias.dia AND u.deleted_at IS NOT NULL) AS "solicitou exclusão"
FROM dias
ORDER BY dias.dia;