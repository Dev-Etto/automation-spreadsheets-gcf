SELECT 
  TO_CHAR(cu.created_at, 'DD/MM/YYYY') AS "Data do Cadastro",
  cu.full_name AS "Nome",
  cu.email AS "Email"
FROM candidate."user" cu
LEFT JOIN candidate.user_details cud ON cud.user_id = cu.id
WHERE 
  cu.deleted_at IS NULL 
  AND cu.status = 'ACTIVE'
  AND cud.user_id IS NULL
ORDER BY cu.created_at DESC;