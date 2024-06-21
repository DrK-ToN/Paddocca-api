-- Limpar tabelas existentes
DROP TABLE IF EXISTS log_operacoes;
DROP TABLE IF EXISTS entregador;
DROP TABLE IF EXISTS cliente;
DROP TABLE IF EXISTS fornecedor;
DROP TABLE IF EXISTS usuario;

###############################################

-- Criar tabela de log
CREATE TABLE log_operacoes (
  id SERIAL PRIMARY KEY,
  tabela VARCHAR(50) NOT NULL,
  operacao VARCHAR(10) NOT NULL,
  registro JSONB,
  data TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Criar tabela usuario
CREATE TABLE usuario (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  senha VARCHAR(255) NOT NULL,
  endereco VARCHAR(255) NOT NULL,
  telefone INT
);

-- Criar tabela fornecedor
CREATE TABLE fornecedor (
  id_usuario INTEGER PRIMARY KEY REFERENCES usuario(id),
  cnpj VARCHAR(20) NOT NULL
);

-- Criar tabela cliente
CREATE TABLE cliente (
  id_usuario INTEGER PRIMARY KEY REFERENCES usuario(id),
  cpf VARCHAR(11) NOT NULL,
  data_nasc DATE NOT NULL
);

-- Criar tabela entregador
CREATE TABLE entregador (
  id_usuario INTEGER PRIMARY KEY REFERENCES usuario(id),
  data_nasc DATE NOT NULL,
  cpf VARCHAR(11) NOT NULL,
  cnh VARCHAR(20) NOT NULL,
  veiculo VARCHAR(255) NOT NULL,
  placa VARCHAR(10)
);

###############################################
	
-- Consultar registros no log
SELECT * FROM log_operacoes;
-- Verificar dados na tabela usuario
SELECT * FROM usuario;
-- Verificar dados na tabela fornecedor
SELECT * FROM fornecedor;
-- Verificar dados na tabela cliente
SELECT * FROM cliente;
-- Verificar dados na tabela entregador
SELECT * FROM entregador;

###############################################

-- Função para registrar INSERT
CREATE OR REPLACE FUNCTION log_insert()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO log_operacoes (tabela, operacao, registro)
  VALUES (TG_TABLE_NAME, 'INSERT', row_to_json(NEW));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Função para registrar UPDATE
CREATE OR REPLACE FUNCTION log_update() 
RETURNS TRIGGER AS $$
BEGIN
  IF OLD IS DISTINCT FROM NEW THEN
    INSERT INTO log_operacoes (tabela, operacao, registro)
    VALUES (TG_TABLE_NAME, 'UPDATE', row_to_json(NEW));
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Função para registrar DELETE
CREATE OR REPLACE FUNCTION log_delete()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO log_operacoes (tabela, operacao, registro)
  VALUES (TG_TABLE_NAME, 'DELETE', row_to_json(OLD));
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

###############################################

-- Trigger para INSERT na tabela usuario
CREATE TRIGGER trg_usuario_insert
AFTER INSERT ON usuario
FOR EACH ROW
EXECUTE FUNCTION log_insert();

-- Trigger para UPDATE na tabela usuario
CREATE TRIGGER trg_usuario_update
AFTER UPDATE ON usuario
FOR EACH ROW
EXECUTE FUNCTION log_update();

-- Trigger para DELETE na tabela usuario
CREATE TRIGGER trg_usuario_delete
AFTER DELETE ON usuario
FOR EACH ROW
EXECUTE FUNCTION log_delete();

###############################################

/*
DROP TRIGGER trg_usuario_insert ON usuario;
DROP TRIGGER trg_usuario_update ON usuario;
DROP TRIGGER trg_usuario_delete ON usuario;*/

-- Inserir dados nas tabelas usando PL/pgSQL
DO
$$
DECLARE
  novo_usuario_id INTEGER;
BEGIN
  -- Inserir dados na tabela usuario e obter o id
  INSERT INTO usuario (nome, email, senha, endereco, telefone)
  VALUES ('Padaria da Maria', 'padamaria@email.com', '123', 'Endereço do Fornecedor', 113456789)
  RETURNING id INTO novo_usuario_id;

  -- Inserir dados na tabela fornecedor usando o id retornado
  INSERT INTO fornecedor (id_usuario, cnpj)
  VALUES (novo_usuario_id, '12.345.678/0001-99');

  -- Inserir dados na tabela usuario e obter o id
  INSERT INTO usuario (nome, email, senha, endereco, telefone)
  VALUES ('João Cliente', 'jocli@email.com', '321', 'Endereço do Cliente', 114567892)
  RETURNING id INTO novo_usuario_id;

  -- Inserir dados na tabela cliente usando o id retornado
  INSERT INTO cliente (id_usuario, cpf, data_nasc)
  VALUES (novo_usuario_id, '12345678911', '1998-08-28');

-- Inserir dados na tabela usuario e obter o id
  INSERT INTO usuario (nome, email, senha, endereco, telefone)
  VALUES ('Paulo Fregues', 'pafre@email.com', '213', 'Endereço do Cliente, 2', 1167891234)
  RETURNING id INTO novo_usuario_id;

  -- Inserir dados na tabela cliente usando o id retornado
  INSERT INTO cliente (id_usuario, cpf, data_nasc)
  VALUES (novo_usuario_id, '45612378944', '1985-03-30');

  -- Inserir dados na tabela usuario e obter o id
  INSERT INTO usuario (nome, email, senha, endereco, telefone)
  VALUES ('Zé Entrega', 'zefast@email.com', '231', 'Endereço do Entregador', 115678912)
  RETURNING id INTO novo_usuario_id;

  -- Inserir dados na tabela entregador usando o id retornado
  INSERT INTO entregador (id_usuario, data_nasc, cpf, cnh, veiculo, placa)
  VALUES (novo_usuario_id, '2012-02-22', '98765432199', '123456', 'Moto', 'zzz1234');

END
$$;

###############################################

 -- Atualizar os endereços dos usuarios
BEGIN
  UPDATE usuario SET endereco = 'Rua dos Fornecedores, 123' WHERE id = 1;
  UPDATE usuario SET endereco = 'Rua dos Clientes, 321' WHERE id = 2;
  UPDATE usuario SET endereco = 'Rua dos Clientes, 213' WHERE id = 3;
  UPDATE usuario SET endereco = 'Rua dos Entregadores, 231' WHERE id = 4;

COMMIT

 -- Deletar usuario
BEGIN

  DELETE FROM cliente WHERE id_usuario = 4;
  DELETE FROM usuario WHERE id = 4;
	
COMMIT

####################################################
	
-- left join
SELECT * FROM usuario
LEFT JOIN fornecedor ON
usuario.id = fornecedor.id_usuario;

--right join
SELECT * FROM fornecedor
RIGHT JOIN usuario ON
fornecedor.id_usuario = usuario.id;

--inner join
SELECT * FROM usuario
INNER JOIN fornecedor ON
usuario.id = fornecedor.id_usuario;

-- cross join
SELECT * FROM usuario
CROSS JOIN fornecedor;

-- outer join
SELECT * FROM usuario
FULL OUTER JOIN fornecedor ON
usuario.id = fornecedor.id_usuario;