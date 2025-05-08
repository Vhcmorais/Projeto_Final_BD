# 🐾 Sistema de Banco de Dados para Hospital Veterinário - Projeto Final UFU (2025)


🧑🏽‍💻 Este repositório hospeda meu projeto final da disciplina **Banco de Dados**, ofertada pela **Universidade Federal de Uberlândia (UFU)** no semestre 2024/2, no ano de 2025.

---

## 💡 Sobre o Projeto

A proposta do projeto final era que fizéssemos um sistema de Banco de Dados, simulando algum tipo de estabelecimento onde é necessário o registro de dados para manter a base de dados do estabelecimento.

Minha proposta para o projeto foi a simulação de um sistema de um **Hospital Veterinário**, o qual foi criado para registrar alguns dados para um atendimento otimizado.

Meu sistema conta com 10 tabelas, sendo elas:

- Tabela de registro dos **tutores**
- Registro de dados dos **animais**
- Registro de dados dos **funcionários** do hospital veterinário
- Registro de **medicamentos**, que serão prescritos aos pacientes

Finalizando os registros de dados pessoais, criei as tabelas que iniciam os serviços do hospital, que são:

- Tabela para registro de **agendamentos**
- Tabela de **consultas** dos animais
- Tabela de **prontuário médico** das consultas
- Tabela de **serviços realizados** no hospital
- Tabela de **prescrições** de remédios ou serviços
- Tabela que registra as **consultas e os serviços realizados**

---

## 🛠️ Tecnologias Utilizadas

- PostgreSQL
- pgAdmin 4
- [Draw.io](https://app.diagrams.net/) (Para esquematizar o planejamento)
- GitHub

---

## 📂 Estrutura do Repositório

- `/sql/`: Scripts SQL de criação e manipulação do Banco "Hospital Veterinário"
- `/diagrama/`: Diagrama de Lógica e Planejamento
- `/assets/`: Imagens utilizadas no arquivo README.md
- `README.md`: Este arquivo


---

## 💭 Planejamento de Criação

- Antes da implementação do Banco de Dados, utilizei a ferramenta Draw.io para esquematizar a lógica de funcionamento do Hospital Veterinário e planejar as tabelas necessárias para o desenvolvimento deste projeto:

![Esquemático do Sistema](assets/esquemático.jpeg)

---

## 🧑🏽‍💻 CRIANDO O SCRIPT SQL

- O projeto é iniciado com a criação de um schema chamado "sistema" para a otimização de alguns pontos, principalmente para os ids, e suas sequences dentro do schema: 
```
-- CRIANDO SCHEMA E SEQUENCES PARA AUTOMATIZAR OS IDS NECESSÁRIOS --

CREATE SCHEMA sistema;

CREATE SEQUENCE sistema.tb_tutores_id_seq START 1;
CREATE SEQUENCE sistema.tb_animais_id_seq START 1;
CREATE SEQUENCE sistema.tb_funcionarios_id_seq START 1;
.
.
.
    Outras Sequences...
```

- Após a criação das sequences e do esquema, faço a criação das tabelas: 

```
-- CRIANDO TABELAS DO BANCO DE DADOS - HOSPITAL VETERINÁRIO --


CREATE TABLE sistema.tutores
(
	id_tutor	INTEGER 		PRIMARY KEY				default nextval('sistema.tb_tutores_id_seq'),
	nome 		VARCHAR(32) 	constraint nn_nome 		not null,
	telefone 	VARCHAR(20)		constraint nn_telefone	not null,
	email		VARCHAR(32)		constraint nn_email 	not null,
	endereco	VARCHAR(32)		constraint nn_endereco	not null
);
.
.
.
    Outras tabelas...
```
- Após a criação das tabelas, foi o momento de povoar as tabelas. Para me inspirar a criar as tabelas, solicitei ao ChatGPT que me apresentasse algumas situações de atendimento para o Hospital Veterinário e assim, fui colocando as propostas em prática dentro do meu script:

*Exemplo proposto pelo ChatGPT:
"O tutor Paulo levou sua tartaruga Tuca ao hospital veterinário após notar uma rachadura no casco. A Dra. Renata examinou e recomendou limpeza, pomada cicatrizante e observação. Serviço de curativo aplicado e prescrição de medicamentos tópicos."*

```sql
INSERT INTO sistema.tutores (nome, telefone, email, endereco)
VALUES ('Paulo Henrique da Mata', '(62)91234-5566', 'paulo.h.mata@gmail.com', 'Rua das Águas, 99 - Centro');

INSERT INTO sistema.animais (nome, especie, raca, idade, peso, id_tutor)
VALUES ('Tuca', 'Réptil', 'Tartaruga Tigre-d’água', 5, 2,
       (SELECT id_tutor FROM sistema.tutores WHERE nome = 'Paulo Henrique da Mata'));
	   
INSERT INTO sistema.funcionarios (nome, funcao, telefone, salario)
VALUES ('Renata Oliveira Santos', 'Veterinária de Silvestres', '(62)99876-3344', 'R$ 7.500,00');
.
.
. 
    Mais inserts...
```

- Por fim, foi implementado no script alguns selects para visualização de resultados que fossem satisfatórios e úteis para o usuário no Hospital Veterinário, como: 

```sql
-- # Select Visualização - Nome do animal, nome do tutor, nome do profissional que 
atendeu, data e horario de atendimento, observacoes, serviço e quantidade de serviços! # --

SELECT
    a.nome AS nome_animal,
    t.nome AS tutor,
    f.nome AS profissional_atendente,
    c.data_horario,
    c.observacoes,
    s.descricao AS servico,
    cs.quantidade
FROM sistema.consulta c
JOIN sistema.animais a ON c.id_animal = a.id_animal
JOIN sistema.tutores t ON a.id_tutor = t.id_tutor
JOIN sistema.funcionarios f ON c.id_funcionario = f.id_funcionario
JOIN sistema.consulta_servico cs ON c.id_consulta = cs.id_consulta
JOIN sistema.servico s ON cs.id_servico = s.id_servico
ORDER BY c.data_horario DESC NULLS LAST;
```
---

---

## 🫵 Desafio 

A apresentação do projeto contou com 3 desafios propostos pelo professor orientador para avaliação do sistema, foram eles: 

1) Inserir uma view de tabela temporária com JOINs;
2) Inserir triggers para controle da operação UPDATE em qualquer tabela;
3) Inserir um Stored Procedure que receba uma inserção em uma tabela e retorne o ID do dado inserido.

Cada desafio foi resolvido com os seguintes códigos:

1) Inserir uma view de tabela temporária com JOINs;

```
SELECT
    ag.data_hora,
    t.nome AS tutor,
    f.nome AS profissional,
    ag.status
FROM sistema.agenda ag
JOIN sistema.tutores t ON ag.id_tutor = t.id_tutor
JOIN sistema.funcionarios f ON ag.id_funcionario = f.id_funcionario
ORDER BY ag.data_hora;
```
2) Inserir triggers para controle da operação UPDATE em qualquer tabela;
```
CREATE TABLE sistema.dia_consultas (
data_hr	VARCHAR		NOT NULL,
consultas_qt	NUMERIC);
CREATE TABLE sistema.dia_consulta_controle(
operacao	CHAR 		NOT NULL,
usuario	    VARCHAR     NOT NULL,
dt_hr	    TIMESTAMP	NOT NULL,
data_hr	    VARCHAR	 	NOT NULL,
consultas_qt     NUMERIC);
CREATE OR REPLACE FUNCTION sistema.fn_dia_consulta_controle()
RETURNS trigger AS
$$
	BEGIN
    	IF(tg_op = 'UPDATE') THEN
           	INSERT INTO sistema.dia_consulta_controle
            SELECT 'A', user, now(),NEW.*;
            RETURN NEW;
        END IF;
        RETURN NULL;                   
    END
$$
LANGUAGE plpgsql;
CREATE TRIGGER tg_controle_diaconsulta
AFTER INSERT OR UPDATE OR DELETE ON sistema.dia_consultas
FOR EACH ROW EXECUTE PROCEDURE sistema.fn_dia_consulta_controle();

select * from sistema.dia_consultas;

select * from sistema.dia_consulta_controle;

insert into sistema.dia_consultas(data_hr, consultas_qt)
values  ('08/05/2025', 5),
		('15/05/2025', 3),
		('18/05/2025', 7),
		('25/05/2025', 3),
		('31/05/2025', 15);
		
update sistema.dia_consultas
set data_hr = '10/05/2025' where consultas_qt = 5;

update sistema.dia_consultas
set data_hr = '01/06/25' where consultas_qt = 15;
```

3) Inserir um Stored Procedure que receba uma inserção em uma tabela e retorne o ID do dado inserido:
```
CREATE OR REPLACE FUNCTION sistema.fn_return_insertedid(
    p_nome VARCHAR,
    p_telefone VARCHAR,
    p_email VARCHAR,
    p_endereco VARCHAR
) RETURNS INTEGER AS
$$
DECLARE 
    t_id sistema.tutores.id_tutor%TYPE;
BEGIN
    INSERT INTO sistema.tutores (nome, telefone, email, endereco)
    VALUES (p_nome, p_telefone, p_email, p_endereco)
    RETURNING id_tutor INTO t_id;

    RETURN t_id;
END;
$$
LANGUAGE plpgsql;


SELECT sistema.fn_return_insertedid(
    'Rafinha Santos',
    '(11) 98765-4321',
    'rafinha@logomail.com',
    'Rua das Flores, 123'
);


SELECT sistema.fn_return_insertedid(
    'Luca Braga',
    '(11)1234-2314',
    'lucabraga@gmail.com',
    'Rua das Acacias, 4356'
);

SELECT sistema.fn_return_insertedid(
    'Rony',
    '(11)43414',
    'rony@gmail.com',
    'Rua das Acacias, 213'
);
```
---

## 📌 Conclusão

Este projeto me proporcionou uma experiência prática essencial na modelagem, criação e manipulação de bancos de dados relacionais. A simulação de um sistema real de um Hospital Veterinário exigiu atenção a detalhes como integridade referencial, organização de dados e clareza na consulta das informações. Tenho como planejamento e objetivo futuro de implementar uma interface gráfica para esse projeto :)   

<p align="center">
  <img src="assets/dog.png" width="100" height="100" style="border-radius: 50%;"/>
</p>

---

## 👤 Sobre o Autor

Desenvolvido por **Vitor Henrique Carvalho de Morais**, estudante de Engenharia da Computação na **Universidade Federal de Uberlândia (UFU)**.

- 💼 [Portfólio](https://vhcdev.netlify.app/)
- 🐙 [GitHub](https://github.com/Vhcmorais)
- ✉️ vhcmdev@gmail.com

Sinta-se à vontade para explorar o repositório, deixar sugestões ou entrar em contato! 🚀
