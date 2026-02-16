/*******************************************************************************
 * SCHEMA: desafio_alura_vendas
 * OBJETIVO: Resolver as 10 questões práticas de agregação e subconsultas.
 *******************************************************************************/

CREATE DATABASE IF NOT EXISTS desafio_alura_vendas;
USE desafio_alura_vendas;

-- 1. ESTRUTURA (DDL)
CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100)
);

CREATE TABLE categorias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome_categoria VARCHAR(50)
);

CREATE TABLE fornecedores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome_empresa VARCHAR(100)
);

CREATE TABLE produtos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100),
    preco_unitario DECIMAL(10,2),
    id_categoria INT,
    id_fornecedor INT,
    FOREIGN KEY (id_categoria) REFERENCES categorias(id),
    FOREIGN KEY (id_fornecedor) REFERENCES fornecedores(id)
);

CREATE TABLE pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT,
    data_hora_pedido DATETIME,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id)
);

CREATE TABLE itens_pedidos (
    id_pedido INT,
    id_produto INT,
    quantidade INT,
    preco_venda DECIMAL(10,2),
    PRIMARY KEY (id_pedido, id_produto),
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id),
    FOREIGN KEY (id_produto) REFERENCES produtos(id)
);

-- 2. PREENCHIMENTO (DML)
INSERT INTO clientes (nome) VALUES ('Henrique'), ('Alice'), ('Bruno'), ('Carla');
INSERT INTO categorias (nome_categoria) VALUES ('Eletrônicos'), ('Livros'), ('Culinária');
INSERT INTO fornecedores (nome_empresa) VALUES ('TechSource'), ('Livraria Central'), ('Global Foods');

INSERT INTO produtos (nome, preco_unitario, id_categoria, id_fornecedor) VALUES 
('Smartphone', 2000.00, 1, 1), 
('Cálculo I', 150.00, 2, 2), 
('Panela', 100.00, 3, 3);

-- Inserindo pedidos em anos diferentes (2021 e 2022)
INSERT INTO pedidos (id_cliente, data_hora_pedido) VALUES 
(1, '2021-05-10 10:00:00'), -- Primeiro ano disponível
(2, '2022-03-15 14:00:00'), 
(3, '2022-07-20 16:00:00');

INSERT INTO itens_pedidos (id_pedido, id_produto, quantidade, preco_venda) VALUES 
(1, 1, 2, 2000.00), -- Venda em 2021 (TechSource)
(2, 2, 10, 150.00), -- Venda em 2022 (Livros)
(3, 3, 5, 100.00);   -- Venda em 2022 (Culinária)

-- 3. RESOLUÇÃO DAS ATIVIDADES (DQL)

-- 01: Número de Clientes
SELECT COUNT(*) AS total_clientes FROM clientes;

-- 02: Quantos produtos foram vendidos no ano de 2022?
-- Usamos SUM(quantidade) para totalizar os itens saídos.
SELECT SUM(quantidade) AS total_produtos_2022 
FROM itens_pedidos ip
JOIN pedidos p ON ip.id_pedido = p.id
WHERE YEAR(p.data_hora_pedido) = 2022;

-- 03: Qual a categoria que mais vendeu em 2022?
-- Agrupamos por categoria e ordenamos pelo volume de vendas.
SELECT c.nome_categoria, SUM(ip.quantidade) AS qtd_vendida
FROM itens_pedidos ip
JOIN pedidos p ON ip.id_pedido = p.id
JOIN produtos pr ON ip.id_produto = pr.id
JOIN categorias c ON pr.id_categoria = c.id
WHERE YEAR(p.data_hora_pedido) = 2022
GROUP BY c.nome_categoria
ORDER BY qtd_vendida DESC LIMIT 1;

-- 04: Qual o primeiro ano disponível na base?
SELECT MIN(YEAR(data_hora_pedido)) AS primeiro_ano FROM pedidos;

