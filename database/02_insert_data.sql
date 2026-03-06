/* ============================================================
   INÍCIO DA TRANSAÇÃO
   ============================================================ */
BEGIN TRANSACTION;

/* ============================================================
   INSERT – PRIORIDADES
   (somente na primeira execução do primeiro usuário)
   ============================================================ */

INSERT INTO T_NS_PRIORIDADE (nm_prioridade) VALUES
('Baixa'),
('Média'),
('Alta'),
('Obrigatória');


/* ============================================================
   INSERT – FORMAS DE PAGAMENTO
   (somente na primeira execução do primeiro usuário)
   ============================================================ */

INSERT INTO T_NS_PAGAMENTO (tp_pagamento) VALUES
('Pix'),
('Boleto'),
('Débito Automático'),
('Crédito à Vista'),
('Crédito Parcelado');



/* ============================================================
   USUÁRIO 1 — Lucas Almeida
   2 cartões → Crédito Nubank / Débito Itaú
   Movimentações: 7–12 por saldo
   Meta: 1 | Objetivos: 2
   ============================================================ */

INSERT INTO T_NS_USUARIO
(nm_usuario, ds_email, ds_senha, dt_nascimento, tp_genero, tp_premium, vl_renda)
VALUES
('Lucas Almeida', 'lucas.almeida@exemplo.com', 'Lk@2025!secure', '1994-03-12', 'M', 1, 7200.00);

DECLARE @idUser1 INT = SCOPE_IDENTITY(); -- retorna o ID do usuário recém-criado



/* ============================================================
   CARTÃO 1 – Crédito Nubank
   ============================================================ */

INSERT INTO T_NS_CARTAO
(id_usuario, nm_cartao, dt_validade, vl_hex_cor, nm_instituicao, tp_soma_carteira, tp_cartao)
VALUES
(@idUser1, 'Nubank Crédito', '2028-07-01', '6A0DAD', 'Nubank', 1, 'C');


DECLARE @idCartao1 INT = SCOPE_IDENTITY(); -- retorna o ID do cartão recém-criado

/* Crédito */
INSERT INTO T_NS_CREDITO (id_cartao, dt_fechamento, dt_vencimento, nr_limite_cartao)
VALUES (@idCartao1, '2025-05-05', '2025-05-15', 4500.00);



/* ============================================================
   CARTÃO 2 – Débito Itaú
   ============================================================ */

INSERT INTO T_NS_CARTAO
(id_usuario, nm_cartao, dt_validade, vl_hex_cor, nm_instituicao, tp_soma_carteira, tp_cartao)
VALUES
(@idUser1, 'Itaú Débito', '2029-03-01', '0044FF', 'Itaú', 1, 'D');

DECLARE @idCartao2 INT = SCOPE_IDENTITY();

/* Débito */
INSERT INTO T_NS_DEBITO (id_cartao, nr_cvv, nr_limite_gastos)
VALUES (@idCartao2, 812, 2500.00);




/* ============================================================
   SALDOS MENSAIS — CARTÃO 1 (Crédito)
   Jan–Out 2025
   ============================================================ */

DECLARE @Mes INT = 1;

WHILE @Mes <= 10 -- WHILE para gerar 10 saldos
BEGIN
    INSERT INTO T_NS_SALDO (dt_saldo, id_cartao)
    VALUES (DATEFROMPARTS(2025, @Mes, 1), @idCartao1);

    SET @Mes = @Mes + 1; -- Mantém a continuidade do while
END;


/* ============================================================
   SALDOS MENSAIS — CARTÃO 2 (Débito)
   Jan–Out 2025
   ============================================================ */

SET @Mes = 1;

WHILE @Mes <= 10 -- WHILE para gerar 10 saldos
BEGIN
    INSERT INTO T_NS_SALDO (dt_saldo, id_cartao)
    VALUES (DATEFROMPARTS(2025, @Mes, 1), @idCartao2);

    SET @Mes = @Mes + 1; -- Mantém a continuidade do while
END;



/* ============================================================
   MOVIMENTAÇÕES – CARTÃO 1 e CARTÃO 2
   ============================================================ */


--------------------------------------------------------------
-- MOVIMENTAÇÕES FIXAS DE EXEMPLO (serão repetidas por mês)
--------------------------------------------------------------

DECLARE @Mov TABLE ( --lista de movimentações padrão
    ds NVARCHAR(50),
    valor NUMERIC(9,2),
    tp CHAR(1),
    pg INT,
    pri INT,
    fixa BIT,
    pago BIT
);

INSERT INTO @Mov VALUES -- Dados padrões que podem ser repetidos, evita escrever 200 INSERTs manualmente
('Mercado',           120.50, 'D', 1, 2, 0, 1),
('Restaurante',        89.90, 'D', 1, 1, 0, 1),
('Uber',               32.70, 'D', 1, 1, 0, 1),
('Farmácia',           54.20, 'D', 1, 3, 0, 1),
('Assinatura Netflix', 39.90, 'D', 3, 2, 1, 1),
('Salário',          3800.00, 'R', 1, 1, 1, 1),
('Transferência Pix', 200.00, 'R', 1, 1, 0, 1);



/* ============================================================
   INSERÇÃO DAS MOVIMENTAÇÕES PARA CADA SALDO
   ============================================================ */

DECLARE @idSaldo INT;

DECLARE curSaldo CURSOR FOR -- Pega todos os saldos criados anteriormente e abre o cursor
SELECT id_saldo FROM T_NS_SALDO WHERE id_cartao IN (@idCartao1, @idCartao2);

