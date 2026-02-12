CREATE DATABASE IF NOT EXISTS sistema_automacao;
USE sistema_automacao;

-- Tabela de Produtos (Base)
CREATE TABLE produtos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100),
    preco DECIMAL(10,2),
    estoque INT DEFAULT 0
);

-- Tabela de Log (Para auditoria via Trigger)
CREATE TABLE log_movimentacao (
    id INT PRIMARY KEY AUTO_INCREMENT,
    mensagem VARCHAR(255),
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Inserindo dados iniciais
INSERT INTO produtos (nome, preco, estoque) VALUES 
('Teclado Mecânico', 250.00, 10),
('Mouse Gamer', 120.00, 15),
('Monitor 144hz', 1100.00, 5);

-- Criando a VIEW
CREATE VIEW vw_estoque_critico AS
SELECT nome, estoque 
FROM produtos 
WHERE estoque < 10;

-- Consultando a VIEW
SELECT * FROM vw_estoque_critico;

-- Mudamos o delimitador para o MySQL não confundir o ";" interno da Trigger
DELIMITER //

CREATE TRIGGER tr_audit_novo_produto
AFTER INSERT ON produtos
FOR EACH ROW
BEGIN
    -- 'NEW' refere-se aos dados que acabaram de ser inseridos
    INSERT INTO log_movimentacao (mensagem) 
    VALUES (CONCAT('NOVO ITEM ADICIONADO: ', NEW.nome, ' com estoque de ', NEW.estoque));
END; //

DELIMITER //

-- 1. TRIGGER PARA EDIÇÃO (UPDATE)
-- Acionada sempre que um valor for alterado na tabela produtos
CREATE TRIGGER tr_audit_alterar_produto
AFTER UPDATE ON produtos
FOR EACH ROW
BEGIN
    INSERT INTO log_movimentacao (mensagem) 
    VALUES (CONCAT('PRODUTO ALTERADO: ', OLD.nome, 
                   ' | Preço Antigo: ', OLD.preco, ' -> Novo: ', NEW.preco,
                   ' | Estoque Antigo: ', OLD.estoque, ' -> Novo: ', NEW.estoque));
END; //

-- 2. TRIGGER PARA EXCLUSÃO (DELETE)
-- Acionada sempre que um item for removido da tabela produtos
CREATE TRIGGER tr_audit_excluir_produto
AFTER DELETE ON produtos
FOR EACH ROW
BEGIN
    INSERT INTO log_movimentacao (mensagem) 
    VALUES (CONCAT('PRODUTO REMOVIDO: ', OLD.nome, ' (ID: ', OLD.id, ')'));
END; //

DELIMITER ;

DELIMITER ;

-- 1. Inserir um produto
INSERT INTO produtos (nome, preco, estoque) VALUES ('Webcam Full HD', 350.00, 3);

-- 2. Verificar se a Trigger funcionou (Olhe a tabela de logs!)
SELECT * FROM log_movimentacao;

-- 3. Verificar se o produto já aparece na nossa VIEW de estoque crítico
SELECT * FROM vw_estoque_critico;
-- ------------------------------------------------------------------------------------------ --
-- UPDATE: Alterando o preço de um produto específico
-- Sempre use WHERE para não alterar a tabela inteira!
UPDATE produtos 
SET preco = 280.00 
WHERE nome = 'Teclado Mecânico';

-- 1. Inicia o bloco transacional
START TRANSACTION;

-- 2. Atualiza o preço e o estoque de um item existente
UPDATE produtos 
SET preco = 1150.00, estoque = 8 
WHERE nome = 'Monitor 144hz';

-- 3. Registra manualmente a ação no log (além da Trigger automática)
INSERT INTO log_movimentacao (mensagem) 
VALUES ('Monitor 144hz atualizado para novo preço e estoque.');

-- 4. Confirma as alterações permanentemente no disco
COMMIT;

-- Verifique que as alterações persistem
SELECT * FROM produtos WHERE nome = 'Monitor 144hz';
-- --------------------------
-- 1. Inicia nova transação
START TRANSACTION;

-- 2. Tenta deletar todos os produtos (Erro comum: esquecer o WHERE)
DELETE FROM produtos; 

-- 3. Percebeu o erro? O comando ROLLBACK desfaz tudo o que foi feito desde o START
ROLLBACK;

-- Verifique que seus produtos AINDA ESTÃO LÁ
SELECT * FROM produtos;

-- --------------------------
START TRANSACTION;

-- Ao inserir este produto, a Trigger 'tr_audit_novo_produto' é acionada internamente
INSERT INTO produtos (nome, preco, estoque) VALUES ('Fone Bluetooth', 150.00, 2);

-- Verificamos que ele apareceu na VIEW e no LOG dentro da transação
SELECT * FROM vw_estoque_critico;
SELECT * FROM log_movimentacao;

-- Se dermos ROLLBACK agora, o produto some da tabela, o log some da tabela de logs 
-- e a VIEW para de mostrá-lo. É o princípio da Atomicidade.
ROLLBACK;

-- Atualizando o preço e o estoque simultaneamente
UPDATE produtos 
SET preco = 280.00, estoque = 12
WHERE nome = 'Teclado Mecânico';

-- Exemplo de exclusão simples
DELETE FROM produtos WHERE id = 4;

-- Exemplo de lógica CASCADE (Exige que a FK tenha sido criada com ON DELETE CASCADE)
-- Se excluirmos um cliente, todos os seus pedidos vinculados seriam deletados automaticamente.
-- DELETE FROM clientes WHERE id = 1;
-- ----------------------------------------------------
-- TESTE DE UPDATE COM COMMIT
START TRANSACTION;
UPDATE produtos SET preco = 300.00 WHERE nome = 'Teclado Mecânico';
COMMIT; -- Salva a alteração e o log gerado pela trigger

-- TESTE DE DELETE COM ROLLBACK (Segurança)
START TRANSACTION;
DELETE FROM produtos WHERE nome = 'Mouse Gamer';
-- Se você consultar agora, o mouse sumiu e o log foi gerado.
SELECT * FROM log_movimentacao; 
ROLLBACK; -- Desfaz a exclusão E apaga o log automático da trigger!

-- Verificação final
SELECT * FROM produtos; -- O Mouse Gamer continua aqui
SELECT * FROM log_movimentacao; -- O log de remoção foi descartado pelo rollback