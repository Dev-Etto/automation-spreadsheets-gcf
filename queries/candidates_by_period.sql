SELECT
  TO_CHAR(cu.created_at, 'YYYY-MM-DD') AS "Data de cadastro",
  cu.id AS "ID do Candidato",
  ca.city AS "Cidade",
  ca.state AS "Estado",
  cud.gender AS "Gênero",
  cud.civil_state AS "Estado Civil",
  EXTRACT(YEAR FROM AGE(cud.birth_date)) AS "Idade",
  STRING_AGG(DISTINCT jp.name, ', ') AS "Cargos de Interesse",
  STRING_AGG(DISTINCT cm.name, ', ') AS "Preferência formato de contratação",
  STRING_AGG(DISTINCT jm.name, ', ') AS "Preferência formato de trabalho",
  STRING_AGG(DISTINCT ja.name, ', ') AS "Disponibilidade",
  cud.max_salary AS "Expectativa Remuneração",
  (
    SELECT jp2.name
    FROM candidate.candidate_professional_history cph2
    JOIN common.job_position jp2 ON jp2.id = cph2.job_position_id
    WHERE cph2.candidate_id = cu.id AND cph2.current_job = true
    ORDER BY cph2.start_date DESC
    LIMIT 1
  ) AS "Cargo Atual",
  (
    SELECT jp3.name
    FROM candidate.candidate_professional_history cph3
    JOIN common.job_position jp3 ON jp3.id = cph3.job_position_id
    WHERE cph3.candidate_id = cu.id AND (cph3.current_job = false OR cph3.current_job IS NULL)
    ORDER BY cph3.start_date DESC
    LIMIT 1
  ) AS "Cargo Mais Recente",
  
  -- Experiência por cargo (em ordem alfabética conforme especificado)
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '77aabde3-49f0-4f0e-8001-5ccfdbe6cd63') AS "Analista de Business Intelligence", -- Analista de Business Intelligence
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '7d0b2ade-291f-451b-b14a-78d15951d944') AS "Analista de Conteúdo", -- Analista de Conteúdo
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '3da356ff-87ac-41fe-8aae-7fcdb3f7547d') AS "Analista de CRM", -- Analista de CRM
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '7ca59a3f-612b-4810-bf51-e217e96f4774') AS "Analista de Customer Success (CS)", -- Analista de Customer Success (CS)
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '18db59ee-c437-441b-a3f9-cb871d5f2080') AS "Analista de Dados", -- Analista de Dados
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '4bda7e6d-7010-4092-bb54-21101ca3d6f3') AS "Analista de E-mail Marketing", -- Analista de E-mail Marketing
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = 'a5009ec4-3e52-4b31-bd1c-5c8b7fc28082') AS "Analista de Infraestrutura de Mkt Digital", -- Analista de Infraestrutura de Mkt Digital
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = 'ae23fcaf-7d85-4d66-b7e8-497e5fdf7bc4') AS "Analista de Marketing", -- Analista de Marketing
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '78b38f64-f047-4910-b9fa-fcf2aaa6a11f') AS "Analista de Recursos Humanos", -- Analista de Recursos Humanos
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '305bfc44-3066-4a21-8452-2c439d8ea9fb') AS "Analista de SEO", -- Analista de SEO
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '375f2e72-abc6-4c92-8064-bfdcb8380786') AS "Analista Financeiro", -- Analista Financeiro
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '5e648417-151b-40ec-af9b-3b29ed6fd9c4') AS "Arquiteto de Software", -- Arquiteto de Software
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '1ceda7e1-7e3e-44f9-acbc-66971af8ffe6') AS "Assistente Administrativo", -- Assistente Administrativo
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = 'a4c938c6-d264-468f-9598-278d7240cc78') AS "Assistente de Infoproduto", -- Assistente de Infoproduto
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '0043374b-2eb6-4f9f-bf8c-c83904e5a2d9') AS "Assistente Pessoal", -- Assistente Pessoal
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = 'f38cdfb1-56aa-41ed-8773-6af1a4bc708a') AS "BDR", -- BDR
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = 'ff40e826-e303-4c65-b405-b9a6d9665afb') AS "Cientista de Dados", -- Cientista de Dados
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '9b115d79-04d4-4f8d-8a2f-776b2d1061bf') AS "Closer", -- Closer
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '8f720b8a-3f43-49de-b8a0-e34a66173129') AS "Community Manager / Gestor de Comunidade", -- Community Manager / Gestor de Comunidade
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '58871c05-f2ea-4fdb-9dec-004cb888c93a') AS "Consultor de Treinamentos", -- Consultor de Treinamentos
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '2eaba755-1e33-4f79-a822-acf1d4e75366') AS "Controller Administrativo", -- Controller Administrativo
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = 'b98496f9-0c89-4d0f-ae21-4f18c7680adf') AS "Coordenador Comercial", -- Coordenador Comercial
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '55e4e9d4-584d-4d68-a081-6d08b85d7358') AS "Coordenador de Customer Success", -- Coordenador de Customer Success
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = 'db667334-1e4f-4b02-a719-bc62a9cd4e62') AS "Coordenador de Eventos", -- Coordenador de Eventos
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '6e78dbaf-ce92-47d6-ad77-3dccddca1883') AS "Coordenador de Recursos Humanos", -- Coordenador de Recursos Humanos
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '834c45f5-1c6f-42be-a234-ecf5ec69a17e') AS "Coordenador Financeiro", -- Coordenador Financeiro
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = 'caa19679-59a0-439f-aa8d-1a94306980bf') AS "Copywriter", -- Copywriter
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '0cb1ddf7-827b-4838-9075-5acdf7198c39') AS "Customer Experience (CX)", -- Customer Experience (CX)
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '6934d4e3-f9b2-4bdd-b968-3fce4cb082fd') AS "Desenvolvedor Back-end", -- Desenvolvedor Back-end
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '7c9725c8-7eae-41fe-bb22-1eb753a4e4e2') AS "Desenvolvedor Front-end", -- Desenvolvedor Front-end
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '8c002614-2fac-437a-b2b7-f8a2dcaeaf68') AS "Desenvolvedor Fullstack", -- Desenvolvedor Fullstack
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '3cde1fca-2379-4f0b-9030-60a04197f533') AS "Desenvolvedor Mobile", -- Desenvolvedor Mobile
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = 'c76a02c3-ed48-4547-8204-4cfa26ac1459') AS "Designer", -- Designer
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '992ed0a8-95fa-486b-b9aa-2117d3207536') AS "Designer de Produto / Designer Instrucional", -- Designer de Produto / Designer Instrucional
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '7f931127-e33d-45d1-85ba-1dc80d68db19') AS "DevOps", -- DevOps
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = 'a8385e07-f592-4064-9622-b5db9d61b658') AS "Diretor de Criação", -- Diretor de Criação
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '1b8c45ac-c934-4c9d-9977-8983a3578fea') AS "Diretor de Marketing - CMO", -- Diretor de Marketing - CMO
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = 'a7896676-a8f6-4c0d-8896-2e1158bbcb1c') AS "Diretor de Operações - COO", -- Diretor de Operações - COO
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '6f9ecd68-8b38-4b18-a483-acd1c368c245') AS "Diretor de Produto - CPO", -- Diretor de Produto - CPO
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '34d163b9-77e9-4b76-9171-709184a1dd49') AS "Diretor de Receitas - CRO", -- Diretor de Receitas - CRO
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '1e37e294-65b8-4b6f-b066-87849108e5df') AS "Diretor de Tecnologia - CTO", -- Diretor de Tecnologia - CTO
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '2fc0e548-c3a3-45ec-a8dd-b99832ecbdef') AS "Diretor Executivo - CEO", -- Diretor Executivo - CEO
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '7d233512-102a-4dda-ab71-b236afed26d4') AS "Editor de Vídeos", -- Editor de Vídeos
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '31ab4d2b-a060-4797-9c32-2a07ebd5023a') AS "Engenheiro de Dados", -- Engenheiro de Dados
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = 'e32b7570-4499-4cd8-ba35-04830437c3a6') AS "Especialista em Branding", -- Especialista em Branding
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = 'b9c03277-a64f-4eb5-bce1-aae6ce3c45e1') AS "Estrategista de Conteúdo", -- Estrategista de Conteúdo
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '394efc5b-954f-4321-a291-5d2ee03b1fa8') AS "Estrategista Digital", -- Estrategista Digital
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = 'ba512e90-6bff-4f35-8136-68c288c63ca3') AS "Executivo de Contas (Account Executive)", -- Executivo de Contas (Account Executive)
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '21aa8177-b3b9-43bb-bd2b-1c3cd4efeea6') AS "Gerente Administrativo", -- Gerente Administrativo
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = 'c1f7f3cc-cbca-47fa-a909-7217d1bdf601') AS "Gerente de Projetos", -- Gerente de Projetos
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '9883b677-ade9-4d1d-b1bf-bc6aa9cd6fcc') AS "Gerente de RH", -- Gerente de RH
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '695b962d-99b9-4e15-b306-7a372eeb19a0') AS "Gerente Financeiro", -- Gerente Financeiro
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = 'e2742acb-76e5-4f56-b521-11decff8e8e5') AS "Gestor de Infraestrutura / Automações", -- Gestor de Infraestrutura / Automações
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '94859db6-9da7-48f8-aaf4-47f5ff40282b') AS "Gestor de Tráfego", -- Gestor de Tráfego
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = 'dd2f4629-9bcb-4129-a634-3e51e522a030') AS "Growth Hacker", -- Growth Hacker
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '2a80f9f0-d27f-4d1d-b825-eb2d8d1e4e7b') AS "Head Comercial", -- Head Comercial
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '8f1cf2f8-3ebd-4cf5-81b6-6b69b40f5622') AS "Head de Marketing", -- Head de Marketing
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = 'a0cfefae-8307-4677-876a-1ef555d378a8') AS "Head de Produto", -- Head de Produto
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = 'c230d62c-7d3a-4e43-8486-81cff8f76db6') AS "Head de RH", -- Head de RH
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '22bd7643-4653-485f-afb9-0dee6b1a1aae') AS "Mobile Developer", -- Mobile Developer
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '05ace8b6-9dc4-42f6-a5ce-c4cc1b28b676') AS "Product Owner", -- Product Owner
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '058688b4-03ad-443b-9c5c-66f9aac9b853') AS "QA Engineer / Analista de Testes", -- QA Engineer / Analista de Testes
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = 'b818c172-dc52-4d2d-98b5-b554aba27392') AS "Recuperador de Vendas", -- Recuperador de Vendas
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '1285a25d-552f-42b1-9be8-0b54aa56a0e5') AS "Redator", -- Redator
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = 'f37e32f2-55db-4e25-9734-7d24fae72ca3') AS "Revenue Operations (RevOps)", -- Revenue Operations (RevOps)
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = 'f30c567a-a3de-45a5-8c32-a4d45a5192b2') AS "Sales Ops (Operações de Vendas)", -- Sales Ops (Operações de Vendas)
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '8a686411-cc0f-49f7-a528-cfdbec417e58') AS "SDR (Sales Development Rep.)", -- SDR (Sales Development Rep.)
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '1d445615-8548-4ad6-a041-5c57808fbac5') AS "Secretária Executiva", -- Secretária Executiva
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = 'fc43fdfa-7319-470f-8e94-abc308fe5bcc') AS "Social Media", -- Social Media
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = 'fc7a06ea-9557-41af-98f9-2bd22db78b15') AS "Social Seller", -- Social Seller
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = 'a8862d50-c61d-4dea-998a-bdf4e26196b1') AS "Suporte", -- Suporte
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = 'ea0124b1-1336-42f6-9f5d-792b8a2a13bc') AS "Tech Lead", -- Tech Lead
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '8e998bb2-5e33-448b-8d7a-e6f8c282dc64') AS "UI Designer", -- UI Designer
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = 'b54c1b48-d443-4c3e-9584-18319d5253f5') AS "UX Designer", -- UX Designer
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = 'bb8135ac-fc10-46a6-9bb7-f8ae971e5691') AS "Vendedor", -- Vendedor
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '2d1c275c-c4fe-4972-bd00-7e6a025523e2') AS "Videomaker", -- Videomaker
  EXISTS (SELECT 1 FROM candidate.candidate_professional_history cph WHERE cph.candidate_id = cu.id AND cph.job_position_id = '5d19cf46-1db0-4283-9035-4f7fbac981bd') AS "Web Designer", -- Web Designer
  
  cu.full_name AS "Nome do Candidato",
  cu.cpf AS "CPF",
  -- Última vaga que o candidato se candidatou
  (
    SELECT jp4.name
    FROM candidate.application app
    JOIN common.job_opening jo ON jo.id = app.job_opening_id
    JOIN common.job_position jp4 ON jp4.id = jo.job_position_id
    WHERE app.candidate_id = cu.id AND app.deleted_at IS NULL
    ORDER BY app.created_at DESC
    LIMIT 1
  ) AS "Última Candidatura do Candidato",
  
  -- Data da última candidatura
  (
    SELECT TO_CHAR(app.created_at, 'YYYY-MM-DD')
    FROM candidate.application app
    WHERE app.candidate_id = cu.id AND app.deleted_at IS NULL
    ORDER BY app.created_at DESC
    LIMIT 1
  ) AS "Data da Última Candidatura"
  