OPEN curSaldo;
FETCH NEXT FROM curSaldo INTO @idSaldo;

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO T_NS_MOVIMENTACAO
    (id_saldo, id_prioridade, id_pagamento, dt_movimentacao,
     vl_movimentacao, tp_movimentacao, ds_movimentacao,
     tp_prioridade, tp_fixa, tp_foi_pago)
    SELECT
        @idSaldo,
        m.pri,
        m.pg,
        DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 27, DATEFROMPARTS(2025, 1, 1)),
        m.valor,
        m.tp,
        m.ds,
        CASE m.pri
            WHEN 1 THEN 'B'
            WHEN 2 THEN 'M'
            WHEN 3 THEN 'A'
            WHEN 4 THEN 'O'
        END,
        m.fixa,
        m.pago
    FROM @Mov m;

    FETCH NEXT FROM curSaldo INTO @idSaldo;
END;

CLOSE curSaldo;
DEALLOCATE curSaldo;



/* ============================================================
   META E OBJETIVOS DO USUÁRIO 1
   ============================================================ */

INSERT INTO T_NS_META
(id_usuario, vl_meta, dt_inicio, dt_fim, tp_concluido)
VALUES
(@idUser1, 5000.00, '2025-01-10', '2025-12-10', 0);

DECLARE @idMeta1 INT = SCOPE_IDENTITY();

INSERT INTO T_NS_OBJETIVO (id_meta, ds_objetivo, tp_concluido) VALUES
(@idMeta1, 'Montar reserva de emergência', 0),
(@idMeta1, 'Quitar pequena dívida no cartão', 0);



/* ============================================================
   FIM DO BLOCO — USUÁRIO 1
   (SEM COMMIT / SEM ROLLBACK)
   ============================================================ */

/* ============================================================
   USUÁRIO 2 — Carolina Mendes
   1 cartão → Crédito Inter
   Movimentações: 7–12 por saldo
   Metas: 2 | Objetivos: 2–3
   ============================================================ */

INSERT INTO T_NS_USUARIO
(nm_usuario, ds_email, ds_senha, dt_nascimento, tp_genero, tp_premium, vl_renda)
VALUES
('Carolina Mendes', 'carolina.mendes@exemplo.com', 'Cm@2025#safe', '1989-11-28', 'F', 0, 5400.00);

DECLARE @idUser2 INT = SCOPE_IDENTITY();



/* ============================================================
   CARTÃO 1 – Crédito Banco Inter
   ============================================================ */

INSERT INTO T_NS_CARTAO
(id_usuario, nm_cartao, dt_validade, vl_hex_cor, nm_instituicao, tp_soma_carteira, tp_cartao)
VALUES
(@idUser2, 'Inter Crédito', '2027-09-01', 'FF7000', 'Banco Inter', 1, 'C');

DECLARE @idCartao2_1 INT = SCOPE_IDENTITY();

/* Registro de crédito */
INSERT INTO T_NS_CREDITO (id_cartao, dt_fechamento, dt_vencimento, nr_limite_cartao)
VALUES (@idCartao2_1, '2025-04-07', '2025-04-17', 6000.00);



/* ============================================================
   SALDOS MENSAIS — CARTÃO DE CRÉDITO
   Jan–Out 2025
   ============================================================ */

DECLARE @Mes2 INT = 1;

WHILE @Mes2 <= 10
BEGIN
    INSERT INTO T_NS_SALDO (dt_saldo, id_cartao)
    VALUES (DATEFROMPARTS(2025, @Mes2, 1), @idCartao2_1);

    SET @Mes2 = @Mes2 + 1;
END;




/* ============================================================
   MOVIMENTAÇÕES — USUÁRIO 2
   (mesmo conjunto base para cada mês)
   ============================================================ */

DECLARE @Mov2 TABLE (
    ds NVARCHAR(50),
    valor NUMERIC(9,2),
    tp CHAR(1),
    pg INT,
    pri INT,
    fixa BIT,
    pago BIT
);

INSERT INTO @Mov2 VALUES
('Mercado',           134.20, 'D', 1, 2, 0, 1),
('Restaurante',       102.40, 'D', 1, 1, 0, 1),
('Uber',               28.30, 'D', 1, 1, 0, 1),
('Farmácia',           49.10, 'D', 1, 3, 0, 1),
('Spotify',            21.90, 'D', 3, 2, 1, 1),
('Salário',          5100.00, 'R', 1, 1, 1, 1),
('Transferência Pix', 300.00, 'R', 1, 1, 0, 1);



/* ============================================================
   INSERÇÃO DAS MOVIMENTAÇÕES PARA CADA SALDO DO CARTÃO
   ============================================================ */

DECLARE @idSaldo2 INT;

DECLARE curSaldo2 CURSOR FOR
SELECT id_saldo FROM T_NS_SALDO WHERE id_cartao = @idCartao2_1;

OPEN curSaldo2;
FETCH NEXT FROM curSaldo2 INTO @idSaldo2;

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO T_NS_MOVIMENTACAO
    (id_saldo, id_prioridade, id_pagamento, dt_movimentacao,
     vl_movimentacao, tp_movimentacao, ds_movimentacao,
     tp_prioridade, tp_fixa, tp_foi_pago)
    SELECT
        @idSaldo2,
        m.pri,
        m.pg,
        DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 27, DATEFROMPARTS(2025, 1, 1)),
        m.valor,
        m.tp,
        m.ds,
        CASE m.pri
            WHEN 1 THEN 'B'
            WHEN 2 THEN 'M'
            WHEN 3 THEN 'A'
            WHEN 4 THEN 'O'
        END,
        m.fixa,
        m.pago
    FROM @Mov2 m;

    FETCH NEXT FROM curSaldo2 INTO @idSaldo2;
END;

CLOSE curSaldo2;
DEALLOCATE curSaldo2;




