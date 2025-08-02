SELECT 
    TO_CHAR(created_at, 'DD/MM/YYYY') AS "Data da Criação",
    full_name AS "Nome do Candidato", 
    email AS "Email"
FROM candidate."user"
WHERE status = 'INACTIVE'
    AND deleted_at IS NULL
ORDER BY created_at DESC;