-- ==========================================
-- SCRIPT: Adicionar Colunas Faltantes
-- ==========================================
-- Versão: 2.0 (Compatível com MySQL 5.7+)
-- Descrição: Adiciona as colunas que o código SAW20 espera
-- ==========================================

-- A tabela tbenviomgsmassa já existe com: id, numero, status
-- Precisamos adicionar as colunas que o código SAW20 usa

-- 1. Adicionar coluna 'nome' (nome da campanha)
ALTER TABLE `tbenviomgsmassa` 
ADD COLUMN `nome` VARCHAR(255) NOT NULL DEFAULT 'Campanha' 
COMMENT 'Nome da campanha';

-- 2. Adicionar coluna 'msg' (mensagem a enviar)
ALTER TABLE `tbenviomgsmassa` 
ADD COLUMN `msg` LONGTEXT 
COMMENT 'Mensagem a ser enviada';

-- 3. Adicionar coluna 'dt_envio' (data/hora do envio)
ALTER TABLE `tbenviomgsmassa` 
ADD COLUMN `dt_envio` DATETIME NULL 
COMMENT 'Data/hora do envio';

-- 4. Adicionar coluna 'ativo' (se a campanha está ativa)
ALTER TABLE `tbenviomgsmassa` 
ADD COLUMN `ativo` TINYINT(1) DEFAULT 1 
COMMENT 'Se a campanha está ativa';

-- 5. Adicionar coluna 'created_at' (data de criação)
ALTER TABLE `tbenviomgsmassa` 
ADD COLUMN `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
COMMENT 'Data de criação';

-- 6. Adicionar coluna 'updated_at' (data da última atualização)
ALTER TABLE `tbenviomgsmassa` 
ADD COLUMN `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
ON UPDATE CURRENT_TIMESTAMP 
COMMENT 'Data da última atualização';

-- ==========================================
-- AGORA VAMOS REORGANIZAR A TABELA
-- ==========================================
-- Remover a coluna 'numero' e 'status' da tabela tbenviomgsmassa
-- porque na verdade elas devem ficar na tabela tbenviomassanumero

-- (Opcional) Se quiser remover essas colunas desta tabela:
-- ALTER TABLE `tbenviomgsmassa` DROP COLUMN IF EXISTS `numero`;
-- ALTER TABLE `tbenviomgsmassa` DROP COLUMN IF EXISTS `status`;

-- ==========================================
-- CRIAR TABELA tbenviomassanumero
-- ==========================================
-- Esta tabela relaciona os números com as campanhas

CREATE TABLE IF NOT EXISTS `tbenviomassanumero` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `id_msg` INT NOT NULL COMMENT 'Referência para a campanha',
  `numero` VARCHAR(20) NOT NULL COMMENT 'Número de telefone a enviar',
  `status` VARCHAR(50) DEFAULT 'pendente' COMMENT 'Status do envio: pendente, enviado, falha',
  `resposta` LONGTEXT NULL COMMENT 'Resposta recebida',
  `data_envio` DATETIME NULL COMMENT 'Data/hora do envio',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de criação',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data da última atualização',
  KEY `idx_id_msg` (`id_msg`),
  KEY `idx_numero` (`numero`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='Números de telefone para envio em massa';

-- Adicionar chave estrangeira (separadamente para compatibilidade)
ALTER TABLE `tbenviomassanumero` 
ADD FOREIGN KEY (`id_msg`) REFERENCES `tbenviomgsmassa`(`id`) ON DELETE CASCADE;

-- ==========================================
-- CRIAR ÍNDICES PARA PERFORMANCE
-- ==========================================

ALTER TABLE `tbenviomgsmassa` 
ADD INDEX `idx_ativo` (`ativo`);

ALTER TABLE `tbenviomgsmassa` 
ADD INDEX `idx_dt_envio` (`dt_envio`);

ALTER TABLE `tbenviomgsmassa` 
ADD INDEX `idx_ativo_dt` (`ativo`, `dt_envio`);

ALTER TABLE `tbenviomassanumero` 
ADD INDEX `idx_msg_status` (`id_msg`, `status`);

-- ==========================================
-- VERIFICAÇÃO FINAL
-- ==========================================

SELECT 'Estrutura final de tbenviomgsmassa:' AS info;
DESCRIBE tbenviomgsmassa;

SELECT 'Estrutura final de tbenviomassanumero:' AS info;
DESCRIBE tbenviomassanumero;

-- ==========================================
-- FIM DO SCRIPT
-- ==========================================
