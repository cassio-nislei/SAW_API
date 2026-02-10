-- ==========================================
-- SCRIPT: Adicionar Colunas Faltantes
-- ==========================================
-- Addiona as colunas que o código SAW20 espera

-- ==========================================
-- TABELA: tbenviomgsmassa
-- ==========================================

-- Coluna 'canal' já existe, pulamos
-- ALTER TABLE `tbenviomgsmassa` 
-- ADD COLUMN `canal` INT DEFAULT 1 COMMENT 'Canal de comunicação';

-- Coluna 'dt_inclusao' já existe, pulamos
-- ALTER TABLE `tbenviomgsmassa` 
-- ADD COLUMN `dt_inclusao` DATE COMMENT 'Data de inclusão';

-- Coluna 'tipo_mensagem' já existe, pulamos
-- ALTER TABLE `tbenviomgsmassa` 
-- ADD COLUMN `tipo_mensagem` INT DEFAULT 2 COMMENT 'Tipo da mensagem';

-- ==========================================
-- TABELA: tbenviomassanumero
-- ==========================================

-- Coluna 'canal' já existe, pulamos
-- ALTER TABLE `tbenviomassanumero` 
-- ADD COLUMN `canal` INT DEFAULT 1 COMMENT 'Canal de comunicação';

ALTER TABLE `tbenviomassanumero` 
ADD COLUMN `nome` VARCHAR(255) COMMENT 'Nome do contato';

ALTER TABLE `tbenviomassanumero` 
ADD COLUMN `enviada` TINYINT(1) DEFAULT 0 COMMENT 'Se foi enviada';

-- ==========================================
-- Verificar estrutura final
-- ==========================================

SELECT 'Estrutura FINAL de tbenviomgsmassa' AS info;
DESCRIBE tbenviomgsmassa;

SELECT 'Estrutura FINAL de tbenviomassanumero' AS info;
DESCRIBE tbenviomassanumero;

-- ==========================================
-- FIM DO SCRIPT
-- ==========================================
