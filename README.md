# Banco de Dados — Startup New Start

Este repositório contém o **projeto de banco de dados** desenvolvido para a startup fictícia **New Start**, criada durante o **TCC do curso técnico em Ciência de Dados — Cedup Timbó**.

O banco foi projetado para estruturar os dados necessários para o funcionamento da aplicação, incluindo **criação do banco, inserção de dados e consultas SQL** utilizadas pelo sistema.

---

## 🎨 Protótipo da aplicação

O design da aplicação, incluindo **todas as telas e o dicionário de dados**, foi desenvolvido no Figma.

🔗 Protótipo completo:  
https://www.figma.com/design/TFtMfasFMZtBGzZqtiUxQN/TCC---New-Start?node-id=0-1&t=682FZkhWX8suSruh-1


---

## Estrutura do projeto

Os scripts SQL estão organizados por etapa dentro da pasta `database`.

```
database/
│
├ 01_create_database.sql
├ 02_insert_data.sql
└ 03_queries.sql
```

Esses arquivos incluem:

- criação do banco de dados
- criação de tabelas
- inserção de dados
- consultas utilizadas pela aplicação

---

## 📊 Exemplo de comando SQL

```sql
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
```

---

## 🛠 Tecnologias utilizadas

- SQL
- Banco de dados relacional
- Prototipação de interface
- Estruturação de dados

---

## Objetivo do projeto

Este projeto foi desenvolvido para:

- estruturar um banco de dados para uma aplicação
- praticar comandos SQL
- organizar dados de forma relacional
- simular a estrutura de backend de uma startup

---

## 🏆 Contexto acadêmico

O projeto faz parte da startup fictícia **New Start**, criada durante o **Trabalho de Conclusão de Curso (TCC)** do técnico em Ciência de Dados.

Premiações obtidas pelo projeto:

🥇 1º Lugar — TCS  
🥇 1º Lugar — TCS  
🥈 2º Lugar — TCC

---

## 👨‍💻 Autor

Kayke Alves Souza

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Kayke%20Alves%20Souza-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/kaykealvesdesouza)
