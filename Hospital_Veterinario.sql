-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CRIANDO SCHEMA E SEQUENCES PARA AUTOMATIZAR OS IDS NECESSÁRIOS --
-------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE SCHEMA sistema;

CREATE SEQUENCE sistema.tb_tutores_id_seq START 1;
CREATE SEQUENCE sistema.tb_animais_id_seq START 1;
CREATE SEQUENCE sistema.tb_funcionarios_id_seq START 1;
CREATE SEQUENCE sistema.tb_prontuario_medico_id_seq START 1;
CREATE SEQUENCE sistema.tb_medicamentos_id_seq START 1;
CREATE SEQUENCE sistema.tb_agenda_id_seq START 1;
CREATE SEQUENCE sistema.tb_consulta_id_seq START 1;
CREATE SEQUENCE sistema.tb_servico_id_seq START 1;
CREATE SEQUENCE sistema.tb_prescricao_id_seq START 1;

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CRIANDO TABELAS DO BANCO DE DADOS - HOSPITAL VETERINÁRIO --
-------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE sistema.tutores
(
	id_tutor	INTEGER 		PRIMARY KEY				default nextval('sistema.tb_tutores_id_seq'),
	nome 		VARCHAR(32) 	constraint nn_nome 		not null,
	telefone 	VARCHAR(20)		constraint nn_telefone	not null,
	email		VARCHAR(32)		constraint nn_email 	not null,
	endereco	VARCHAR(32)		constraint nn_endereco	not null
);

CREATE TABLE sistema.animais
(
	id_animal 	INTEGER			PRIMARY KEY				default nextval('sistema.tb_animais_id_seq'),
	nome		VARCHAR(32) 	constraint nn_nome		not null,
	especie		VARCHAR(32)		constraint nn_especie	not null,
	raca		VARCHAR(20)		default ('')					,
	idade 		INTEGER 		constraint nn_idade		not null,
	peso		INTEGER			constraint nn_peso		not null,
	id_tutor 	INTEGER											,
	CONSTRAINT fk_id_tutor FOREIGN KEY (id_tutor) REFERENCES sistema.tutores(id_tutor)
);

CREATE TABLE sistema.funcionarios
(
	id_funcionario 		INTEGER 		PRIMARY KEY 			default nextval('sistema.tb_funcionarios_id_seq'),
	nome				VARCHAR(32) 	constraint nn_nome		not null,
	funcao				VARCHAR(32)		constraint nn_funcao	not null,
	telefone			VARCHAR(32)		constraint nn_telefone	not null,
	salario				VARCHAR(32)		constraint nn_salario	not null
);

CREATE TABLE sistema.prontuario_medico
(
	id_prontuario 			INTEGER			PRIMARY KEY 				default nextval('sistema.tb_prontuario_medico_id_seq'),
	id_animal 				INTEGER																							   ,
	historico_doenca		TEXT			constraint nn_historico		not null,
	alergias				VARCHAR(32)		constraint nn_alergias		not null,
	tratamentos_andamento	VARCHAR(32)		constraint nn_andamento 	not null,
	CONSTRAINT fk_id_animal FOREIGN KEY (id_animal) REFERENCES sistema.animais(id_animal)
);

CREATE TABLE sistema.medicamentos
(
	id_medicamentos 		INTEGER	 		PRIMARY KEY 				default nextval('sistema.tb_medicamentos_id_seq'),
	nome					VARCHAR(32)		constraint nn_nome			not null,
	tipo_medicamento 		VARCHAR(15)		constraint nn_tipo			not null,
	fabricante				VARCHAR(15)		default('')							
);

CREATE TABLE sistema.agenda
(
	id_agendamento 			INTEGER			PRIMARY KEY 				default nextval('sistema.tb_agenda_id_seq'),
	data_hora				TIMESTAMP																				,
	id_tutor				INTEGER																					,
	id_funcionario			INTEGER																					,
	status					VARCHAR(32)		constraint nn_status		not null,
	CONSTRAINT fk_id_tutor FOREIGN KEY (id_tutor) REFERENCES sistema.tutores(id_tutor),
	CONSTRAINT fk_id_funcionario FOREIGN KEY (id_funcionario) REFERENCES sistema.funcionarios(id_funcionario)
);

