/*******************************************************************************
 * SCRIPT DE ESTUDO DE BANCO DE DATOS - MYSQL
 * BANCO: laboratorio_ti | TABELAS: fornecedores_novo, pedidos_novo
 * OBJETIVO: Evitar conflitos e demonstrar comandos DDL, DML e DQL
 *******************************************************************************/

-- 1. DEFINIÇÃO DO AMBIENTE (DDL)
-- Cria o banco de dados do zero para garantir que não haja conflitos
CREATE DATABASE IF NOT EXISTS laboratorio_ti;
USE laboratorio_ti;

-- 2. CRIAÇÃO DAS TABELAS (DDL)
-- Tabela de Fornecedores (Entidade Independente)
CREATE TABLE fornecedores_novo (
    id_fornecedor INT AUTO_INCREMENT PRIMARY KEY,
    nome_empresa VARCHAR(100) NOT NULL,
    pais VARCHAR(50),
    email_contato VARCHAR(100),
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Pedidos (Entidade Dependente - Relacionada por FK)
CREATE TABLE pedidos_novo (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    data_pedido DATE NOT NULL,
    valor_total DECIMAL(10, 2) NOT NULL,
    status_pedido ENUM('Processando', 'Finalizado', 'Cancelado') DEFAULT 'Processando',
    fk_fornecedor INT,
    -- Definindo a Chave Estrangeira para garantir a Integridade Referencial
    CONSTRAINT fk_id_fornecedor FOREIGN KEY (fk_fornecedor) 
        REFERENCES fornecedores_novo(id_fornecedor)
        ON DELETE CASCADE -- Se o fornecedor for deletado, os pedidos também serão
);

-- 3. INSERÇÃO DE DADOS (DML)
-- Populando Fornecedores
INSERT INTO fornecedores_novo (nome_empresa, pais, email_contato) VALUES 
('Quantum Hardware', 'EUA', 'sales@quantum.com'),
('Semicondutores S.A.', 'Brasil', 'contato@semicond.com.br'),
('Tech Global', 'China', 'support@techglobal.cn');

-- Populando Pedidos (Referenciando os IDs dos fornecedores acima)
INSERT INTO pedidos_novo (data_pedido, valor_total, status_pedido, fk_fornecedor) VALUES 
('2026-02-01', 5000.00, 'Finalizado', 1),
('2026-02-05', 1250.75, 'Processando', 2),
('2026-02-08', 300.00, 'Finalizado', 1),
('2026-02-10', 9800.00, 'Processando', 3);


-- 4. MANIPULAÇÃO E ATUALIZAÇÃO (DML)
-- Alterando um registro específico
UPDATE pedidos_novo SET status_pedido = 'Finalizado' WHERE id_pedido = 2;

-- Deletando um pedido específico (ID 4)
DELETE FROM pedidos_novo WHERE id_pedido = 4;

-- 5. CONSULTAS E RELATÓRIOS (DQL)
-- Consulta Simples: Todos os fornecedores
SELECT * FROM fornecedores_novo;

-- Consulta com Filtro: Pedidos acima de R$ 1.000,00
SELECT * FROM pedidos_novo WHERE valor_total > 1000;

-- Consulta Relacional (INNER JOIN): Ver o nome do fornecedor em cada pedido
SELECT 
    P.id_pedido, 
    F.nome_empresa, 
    P.valor_total, 
    P.status_pedido
FROM pedidos_novo P
INNER JOIN fornecedores_novo F ON P.fk_fornecedor = F.id_fornecedor;

-- Agregação: Total gasto por fornecedor
SELECT 
    F.nome_empresa, 
    SUM(P.valor_total) AS total_acumulado
FROM pedidos_novo P
JOIN fornecedores_novo F ON P.fk_fornecedor = F.id_fornecedor
GROUP BY F.nome_empresa;

/*******************************************************************************
 * FIM DO SCRIPT
 *******************************************************************************/
 
 -- 1) Criação da tabela e inserção de registros
CREATE TABLE funcionarios (
    id INT PRIMARY KEY,
    nome VARCHAR(100),
    departamento VARCHAR(100),
    salario FLOAT
);

INSERT INTO funcionarios (id, nome, departamento, salario) VALUES
(1, 'Heitor Vieira', 'Financeiro', 4959.22),
(2, 'Daniel Campos', 'Vendas', 3884.44),
(3, 'Luiza Dias', 'TI', 8205.78),
(4, 'Davi Lucas Moraes', 'Financeiro', 8437.02),
(5, 'Pietro Cavalcanti', 'TI', 4946.88),
(6, 'Evelyn da Mata', 'Vendas', 5278.88),
(7, 'Isabella Rocha', 'Marketing', 4006.03),
(8, 'Sra. Manuela Azevedo', 'Vendas', 6101.88),
(9, 'Brenda Cardoso', 'TI', 8853.34),
(10, 'Danilo Souza', 'TI', 8242.14);

-- 2) Selecionar todos os registros
SELECT * FROM funcionarios;

-- 3) Funcionários de "Vendas"
SELECT nome FROM funcionarios WHERE departamento = 'Vendas';

-- 4) Funcionários com salário > 5000
SELECT * FROM funcionarios WHERE salario > 5000;

-- 5) Departamentos distintos (Unique values)
SELECT DISTINCT departamento FROM funcionarios;

-- 6) Atualizar salário do departamento de TI
-- Nota: Desative o "Safe Updates" no Workbench se der erro ou use a PK no WHERE
UPDATE funcionarios SET salario = 7500 WHERE departamento = 'TI';

-- 7) Deletar funcionários com salário < 4000
DELETE FROM funcionarios WHERE salario < 4000;

-- 8) Nomes e salários de Vendas com salário >= 6000
SELECT nome, salario FROM funcionarios 
WHERE departamento = 'Vendas' AND salario >= 6000;

-- 9) Criar tabela projetos com Chave Estrangeira (FK)
CREATE TABLE projetos (
    id_projeto INT PRIMARY KEY,
    nome_projeto VARCHAR(100),
    id_gerente INT,
    CONSTRAINT fk_gerente FOREIGN KEY (id_gerente) REFERENCES funcionarios(id)
);

-- Inserindo 3 registros (Atenção: o gerente deve existir na tabela funcionarios)
INSERT INTO projetos (id_projeto, nome_projeto, id_gerente) VALUES
(101, 'Expansão de Rede', 3),
(102, 'Novo CRM', 2), -- Note que se você deletou o ID 2 no passo 7, este comando falhará.
(103, 'Portal RH', 4);

-- Selecionar projetos do gerente ID 2
SELECT * FROM projetos WHERE id_gerente = 2;

-- 10) Remover a tabela funcionarios
-- Nota: Como há uma FK em 'projetos' apontando para 'funcionarios', 
-- você precisará remover a tabela 'projetos' primeiro ou usar DROP TABLE ... CASCADE.
DROP TABLE projetos; 
DROP TABLE funcionarios;