/* ============================================================
   METAS E OBJETIVOS DO USUÁRIO 2
   ============================================================ */

-- META 1
INSERT INTO T_NS_META
(id_usuario, vl_meta, dt_inicio, dt_fim, tp_concluido)
VALUES
(@idUser2, 8000.00, '2025-02-05', '2025-12-25', 0);

DECLARE @idMeta2_1 INT = SCOPE_IDENTITY();

INSERT INTO T_NS_OBJETIVO (id_meta, ds_objetivo, tp_concluido) VALUES
(@idMeta2_1, 'Guardar para viagem internacional', 0),
(@idMeta2_1, 'Construir fundo de emergência', 0);


-- META 2
INSERT INTO T_NS_META
(id_usuario, vl_meta, dt_inicio, dt_fim, tp_concluido)
VALUES
(@idUser2, 1500.00, '2025-03-10', '2025-06-10', 0);

DECLARE @idMeta2_2 INT = SCOPE_IDENTITY();

INSERT INTO T_NS_OBJETIVO (id_meta, ds_objetivo, tp_concluido) VALUES
(@idMeta2_2, 'Comprar novo smartphone', 0),
(@idMeta2_2, 'Aumentar limite do cartão', 0),
(@idMeta2_2, 'Evitar gastos desnecessários', 0);



/* ============================================================
   FIM DO BLOCO — USUÁRIO 2
   ============================================================ */
   
   /* ============================================================
   USUÁRIO 3 — Bruno Carvalho
   2 cartões → Crédito Santander / Débito Bradesco
   Movimentações: 7–12 por saldo
   Meta: 1 | Objetivos: 3
   ============================================================ */

INSERT INTO T_NS_USUARIO
(nm_usuario, ds_email, ds_senha, dt_nascimento, tp_genero, tp_premium, vl_renda)
VALUES
('Bruno Carvalho', 'bruno.carvalho@exemplo.com', 'BrC@2025!pass', '1990-07-16', 'M', 1, 6800.00);

DECLARE @idUser3 INT = SCOPE_IDENTITY();



/* ============================================================
   CARTÃO 1 – Crédito Santander
   ============================================================ */

INSERT INTO T_NS_CARTAO
(id_usuario, nm_cartao, dt_validade, vl_hex_cor, nm_instituicao, tp_soma_carteira, tp_cartao)
VALUES
(@idUser3, 'Santander Crédito', '2028-01-01', 'FF0000', 'Santander', 1, 'C');

DECLARE @idCartao3_1 INT = SCOPE_IDENTITY();

INSERT INTO T_NS_CREDITO (id_cartao, dt_fechamento, dt_vencimento, nr_limite_cartao)
VALUES (@idCartao3_1, '2025-05-10', '2025-05-20', 5500.00);



/* ============================================================
   CARTÃO 2 – Débito Bradesco
   ============================================================ */

INSERT INTO T_NS_CARTAO
(id_usuario, nm_cartao, dt_validade, vl_hex_cor, nm_instituicao, tp_soma_carteira, tp_cartao)
VALUES
(@idUser3, 'Bradesco Débito', '2029-06-01', '0000FF', 'Bradesco', 1, 'D');

DECLARE @idCartao3_2 INT = SCOPE_IDENTITY();

INSERT INTO T_NS_DEBITO (id_cartao, nr_cvv, nr_limite_gastos)
VALUES (@idCartao3_2, 427, 3000.00);



/* ============================================================
   SALDOS MENSAIS — CARTÃO 1 e CARTÃO 2
   ============================================================ */

DECLARE @Mes3 INT = 1;

WHILE @Mes3 <= 10
BEGIN
    INSERT INTO T_NS_SALDO (dt_saldo, id_cartao)
    VALUES (DATEFROMPARTS(2025, @Mes3, 1), @idCartao3_1);

    INSERT INTO T_NS_SALDO (dt_saldo, id_cartao)
    VALUES (DATEFROMPARTS(2025, @Mes3, 1), @idCartao3_2);

    SET @Mes3 = @Mes3 + 1;
END;




/* ============================================================
   MOVIMENTAÇÕES — USUÁRIO 3
   ============================================================ */

DECLARE @Mov3 TABLE (
    ds NVARCHAR(50),
    valor NUMERIC(9,2),
    tp CHAR(1),
    pg INT,
    pri INT,
    fixa BIT,
    pago BIT
);

INSERT INTO @Mov3 VALUES
('Mercado',           145.60, 'D', 1, 2, 0, 1),
('Restaurante',        98.50, 'D', 1, 1, 0, 1),
('Uber',               35.20, 'D', 1, 1, 0, 1),
('Farmácia',           62.10, 'D', 1, 3, 0, 1),
('Assinatura HBO',     34.90, 'D', 3, 2, 1, 1),
('Salário',          6800.00, 'R', 1, 1, 1, 1),
('Transferência Pix', 450.00, 'R', 1, 1, 0, 1);



/* ============================================================
   INSERÇÃO DAS MOVIMENTAÇÕES PARA CADA SALDO
   ============================================================ */

DECLARE @idSaldo3 INT;

DECLARE curSaldo3 CURSOR FOR
SELECT id_saldo FROM T_NS_SALDO WHERE id_cartao IN (@idCartao3_1, @idCartao3_2);

