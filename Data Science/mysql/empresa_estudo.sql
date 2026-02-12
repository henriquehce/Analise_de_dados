-- Criando um banco de dados específico para os exercícios
CREATE DATABASE IF NOT EXISTS exercicios_estudo;
USE exercicios_estudo;

-- Criação da tabela de Clientes
CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    primeiro_nome VARCHAR(50),
    ultimo_nome VARCHAR(50),
    nome VARCHAR(100) -- Coluna para o exercício 1
);

-- Criação da tabela de Produtos
CREATE TABLE produtos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome_produto VARCHAR(100),
    descricao TEXT
);

-- Criação da tabela de Funcionários
CREATE TABLE funcionarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100),
    departamento VARCHAR(100),
    salario FLOAT,
    data_nasc DATE
);

-- Criação da tabela de Vendas e Pedidos
CREATE TABLE vendas (
    id_venda INT PRIMARY KEY AUTO_INCREMENT,
    data_venda DATE
);

CREATE TABLE pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    preco_total DECIMAL(10,2)
);

-- Criação da tabela de Eventos e Avaliações
CREATE TABLE eventos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    data_string VARCHAR(20)
);

CREATE TABLE avaliacoes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    pontuacao INT
);

-- POPULANDO DADOS (Exemplos rápidos para teste)
INSERT INTO clientes (primeiro_nome, ultimo_nome, nome) VALUES ('Henrique', 'Cipriani', 'Henrique Cipriani'), ('Alice', 'Silva', 'Alice Silva'), ('Bruno', 'Souza', 'Bruno Souza'), ('Carla', 'Dias', 'Carla Dias'), ('Daniel', 'Ohara', 'Daniel Ohara'), ('Eduarda', 'Lima', 'Eduarda Lima');
INSERT INTO produtos (nome_produto, descricao) VALUES ('Teclado', 'Mecânico RGB'), ('Mouse', NULL), ('Monitor', '144Hz');
INSERT INTO funcionarios (nome, departamento, salario, data_nasc) VALUES ('Arnaldo Rodrigues', 'Vendas', 6000, '1992-05-10'), ('Beatriz Silva', 'TI', 7500, '1995-03-20'), ('Carlos Santos', 'Vendas', 4000, '1988-10-15');
INSERT INTO vendas (data_venda) VALUES ('2026-01-10'), ('2025-12-25');
INSERT INTO pedidos (preco_total) VALUES (150.75), (99.40), (250.99);
INSERT INTO eventos (data_string) VALUES ('2023-05-15'), ('2022-12-01');
INSERT INTO avaliacoes (pontuacao) VALUES (2), (5), (9);
-- --------------------------------------------------------------------------------------------- --

-- 1) Selecione os primeiros 5 registros da tabela clientes, ordenando pelo nome em ordem crescente.
SELECT * FROM clientes ORDER BY nome ASC LIMIT 5;

-- 2) Encontre todos os produtos na tabela produtos que não têm uma descrição associada.
SELECT * FROM produtos WHERE descricao IS NULL;

-- 3) Liste os funcionários cujo nome começa com 'A' e termina com 's' na tabela funcionarios.
-- O % representa qualquer quantidade de caracteres no meio.
SELECT * FROM funcionarios WHERE nome LIKE 'A%s';

-- 4) Exiba o departamento e a média salarial agrupada, apenas para médias superiores a $5000.
-- HAVING é usado porque o filtro ocorre após o cálculo da média (agregação).
SELECT departamento, AVG(salario) AS media_salarial 
FROM funcionarios 
GROUP BY departamento 
HAVING media_salarial > 5000;

-- 5) Selecione clientes, concatene primeiro e último nome e calcule o comprimento total do nome completo.
SELECT 
    CONCAT(primeiro_nome, ' ', ultimo_nome) AS nome_completo,
    LENGTH(CONCAT(primeiro_nome, ultimo_nome)) AS comprimento_total 
FROM clientes;

-- 6) Para cada venda, exiba o ID, a data e a diferença em dias entre a data da venda e a data atual.
SELECT id_venda, data_venda, DATEDIFF(CURDATE(), data_venda) AS dias_passados FROM vendas;

-- 7) Selecione todos os itens da tabela pedidos e arredonde o preço total para o número inteiro mais próximo.
SELECT *, ROUND(preco_total) AS preco_inteiro FROM pedidos;

-- 8) Converta a coluna data_string (texto) para tipo data e selecione eventos após '2023-01-01'.
SELECT * FROM eventos WHERE STR_TO_DATE(data_string, '%Y-%m-%d') > '2023-01-01';

-- 9) Classifique cada avaliação como 'Boa', 'Média', ou 'Ruim' com base na pontuação (1-3, 4-7, 8-10).
SELECT *,
    CASE 
        WHEN pontuacao BETWEEN 1 AND 3 THEN 'Ruim'
        WHEN pontuacao BETWEEN 4 AND 7 THEN 'Média'
        WHEN pontuacao BETWEEN 8 AND 10 THEN 'Boa'
    END AS classificacao
FROM avaliacoes;

-- 10) Altere o nome da coluna data_nasc para data_nascimento e selecione nascidos após '1990-01-01'.
ALTER TABLE funcionarios RENAME COLUMN data_nasc TO data_nascimento;
SELECT * FROM funcionarios WHERE data_nascimento > '1990-01-01';
