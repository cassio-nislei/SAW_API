-- MySQL Initialization Script for SAW API
-- Este arquivo é executado automaticamente ao iniciar o container MySQL

-- Garantir que a database está criada com a codificação correta
CREATE DATABASE IF NOT EXISTS saw15 
  CHARACTER SET utf8mb4 
  COLLATE utf8mb4_unicode_ci;

-- Selecionar a database
USE saw15;

-- Configurar sql_mode para evitar erros de GROUP BY
SET GLOBAL sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
SET SESSION sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- Criar usuário se não existir
CREATE USER IF NOT EXISTS 'saw_user'@'%' IDENTIFIED BY 'Ncm@647534';

-- Dar todas as permissões
GRANT ALL PRIVILEGES ON saw15.* TO 'saw_user'@'%';
GRANT ALL PRIVILEGES ON saw15.* TO 'saw_user'@'localhost';
GRANT SUPER ON *.* TO 'saw_user'@'%';

-- Flush privileges para aplicar
FLUSH PRIVILEGES;

-- Definir max_connections e outras variáveis
SET GLOBAL max_connections=1000;
SET GLOBAL max_allowed_packet=256*1024*1024;

-- Log
SELECT 'SAW API Database initialized successfully' as Status;