OPEN curSaldo3;
FETCH NEXT FROM curSaldo3 INTO @idSaldo3;

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO T_NS_MOVIMENTACAO
    (id_saldo, id_prioridade, id_pagamento, dt_movimentacao,
     vl_movimentacao, tp_movimentacao, ds_movimentacao,
     tp_prioridade, tp_fixa, tp_foi_pago)
    SELECT
        @idSaldo3,
        m.pri,
        m.pg,
        DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 27, DATEFROMPARTS(2025, 1, 1)),
        m.valor,
        m.tp,
        m.ds,
        CASE m.pri
            WHEN 1 THEN 'B'
            WHEN 2 THEN 'M'
            WHEN 3 THEN 'A'
            WHEN 4 THEN 'O'
        END,
        m.fixa,
        m.pago
    FROM @Mov3 m;

    FETCH NEXT FROM curSaldo3 INTO @idSaldo3;
END;

CLOSE curSaldo3;
DEALLOCATE curSaldo3;



/* ============================================================
   META E OBJETIVOS DO USUÁRIO 3
   ============================================================ */

INSERT INTO T_NS_META
(id_usuario, vl_meta, dt_inicio, dt_fim, tp_concluido)
VALUES
(@idUser3, 7000.00, '2025-01-15', '2025-12-15', 0);

DECLARE @idMeta3_1 INT = SCOPE_IDENTITY();

INSERT INTO T_NS_OBJETIVO (id_meta, ds_objetivo, tp_concluido) VALUES
(@idMeta3_1, 'Comprar notebook novo', 0),
(@idMeta3_1, 'Pagar parcelas do carro', 0),
(@idMeta3_1, 'Investir em ações', 0);



/* ============================================================
   FIM DO BLOCO — USUÁRIO 3
   ============================================================ */
   
   /* ============================================================
   USUÁRIO 4 — Daniela Ribeiro
   1 cartão → Débito Nubank
   Movimentações: 7–12 por saldo
   Metas: 2 | Objetivos: 2 cada
   ============================================================ */

INSERT INTO T_NS_USUARIO
(nm_usuario, ds_email, ds_senha, dt_nascimento, tp_genero, tp_premium, vl_renda)
VALUES
('Daniela Ribeiro', 'daniela.ribeiro@exemplo.com', 'DRi@2025!pwd', '1992-03-21', 'F', 0, 4700.00);

DECLARE @idUser4 INT = SCOPE_IDENTITY();



/* ============================================================
   CARTÃO 1 – Débito Nubank
   ============================================================ */

INSERT INTO T_NS_CARTAO
(id_usuario, nm_cartao, dt_validade, vl_hex_cor, nm_instituicao, tp_soma_carteira, tp_cartao)
VALUES
(@idUser4, 'Nubank Débito', '2026-12-01', '8A2BE2', 'Nubank', 1, 'D');

DECLARE @idCartao4_1 INT = SCOPE_IDENTITY();

INSERT INTO T_NS_DEBITO (id_cartao, nr_cvv, nr_limite_gastos)
VALUES (@idCartao4_1, 321, 2500.00);



/* ============================================================
   SALDOS MENSAIS — CARTÃO
   ============================================================ */

DECLARE @Mes4 INT = 1;

WHILE @Mes4 <= 10
BEGIN
    INSERT INTO T_NS_SALDO (dt_saldo, id_cartao)
    VALUES (DATEFROMPARTS(2025, @Mes4, 1), @idCartao4_1);

    SET @Mes4 = @Mes4 + 1;
END;




/* ============================================================
   MOVIMENTAÇÕES — USUÁRIO 4
   ============================================================ */

DECLARE @Mov4 TABLE (
    ds NVARCHAR(50),
    valor NUMERIC(9,2),
    tp CHAR(1),
    pg INT,
    pri INT,
    fixa BIT,
    pago BIT
);

INSERT INTO @Mov4 VALUES
('Mercado',           110.75, 'D', 1, 2, 0, 1),
('Restaurante',        75.50, 'D', 1, 1, 0, 1),
('Uber',               22.90, 'D', 1, 1, 0, 1),
('Farmácia',           48.30, 'D', 1, 3, 0, 1),
('Assinatura Disney',  29.90, 'D', 3, 2, 1, 1),
('Salário',          4700.00, 'R', 1, 1, 1, 1),
('Transferência Pix', 180.00, 'R', 1, 1, 0, 1);



/* ============================================================
   INSERÇÃO DAS MOVIMENTAÇÕES PARA CADA SALDO
   ============================================================ */

DECLARE @idSaldo4 INT;

DECLARE curSaldo4 CURSOR FOR
SELECT id_saldo FROM T_NS_SALDO WHERE id_cartao = @idCartao4_1;

OPEN curSaldo4;
FETCH NEXT FROM curSaldo4 INTO @idSaldo4;

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO T_NS_MOVIMENTACAO
    (id_saldo, id_prioridade, id_pagamento, dt_movimentacao,
     vl_movimentacao, tp_movimentacao, ds_movimentacao,
     tp_prioridade, tp_fixa, tp_foi_pago)
    SELECT
        @idSaldo4,
        m.pri,
        m.pg,
        DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 27, DATEFROMPARTS(2025, 1, 1)),
        m.valor,
        m.tp,
        m.ds,
        CASE m.pri
            WHEN 1 THEN 'B'
            WHEN 2 THEN 'M'
            WHEN 3 THEN 'A'
            WHEN 4 THEN 'O'
        END,
        m.fixa,
        m.pago
    FROM @Mov4 m;

    FETCH NEXT FROM curSaldo4 INTO @idSaldo4;
END;

CLOSE curSaldo4;
DEALLOCATE curSaldo4;



/* ============================================================
   METAS E OBJETIVOS DO USUÁRIO 4
   ============================================================ */

-- META 1
INSERT INTO T_NS_META
(id_usuario, vl_meta, dt_inicio, dt_fim, tp_concluido)
VALUES
(@idUser4, 4000.00, '2025-01-10', '2025-08-15', 0);

