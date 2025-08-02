SELECT 
  TO_CHAR(c.created_at, 'DD/MM/YYYY') AS "dataCreacao",
  c.full_name AS "nome",
  c.email AS "email",
  cd.whatsapp AS "whatsapp"
FROM candidate.user c
INNER JOIN candidate.user_details cd ON c.id = cd.user_id
LEFT JOIN candidate.candidate_professional_history cph ON c.id = cph.candidate_id 
  AND cph.deleted_at IS NULL
WHERE 
  c.deleted_at IS NULL 
  AND c.status = 'ACTIVE'
  AND cd.deleted_at IS NULL
  AND cph.candidate_id IS NULL
ORDER BY c.created_at DESC;