CREATE TABLE sistema.servico
(
	id_servico 				INTEGER 		PRIMARY KEY 				default nextval('sistema.tb_servico_id_seq'),
	descricao				TEXT			constraint nn_desc 			not null,
	preco					VARCHAR(20)		constraint nn_preco			not null
);

CREATE TABLE sistema.consulta
(
	id_consulta 			INTEGER 		PRIMARY KEY 				default nextval('sistema.tb_consulta_id_seq'),
	data_horario			TIMESTAMP																				  ,
	observacoes				TEXT																					  ,
	id_animal				INTEGER																					  ,
	id_funcionario			INTEGER																					  ,
	CONSTRAINT fk_id_animal FOREIGN KEY (id_animal) REFERENCES sistema.animais(id_animal),
	CONSTRAINT fk_id_funcionario FOREIGN KEY (id_funcionario) REFERENCES sistema.funcionarios(id_funcionario)
);

CREATE TABLE sistema.prescricao
(
	id_prescricao 			INTEGER			PRIMARY KEY 				default nextval('sistema.tb_prescricao_id_seq'),
	id_consulta				INTEGER,
	id_medicamentos			INTEGER,
	dosagem					VARCHAR(10)		constraint nn_dosagem		not null,
	duracao_tratamento		VARCHAR(10)		constraint nn_duracao		not null,
	CONSTRAINT fk_id_consulta FOREIGN KEY (id_consulta) REFERENCES sistema.consulta(id_consulta),
	CONSTRAINT fk_id_medicamentos FOREIGN KEY (id_medicamentos) REFERENCES sistema.medicamentos(id_medicamentos)
);

CREATE TABLE sistema.consulta_servico
(
	id_consulta				INTEGER,
	id_servico				INTEGER,
	quantidade				VARCHAR(32),	
	CONSTRAINT fk_id_servico FOREIGN KEY (id_servico) REFERENCES sistema.servico(id_servico),
	CONSTRAINT fk_id_consulta FOREIGN KEY (id_consulta) REFERENCES sistema.consulta(id_consulta)
);

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DINÂMICAS PARA POVOAR TABELAS ---------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------

-- João da Silva levou seu cachorro Thor para uma consulta com a veterinária Dra. Ana, com suspeita de otite. Foi prescrito Otosporin por 7 dias. Consulta registrada e serviço de consulta geral cobrado.

INSERT INTO sistema.tutores (nome, telefone, email, endereco)
VALUES ('João da Silva', '(11)99999-8888', 'joao.silva@email.com', 'Rua das Palmeiras, 123 - Bairro Tocantins');

INSERT INTO sistema.animais (nome, especie, raca, idade, peso, id_tutor)
VALUES ('Thor', 'Cachorro', 'Labrador', 5, 30,
    (SELECT id_tutor FROM sistema.tutores WHERE nome = 'João da Silva'));
	
INSERT INTO sistema.funcionarios (nome, funcao, telefone, salario)
VALUES ('Dra. Ana Lúcia', 'Veterinária', '(11)98888-7777', '8500.00');

INSERT INTO sistema.medicamentos (nome, tipo_medicamento, fabricante)
VALUES ('Otosporin', 'Otológico', 'VetPharma');

INSERT INTO sistema.servico (descricao, preco)
VALUES ('Consulta Geral', '150.00');

INSERT INTO sistema.consulta (data_horario, observacoes, id_animal, id_funcionario)
VALUES (
    '2025-04-30 10:00:00',
    'Suspeita de otite. O animal apresentou coceira na orelha esquerda.',
    (SELECT id_animal FROM sistema.animais WHERE nome = 'Thor'),
    (SELECT id_funcionario FROM sistema.funcionarios WHERE nome = 'Dra. Ana Lúcia')
);

INSERT INTO sistema.prescricao (id_consulta, id_medicamentos, dosagem, duracao_tratamento)
VALUES (
    (SELECT id_consulta FROM sistema.consulta ORDER BY id_consulta DESC LIMIT 1),
    (SELECT id_medicamentos FROM sistema.medicamentos WHERE nome = 'Otosporin'),
    '2 gotas',
    '7 dias'
);

INSERT INTO sistema.consulta_servico (id_consulta, id_servico, quantidade)
VALUES (
    (SELECT id_consulta FROM sistema.consulta ORDER BY id_consulta DESC LIMIT 1),
    (SELECT id_servico FROM sistema.servico WHERE descricao = 'Consulta Geral'),
    '1'
);

-- Maria Souza levou sua gata Luna para tomar vacina. O técnico Carlos aplicou a vacina antirrábica. Serviço de vacinação registrado, sem prescrição.

INSERT INTO sistema.tutores (nome, telefone, email, endereco)
VALUES ('Maria de Fátima Souza', '(34)99999-1133', 'mariadesouza@yahoo.com', 'Rua das Goiabeiras, 413 - Bairro Londres');

INSERT INTO sistema.animais (nome, especie, raca, idade, peso, id_tutor)
VALUES ('Luna', 'Gato', 'SRD', 7, 5, (select id_tutor from sistema.tutores where nome = 'Maria de Fátima Souza'));

INSERT INTO sistema.funcionarios (nome, funcao, telefone, salario)
VALUES ('Carlos Alberto Silva', 'Técnico Veterinário', '(38)98888-8877', 2500.00);

INSERT INTO sistema.consulta (observacoes, id_animal, id_funcionario)
VALUES ('Consulta de rotina. É preciso a vacinação antirrábica.',
	   (select id_animal from sistema.animais where nome ='Luna'), 
	   (select id_funcionario from sistema.funcionarios where nome = 'Carlos Alberto Silva'));
	   
INSERT INTO sistema.servico (descricao, preco)
VALUES ('Vacinação antirrábica.', 'R$ 80,00');

INSERT INTO sistema.consulta_servico(id_consulta, id_servico, quantidade)
VALUES ((select id_consulta from sistema.consulta where id_animal = 5), 
		 (select id_servico from sistema.servico where id_servico = 2),
		 '1 vacina.')

select * from sistema.tutores;

-- Pedro Lima levou o coelho Snow para checar uma queda de pelo. Consulta com Dr. Rafael, diagnosticado estresse. Serviço de consulta e orientação registrados.

INSERT INTO sistema.tutores (nome, telefone, email, endereco)
VALUES ('Pedro Lima Caldas', '(34)91111-1122', 'plimacaldas@outlook.com.br', 'Rua das Aves, 334 - Bairro Gelado');

INSERT INTO sistema.animais (nome, especie, raca, idade, peso, id_tutor)
VALUES ('Snow', 'Coelho', 'Angorá', 2, 3, (select id_tutor from sistema.tutores where nome = 'Pedro Lima Caldas'));

INSERT INTO sistema.funcionarios (nome, funcao, telefone, salario)
VALUES ('Dr. Rafael Carvalho', 'Médico Veterinário', '(13)98843-7531', 'R$ 8.000,00');

INSERT INTO sistema.consulta (observacoes, id_animal, id_funcionario)
VALUES ('O tutor de Snow reclama de queda de pelo. Diagnóstico: Estresse',
  	   (SELECT id_animal FROM sistema.animais WHERE nome = 'Snow'),
  	   (SELECT id_funcionario FROM sistema.funcionarios WHERE nome = 'Dr. Rafael Carvalho'));
		 
INSERT INTO sistema.servico (descricao, preco)
VALUES ('Consulta', 'R$ 120,00');

INSERT INTO sistema.medicamentos (nome, tipo_medicamento, fabricante)
VALUES ('Gabapentina','Anticonvulsionante', 'Biolab');

INSERT INTO sistema.prescricao (id_consulta, id_medicamentos, dosagem, duracao_tratamento)
VALUES ((select id_consulta from sistema.consulta where id_animal = 6),
		(select id_medicamentos from sistema.medicamentos where nome = 'Gabapentina'), 100, 5);
		
