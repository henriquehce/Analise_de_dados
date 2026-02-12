CREATE DATABASE IF NOT EXISTS sistema_integrado_rh;
USE sistema_integrado_rh;

-- Tabela Pai: Colaboradores
CREATE TABLE Colaboradores (
    id_colaborador INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    data_nascimento DATE NOT NULL,
    departamento VARCHAR(50),
    salario DECIMAL(10, 2)
);

-- Tabela Filha: Treinamentos (Relacionamento 1:N)
CREATE TABLE Treinamentos (
    id_treinamento INT PRIMARY KEY AUTO_INCREMENT,
    id_colaborador INT,
    curso VARCHAR(100),
    data_conclusao DATE,
    valor_investido DECIMAL(10, 2),
    CONSTRAINT fk_colab_treino FOREIGN KEY (id_colaborador) 
        REFERENCES Colaboradores(id_colaborador) ON DELETE CASCADE
);

-- Tabela Independente: Faturamento Mensal
CREATE TABLE Faturamento (
    id_faturamento INT PRIMARY KEY AUTO_INCREMENT,
    mes_referencia VARCHAR(20),
    valor_bruto DECIMAL(15, 2),
    despesas DECIMAL(15, 2)
);

-- INSERÇÃO DE DADOS PARA TESTE
INSERT INTO Colaboradores (nome, data_nascimento, departamento, salario) VALUES 
('Henrique Cipriani', '2000-05-15', 'TI', 8500.50),
('Alice Silva', '1995-03-20', 'RH', 5200.00),
('Bruno Souza', '1988-10-10', 'TI', 7100.00),
('Carla Dias', '2001-02-12', 'Vendas', 3900.00);

INSERT INTO Treinamentos (id_colaborador, curso, data_conclusao, valor_investido) VALUES 
(1, 'MySQL Masterclass', '2026-01-10', 1500.75),
(1, 'Python para Dados', '2026-02-01', 1200.40),
(2, 'Gestão de Pessoas', '2025-12-15', 800.00),
(3, 'Segurança da Informação', '2026-01-20', 2100.99);

INSERT INTO Faturamento (mes_referencia, valor_bruto, despesas) VALUES 
('Janeiro 2026', 150000.00, 45000.50),
('Fevereiro 2026', 165000.00, 48000.75);
