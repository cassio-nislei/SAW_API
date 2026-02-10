-- ==========================================
-- SCRIPT: Diagnosticar Tabelas de Envio
-- ==========================================
-- Versão: 1.0
-- Descrição: Verifica a estrutura atual das tabelas
-- ==========================================

-- 1. Mostrar estrutura da tabela tbenviomgsmassa
SELECT 'Estrutura de tbenviomgsmassa:' AS diagnostico;
DESCRIBE tbenviomgsmassa;

-- 2. Mostrar estrutura da tabela tbenviomassanumero (se existir)
SELECT 'Estrutura de tbenviomassanumero:' AS diagnostico;
DESCRIBE tbenviomassanumero;

-- 3. Mostrar dados atuais (se existirem)
SELECT 'Total de registros em tbenviomgsmassa:' AS info;
SELECT COUNT(*) as total_registros FROM tbenviomgsmassa;

SELECT 'Primeiros registros de tbenviomgsmassa:' AS info;
SELECT * FROM tbenviomgsmassa LIMIT 5;

-- ==========================================
-- NOTAS:
-- ==========================================
-- Se alguma tabela não existir, você verá um erro "Table doesn't exist"
-- Se alguma coluna não existir, não aparecerá na descrição
-- 
-- Colunas esperadas em tbenviomgsmassa:
-- - id (INT PRIMARY KEY)
-- - nome (VARCHAR)
-- - msg (LONGTEXT)
-- - dt_envio (DATETIME)
-- - ativo (TINYINT)
-- - created_at (TIMESTAMP)
-- - updated_at (TIMESTAMP)
-- 
-- Colunas esperadas em tbenviomassanumero:
-- - id (INT PRIMARY KEY)
-- - id_msg (INT - FK para tbenviomgsmassa)
-- - numero (VARCHAR)
-- - status (VARCHAR)
-- - resposta (LONGTEXT)
-- - data_envio (DATETIME)
-- - created_at (TIMESTAMP)
-- - updated_at (TIMESTAMP)
-- ==========================================
