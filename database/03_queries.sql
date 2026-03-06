/* ============================================================
   SELECTs CABULOSOS
   ============================================================ */

/* ============================================================
   SELECT - Total gasto por mês dos cartões de cada user
   ============================================================ */

SELECT
    u.nm_usuario,
    c.nm_cartao,
    YEAR(s.dt_saldo) AS ano,
    DATENAME(MONTH, s.dt_saldo) AS mes_nome,
    SUM(m.vl_movimentacao) AS total_gasto
FROM T_NS_MOVIMENTACAO m
JOIN T_NS_SALDO s
    ON s.id_saldo = m.id_saldo
JOIN T_NS_CARTAO c
    ON c.id_cartao = s.id_cartao
JOIN T_NS_USUARIO u
    ON u.id_usuario = c.id_usuario
WHERE m.tp_movimentacao = 'D'
GROUP BY
    u.nm_usuario,
    c.nm_cartao,
    YEAR(s.dt_saldo),
    DATENAME(MONTH, s.dt_saldo),
    MONTH(s.dt_saldo)
ORDER BY
    u.nm_usuario,
    YEAR(s.dt_saldo),
    MONTH(s.dt_saldo);

/* ============================================================
   SELECT - Todas movimentações feitas nos meses, de cada cartão de um user escolhido, ou de todos
   ============================================================ */

SELECT 
    u.nm_usuario,
    c.nm_cartao,

    YEAR(s.dt_saldo) AS ano,
    DATENAME(MONTH, s.dt_saldo) AS mes_nome,

    DAY(m.dt_movimentacao) AS dia_movimentacao,

    m.vl_movimentacao,
    m.ds_movimentacao,

    -- Tradução de D/R
    CASE 
        WHEN m.tp_movimentacao = 'D' THEN 'Despesa'
        WHEN m.tp_movimentacao = 'R' THEN 'Receita'
    END AS tipo_movimentacao

FROM T_NS_MOVIMENTACAO m
JOIN T_NS_SALDO s 
    ON s.id_saldo = m.id_saldo
JOIN T_NS_CARTAO c 
    ON c.id_cartao = s.id_cartao
JOIN T_NS_USUARIO u 
    ON u.id_usuario = c.id_usuario

WHERE u.id_usuario = 1 -- User escolhido, caso queira todos, só tirar a cláusula

ORDER BY 
    ano,
    MONTH(s.dt_saldo),
    dia_movimentacao;

/* ============================================================
   SELECT - Total gasto em cada cartão de cada prioridade dos users
   ============================================================ */

SELECT
    u.nm_usuario,
    c.nm_cartao,
    p.nm_prioridade AS prioridade,       
    YEAR(s.dt_saldo) AS ano,
    DATENAME(MONTH, s.dt_saldo) AS mes_nome,
    SUM(m.vl_movimentacao) AS total_gasto
FROM T_NS_MOVIMENTACAO m
JOIN T_NS_SALDO s     ON s.id_saldo = m.id_saldo
JOIN T_NS_CARTAO c    ON c.id_cartao = s.id_cartao
JOIN T_NS_USUARIO u   ON u.id_usuario = c.id_usuario
JOIN T_NS_PRIORIDADE p ON p.id_prioridade = m.id_prioridade
WHERE m.tp_movimentacao = 'D'   -- só despesas
GROUP BY
    u.nm_usuario,
    c.nm_cartao,
    p.nm_prioridade,
    YEAR(s.dt_saldo),
    DATENAME(MONTH, s.dt_saldo),
    MONTH(s.dt_saldo)             
ORDER BY
    u.nm_usuario,
    c.nm_cartao,
    YEAR(s.dt_saldo),
    MONTH(s.dt_saldo),
    p.nm_prioridade;

/* ============================================================
   SELECT - Total gasto em cada prioridade dos users
   ============================================================ */

SELECT
    u.nm_usuario,
    p.nm_prioridade AS prioridade,
    YEAR(s.dt_saldo) AS ano,
    DATENAME(MONTH, s.dt_saldo) AS mes_nome,
    SUM(m.vl_movimentacao) AS total_gasto
