-- Adicionar coluna para armazenar foto do operador em base64 na tabela tbusuario
-- Data: 2026-02-22

ALTER TABLE tbusuario 
ADD COLUMN foto_base64 LONGTEXT COLLATE utf8mb4_unicode_ci AFTER msg_almoco;

-- Adicionar comentário descritivo à coluna
ALTER TABLE tbusuario 
MODIFY COLUMN foto_base64 LONGTEXT COLLATE utf8mb4_unicode_ci COMMENT 'Foto do operador em formato base64 (PNG, JPG, etc)';

-- Verificar a adição
SHOW COLUMNS FROM tbusuario;