-- 	STRING_AGG(DISTINCT ce.name, ', ') AS "Cursos",
--   STRING_AGG(DISTINCT cce.name, ', ') AS "Cursos Customizados"

FROM candidate."user" cu
INNER JOIN candidate.user_details cud ON cud.user_id = cu.id
LEFT JOIN candidate.candidate_address ca ON ca.user_id = cu.id
LEFT JOIN candidate.candidate_preference_job_opening cpjo ON cpjo.candidate_id = cu.id
LEFT JOIN common.job_position jp ON jp.id = cpjo.job_position_id
LEFT JOIN candidate.candidate_contract_model ccm ON ccm.candidate_id = cu.id
LEFT JOIN common.contract_model cm ON cm.id = ccm.contract_model_id
LEFT JOIN candidate.candidate_job_model cjm ON cjm.candidate_id = cu.id
LEFT JOIN common.job_model jm ON jm.id = cjm.job_model_id
LEFT JOIN candidate.candidate_availability ca2 ON ca2.candidate_id = cu.id
LEFT JOIN common.job_availability ja ON ja.id = ca2.availability_id
LEFT JOIN candidate.candidate_course_education cce1 ON cce1.candidate_id = cu.id
LEFT JOIN common.course_education ce ON ce.id = cce1.course_education_id
LEFT JOIN candidate.candidate_custom_course cce ON cce.candidate_id = cu.id

WHERE cu.deleted_at IS NULL
GROUP BY cu.created_at, cu.id, cu.full_name, cu.cpf, ca.city, ca.state, cud.gender, cud.civil_state, cud.birth_date, cud.max_salary
ORDER BY cu.created_at ASC;