SELECT
  jo.id AS "id_vaga",
  jp.name AS "cargo",
  ru.name AS "recrutador_portus",
  cu.name AS "recrutador_cliente",
  c.fantasy_name AS "cliente",
  jo.status,
  jm.name AS "modalidade",
  CASE
    WHEN jm.work_modality = 'REMOTE' THEN ''
    ELSE STRING_AGG(DISTINCT CONCAT(jopr.city, ' / ', jopr.state), ', ')
  END AS "local_vaga",
  COUNT(a.id) AS "total_candidaturas",
  COUNT(*) FILTER (WHERE a.status = 'NEW') AS "novos",
  COUNT(*) FILTER (WHERE a.status = 'LIKED') AS "gostei",
  COUNT(*) FILTER (WHERE a.status = 'INTERVIEW') AS "em_entrevista",
  COUNT(*) FILTER (WHERE a.status = 'HIRED') AS "contratado",
  COUNT(*) FILTER (WHERE a.status = 'REJECTED') AS "rejeitado",
  COUNT(*) FILTER (WHERE a.status = 'CANCELED') AS "cancelado",
  COUNT(*) FILTER (WHERE a.match_index > 70) AS "candidatos_match_70",
  ROUND(AVG(a.match_index)::numeric, 2) AS "media_match"
FROM common.job_opening jo
JOIN common.job_position jp ON jp.id = jo.job_position_id
LEFT JOIN recruiter.user ru ON ru.id = jo.responsible_recruiter_id
LEFT JOIN client.user cu ON cu.id = jo.responsible_client_id
LEFT JOIN recruiter.client c ON c.id = jo.client_id
LEFT JOIN common.job_model jm ON jm.id = jo.job_model_id
LEFT JOIN common.job_opening_preferred_region jopr ON jopr.job_opening_id = jo.id
LEFT JOIN candidate.application a ON a.job_opening_id = jo.id AND a.deleted_at IS NULL
WHERE (jo.status = 'IN_PROGRESS' OR jo.status = 'CLOSED_FOR_APPLICATIONS')
  AND jo.deleted_at IS NULL
GROUP BY jo.id, jp.name, ru.name, cu.name, c.fantasy_name, jo.status, jm.name, jm.work_modality
ORDER BY jo.created_at DESC;