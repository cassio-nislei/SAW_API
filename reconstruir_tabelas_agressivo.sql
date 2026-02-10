-- ==========================================
-- SCRIPT: Reconstruir Tabelas (Agressivo)
-- ==========================================
-- Versão: 1.0 (APENAS USE ESTE SE NADA MAIS FUNCIONAR)
-- Descrição: Remove E recria as tabelas do zero
-- AVISO: Isso DELETARÁ todos os dados existentes!
-- ==========================================

-- ==========================================
-- ETAPA 1: Fazer backup dos dados (IMPORTANTE!)
-- ==========================================
-- Antes de executar, salve seus dados!

CREATE TABLE IF NOT EXISTS `backup_tbenviomgsmassa` AS SELECT * FROM `tbenviomgsmassa`;
CREATE TABLE IF NOT EXISTS `backup_tbenviomassanumero` AS SELECT * FROM `tbenviomassanumero`;

SELECT 'Backup criado em backup_tbenviomgsmassa' AS info;
SELECT 'Backup criado em backup_tbenviomassanumero' AS info;

-- ==========================================
-- ETAPA 2: Remover tabelas antigas
-- ==========================================

DROP TABLE IF EXISTS `tbenviomassanumero`;
DROP TABLE IF EXISTS `tbenviomgsmassa`;

-- ==========================================
-- ETAPA 3: Recriar tabela tbenviomgsmassa
-- ==========================================

CREATE TABLE `tbenviomgsmassa` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `nome` VARCHAR(255) NOT NULL DEFAULT 'Campanha' COMMENT 'Nome da campanha',
  `msg` LONGTEXT COMMENT 'Mensagem a ser enviada',
  `dt_envio` DATETIME NULL COMMENT 'Data/hora do envio',
  `ativo` TINYINT(1) DEFAULT 1 COMMENT 'Se a campanha está ativa',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de criação',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data da última atualização',
  KEY `idx_ativo` (`ativo`),
  KEY `idx_dt_envio` (`dt_envio`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Campanhas de envio em massa';

-- ==========================================
-- ETAPA 4: Recriar tabela tbenviomassanumero
-- ==========================================

CREATE TABLE `tbenviomassanumero` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `id_msg` INT NOT NULL COMMENT 'Referência para a campanha',
  `numero` VARCHAR(20) NOT NULL COMMENT 'Número de telefone a enviar',
  `status` INT DEFAULT 0 COMMENT 'Status do envio',
  `resposta` LONGTEXT NULL COMMENT 'Resposta recebida',
  `data_envio` DATETIME NULL COMMENT 'Data/hora do envio',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de criação',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data da última atualização',
  KEY `idx_id_msg` (`id_msg`),
  KEY `idx_numero` (`numero`),
  KEY `idx_msg_status` (`id_msg`, `status`),
  CONSTRAINT `fk_tbenviomassanumero_id_msg` FOREIGN KEY (`id_msg`) 
    REFERENCES `tbenviomgsmassa`(`id`) 
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Números de telefone para envio em massa';

-- ==========================================
-- ETAPA 5: Verificar estrutura final
-- ==========================================

SELECT 'Estrutura FINAL de tbenviomgsmassa' AS info;
DESCRIBE tbenviomgsmassa;

SELECT 'Estrutura FINAL de tbenviomassanumero' AS info;
DESCRIBE tbenviomassanumero;

-- ==========================================
-- ETAPA 6: Se quiser recuperar dados (OPCIONAL)
-- ==========================================
-- Descomente as linhas abaixo para restaurar dados do backup

-- INSERT INTO `tbenviomgsmassa` 
-- SELECT * FROM `backup_tbenviomgsmassa` 
-- WHERE id NOT IN (SELECT id FROM tbenviomgsmassa LIMIT 999999);

-- SELECT 'Dados restaurados do backup' AS info;

-- ==========================================
-- FIM DO SCRIPT
-- ==========================================
-- Tabelas foram recriadas com sucesso!
-- Se você tinha dados que quer recuperar, estão em backup_tbenviomgsmassa
-- Para restaurar: DELETE tbenviomgsmassa; INSERT INTO tbenviomgsmassa SELECT * FROM backup_tbenviomgsmassa;
-- ==========================================