FROM T_NS_MOVIMENTACAO m
JOIN T_NS_SALDO s          ON s.id_saldo = m.id_saldo
JOIN T_NS_CARTAO c         ON c.id_cartao = s.id_cartao
JOIN T_NS_USUARIO u        ON u.id_usuario = c.id_usuario
JOIN T_NS_PRIORIDADE p     ON p.id_prioridade = m.id_prioridade
WHERE m.tp_movimentacao = 'D'
GROUP BY
    u.nm_usuario,
    p.nm_prioridade,
    YEAR(s.dt_saldo),
    DATENAME(MONTH, s.dt_saldo),
    MONTH(s.dt_saldo)
ORDER BY
    u.nm_usuario,
    ano,
    MONTH(s.dt_saldo),   
    p.nm_prioridade;

/* ============================================================
   SELECT - Total de receitas e despesas de cada cartão em cada mês dos users
   ============================================================ */

SELECT
    u.nm_usuario,
    c.nm_cartao,

    YEAR(s.dt_saldo) AS ano,
    DATENAME(MONTH, s.dt_saldo) AS mes_nome,

    -- Total de despesas (D)
    SUM(CASE WHEN m.tp_movimentacao = 'D' THEN m.vl_movimentacao ELSE 0 END) AS total_despesas,

    -- Total de receitas (R)
    SUM(CASE WHEN m.tp_movimentacao = 'R' THEN m.vl_movimentacao ELSE 0 END) AS total_receitas

FROM T_NS_MOVIMENTACAO m
JOIN T_NS_SALDO s          ON s.id_saldo = m.id_saldo
JOIN T_NS_CARTAO c         ON c.id_cartao = s.id_cartao
JOIN T_NS_USUARIO u        ON u.id_usuario = c.id_usuario

GROUP BY
    u.nm_usuario,
    c.nm_cartao,
    YEAR(s.dt_saldo),
    DATENAME(MONTH, s.dt_saldo),
    MONTH(s.dt_saldo)

ORDER BY
    u.nm_usuario,
    c.nm_cartao,
    ano,
    MONTH(s.dt_saldo); 

/* ============================================================
   SELECT - Total existente na carteira do mês mais recente, dos cartões que o user quis mostrar na carteira
   ============================================================ */

WITH UltimoMes AS (
    SELECT 
        MAX(s.dt_saldo) AS dt_mais_recente
    FROM T_NS_SALDO s
) -- Mês mais recente

SELECT
    u.nm_usuario,
    c.nm_cartao,
    YEAR(s.dt_saldo) AS ano,
    DATENAME(MONTH, s.dt_saldo) AS mes_nome,

    -- total do cartão = receitas - despesas
    SUM(CASE WHEN m.tp_movimentacao = 'R' THEN m.vl_movimentacao ELSE 0 END)
    -
    SUM(CASE WHEN m.tp_movimentacao = 'D' THEN m.vl_movimentacao ELSE 0 END)
    AS total_carteira

FROM UltimoMes um
JOIN T_NS_SALDO s
    ON s.dt_saldo = um.dt_mais_recente
JOIN T_NS_CARTAO c
    ON c.id_cartao = s.id_cartao
JOIN T_NS_USUARIO u
    ON u.id_usuario = c.id_usuario
JOIN T_NS_MOVIMENTACAO m
    ON m.id_saldo = s.id_saldo

WHERE c.tp_soma_carteira = 1      -- só cartões que aparecem na carteira

GROUP BY
    u.nm_usuario,
    c.nm_cartao,
    YEAR(s.dt_saldo),
    DATENAME(MONTH, s.dt_saldo)
ORDER BY
    u.nm_usuario,
    c.nm_cartao;

/* ============================================================
   SELECT - Total gasto em cada prioridade (Gastam mais com média e baixa, do que alta)
   ============================================================ */

SELECT
    p.nm_prioridade,
    SUM(m.vl_movimentacao) AS total_gasto
FROM T_NS_MOVIMENTACAO m
JOIN T_NS_PRIORIDADE p
    ON p.id_prioridade = m.id_prioridade
WHERE m.tp_movimentacao = 'D'   -- só despesas
GROUP BY
    p.nm_prioridade
ORDER BY
    total_gasto DESC;

