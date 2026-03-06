/* ============================================================
   Tabelas Base
   ============================================================ */

CREATE TABLE T_NS_CARTAO
(
    id_cartao       INT IDENTITY(1,1) NOT NULL,
    id_usuario      INT NOT NULL,
    nm_cartao       NVARCHAR(50) NOT NULL,
    dt_validade     DATE NOT NULL,
    vl_hex_cor      CHAR(6) NOT NULL,
    nm_instituicao  NVARCHAR(100) NOT NULL,
    tp_soma_carteira BIT NOT NULL,
    tp_cartao       CHAR(1) NOT NULL
);
GO

ALTER TABLE T_NS_CARTAO 
ADD CONSTRAINT PK_CARTAO 
PRIMARY KEY CLUSTERED (id_cartao);
GO

/* ===================== T_NS_CREDITO ===================== */

CREATE TABLE T_NS_CREDITO
(
    id_cartao        INT NOT NULL,
    dt_fechamento    DATE NOT NULL,
    dt_vencimento    DATE NOT NULL,
    nr_limite_cartao NUMERIC(9,2) NOT NULL
);
GO

-- Primary + Foreign 
ALTER TABLE T_NS_CREDITO 
ADD CONSTRAINT PF_CARTAO_CRED 
PRIMARY KEY CLUSTERED (id_cartao);
GO


/* ===================== T_NS_DEBITO ====================== */

CREATE TABLE T_NS_DEBITO
(
    id_cartao         INT NOT NULL,
    nr_cvv            INT NOT NULL,
    nr_limite_gastos  NUMERIC(9,2) NOT NULL
);
GO

-- Primary + Foreign 
ALTER TABLE T_NS_DEBITO 
ADD CONSTRAINT PF_CARTAO_DEB 
PRIMARY KEY CLUSTERED (id_cartao);
GO


/* ======================= T_NS_META ======================= */

CREATE TABLE T_NS_META
(
    id_meta      INT IDENTITY(1,1) NOT NULL,
    id_usuario   INT NOT NULL,
    vl_meta      NUMERIC(9,2) NOT NULL,
    dt_inicio    DATE NOT NULL,
    dt_fim       DATE NOT NULL,
    tp_concluido BIT NOT NULL
);
GO

ALTER TABLE T_NS_META 
ADD CONSTRAINT PK_META 
PRIMARY KEY CLUSTERED (id_meta);
GO


/* ================== T_NS_MOVIMENTACAO ==================== */

CREATE TABLE T_NS_MOVIMENTACAO
(
    id_movimentacao INT IDENTITY(1,1) NOT NULL,
    id_saldo        INT NOT NULL,
    id_prioridade   INT NOT NULL,
    id_pagamento    INT NOT NULL,
    dt_movimentacao DATETIME NOT NULL,
    vl_movimentacao NUMERIC(9,2) NOT NULL,
    tp_movimentacao CHAR(1) NOT NULL,
    ds_movimentacao NVARCHAR(50) NOT NULL,
    tp_prioridade   CHAR(1) NOT NULL,
    tp_fixa         BIT NOT NULL,
    tp_foi_pago     BIT NOT NULL
);
GO

ALTER TABLE T_NS_MOVIMENTACAO 
ADD CONSTRAINT PK_MOV 
PRIMARY KEY CLUSTERED (id_movimentacao);
GO


/* ====================== T_NS_OBJETIVO ==================== */

CREATE TABLE T_NS_OBJETIVO
(
    id_objetivo INT IDENTITY(1,1) NOT NULL,
    id_meta     INT NOT NULL,
    ds_objetivo NVARCHAR(40) NOT NULL,
    tp_concluido BIT NOT NULL
);
GO

ALTER TABLE T_NS_OBJETIVO 
ADD CONSTRAINT PK_OBJETIVO 
PRIMARY KEY CLUSTERED (id_objetivo);
GO


/* ====================== T_NS_PAGAMENTO =================== */

CREATE TABLE T_NS_PAGAMENTO
(
    id_pagamento INT IDENTITY(1,1) NOT NULL,
    tp_pagamento VARCHAR(20) NOT NULL
);
GO

ALTER TABLE T_NS_PAGAMENTO 
ADD CONSTRAINT PK_PAGAMENTO 
PRIMARY KEY CLUSTERED (id_pagamento);
GO


/* ===================== T_NS_PRIORIDADE =================== */

CREATE TABLE T_NS_PRIORIDADE
(
    id_prioridade INT IDENTITY(1,1) NOT NULL,
    nm_prioridade VARCHAR(11) NOT NULL
);
GO

ALTER TABLE T_NS_PRIORIDADE 
ADD CONSTRAINT PK_PRIORI 
PRIMARY KEY CLUSTERED (id_prioridade);
GO


/* ======================== T_NS_SALDO ===================== */

CREATE TABLE T_NS_SALDO
(
    id_saldo  INT IDENTITY(1,1) NOT NULL,
    dt_saldo  DATE NOT NULL,
    id_cartao INT NOT NULL
);
GO

ALTER TABLE T_NS_SALDO 
ADD CONSTRAINT PK_SALDO 
PRIMARY KEY CLUSTERED (id_saldo);
GO


/* ======================= T_NS_USUARIO ==================== */

