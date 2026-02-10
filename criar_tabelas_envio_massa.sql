-- ==========================================
-- SCRIPT: Criar Tabelas de Envio em Massa
-- ==========================================
-- Versão: 2.0 (Melhorado para manipular tabelas existentes)
-- Data: 10 de Fevereiro de 2026
-- Descrição: Cria as tabelas necessárias para a funcionalidade de Envio em Massa
-- ==========================================

-- Tabela Principal: Campanhas de Envio em Massa
CREATE TABLE IF NOT EXISTS `tbenviomgsmassa` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `nome` VARCHAR(255) NOT NULL COMMENT 'Nome da campanha',
  `msg` LONGTEXT NOT NULL COMMENT 'Mensagem a ser enviada',
  `dt_envio` DATETIME NULL COMMENT 'Data/hora do envio',
  `ativo` TINYINT(1) DEFAULT 1 COMMENT 'Se a campanha está ativa',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de criação',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data da última atualização',
  KEY `idx_ativo` (`ativo`),
  KEY `idx_dt_envio` (`dt_envio`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Campanhas de envio em massa';

-- ==========================================
-- AJUSTAR TABELA EXISTENTE (Se ela já existe)
-- ==========================================

-- Adicionar colunas faltantes se a tabela já existe
ALTER TABLE `tbenviomgsmassa` ADD COLUMN IF NOT EXISTS `ativo` TINYINT(1) DEFAULT 1 COMMENT 'Se a campanha está ativa';
ALTER TABLE `tbenviomgsmassa` ADD COLUMN IF NOT EXISTS `dt_envio` DATETIME NULL COMMENT 'Data/hora do envio';
ALTER TABLE `tbenviomgsmassa` ADD COLUMN IF NOT EXISTS `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de criação';
ALTER TABLE `tbenviomgsmassa` ADD COLUMN IF NOT EXISTS `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data da última atualização';

-- Tabela Secundária: Números de telefone para envio
CREATE TABLE IF NOT EXISTS `tbenviomassanumero` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `id_msg` INT NOT NULL COMMENT 'Referência para a campanha',
  `numero` VARCHAR(20) NOT NULL COMMENT 'Número de telefone a enviar',
  `status` VARCHAR(50) DEFAULT 'pendente' COMMENT 'Status do envio: pendente, enviado, falha',
  `resposta` LONGTEXT NULL COMMENT 'Resposta recebida',
  `data_envio` DATETIME NULL COMMENT 'Data/hora do envio',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de criação do registro',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data da última atualização',
  FOREIGN KEY (`id_msg`) REFERENCES `tbenviomgsmassa`(`id`) ON DELETE CASCADE,
  KEY `idx_id_msg` (`id_msg`),
  KEY `idx_status` (`status`),
  KEY `idx_numero` (`numero`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Números de telefone para envio em massa';

-- ==========================================
-- ÍNDICES ADICIONAIS PARA PERFORMANCE
-- ==========================================

-- Índice para buscar campanhas ativas rapidamente (adicionar se não existe)
ALTER TABLE `tbenviomgsmassa` ADD INDEX IF NOT EXISTS `idx_ativo_dt` (`ativo`, `dt_envio`);

-- Índice para buscar números por status rapidamente (adicionar se não existe)
ALTER TABLE `tbenviomassanumero` ADD INDEX IF NOT EXISTS `idx_msg_status` (`id_msg`, `status`);

-- ==========================================
-- DADOS DE EXEMPLO (OPCIONAL - DELETE SE NÃO QUISER)
-- ==========================================

-- INSERT INTO `tbenviomgsmassa` (`nome`, `msg`) VALUES 
-- ('Campanha Teste', 'Olá! Esta é uma mensagem de teste.');

-- ==========================================
-- FIM DO SCRIPT
-- ==========================================
-- Próximos passos:
-- 1. Execute este script no seu banco de dados
-- 2. A funcionalidade de Envio em Massa estará disponível
-- 3. Teste a criação de uma nova campanha
-- ==========================================

-- ==========================================
-- VERIFICAÇÃO DA TABELA (Execute para conferir estrutura)
-- ==========================================
-- Execute este comando para ver a estrutura atual da tabela:
-- DESCRIBE tbenviomgsmassa;
-- DESCRIBE tbenviomassanumero;
-- 
-- Se as colunas id_msg, ativo, dt_envio ou outras não aparecerem,
-- adicione-as manualmente com:
-- ALTER TABLE `tbenviomgsmassa` ADD COLUMN `nome_coluna` tipo;
-- ==========================================