DECLARE @idMeta4_1 INT = SCOPE_IDENTITY();

INSERT INTO T_NS_OBJETIVO (id_meta, ds_objetivo, tp_concluido) VALUES
(@idMeta4_1, 'Fazer curso de inglês', 0),
(@idMeta4_1, 'Economizar para férias', 0);

-- META 2
INSERT INTO T_NS_META
(id_usuario, vl_meta, dt_inicio, dt_fim, tp_concluido)
VALUES
(@idUser4, 1200.00, '2025-03-01', '2025-06-01', 0);

DECLARE @idMeta4_2 INT = SCOPE_IDENTITY();

INSERT INTO T_NS_OBJETIVO (id_meta, ds_objetivo, tp_concluido) VALUES
(@idMeta4_2, 'Comprar bicicleta nova', 0),
(@idMeta4_2, 'Reduzir gastos com delivery', 0);



/* ============================================================
   FIM DO BLOCO — USUÁRIO 4
   ============================================================ */

/* ============================================================
   USUÁRIO 5 — Eduardo Santos
   2 cartões → Crédito Itaú / Débito Caixa
   Movimentações: 7–12 por saldo
   Meta: 1 | Objetivos: 3
   ============================================================ */

INSERT INTO T_NS_USUARIO
(nm_usuario, ds_email, ds_senha, dt_nascimento, tp_genero, tp_premium, vl_renda)
VALUES
('Eduardo Santos', 'eduardo.santos@exemplo.com', 'EdS@2025$secure', '1987-12-05', 'M', 1, 7500.00);

DECLARE @idUser5 INT = SCOPE_IDENTITY();



/* ============================================================
   CARTÃO 1 – Crédito Itaú
   ============================================================ */

INSERT INTO T_NS_CARTAO
(id_usuario, nm_cartao, dt_validade, vl_hex_cor, nm_instituicao, tp_soma_carteira, tp_cartao)
VALUES
(@idUser5, 'Itaú Crédito', '2027-11-01', '00FF00', 'Itaú', 1, 'C');

DECLARE @idCartao5_1 INT = SCOPE_IDENTITY();

INSERT INTO T_NS_CREDITO (id_cartao, dt_fechamento, dt_vencimento, nr_limite_cartao)
VALUES (@idCartao5_1, '2025-04-05', '2025-04-15', 7000.00);



/* ============================================================
   CARTÃO 2 – Débito Caixa
   ============================================================ */

INSERT INTO T_NS_CARTAO
(id_usuario, nm_cartao, dt_validade, vl_hex_cor, nm_instituicao, tp_soma_carteira, tp_cartao)
VALUES
(@idUser5, 'Caixa Débito', '2028-07-01', 'FFD700', 'Caixa Econômica', 1, 'D');

DECLARE @idCartao5_2 INT = SCOPE_IDENTITY();

INSERT INTO T_NS_DEBITO (id_cartao, nr_cvv, nr_limite_gastos)
VALUES (@idCartao5_2, 215, 3500.00);



/* ============================================================
   SALDOS MENSAIS — CARTÕES
   ============================================================ */

DECLARE @Mes5 INT = 1;

WHILE @Mes5 <= 10
BEGIN
    INSERT INTO T_NS_SALDO (dt_saldo, id_cartao)
    VALUES (DATEFROMPARTS(2025, @Mes5, 1), @idCartao5_1);

    INSERT INTO T_NS_SALDO (dt_saldo, id_cartao)
    VALUES (DATEFROMPARTS(2025, @Mes5, 1), @idCartao5_2);

    SET @Mes5 = @Mes5 + 1;
END;




/* ============================================================
   MOVIMENTAÇÕES — USUÁRIO 5
   ============================================================ */

DECLARE @Mov5 TABLE (
    ds NVARCHAR(50),
    valor NUMERIC(9,2),
    tp CHAR(1),
    pg INT,
    pri INT,
    fixa BIT,
    pago BIT
);

INSERT INTO @Mov5 VALUES
('Mercado',           160.00, 'D', 1, 2, 0, 1),
('Restaurante',       120.50, 'D', 1, 1, 0, 1),
('Uber',               40.30, 'D', 1, 1, 0, 1),
('Farmácia',           55.20, 'D', 1, 3, 0, 1),
('Assinatura Amazon',  25.90, 'D', 3, 2, 1, 1),
('Salário',          7500.00, 'R', 1, 1, 1, 1),
('Transferência Pix', 500.00, 'R', 1, 1, 0, 1);



/* ============================================================
   INSERÇÃO DAS MOVIMENTAÇÕES PARA CADA SALDO
   ============================================================ */

DECLARE @idSaldo5 INT;

DECLARE curSaldo5 CURSOR FOR
SELECT id_saldo FROM T_NS_SALDO WHERE id_cartao IN (@idCartao5_1, @idCartao5_2);

OPEN curSaldo5;
FETCH NEXT FROM curSaldo5 INTO @idSaldo5;

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO T_NS_MOVIMENTACAO
    (id_saldo, id_prioridade, id_pagamento, dt_movimentacao,
     vl_movimentacao, tp_movimentacao, ds_movimentacao,
     tp_prioridade, tp_fixa, tp_foi_pago)
    SELECT
        @idSaldo5,
        m.pri,
        m.pg,
        DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 27, DATEFROMPARTS(2025, 1, 1)),
        m.valor,
        m.tp,
        m.ds,
        CASE m.pri
            WHEN 1 THEN 'B'
            WHEN 2 THEN 'M'
            WHEN 3 THEN 'A'
            WHEN 4 THEN 'O'
        END,
        m.fixa,
        m.pago
    FROM @Mov5 m;

    FETCH NEXT FROM curSaldo5 INTO @idSaldo5;