CREATE TABLE T_NS_USUARIO
(
    id_usuario    INT IDENTITY(1,1) NOT NULL,
    nm_usuario    NVARCHAR(100) NOT NULL,
    ds_email      NVARCHAR(150) NOT NULL,
    ds_senha      NVARCHAR(20) NOT NULL,
    dt_nascimento DATE NOT NULL,
    tp_genero     CHAR(1) NOT NULL,
    tp_premium    BIT NOT NULL,
    vl_renda      NUMERIC(9,2) NULL
);
GO

ALTER TABLE T_NS_USUARIO
ADD CONSTRAINT UN_USER_EMAIL UNIQUE (ds_email);
GO

ALTER TABLE T_NS_USUARIO 
ADD CONSTRAINT PK_USER 
PRIMARY KEY CLUSTERED (id_usuario);
GO


/* ============================================================
   Foreign Keys 
   ============================================================ */

ALTER TABLE T_NS_CARTAO
ADD CONSTRAINT FK_USER_CARTAO 
FOREIGN KEY (id_usuario)
REFERENCES T_NS_USUARIO (id_usuario)
ON DELETE NO ACTION 
ON UPDATE NO ACTION;
GO

-- Crédito: PF_CARTAO_CRED é PK; agora adiciona FK com mesmo propósito
ALTER TABLE T_NS_CREDITO
ADD CONSTRAINT FK_CARTAO_CRED 
FOREIGN KEY (id_cartao)
REFERENCES T_NS_CARTAO (id_cartao)
ON DELETE CASCADE
ON UPDATE NO ACTION;
GO

-- Débito: PF_CARTAO_DEB é PK; add FK
ALTER TABLE T_NS_DEBITO
ADD CONSTRAINT FK_CARTAO_DEB 
FOREIGN KEY (id_cartao)
REFERENCES T_NS_CARTAO (id_cartao)
ON DELETE CASCADE
ON UPDATE NO ACTION;
GO

ALTER TABLE T_NS_META
ADD CONSTRAINT FK_USER_META 
FOREIGN KEY (id_usuario)
REFERENCES T_NS_USUARIO (id_usuario)
ON DELETE NO ACTION 
ON UPDATE NO ACTION;
GO

ALTER TABLE T_NS_MOVIMENTACAO
ADD CONSTRAINT FK_PAG_MOVI 
FOREIGN KEY (id_pagamento)
REFERENCES T_NS_PAGAMENTO (id_pagamento)
ON DELETE NO ACTION 
ON UPDATE NO ACTION;
GO

ALTER TABLE T_NS_MOVIMENTACAO
ADD CONSTRAINT FK_PRI_MOV 
FOREIGN KEY (id_prioridade)
REFERENCES T_NS_PRIORIDADE (id_prioridade)
ON DELETE NO ACTION 
ON UPDATE NO ACTION;
GO

ALTER TABLE T_NS_MOVIMENTACAO
ADD CONSTRAINT FK_SALDO_MOV 
FOREIGN KEY (id_saldo)
REFERENCES T_NS_SALDO (id_saldo)
ON DELETE CASCADE
ON UPDATE NO ACTION;
GO

ALTER TABLE T_NS_OBJETIVO
ADD CONSTRAINT FK_META_OBJETIVO 
FOREIGN KEY (id_meta)
REFERENCES T_NS_META (id_meta)
ON DELETE CASCADE
ON UPDATE NO ACTION;
GO

ALTER TABLE T_NS_SALDO
ADD CONSTRAINT FK_CARTAO_SALDO 
FOREIGN KEY (id_cartao)
REFERENCES T_NS_CARTAO (id_cartao)
ON DELETE CASCADE
ON UPDATE NO ACTION;
GO


/* ============================================================
   Checks 
   ============================================================ */

ALTER TABLE T_NS_USUARIO
ADD CONSTRAINT CK_USER_GENERO
CHECK (tp_genero IN ('M', 'F', 'O'));
GO

ALTER TABLE T_NS_CARTAO
ADD CONSTRAINT CK_CARTAO_TP_CAR
CHECK (tp_cartao IN ('D', 'C'));
GO

ALTER TABLE T_NS_MOVIMENTACAO
ADD CONSTRAINT CK_MOV_TP_MOV
CHECK (tp_movimentacao IN ('D', 'R'));
GO


/* ============================================================
   TRIGGERS DE HERANÇA (ARC) 
   ============================================================ */

-- Crédito
CREATE TRIGGER ARC_CARTAO_CREDITO
ON T_NS_CREDITO
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN T_NS_CARTAO c ON c.id_cartao = i.id_cartao
        WHERE c.tp_cartao <> 'C'
    )
    BEGIN
        RAISERROR(
            'Violação de herança: Apenas cartões com tp_cartao = ''C'' podem ter registro em T_NS_CREDITO.',
            16, 1
        );
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- Débito
CREATE TRIGGER ARC_CARTAO_DEBITO
ON T_NS_DEBITO
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN T_NS_CARTAO c ON c.id_cartao = i.id_cartao
        WHERE c.tp_cartao <> 'D'
    )
    BEGIN
        RAISERROR(
            'Violação de herança: Apenas cartões com tp_cartao = ''D'' podem ter registro em T_NS_DEBITO.',
            16, 1
        );
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO
