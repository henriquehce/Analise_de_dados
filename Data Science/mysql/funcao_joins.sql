CREATE DATABASE IF NOT EXISTS estudo_joins;
USE estudo_joins;

-- Criar tabelas
CREATE TABLE categorias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome_categoria VARCHAR(50) NOT NULL
);

CREATE TABLE produtos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100),
    id_categoria INT,
    preco DECIMAL(10,2),
    FOREIGN KEY (id_categoria) REFERENCES categorias(id)
);

CREATE TABLE promocoes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome_item VARCHAR(100),
    desconto DECIMAL(5,2)
);

-- Limpar e popular com dados estratégicos
TRUNCATE TABLE produtos;
TRUNCATE TABLE promocoes;

INSERT INTO categorias (nome_categoria) VALUES ('Bebidas'), ('Lanches'), ('Sobremesas');

INSERT INTO produtos (nome, id_categoria, preco) VALUES 
('Espresso', 1, 5.00), 
('Cappuccino', 1, 7.50), 
('Misto Quente', 2, 12.00),
('Suco de Laranja', 1, 8.00),
('Produto Sem Categoria', NULL, 10.00);

INSERT INTO promocoes (nome_item, desconto) VALUES 
('Espresso', 1.00), 
('Misto Quente', 2.50),
('Bolo de Rolo', 3.00);
-- ----------------------------------------------------------------------------------------- --
-- INNER JOIN: Somente o que tem correspondência em AMBAS (Interseção de colunas)
SELECT p.nome AS produto, c.nome_categoria AS categoria
FROM produtos p
INNER JOIN categorias c ON p.id_categoria = c.id;

-- LEFT JOIN: Mantém todos os produtos (inclusive o 'Sem Categoria')
SELECT p.nome AS produto, c.nome_categoria AS categoria
FROM produtos p
LEFT JOIN categorias c ON p.id_categoria = c.id;

-- RIGHT JOIN: Mantém todas as categorias (inclusive 'Sobremesas' que não tem produtos)
SELECT p.nome AS produto, c.nome_categoria AS categoria
FROM produtos p
RIGHT JOIN categorias c ON p.id_categoria = c.id;

-- SIMULAÇÃO DE FULL JOIN: Une o resultado do LEFT e do RIGHT
SELECT p.nome, c.nome_categoria FROM produtos p LEFT JOIN categorias c ON p.id_categoria = c.id
UNION
SELECT p.nome, c.nome_categoria FROM produtos p RIGHT JOIN categorias c ON p.id_categoria = c.id;
-- ----------------------------------------------------------------------------------------- --
-- INTERSECT: Itens que estão na lista de produtos E na de promoções
SELECT nome FROM produtos
INTERSECT
SELECT nome_item FROM promocoes;

-- EXCEPT: Itens que são produtos MAS NÃO estão em promoção
SELECT nome FROM produtos
EXCEPT
SELECT nome_item FROM promocoes;

-- SUBCONSULTA COM HAVING: Produtos de categorias onde a média de preço é maior que 6.00
SELECT nome, preco 
FROM produtos 
WHERE id_categoria IN (
    SELECT id_categoria 
    FROM produtos 
    GROUP BY id_categoria 
    HAVING AVG(preco) > 6.00
);