END;

CLOSE curSaldo5;
DEALLOCATE curSaldo5;



/* ============================================================
   META E OBJETIVOS DO USUÁRIO 5
   ============================================================ */

INSERT INTO T_NS_META
(id_usuario, vl_meta, dt_inicio, dt_fim, tp_concluido)
VALUES
(@idUser5, 10000.00, '2025-01-20', '2025-12-20', 0);

DECLARE @idMeta5_1 INT = SCOPE_IDENTITY();

INSERT INTO T_NS_OBJETIVO (id_meta, ds_objetivo, tp_concluido) VALUES
(@idMeta5_1, 'Pagar dívida do carro', 0),
(@idMeta5_1, 'Investir em previdência', 0),
(@idMeta5_1, 'Comprar móveis novos', 0);



/* ============================================================
   FIM DO BLOCO — USUÁRIO 5
   ============================================================ */

/* ============================================================
   USUÁRIO 6 — Fernanda Lima
   1 cartão → Crédito Banco do Brasil
   Movimentações: 7–12 por saldo
   Metas: 2 | Objetivos: 2 cada
   ============================================================ */

INSERT INTO T_NS_USUARIO
(nm_usuario, ds_email, ds_senha, dt_nascimento, tp_genero, tp_premium, vl_renda)
VALUES
('Fernanda Lima', 'fernanda.lima@exemplo.com', 'FeLi@2025#123', '1991-09-10', 'F', 1, 6200.00);

DECLARE @idUser6 INT = SCOPE_IDENTITY();



/* ============================================================
   CARTÃO 1 – Crédito Banco do Brasil
   ============================================================ */

INSERT INTO T_NS_CARTAO
(id_usuario, nm_cartao, dt_validade, vl_hex_cor, nm_instituicao, tp_soma_carteira, tp_cartao)
VALUES
(@idUser6, 'BB Crédito', '2027-10-01', '1E90FF', 'Banco do Brasil', 1, 'C');

DECLARE @idCartao6_1 INT = SCOPE_IDENTITY();

INSERT INTO T_NS_CREDITO (id_cartao, dt_fechamento, dt_vencimento, nr_limite_cartao)
VALUES (@idCartao6_1, '2025-03-15', '2025-03-25', 6500.00);



/* ============================================================
   SALDOS MENSAIS — CARTÃO
   ============================================================ */

DECLARE @Mes6 INT = 1;

WHILE @Mes6 <= 10
BEGIN
    INSERT INTO T_NS_SALDO (dt_saldo, id_cartao)
    VALUES (DATEFROMPARTS(2025, @Mes6, 1), @idCartao6_1);

    SET @Mes6 = @Mes6 + 1;
END;




/* ============================================================
   MOVIMENTAÇÕES — USUÁRIO 6
   ============================================================ */

DECLARE @Mov6 TABLE (
    ds NVARCHAR(50),
    valor NUMERIC(9,2),
    tp CHAR(1),
    pg INT,
    pri INT,
    fixa BIT,
    pago BIT
);

INSERT INTO @Mov6 VALUES
('Mercado',           135.80, 'D', 1, 2, 0, 1),
('Restaurante',        88.40, 'D', 1, 1, 0, 1),
('Uber',               28.50, 'D', 1, 1, 0, 1),
('Farmácia',           52.70, 'D', 1, 3, 0, 1),
('Assinatura Spotify', 29.90, 'D', 3, 2, 1, 1),
('Salário',          6200.00, 'R', 1, 1, 1, 1),
('Transferência Pix', 300.00, 'R', 1, 1, 0, 1);



/* ============================================================
   INSERÇÃO DAS MOVIMENTAÇÕES PARA CADA SALDO
   ============================================================ */

DECLARE @idSaldo6 INT;

DECLARE curSaldo6 CURSOR FOR
SELECT id_saldo FROM T_NS_SALDO WHERE id_cartao = @idCartao6_1;

OPEN curSaldo6;
FETCH NEXT FROM curSaldo6 INTO @idSaldo6;

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO T_NS_MOVIMENTACAO
    (id_saldo, id_prioridade, id_pagamento, dt_movimentacao,
     vl_movimentacao, tp_movimentacao, ds_movimentacao,
     tp_prioridade, tp_fixa, tp_foi_pago)
    SELECT
        @idSaldo6,
        m.pri,
        m.pg,
        DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 27, DATEFROMPARTS(2025, 1, 1)),
        m.valor,
        m.tp,
        m.ds,
        CASE m.pri
            WHEN 1 THEN 'B'
            WHEN 2 THEN 'M'
            WHEN 3 THEN 'A'
            WHEN 4 THEN 'O'
        END,
        m.fixa,
        m.pago
    FROM @Mov6 m;

    FETCH NEXT FROM curSaldo6 INTO @idSaldo6;
END;

CLOSE curSaldo6;
DEALLOCATE curSaldo6;



/* ============================================================
   METAS E OBJETIVOS DO USUÁRIO 6
   ============================================================ */

-- META 1
INSERT INTO T_NS_META
(id_usuario, vl_meta, dt_inicio, dt_fim, tp_concluido)
VALUES
(@idUser6, 5000.00, '2025-01-05', '2025-10-30', 0);

DECLARE @idMeta6_1 INT = SCOPE_IDENTITY();

INSERT INTO T_NS_OBJETIVO (id_meta, ds_objetivo, tp_concluido) VALUES
(@idMeta6_1, 'Fazer intercâmbio', 0),
(@idMeta6_1, 'Economizar para carro novo', 0);