INSERT INTO sistema.consulta_servico (id_consulta, id_servico, quantidade)
values ((select id_consulta from sistema.consulta where id_animal = 6),
		(select id_servico from sistema.servico where id_servico = 3),
		'1 consulta');

-- Carla Mendes levou seu cão Max com febre. Consulta com Dra. Ana, prescrição de Dipirona por 7 dias. Serviço de consulta e medicamento registrados.

INSERT INTO sistema.tutores (nome, telefone, email, endereco)
VALUES ('Carla Mendes', '(32)1233-3124', 'carlamendes@gmail.com', 'Rua Osasco, 123 - Bairro Custódio Pereira');

INSERT INTO sistema.animais (nome, especie, raca, idade, peso, id_tutor)
VALUES ('Max', 'Cachorro', 'Husky Siberiano', 6, 45, (select id_tutor from sistema.tutores where nome = 'Carla Mendes'));

INSERT INTO sistema.consulta (observacoes, id_animal, id_funcionario)
VALUES ('Sintomas de Febre', 
	   (select id_animal from sistema.animais where nome = 'Max'),
	   (select id_funcionario from sistema.funcionarios where nome = 'Dra. Ana Lúcia'));
	   
INSERT INTO sistema.medicamentos (nome, tipo_medicamento, fabricante)
VALUES ('Dipirona','Analgésico', 'Biovet');

INSERT INTO sistema.prescricao (id_consulta, id_medicamentos, dosagem, duracao_tratamento)
VALUES ((select id_consulta from sistema.consulta where id_consulta = 6),
	   (select id_medicamentos from sistema.medicamentos where nome = 'Dipirona'), 1, 7);
	
INSERT INTO sistema.servico (descricao, preco)
VALUES ('Consulta, prescricao de medicamento e medicação', 'R$ 150,00');

INSERT INTO sistema.consulta_servico (id_consulta, id_servico, quantidade)
VALUES ((select id_consulta from sistema.consulta where id_animal = 7),
		(select id_servico from sistema.servico where id_servico = 4),
		'1 consulta e 1 medicação');

-- Beatriz Nogueira agendou um check-up pré cirúrgico para sua cadela Lola. No dia agendado, o Dr. Fábio a atendeu e prescreveu sua retirada de tumor; 

INSERT INTO sistema.tutores (nome, telefone, email, endereco)
VALUES ('Beatriz Nogueira', '(21) 3233-3124', 'bianogs@gmail.com', 'Rua Brasil, 342 - Bairro Umuarama');

INSERT INTO sistema.animais (nome, especie, raca, idade, peso, id_tutor)
VALUES ('Lola', 'Cachorro', 'Bulldog', 9, 28, (select id_tutor from sistema.tutores where nome = 'Beatriz Nogueira'));

INSERT INTO sistema.funcionarios (nome, funcao, telefone, salario)
VALUES ('Dr. Fábio Marra', 'Cirurgião Veterinário', '(13)5432-7531', 'R$ 13.500,00');

INSERT INTO sistema.consulta (observacoes, id_animal, id_funcionario)
VALUES ('Avaliação e Exames Pré-Cirúrgicos', 
	   (select id_animal from sistema.animais where nome = 'Lola'),
	   (select id_funcionario from sistema.funcionarios where nome = 'Dr. Fábio Marra'));
	   
INSERT INTO sistema.servico (descricao, preco)
VALUES ('Consulta e avaliação para cirurgia', 'R$ 200,00');

INSERT INTO sistema.consulta_servico (id_consulta, id_servico, quantidade)
VALUES ((select id_consulta from sistema.consulta where id_animal = 8),
		(select id_servico from sistema.servico where id_servico = 4),
		'1 consulta avaliativa');
		
