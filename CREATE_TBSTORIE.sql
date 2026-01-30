-- Criação da Tabela tbstorie para Stories (Status) - Marketing Module
-- Esta tabela armazena conteúdo de stories/status para distribuição via WhatsApp

CREATE TABLE IF NOT EXISTS tbstorie (
  id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  data datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  canal int NOT NULL DEFAULT 1,
  enviado tinyint(1) NOT NULL DEFAULT 0 COMMENT '0=Não Enviado, 1=Enviado',
  arquivo longtext COLLATE utf8mb4_bin COMMENT 'Conteúdo do arquivo em base64',
  nome_arquivo varchar(255) COLLATE utf8mb4_bin COMMENT 'Nome do arquivo',
  renovar tinyint(1) NOT NULL DEFAULT 0 COMMENT '0=Não Republicar, 1=Republicar a cada 24h',
  KEY idx_canal (canal),
  KEY idx_data (data),
  KEY idx_renovar (renovar)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

ALTER TABLE tbstorie ADD COLUMN enviado TINYINT(1) NOT NULL DEFAULT 0 COMMENT '0 - Não Enviado 1 - Enviado';
