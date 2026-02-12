CREATE DATABASE IF NOT EXISTS gestao_escolar;
USE gestao_escolar;

-- Tabela de Alunos
CREATE TABLE Alunos (
    id_aluno INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    data_nascimento DATE NOT NULL
);

-- Tabela de Disciplinas
CREATE TABLE Disciplinas (
    id_disciplina INT PRIMARY KEY AUTO_INCREMENT,
    nome_disciplina VARCHAR(50) NOT NULL
);

-- Tabela de Notas (Relaciona Aluno e Disciplina)
CREATE TABLE Notas (
    id_nota INT PRIMARY KEY AUTO_INCREMENT,
    id_aluno INT,
    id_disciplina INT,
    valor_nota DECIMAL(4,2),
    FOREIGN KEY (id_aluno) REFERENCES Alunos(id_aluno),
    FOREIGN KEY (id_disciplina) REFERENCES Disciplinas(id_disciplina)
);

-- Inserindo Dados de Teste
INSERT INTO Alunos (nome, data_nascimento) VALUES 
('Alice Silva', '2010-02-15'), 
('Arthur Santos', '2009-11-20'), 
('Beatriz Ramos', '2010-05-10'), 
('Augusto Oliveira', '2008-02-28');

INSERT INTO Disciplinas (nome_disciplina) VALUES ('História'), ('Matemática'), ('Português');

INSERT INTO Notas (id_aluno, id_disciplina, valor_nota) VALUES 
(1, 1, 8.5), (2, 1, 5.0), (3, 1, 7.0), (4, 1, 6.0), -- Notas de História
(1, 2, 9.0), (2, 2, 4.5);
-- ----------------------------------------------------------------------------------------- --

-- CONSULTA 1: Média de Notas dos Alunos em História
-- Usamos JOIN para filtrar pelo nome da disciplina e AVG para a média.
SELECT AVG(valor_nota) AS media_historia 
FROM Notas n
JOIN Disciplinas d ON n.id_disciplina = d.id_disciplina
WHERE d.nome_disciplina = 'História';

-- CONSULTA 2: Informações dos alunos cujo Nome começa com 'A'
-- O operador LIKE 'A%' busca qualquer texto que inicie com a letra A.
SELECT * FROM Alunos 
WHERE nome LIKE 'A%';

-- CONSULTA 3: Alunos que fazem aniversário em fevereiro
-- A função MONTH() extrai o mês da data. 2 representa Fevereiro.
SELECT * FROM Alunos 
WHERE MONTH(data_nascimento) = 2;

-- CONSULTA 4: Calcular a idade dos Alunos
-- TIMESTAMPDIFF calcula a diferença em anos (YEAR) entre a data de nascimento e HOJE (CURDATE).
SELECT nome, 
       TIMESTAMPDIFF(YEAR, data_nascimento, CURDATE()) AS idade 
FROM Alunos;


-- CONSULTA 5: Retornar se o aluno está aprovado (Nota >= 6)
-- A expressão CASE cria uma lógica condicional diretamente no resultado.
SELECT a.nome, n.valor_nota,
    CASE 
        WHEN n.valor_nota >= 6 THEN 'Aprovado'
        ELSE 'Reprovado'
    END AS situacao
FROM Notas n
JOIN Alunos a ON n.id_aluno = a.id_aluno;