INSERT INTO sistema.agenda (data_hora, id_tutor, id_funcionario, status)
VALUES ('03/05/2025 - 14h', (select id_tutor from sistema.tutores where nome ='Beatriz Nogueira'), 
							 (select id_funcionario from sistema.funcionarios where nome = 'Dr. Fábio Marra'),
		'Agendado!');
 
 -- Ana Paula Borges percebe que seu cachorro Magrelo está vomitando há dois dias. Ela liga para a clínica e agenda uma consulta com o veterinário Dr. Henrique Lopes para a tarde do mesmo dia. Durante a consulta, Dr. Henrique examina o animal, prescreve um medicamento para o estômago e cobra pela consulta.

INSERT INTO sistema.tutores (nome, telefone, email, endereco)
VALUES ('Ana Paula Borges', '(35) 98888-1122', 'anapau.la@yahoo.com', 'Rua das Maritacas, 984 - Bairro Centro');

INSERT INTO sistema.animais (nome, especie, raca, idade, peso, id_tutor)
VALUES ('Magrelo', 'Cachorro', 'Golden Retriever', 5, 40, (select id_tutor from sistema.tutores where nome = 'Ana Paula Borges'));

INSERT INTO sistema.agenda (data_hora, id_tutor, id_funcionario, status)
VALUES ('01/04/2025  13h', (select id_tutor from sistema.tutores where nome = 'Ana Paula Borges'), 
						    (select id_funcionario from sistema.funcionarios where nome = 'Dr. Rafael Carvalho'),
		'Concluído!');
		
INSERT INTO sistema.consulta (observacoes, id_animal, id_funcionario)
VALUES ('Vômitos há 2 dias.', (select id_animal from sistema.animais where nome = 'Magrelo'),
							   (select id_funcionario from sistema.funcionarios where nome = 'Dr.Rafael Carvalho'));
							   
INSERT INTO sistema.prontuario_medico (id_animal, historico_doenca, alergias,tratamentos_andamento)
VALUES ((select id_animal from sistema.animais where nome = 'Magrelo'),
    'Thor foi atendido com episódios de vômitos persistentes nos últimos dois dias. Sem histórico prévio de doenças gastrointestinais. Alimentação regular. Nenhuma mudança recente de ração ou ambiente.',
    'Nenhuma alergia conhecida até o momento.',
    'Tratamento com antiemético (Plasil), dosagem de 1 comprimido a cada 8h por 5 dias. Acompanhamento clínico agendado para verificar resposta ao tratamento.');

INSERT INTO sistema.servico (descricao, preco)
VALUES ('Consulta geral de rotina', 'R$ 150,00');

INSERT INTO sistema.consulta_servico (id_consulta, id_servico, quantidade)
VALUES ((select id_consulta from sistema.consulta where id_animal = 9),
		(select id_servico from sistema.servico where id_servico = 6),
		'1 consulta.');

-- A tutora Sandra levou seu papagaio Louro ao hospital veterinário. A Dra. Marina realizou a avaliação e constatou uma deformidade no bico que exige tratamento corretivo. Foi prescrito suplemento de cálcio e realizado um serviço de desgaste do bico.

INSERT INTO sistema.tutores (nome, telefone, email, endereco)
VALUES ('Sandra Maria Tavares', '(21)92345-7788', 'sandra.tavares@gmail.com', 'Av. das Acácias, 45 - Bloco B');

INSERT INTO sistema.animais (nome, especie, raca, idade, peso, id_tutor)
VALUES ('Louro', 'Ave', 'Papagaio', 3, 1,
       (SELECT id_tutor FROM sistema.tutores WHERE nome = 'Sandra Maria Tavares'));
	   
INSERT INTO sistema.funcionarios (nome, funcao, telefone, salario)
VALUES ('Marina Carvalho', 'Veterinária Avícola', '(21)98888-1122', '6800.00');

INSERT INTO sistema.consulta (data_horario, observacoes, id_animal, id_funcionario)
VALUES (CURRENT_TIMESTAMP,
       'Papagaio com bico alongado e torto. Possível deficiência de cálcio. Necessário tratamento e acompanhamento.',
       (SELECT id_animal FROM sistema.animais WHERE nome = 'Louro'),
       (SELECT id_funcionario FROM sistema.funcionarios WHERE nome = 'Marina Carvalho'));
	   