/* ============================================================
   SELECT - Total gasto em cada prioridade por gênero (Masculino gasta muito mais)
   ============================================================ */

SELECT
    u.tp_genero,
    p.nm_prioridade,
    SUM(m.vl_movimentacao) AS total_gasto
FROM T_NS_MOVIMENTACAO m
JOIN T_NS_SALDO s
    ON s.id_saldo = m.id_saldo
JOIN T_NS_CARTAO c
    ON c.id_cartao = s.id_cartao
JOIN T_NS_USUARIO u
    ON u.id_usuario = c.id_usuario
JOIN T_NS_PRIORIDADE p
    ON p.id_prioridade = m.id_prioridade
WHERE m.tp_movimentacao = 'D'
GROUP BY
    u.tp_genero,
    p.nm_prioridade
ORDER BY
    u.tp_genero,
    total_gasto DESC;


/* ============================================================
   SELECT - Metas criadas por gênero (F criou mais metas)
   ============================================================ */

SELECT
    u.tp_genero,
    COUNT(*) AS metas_concluidas
FROM T_NS_META m
JOIN T_NS_USUARIO u
    ON u.id_usuario = m.id_usuario
WHERE m.tp_concluido = 0 -- 0 significa as que foram criadas mas não foram concluídas (ainda)
GROUP BY
    u.tp_genero
ORDER BY
    metas_concluidas DESC;

/* ============================================================
   SELECT - Metas concluídas por gênero (Ninguém concluiu nada)
   ============================================================ */

SELECT
    u.tp_genero,
    COUNT(*) AS metas_concluidas
FROM T_NS_META m
JOIN T_NS_USUARIO u
    ON u.id_usuario = m.id_usuario
WHERE m.tp_concluido = 1 
GROUP BY
    u.tp_genero
ORDER BY
    metas_concluidas DESC;

/* ============================================================
   SELECT - Metas dos usuários, contando com total de objetivo de cada, percentual de conclusão, e se passou do prazo ou está em andamento
   ============================================================ */

SELECT
    u.id_usuario,
    u.nm_usuario,

    -- Informações da meta
    m.id_meta,
    m.vl_meta,
    m.dt_inicio,
    m.dt_fim,
    CASE -- Garantindo que a meta já passou do prazo, ou está em andamento
        WHEN m.tp_concluido = 1 THEN 'Concluída'
        WHEN m.tp_concluido = 0 AND m.dt_fim < GETDATE() THEN 'Encerrada / Não concluída'
        ELSE 'Em andamento'
    END AS status_meta,

    -- Contagem de objetivos da meta
    obj_tot.total_objetivos,
    obj_conc.objetivos_concluidos,

    -- Porcentagem das metas concluídas
    CASE 
        WHEN obj_tot.total_objetivos = 0 THEN 0
        ELSE ROUND((obj_conc.objetivos_concluidos * 100.0) / obj_tot.total_objetivos, 1)
    END AS pct_conclusao,

    -- Informações do objetivo
    o.ds_objetivo,
    CASE 
        WHEN o.tp_concluido = 1 THEN 'Concluído'
        WHEN o.tp_concluido = 0 AND m.dt_fim < GETDATE() THEN 'Encerrado / Não concluído'
        ELSE 'Pendente'
    END AS status_objetivo

FROM T_NS_META m
JOIN T_NS_USUARIO u 
    ON u.id_usuario = m.id_usuario

LEFT JOIN T_NS_OBJETIVO o 
    ON o.id_meta = m.id_meta

-- Totais de objetivos por meta
LEFT JOIN (
    SELECT id_meta, COUNT(*) AS total_objetivos
    FROM T_NS_OBJETIVO
    GROUP BY id_meta
) obj_tot 
    ON obj_tot.id_meta = m.id_meta

-- Objetivos concluídos por meta
LEFT JOIN (
    SELECT id_meta, COUNT(*) AS objetivos_concluidos
    FROM T_NS_OBJETIVO
    WHERE tp_concluido = 1
    GROUP BY id_meta
) obj_conc
    ON obj_conc.id_meta = m.id_meta

ORDER BY
    u.id_usuario,
    m.id_meta,
    o.ds_objetivo;
