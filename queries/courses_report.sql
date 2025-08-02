-- Cursos predefinidos
SELECT
  ce.name || ' - ' || ce.minister AS "Curso - Ministrante",
  COUNT(*) AS "Qtd Perfis",
  'Predefinido' AS "Tipo"
FROM candidate.candidate_course_education cce1
JOIN common.course_education ce ON ce.id = cce1.course_education_id
JOIN candidate."user" cu ON cu.id = cce1.candidate_id
WHERE cu.deleted_at IS NULL
GROUP BY ce.name, ce.minister

UNION ALL

-- Cursos customizados
SELECT
  cce.name || ' - ' || cce.minister AS "Curso - Ministrante",
  COUNT(*) AS "Qtd Perfis",
  'Customizado' AS "Tipo"
FROM candidate.candidate_custom_course cce
JOIN candidate."user" cu ON cu.id = cce.candidate_id
WHERE cu.deleted_at IS NULL
GROUP BY cce.name, cce.minister

ORDER BY "Qtd Perfis" DESC, "Curso - Ministrante";