INSERT INTO sistema.prontuario_medico (id_animal, historico_doenca, alergias, tratamentos_andamento)
VALUES (
  (SELECT id_animal FROM sistema.animais WHERE nome = 'Louro'),
  'Deformidade no bico observada há 2 meses. Alimentação pobre em cálcio. Não apresenta histórico de doenças anteriores.',
  'Nenhuma conhecida',
  'Desgaste periódico do bico e suplementação de cálcio via oral por 30 dias.'
);

INSERT INTO sistema.medicamentos (nome, tipo_medicamento, fabricante)
VALUES ('Avicalcio', 'Suplemento Mineral', 'BioVet');

INSERT INTO sistema.prescricao (id_consulta, id_medicamentos, dosagem, duracao_tratamento)
VALUES (
  (SELECT id_consulta FROM sistema.consulta WHERE id_animal = (SELECT id_animal FROM sistema.animais WHERE nome = 'Louro')),
  (SELECT id_medicamentos FROM sistema.medicamentos WHERE nome = 'Avicalcio'),
  '1 gota/dia',
  '30 dias'
);

INSERT INTO sistema.servico (descricao, preco)
VALUES ('Desgaste de bico com microretífica', 'R$ 120,00');

INSERT INTO sistema.consulta_servico (id_consulta, id_servico, quantidade)
VALUES (
  (SELECT id_consulta FROM sistema.consulta WHERE id_animal = (SELECT id_animal FROM sistema.animais WHERE nome = 'Louro')),
  (SELECT id_servico FROM sistema.servico WHERE descricao ILIKE '%desgaste de bico%'),
  '1 sessão'
);

INSERT INTO sistema.agenda (data_hora, id_tutor, id_funcionario, status)
VALUES (CURRENT_TIMESTAMP, (SELECT id_tutor FROM sistema.tutores WHERE nome = 'Sandra Maria Tavares'),
						   (SELECT id_funcionario FROM sistema.funcionarios WHERE nome = 'Marina Carvalho'),
'Concluído!');

-- Paulo leva sua tartaruga Tuca pois notou uma rachadura em seu casco. Dra. Renata examinou e recomendou limpeza, pomada cicatrizante e observação. Serviço de curativo aplicado e prescrição de medicamento tópicos.

INSERT INTO sistema.tutores (nome, telefone, email, endereco)
VALUES ('Paulo Henrique da Mata', '(62)91234-5566', 'paulo.h.mata@gmail.com', 'Rua das Águas, 99 - Centro');

INSERT INTO sistema.animais (nome, especie, raca, idade, peso, id_tutor)
VALUES ('Tuca', 'Réptil', 'Tartaruga Tigre-d’água', 5, 2,
       (SELECT id_tutor FROM sistema.tutores WHERE nome = 'Paulo Henrique da Mata'));
	   
INSERT INTO sistema.funcionarios (nome, funcao, telefone, salario)
VALUES ('Renata Oliveira Santos', 'Veterinária de Silvestres', '(62)99876-3344', 'R$ 7.500,00');

INSERT INTO sistema.consulta (data_horario, observacoes, id_animal, id_funcionario)
VALUES (CURRENT_TIMESTAMP,
       'Tartaruga com rachadura no casco superior. Suspeita de queda ou pancada.',
       (SELECT id_animal FROM sistema.animais WHERE nome = 'Tuca'),
       (SELECT id_funcionario FROM sistema.funcionarios WHERE nome = 'Renata Oliveira Santos'));
	   
INSERT INTO sistema.prontuario_medico (id_animal, historico_doenca, alergias, tratamentos_andamento)
VALUES (
  (SELECT id_animal FROM sistema.animais WHERE nome = 'Tuca'),
  'Casco rachado observado após tentativa de escalada. Sem histórico anterior.',
  'Nenhuma registrada',
  'Aplicação de pomada cicatrizante e troca diária de curativo por 7 dias.'
);

