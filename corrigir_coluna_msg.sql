-- ==========================================
-- SCRIPT: Corrigir Coluna 'mensagem'
-- ==========================================
-- A tabela tem 2 colunas de mensagem:
-- 1. 'mensagem' (text, NOT NULL, SEM DEFAULT) - PROBLEMA
-- 2. 'msg' (longtext, NULL) - OK
-- 
-- Solução: Permitir NULL ou adicionar DEFAULT na coluna 'mensagem'

-- Modificar coluna 'mensagem' para permitir NULL com DEFAULT value
ALTER TABLE `tbenviomgsmassa` 
MODIFY COLUMN `mensagem` TEXT NULL DEFAULT NULL;

-- Verificar estrutura
SELECT 'Estrutura corrigida de tbenviomgsmassa' AS info;
DESCRIBE tbenviomgsmassa;
