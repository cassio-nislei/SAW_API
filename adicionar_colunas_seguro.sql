-- ==========================================
-- SCRIPT: Adicionar Colunas (Seguro - Sem Perder Dados)
-- ==========================================
-- Versão: 1.0
-- Descrição: Adiciona apenas as colunas faltantes sem remover dados
-- Use este script se tiver dados valiosos que não quer perder
-- ==========================================

-- ==========================================
-- ETAPA 1: Diagnosticar estrutura atual
-- ==========================================
SELECT 'Estrutura ATUAL de tbenviomgsmassa' AS info;
DESCRIBE tbenviomgsmassa;

-- ==========================================
-- ETAPA 2: Adicionar colunas faltantes
-- ==========================================

-- Se der erro "Duplicate column name", a coluna já existe - é normal!
ALTER TABLE `tbenviomgsmassa` ADD COLUMN `nome` VARCHAR(255) DEFAULT 'Campanha';
ALTER TABLE `tbenviomgsmassa` ADD COLUMN `msg` LONGTEXT;
ALTER TABLE `tbenviomgsmassa` ADD COLUMN `dt_envio` DATETIME NULL;
ALTER TABLE `tbenviomgsmassa` ADD COLUMN `ativo` TINYINT(1) DEFAULT 1;
ALTER TABLE `tbenviomgsmassa` ADD COLUMN `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE `tbenviomgsmassa` ADD COLUMN `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

-- ==========================================
-- ETAPA 3: Criar tabela tbenviomassanumero SE NÃO EXISTIR
-- ==========================================
-- IMPORTANTE: Este script preserva qualquer tabela existente
-- Se tbenviomassanumero já existe, nada acontece

CREATE TABLE IF NOT EXISTS `tbenviomassanumero` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `id_msg` INT NOT NULL,
  `numero` VARCHAR(20) NOT NULL,
  `status` INT DEFAULT 0,
  `resposta` LONGTEXT NULL,
  `data_envio` DATETIME NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY `idx_id_msg` (`id_msg`),
  KEY `idx_numero` (`numero`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- ETAPA 4: Tentar adicionar chave estrangeira
-- ==========================================
-- Se der erro "Constraint already exists", é porque já foi adicionada antes

-- Nota: Este comando pode falhar se a FK já existe ou se há dados incompatíveis
-- É seguro tentar, pior que pode acontecer é receber um erro
ALTER TABLE `tbenviomassanumero` 
ADD CONSTRAINT `fk_tbenviomassanumero_id_msg` FOREIGN KEY (`id_msg`) 
REFERENCES `tbenviomgsmassa`(`id`) 
ON DELETE CASCADE;

-- ==========================================
-- ETAPA 5: Criar índices
-- ==========================================
-- Se der erro "Duplicate key name", o índice já existe - é normal!

ALTER TABLE `tbenviomgsmassa` ADD INDEX `idx_ativo` (`ativo`);
ALTER TABLE `tbenviomgsmassa` ADD INDEX `idx_dt_envio` (`dt_envio`);
ALTER TABLE `tbenviomassanumero` ADD INDEX `idx_msg_status` (`id_msg`, `status`);

-- ==========================================
-- ETAPA 6: Verificar estrutura final
-- ==========================================

SELECT 'Estrutura FINAL de tbenviomgsmassa' AS info;
DESCRIBE tbenviomgsmassa;

SELECT 'Estrutura FINAL de tbenviomassanumero' AS info;
DESCRIBE tbenviomassanumero;

SELECT 'Registros em tbenviomgsmassa' AS info, COUNT(*) as total FROM tbenviomgsmassa;
SELECT 'Registros em tbenviomassanumero' AS info, COUNT(*) as total FROM tbenviomassanumero;

-- ==========================================
-- FIM DO SCRIPT
-- ==========================================
-- NOTAS:
-- 1. Se receber erros, é normal - pode significar que já foi executado antes
-- 2. Erros aceitos: "Duplicate column name", "Duplicate key name", "Constraint already exists"
-- 3. Se receber outros erros, salve-os e compartilhe para diagnóstico
-- ==========================================