INSERT INTO sistema.medicamentos (nome, tipo_medicamento, fabricante)
VALUES ('Dermavet', 'Pomada Cicatrizante', 'Ceva');

INSERT INTO sistema.prescricao (id_consulta, id_medicamentos, dosagem, duracao_tratamento)
VALUES (
  (SELECT id_consulta FROM sistema.consulta WHERE id_animal = (SELECT id_animal FROM sistema.animais WHERE nome = 'Tuca')),
  (SELECT id_medicamentos FROM sistema.medicamentos WHERE nome = 'Dermavet'),
  'Aplicar 2x/dia',
  '7 dias'
);

INSERT INTO sistema.servico (descricao, preco)
VALUES ('Curativo em casco rachado', 'R$ 90,00');

INSERT INTO sistema.consulta_servico (id_consulta, id_servico, quantidade)
VALUES (
  (SELECT id_consulta FROM sistema.consulta WHERE id_animal = (SELECT id_animal FROM sistema.animais WHERE nome = 'Tuca')),
  (SELECT id_servico FROM sistema.servico WHERE descricao ILIKE '%casco rachado%'),
  '1 aplicação'
);

-----------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SELECTS COM JOINS PARA VISUALIZAÇÃO DO BANCO DE DADOS ---------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------

-- # Select Visualização - Nome do animal, nome do tutor, nome do profissional que atendeu, data e horario de atendimento, observacoes, serviço e 
-- quantidade de serviços!

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

-- # Select Visualização - Nome do animal, medicamento passado, tipo do medicamento, dosagem, duração do tratamento e o profissional que atendeu!

SELECT
    a.nome AS nome_animal,
    m.nome AS medicamento,
    m.tipo_medicamento,
    p.dosagem,
    p.duracao_tratamento,
    f.nome AS profissional
FROM sistema.prescricao p
JOIN sistema.consulta c ON p.id_consulta = c.id_consulta
JOIN sistema.animais a ON c.id_animal = a.id_animal
JOIN sistema.medicamentos m ON p.id_medicamentos = m.id_medicamentos
JOIN sistema.funcionarios f ON c.id_funcionario = f.id_funcionario
ORDER BY a.nome;

-- # Select Visualização - Agendamentos que foram feitos (data, tutor, profissional e o status do agendamento.)

SELECT
    ag.data_hora,
    t.nome AS tutor,
    f.nome AS profissional,
    ag.status
FROM sistema.agenda ag
JOIN sistema.tutores t ON ag.id_tutor = t.id_tutor
JOIN sistema.funcionarios f ON ag.id_funcionario = f.id_funcionario
ORDER BY ag.data_hora;

-- # Select Visualização - Histórico de atendimento por animais

SELECT
    a.nome AS nome_animal,
    t.nome AS tutor,
    pm.historico_doenca,
    pm.alergias,
    pm.tratamentos_andamento
FROM sistema.prontuario_medico pm
JOIN sistema.animais a ON pm.id_animal = a.id_animal
JOIN sistema.tutores t ON a.id_tutor = t.id_tutor
ORDER BY a.nome;

-- # Select Visualização - Profissional, função do profissional e o total de atendimentos.

SELECT
    f.nome AS profissional,
    f.funcao,
    COUNT(c.id_consulta) AS total_consultas
FROM sistema.consulta c
JOIN sistema.funcionarios f ON c.id_funcionario = f.id_funcionario
GROUP BY f.nome, f.funcao
ORDER BY total_consultas DESC;

-------------------------------------------------------------------------------------------------------------------------------------------------------------

ALTER TABLE sistema.animais
ALTER COLUMN raca TYPE VARCHAR(50);

update sistema.agenda
set data_hora = '20/04/2025 - 18h'
where id_tutor = 9;

select * from sistema.agenda;
select * from sistema.tutores;
select * from sistema.animais;
select * from sistema.funcionarios;
select * from sistema.prontuario_medico;
select * from sistema.medicamentos;
select * from sistema.servico;
select * from sistema.consulta;
select * from sistema.consulta_servico order by id_consulta;
select * from sistema.prescricao;