-- META 2
INSERT INTO T_NS_META
(id_usuario, vl_meta, dt_inicio, dt_fim, tp_concluido)
VALUES
(@idUser6, 2000.00, '2025-02-01', '2025-06-15', 0);

DECLARE @idMeta6_2 INT = SCOPE_IDENTITY();

INSERT INTO T_NS_OBJETIVO (id_meta, ds_objetivo, tp_concluido) VALUES
(@idMeta6_2, 'Comprar computador', 0),
(@idMeta6_2, 'Pagar curso online', 0);



/* ============================================================
   FIM DO BLOCO — USUÁRIO 6
   ============================================================ */

/* ============================================================
   USUÁRIO 7 — Gabriel Oliveira
   2 cartões → Crédito Santander / Débito Bradesco
   Movimentações: 7–12 por saldo
   Meta: 1 | Objetivos: 3
   ============================================================ */

INSERT INTO T_NS_USUARIO
(nm_usuario, ds_email, ds_senha, dt_nascimento, tp_genero, tp_premium, vl_renda)
VALUES
('Gabriel Oliveira', 'gabriel.oliveira@exemplo.com', 'GaOl@2025!pwd', '1989-11-23', 'M', 0, 5800.00);

DECLARE @idUser7 INT = SCOPE_IDENTITY();



/* ============================================================
   CARTÃO 1 – Crédito Santander
   ============================================================ */

INSERT INTO T_NS_CARTAO
(id_usuario, nm_cartao, dt_validade, vl_hex_cor, nm_instituicao, tp_soma_carteira, tp_cartao)
VALUES
(@idUser7, 'Santander Crédito', '2028-03-01', 'FF4500', 'Santander', 1, 'C');

DECLARE @idCartao7_1 INT = SCOPE_IDENTITY();

INSERT INTO T_NS_CREDITO (id_cartao, dt_fechamento, dt_vencimento, nr_limite_cartao)
VALUES (@idCartao7_1, '2025-05-08', '2025-05-18', 6000.00);



/* ============================================================
   CARTÃO 2 – Débito Bradesco
   ============================================================ */

INSERT INTO T_NS_CARTAO
(id_usuario, nm_cartao, dt_validade, vl_hex_cor, nm_instituicao, tp_soma_carteira, tp_cartao)
VALUES
(@idUser7, 'Bradesco Débito', '2029-01-01', '1E90FF', 'Bradesco', 1, 'D');

DECLARE @idCartao7_2 INT = SCOPE_IDENTITY();

INSERT INTO T_NS_DEBITO (id_cartao, nr_cvv, nr_limite_gastos)
VALUES (@idCartao7_2, 348, 3200.00);



/* ============================================================
   SALDOS MENSAIS — CARTÕES
   ============================================================ */

DECLARE @Mes7 INT = 1;

WHILE @Mes7 <= 10
BEGIN
    INSERT INTO T_NS_SALDO (dt_saldo, id_cartao)
    VALUES (DATEFROMPARTS(2025, @Mes7, 1), @idCartao7_1);

    INSERT INTO T_NS_SALDO (dt_saldo, id_cartao)
    VALUES (DATEFROMPARTS(2025, @Mes7, 1), @idCartao7_2);

    SET @Mes7 = @Mes7 + 1;
END;




/* ============================================================
   MOVIMENTAÇÕES — USUÁRIO 7
   ============================================================ */

DECLARE @Mov7 TABLE (
    ds NVARCHAR(50),
    valor NUMERIC(9,2),
    tp CHAR(1),
    pg INT,
    pri INT,
    fixa BIT,
    pago BIT
);

INSERT INTO @Mov7 VALUES
('Mercado',           150.50, 'D', 1, 2, 0, 1),
('Restaurante',        95.30, 'D', 1, 1, 0, 1),
('Uber',               30.20, 'D', 1, 1, 0, 1),
('Farmácia',           50.70, 'D', 1, 3, 0, 1),
('Assinatura Netflix', 39.90, 'D', 3, 2, 1, 1),
('Salário',          5800.00, 'R', 1, 1, 1, 1),
('Transferência Pix', 400.00, 'R', 1, 1, 0, 1);



/* ============================================================
   INSERÇÃO DAS MOVIMENTAÇÕES PARA CADA SALDO
   ============================================================ */

DECLARE @idSaldo7 INT;

DECLARE curSaldo7 CURSOR FOR
SELECT id_saldo FROM T_NS_SALDO WHERE id_cartao IN (@idCartao7_1, @idCartao7_2);

OPEN curSaldo7;
FETCH NEXT FROM curSaldo7 INTO @idSaldo7;

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO T_NS_MOVIMENTACAO
    (id_saldo, id_prioridade, id_pagamento, dt_movimentacao,
     vl_movimentacao, tp_movimentacao, ds_movimentacao,
     tp_prioridade, tp_fixa, tp_foi_pago)
    SELECT
        @idSaldo7,
        m.pri,
        m.pg,
        DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 27, DATEFROMPARTS(2025, 1, 1)),
        m.valor,
        m.tp,
        m.ds,
        CASE m.pri
            WHEN 1 THEN 'B'
            WHEN 2 THEN 'M'
            WHEN 3 THEN 'A'
            WHEN 4 THEN 'O'
        END,
        m.fixa,
        m.pago
    FROM @Mov7 m;

    FETCH NEXT FROM curSaldo7 INTO @idSaldo7;
END;

CLOSE curSaldo7;
DEALLOCATE curSaldo7;



/* ============================================================
   META E OBJETIVOS DO USUÁRIO 7
   ============================================================ */

INSERT INTO T_NS_META
(id_usuario, vl_meta, dt_inicio, dt_fim, tp_concluido)
VALUES
(@idUser7, 8000.00, '2025-02-01', '2025-12-01', 0);

