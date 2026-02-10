-- ==========================================
-- SCRIPT: Reorganizar Tabelas de Envio
-- ==========================================
-- Versão: 1.0
-- Descrição: Corrige a estrutura das tabelas para funcionar com o código SAW20
-- ==========================================

-- ==========================================
-- ETAPA 1: Verificar estrutura atual
-- ==========================================
SELECT 'Estrutura ATUAL de tbenviomgsmassa' AS etapa;
DESCRIBE tbenviomgsmassa;

-- ==========================================
-- ETAPA 2: Colunas já existem em tbenviomgsmassa
-- ==========================================
-- As colunas (nome, msg, dt_envio, ativo, created_at, updated_at) 
-- já foram adicionadas em execução anterior, então pulamos esta etapa

-- ==========================================
-- ETAPA 3: Criar tabela tbenviomassanumero (para os números)
-- ==========================================

-- Primeiro, remover a tabela se existir com estrutura errada
DROP TABLE IF EXISTS `tbenviomassanumero`;

-- Agora criar a tabela CORRETA
CREATE TABLE `tbenviomassanumero` (
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
-- ETAPA 4: Adicionar chave estrangeira
-- ==========================================

ALTER TABLE `tbenviomassanumero` 
ADD CONSTRAINT `fk_tbenviomassanumero_id_msg` FOREIGN KEY (`id_msg`) 
REFERENCES `tbenviomgsmassa`(`id`) 
ON DELETE CASCADE;

-- ==========================================
-- ETAPA 5: Criar índices
-- ==========================================

ALTER TABLE `tbenviomgsmassa` ADD INDEX `idx_ativo` (`ativo`);
ALTER TABLE `tbenviomgsmassa` ADD INDEX `idx_dt_envio` (`dt_envio`);
ALTER TABLE `tbenviomassanumero` ADD INDEX `idx_msg_status` (`id_msg`, `status`);

-- ==========================================
-- ETAPA 6: Verificar estrutura final
-- ==========================================

SELECT 'Estrutura FINAL de tbenviomgsmassa' AS etapa;
DESCRIBE tbenviomgsmassa;

SELECT 'Estrutura FINAL de tbenviomassanumero' AS etapa;
DESCRIBE tbenviomassanumero;

SELECT 'Total de registros em tbenviomgsmassa' AS info;
SELECT COUNT(*) FROM tbenviomgsmassa;

SELECT 'Total de registros em tbenviomassanumero' AS info;
SELECT COUNT(*) FROM tbenviomassanumero;

-- ==========================================
-- FIM DO SCRIPT
-- ==========================================
-- IMPORTANTE:
-- • Se receber "Table 'tbenviomassanumero' doesn't exist" ao excluir, é normal!
-- • Se receber "Duplicate column name", as colunas já foram adicionadas
-- • Se receber "Constraint name already exists", a FK já foi criada
--
-- Todos esses erros são normais e podem ser ignorados.
-- O importante é que no final as duas tabelas estejam com a estrutura correta
--
-- Para verificar se tudo funcionou:
-- DESCRIBE tbenviomgsmassa;
-- DESCRIBE tbenviomassanumero;
-- ==========================================