-- 05: Nome do fornecedor que mais vendeu no primeiro ano
-- 06: Quanto ele vendeu no primeiro ano?
-- Unificamos 05 e 06 usando subconsulta para achar o primeiro ano.
SELECT f.nome_empresa, SUM(ip.quantidade * ip.preco_venda) AS faturamento
FROM itens_pedidos ip
JOIN pedidos p ON ip.id_pedido = p.id
JOIN produtos pr ON ip.id_produto = pr.id
JOIN fornecedores f ON pr.id_fornecedor = f.id
WHERE YEAR(p.data_hora_pedido) = (SELECT MIN(YEAR(data_hora_pedido)) FROM pedidos)
GROUP BY f.nome_empresa
ORDER BY faturamento DESC LIMIT 1;

-- 07: As duas categorias que mais venderam no total (todos os anos)
SELECT c.nome_categoria, SUM(ip.quantidade * ip.preco_venda) AS total_hist
FROM itens_pedidos ip
JOIN produtos pr ON ip.id_produto = pr.id
JOIN categorias c ON pr.id_categoria = c.id
GROUP BY c.nome_categoria
ORDER BY total_hist DESC LIMIT 2;

-- 08: Comparativo de vendas ao longo do tempo (Top 2 Categorias)
-- Usamos subconsulta no IN para filtrar as 2 maiores categorias.
SELECT YEAR(p.data_hora_pedido) AS ano, c.nome_categoria, SUM(ip.quantidade * ip.preco_venda) AS vendas
FROM itens_pedidos ip
JOIN pedidos p ON ip.id_pedido = p.id
JOIN produtos pr ON ip.id_produto = pr.id
JOIN categorias c ON pr.id_categoria = c.id
WHERE c.nome_categoria IN (
    SELECT nome_cat FROM (
        SELECT c2.nome_categoria AS nome_cat FROM itens_pedidos ip2 
        JOIN produtos pr2 ON ip2.id_produto = pr2.id 
        JOIN categorias c2 ON pr2.id_categoria = c2.id 
        GROUP BY c2.nome_categoria ORDER BY SUM(ip2.quantidade * ip2.preco_venda) DESC LIMIT 2
    ) AS sub
)
GROUP BY ano, c.nome_categoria ORDER BY ano;

-- 09: Porcentagem de vendas por categorias no ano de 2022
-- Calculamos a soma individual e dividimos pela soma total de 2022.
SELECT c.nome_categoria, 
       ROUND((SUM(ip.quantidade * ip.preco_venda) / 
       (SELECT SUM(ip2.quantidade * ip2.preco_venda) FROM itens_pedidos ip2 JOIN pedidos p2 ON ip2.id_pedido = p2.id WHERE YEAR(p2.data_hora_pedido) = 2022)) * 100, 2) AS percentual
FROM itens_pedidos ip
JOIN pedidos p ON ip.id_pedido = p.id
JOIN produtos pr ON ip.id_produto = pr.id
JOIN categorias c ON pr.id_categoria = c.id
WHERE YEAR(p.data_hora_pedido) = 2022
GROUP BY c.nome_categoria;

-- 10: Porcentagem a mais que a melhor categoria tem em relação à pior (2022)
-- Usamos CTE (Common Table Expression) para facilitar o cálculo final.
WITH Vendas_2022 AS (
    SELECT c.nome_categoria, SUM(ip.quantidade * ip.preco_venda) AS total
    FROM itens_pedidos ip
    JOIN pedidos p ON ip.id_pedido = p.id
    JOIN produtos pr ON ip.id_produto = pr.id
    JOIN categorias c ON pr.id_categoria = c.id
    WHERE YEAR(p.data_hora_pedido) = 2022
    GROUP BY c.nome_categoria
)
SELECT 
    ROUND(((MAX(total) - MIN(total)) / MIN(total)) * 100, 2) AS porcentagem_a_mais
FROM Vendas_2022;