DECLARE @idMeta7_1 INT = SCOPE_IDENTITY();

INSERT INTO T_NS_OBJETIVO (id_meta, ds_objetivo, tp_concluido) VALUES
(@idMeta7_1, 'Comprar carro novo', 0),
(@idMeta7_1, 'Investir em ações', 0),
(@idMeta7_1, 'Fazer viagem internacional', 0);



/* ============================================================
   FIM DO BLOCO — USUÁRIO 7
   ============================================================ */

/* ============================================================
   USUÁRIO 8 — Juliana Costa
   1 cartão → Débito Santander
   Movimentações: 7–12 por saldo
   Metas: 2 | Objetivos: 2 cada
   ============================================================ */

INSERT INTO T_NS_USUARIO
(nm_usuario, ds_email, ds_senha, dt_nascimento, tp_genero, tp_premium, vl_renda)
VALUES
('Juliana Costa', 'juliana.costa@exemplo.com', 'JuCo@2025*pass', '1993-07-14', 'F', 0, 4100.00);

DECLARE @idUser8 INT = SCOPE_IDENTITY();



/* ============================================================
   CARTÃO 1 – Débito Santander
   ============================================================ */

INSERT INTO T_NS_CARTAO
(id_usuario, nm_cartao, dt_validade, vl_hex_cor, nm_instituicao, tp_soma_carteira, tp_cartao)
VALUES
(@idUser8, 'Santander Débito', '2026-08-01', 'FF69B4', 'Santander', 1, 'D');

DECLARE @idCartao8_1 INT = SCOPE_IDENTITY();

INSERT INTO T_NS_DEBITO (id_cartao, nr_cvv, nr_limite_gastos)
VALUES (@idCartao8_1, 412, 2800.00);



/* ============================================================
   SALDOS MENSAIS — CARTÃO
   ============================================================ */

DECLARE @Mes8 INT = 1;

WHILE @Mes8 <= 10
BEGIN
    INSERT INTO T_NS_SALDO (dt_saldo, id_cartao)
    VALUES (DATEFROMPARTS(2025, @Mes8, 1), @idCartao8_1);

    SET @Mes8 = @Mes8 + 1;
END;




/* ============================================================
   MOVIMENTAÇÕES — USUÁRIO 8
   ============================================================ */

DECLARE @Mov8 TABLE (
    ds NVARCHAR(50),
    valor NUMERIC(9,2),
    tp CHAR(1),
    pg INT,
    pri INT,
    fixa BIT,
    pago BIT
);

INSERT INTO @Mov8 VALUES
('Mercado',           125.50, 'D', 1, 2, 0, 1),
('Restaurante',        70.20, 'D', 1, 1, 0, 1),
('Uber',               27.00, 'D', 1, 1, 0, 1),
('Farmácia',           48.50, 'D', 1, 3, 0, 1),
('Assinatura Netflix', 39.90, 'D', 3, 2, 1, 1),
('Salário',          4100.00, 'R', 1, 1, 1, 1),
('Transferência Pix', 250.00, 'R', 1, 1, 0, 1);



/* ============================================================
   INSERÇÃO DAS MOVIMENTAÇÕES PARA CADA SALDO
   ============================================================ */

DECLARE @idSaldo8 INT;

DECLARE curSaldo8 CURSOR FOR
SELECT id_saldo FROM T_NS_SALDO WHERE id_cartao = @idCartao8_1;

OPEN curSaldo8;
FETCH NEXT FROM curSaldo8 INTO @idSaldo8;

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO T_NS_MOVIMENTACAO
    (id_saldo, id_prioridade, id_pagamento, dt_movimentacao,
     vl_movimentacao, tp_movimentacao, ds_movimentacao,
     tp_prioridade, tp_fixa, tp_foi_pago)
    SELECT
        @idSaldo8,
        m.pri,
        m.pg,
        DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 27, DATEFROMPARTS(2025, 1, 1)),
        m.valor,
        m.tp,
        m.ds,
        CASE m.pri
            WHEN 1 THEN 'B'
            WHEN 2 THEN 'M'
            WHEN 3 THEN 'A'
            WHEN 4 THEN 'O'
        END,
        m.fixa,
        m.pago
    FROM @Mov8 m;

    FETCH NEXT FROM curSaldo8 INTO @idSaldo8;
END;

CLOSE curSaldo8;
DEALLOCATE curSaldo8;



/* ============================================================
   METAS E OBJETIVOS DO USUÁRIO 8
   ============================================================ */

-- META 1
INSERT INTO T_NS_META
(id_usuario, vl_meta, dt_inicio, dt_fim, tp_concluido)
VALUES
(@idUser8, 3000.00, '2025-01-10', '2025-07-30', 0);

DECLARE @idMeta8_1 INT = SCOPE_IDENTITY();

INSERT INTO T_NS_OBJETIVO (id_meta, ds_objetivo, tp_concluido) VALUES
(@idMeta8_1, 'Economizar para viagem', 0),
(@idMeta8_1, 'Comprar smartphone novo', 0);

-- META 2
INSERT INTO T_NS_META
(id_usuario, vl_meta, dt_inicio, dt_fim, tp_concluido)
VALUES
(@idUser8, 1500.00, '2025-03-01', '2025-06-15', 0);

DECLARE @idMeta8_2 INT = SCOPE_IDENTITY();

INSERT INTO T_NS_OBJETIVO (id_meta, ds_objetivo, tp_concluido) VALUES
(@idMeta8_2, 'Comprar monitor novo', 0),
(@idMeta8_2, 'Reduzir gastos com delivery', 0);



/* ============================================================
   FIM DO BLOCO — USUÁRIO 8
   ============================================================ */
