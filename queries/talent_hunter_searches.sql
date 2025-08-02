SELECT
  s.id,
  TO_CHAR(s.created_at, 'YYYY-MM-DD') AS data_pesquisa,
  TO_CHAR(s.created_at, 'HH24:MI:SS') AS horario_pesquisa,
  s.user_id,
  s.user_type,
  -- Nome do usuário
  CASE
    WHEN s.user_type = 'CLIENT' THEN cu.name
    WHEN s.user_type = 'RECRUITER' THEN ru.name
    ELSE ' - '
  END AS user_name,
  -- Nome do cliente associado ao usuário CLIENT
  CASE
    WHEN s.user_type = 'CLIENT' THEN COALESCE(rc.corporate_name, rc.fantasy_name, ' - ')
    ELSE ' - '
  END AS client_name,
  jp.name AS job_position_name,
  s.min_salary,
  s.max_salary,
  COALESCE(et.name, ' - ') AS experience_time_name,
  CASE WHEN array_length(s.keywords, 1) > 0 THEN array_to_string(s.keywords, ', ') ELSE ' - ' END AS keywords,
  COALESCE(s.ia_proficiency_level::text, ' - ') AS ia_proficiency_level,
  COALESCE(s.gender::text, ' - ') AS gender,
  COALESCE(s.candidates_found_count::text, ' - ') AS resultado,

  -- Modelos de contrato (CLT, PJ, etc)
  COALESCE(
    NULLIF(
      ARRAY_TO_STRING(
        ARRAY(
          SELECT cm.name
          FROM common.smart_match_search_contract_model scm
          JOIN common.contract_model cm ON scm.contract_model_id = cm.id
          WHERE scm.search_id = s.id
        ), ', '
      ), ''
    ), ' - '
  ) AS contract_models,

  -- Modelos de trabalho (Remoto, Híbrido, etc)
  COALESCE(
    NULLIF(
      ARRAY_TO_STRING(
        ARRAY(
          SELECT jm.name
          FROM common.smart_match_search_job_model sjm
          JOIN common.job_model jm ON sjm.job_model_id = jm.id
          WHERE sjm.search_id = s.id
        ), ', '
      ), ''
    ), ' - '
  ) AS job_models,

  -- Disponibilidade (Integral, Parcial, etc)
  COALESCE(
    NULLIF(
      ARRAY_TO_STRING(
        ARRAY(
          SELECT a.name
          FROM common.smart_match_search_availability sa
          JOIN common.job_availability a ON sa.availability_id = a.id
          WHERE sa.search_id = s.id
        ), ', '
      ), ''
    ), ' - '
  ) AS availabilities,

  -- Skills (soft/hard)
  COALESCE(
    NULLIF(
      ARRAY_TO_STRING(
        ARRAY(
          SELECT sp.name
          FROM common.smart_match_search_skill ss
          JOIN candidate.skills sp ON ss.skill_id = sp.id
          WHERE ss.search_id = s.id
        ), ', '
      ), ''
    ), ' - '
  ) AS skills,

  -- Ferramentas
  COALESCE(
    NULLIF(
      ARRAY_TO_STRING(
        ARRAY(
          SELECT jt.name
          FROM common.smart_match_search_tool st
          JOIN common.job_tools jt ON st.job_tool_id = jt.id
          WHERE st.search_id = s.id
        ), ', '
      ), ''
    ), ' - '
  ) AS tools,

  -- Idiomas (nome + fluência)
  COALESCE(
    NULLIF(
      ARRAY_TO_STRING(
        ARRAY(
          SELECT l.name || ' (' || fl.name || ')'
          FROM common.smart_match_search_language sl
          JOIN common.language l ON sl.language_id = l.id
          JOIN common.fluency_level fl ON sl.fluency_level_id = fl.id
          WHERE sl.search_id = s.id
        ), ', '
      ), ''
    ), ' - '
  ) AS languages,

  -- Especializações
  COALESCE(
    NULLIF(
      ARRAY_TO_STRING(
        ARRAY(
          SELECT sa.name
          FROM common.smart_match_search_education_specialization ses
          JOIN common.specialization_area sa ON ses.specialization_area_id = sa.id
          WHERE ses.search_id = s.id
        ), ', '
      ), ''
    ), ' - '
  ) AS education_specializations,

  -- Cursos
  COALESCE(
    NULLIF(
      ARRAY_TO_STRING(
        ARRAY(
          SELECT ce.name
          FROM common.smart_match_search_education_course sec
          JOIN common.course_education ce ON sec.course_education_id = ce.id
          WHERE sec.search_id = s.id
        ), ', '
      ), ''
    ), ' - '
  ) AS education_courses,

  -- Regiões (estado - código cidade)
  COALESCE(
    NULLIF(
      ARRAY_TO_STRING(
        ARRAY(
          SELECT sr.state || ' - ' || sr.city_code
          FROM common.smart_match_search_region sr
          WHERE sr.search_id = s.id
        ), ', '
      ), ''
    ), ' - '
  ) AS regions

FROM common.smart_match_search s
LEFT JOIN common.job_position jp ON s.job_position_id = jp.id
LEFT JOIN common.experience_time et ON s.experience_time_id = et.id
LEFT JOIN client.user cu ON s.user_id = cu.id AND s.user_type = 'CLIENT'
LEFT JOIN recruiter.user ru ON s.user_id = ru.id AND s.user_type = 'RECRUITER'
LEFT JOIN recruiter.client rc ON rc.manager_client_user_id = s.user_id
ORDER BY s.created_at DESC;