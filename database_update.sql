-- Script gerado a partir da procedure TfrmServicoSAW.VerificaTabelaseColunas

-- Configuração de charset
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------------------------------------------------------
-- Tabelas
-- ----------------------------------------------------------------------------

-- tbavisosemexpediente
CREATE TABLE IF NOT EXISTS tbavisosemexpediente (
  numero varchar(15) COLLATE utf8_bin DEFAULT NULL,
  dt_aviso date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- tbnotificacoes
CREATE TABLE IF NOT EXISTS tbnotificacoes (
  id int NOT NULL AUTO_INCREMENT,
  id_usuario int NOT NULL,
  mensagem text COLLATE utf8mb4_bin NOT NULL,
  visualizado tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- ----------------------------------------------------------------------------
-- Alterações em Tabelas (Colunas)
-- Nota: Comandos ALTER TABLE podem falhar se a coluna já existir.
-- ----------------------------------------------------------------------------

-- tbusuario
-- ALTER TABLE tbusuario ADD COLUMN IF NOT EXISTS em_almoco TINYINT(1) NOT NULL DEFAULT '0' COMMENT 'Em horario de almoço';
-- ALTER TABLE tbusuario ADD COLUMN IF NOT EXISTS msg_almoco VARCHAR(2500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'Desculpe, não posso responder agora porque estou em horário de almoço, responderei assim que possivel' COMMENT 'msg de horario de almoço';
-- ALTER TABLE tbusuario ADD COLUMN IF NOT EXISTS email VARCHAR(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL;

-- Para garantir compatibilidade com versões antigas do MySQL que não suportam IF NOT EXISTS no ADD COLUMN,
-- recomenda-se rodar estes comandos apenas se necessário ou ignorar erros de "Duplicate column name".
DELIMITER $$
DROP PROCEDURE IF EXISTS UpgradeDatabase $$
CREATE PROCEDURE UpgradeDatabase()
BEGIN
    -- tbusuario
    IF NOT EXISTS(SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='tbusuario' AND COLUMN_NAME='em_almoco') THEN
        ALTER TABLE tbusuario ADD COLUMN em_almoco TINYINT(1) NOT NULL DEFAULT '0' COMMENT 'Em horario de almoço';
    END IF;
    IF NOT EXISTS(SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='tbusuario' AND COLUMN_NAME='msg_almoco') THEN
        ALTER TABLE tbusuario ADD COLUMN msg_almoco VARCHAR(2500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'Desculpe, não posso responder agora porque estou em horário de almoço, responderei assim que possivel' COMMENT 'msg de horario de almoço';
    END IF;
    IF NOT EXISTS(SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='tbusuario' AND COLUMN_NAME='email') THEN
        ALTER TABLE tbusuario ADD COLUMN email VARCHAR(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL;
    END IF;

    -- tbparametros
    IF NOT EXISTS(SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='tbparametros' AND COLUMN_NAME='msg_inicio_atendente') THEN
        ALTER TABLE tbparametros ADD msg_inicio_atendente VARCHAR(255) NOT NULL COMMENT 'Mensagem exibida quando um atendente aceita o chamado' AFTER msg_aguardando_atendimento;
    END IF;
    IF NOT EXISTS(SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='tbparametros' AND COLUMN_NAME='tipo_menu') THEN
        ALTER TABLE tbparametros ADD COLUMN tipo_menu INT NOT NULL DEFAULT '0' COMMENT '0= Menu em Lista 1=Menu Númerico 2 = Menu em Botões.';
    END IF;
    IF NOT EXISTS(SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='tbparametros' AND COLUMN_NAME='historico_atendimento') THEN
        ALTER TABLE tbparametros ADD COLUMN historico_atendimento TINYINT(1) NOT NULL DEFAULT '0' COMMENT '0-NÃO 1-SIM.';
    END IF;
    IF NOT EXISTS(SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='tbparametros' AND COLUMN_NAME='usar_protocolo') THEN
        ALTER TABLE tbparametros ADD COLUMN usar_protocolo TINYINT(1) NOT NULL DEFAULT '0' COMMENT 'Controlar protocolo de atendimentos?';
    END IF;

    -- tbanexos
    IF NOT EXISTS(SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='tbanexos' AND COLUMN_NAME='enviado') THEN
        ALTER TABLE tbanexos ADD COLUMN enviado TINYINT(1) NOT NULL DEFAULT '0' COMMENT '0 - Não Enviado 1 - Enviado.';
    END IF;

    -- tbrespostasautomaticas
    IF NOT EXISTS(SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='tbrespostasautomaticas' AND COLUMN_NAME='nome_arquivo') THEN
        ALTER TABLE tbrespostasautomaticas ADD COLUMN nome_arquivo VARCHAR(100);
    END IF;

    -- tbatendimento
    IF NOT EXISTS(SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='tbatendimento' AND COLUMN_NAME='classifica_atendimento') THEN
        ALTER TABLE tbatendimento ADD COLUMN classifica_atendimento integer default 0 COMMENT '0 - Não Enviado 1 - Enviar 2 - Enviado 3 - Respondido';
    END IF;
END $$
DELIMITER ;

CALL UpgradeDatabase();
DROP PROCEDURE UpgradeDatabase;


-- ----------------------------------------------------------------------------
-- Stored Procedures
-- ----------------------------------------------------------------------------

DELIMITER $$

-- sprDashBoardAnoAtual
DROP PROCEDURE IF EXISTS sprDashBoardAnoAtual $$
CREATE PROCEDURE sprDashBoardAnoAtual()
BEGIN
    select
    ( SELECT COUNT(situacao) AS qtde FROM tbatendimento WHERE situacao = 'T') as triagem,
    ( SELECT COUNT(id) AS qtde FROM tbatendimento WHERE situacao = 'P' ) as pendentes,
    ( SELECT COUNT(id) AS qtde FROM tbatendimento WHERE situacao = 'A' ) as atendendo,
    (SELECT COUNT(id) AS qtde FROM tbatendimento WHERE situacao = 'F'
    and finalizado_por != 'Transferencia' AND year(dt_atend) = year(current_date()) AND COALESCE(id_atend, 0) NOT IN(0)) as finalizados;
END $$

-- sprDashBoardAtendimentosMensais
DROP PROCEDURE IF EXISTS sprDashBoardAtendimentosMensais $$
CREATE PROCEDURE sprDashBoardAtendimentosMensais()
BEGIN
    select
    (select count(id) from tbatendimento where month(dt_atend) = 1 and year(dt_atend) = year(current_date())) as JANEIRO,
    (select count(id) from tbatendimento where month(dt_atend) = 2 and year(dt_atend) = year(current_date())) as FEVEREIRO,
    (select count(id) from tbatendimento where month(dt_atend) = 3 and year(dt_atend) = year(current_date())) as MARCO,
    (select count(id) from tbatendimento where month(dt_atend) = 4 and year(dt_atend) = year(current_date())) as ABRIL,
    (select count(id) from tbatendimento where month(dt_atend) = 5 and year(dt_atend) = year(current_date())) as MAIO,
    (select count(id) from tbatendimento where month(dt_atend) = 6 and year(dt_atend) = year(current_date())) as JUNHO,
    (select count(id) from tbatendimento where month(dt_atend) = 7 and year(dt_atend) = year(current_date())) as JULHO,
    (select count(id) from tbatendimento where month(dt_atend) = 8 and year(dt_atend) = year(current_date())) as AGOSTO,
    (select count(id) from tbatendimento where month(dt_atend) = 9 and year(dt_atend) = year(current_date())) as SETEMBRO,
    (select count(id) from tbatendimento where month(dt_atend) = 10 and year(dt_atend) = year(current_date())) as OUTUBRO,
    (select count(id) from tbatendimento where month(dt_atend) = 11 and year(dt_atend) = year(current_date())) as NOVEMBRO,
    (select count(id) from tbatendimento where month(dt_atend) = 12 and year(dt_atend) = year(current_date())) as DEZEMBRO;
END $$

-- sprDashBoardTempoMedioAtendimentosDiario
DROP PROCEDURE IF EXISTS sprDashBoardTempoMedioAtendimentosDiario $$
CREATE PROCEDURE sprDashBoardTempoMedioAtendimentosDiario()
BEGIN
    select
    DAY(a.data_atendimento) AS data_atendimento,
    TIME_FORMAT(
    COALESCE(SEC_TO_TIME(AVG(TIMESTAMPDIFF(SECOND, CONCAT(t.dt_atend, ' ', t.hr_atend), t.dt_fim))), '00:00:00'),'%H:%i'
    ) AS tempo_medio_atendimento
    FROM (
    SELECT DISTINCT DATE(dt_atend) AS data_atendimento
    FROM tbatendimento
    WHERE MONTH(dt_atend) = MONTH(CURDATE())
    UNION
    SELECT DATE_FORMAT(CURDATE() - INTERVAL (DAY(CURDATE()) - 1) DAY + INTERVAL n DAY, '%Y-%m-%d') AS data_atendimento
    FROM (
    SELECT (t4.n + t2.n * 10 + t1.n * 100) AS n
    FROM (
    SELECT 0 AS n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9
    ) t1
    CROSS JOIN (
    SELECT 0 AS n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9
    ) t2
    CROSS JOIN (
    SELECT 0 AS n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9
    ) t4
    WHERE (t4.n + t2.n * 10 + t1.n * 100) < DAY(LAST_DAY(CURDATE()))
    ) numbers
    ) a
    LEFT JOIN tbatendimento t ON a.data_atendimento = DATE(t.dt_atend)
    GROUP BY a.data_atendimento
    ORDER BY a.data_atendimento;
END $$

-- sprGeraNovoAtendimento
DROP PROCEDURE IF EXISTS sprGeraNovoAtendimento $$
CREATE PROCEDURE sprGeraNovoAtendimento(IN pNumero VARCHAR(20), IN pNome VARCHAR(100), IN pIdAtendente INT, IN pNomeAtendente VARCHAR(100), IN pSituacao VARCHAR(1), IN pCanal VARCHAR(2), IN pSetor VARCHAR(30))
BEGIN
    DECLARE vNovoId INT;
    SELECT	MAX(TA.ID) INTO vNovoId
    FROM	TBATENDIMENTO AS TA
    WHERE	NUMERO = pNumero;
    SET vNovoId = coalesce(vNovoId, 0) + 1;
    INSERT INTO TBATENDIMENTO
    (ID,
    SITUACAO,
    NUMERO,
    NOME,
    DT_ATEND,
    HR_ATEND,
    ID_ATEND,
    NOME_ATEND,
    SETOR,
    CANAL,
    protocolo)
    VALUES
    (vNovoId,
    pSituacao,
    pNumero,
    pNome,
    current_date(),
    current_time(),
    pIdAtendente,
    pNomeAtendente,
    pSetor,
    pCanal,
    DATE_FORMAT(CURRENT_TIMESTAMP(), '%Y%m%d%H%i%s')
    );
    SELECT vNovoId as ID;
END $$

-- sprGravaMsgAtendimento
DROP PROCEDURE IF EXISTS sprGravaMsgAtendimento $$
CREATE PROCEDURE sprGravaMsgAtendimento(pIdAtendimento INT
,pTelefoneContato VARCHAR(15)
,pNomeContato VARCHAR(100)
,pIdMensagem VARCHAR(100)
,pMsg TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
,pRespostaMsg TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
,pCanal VARCHAR(2)
,pArquivo LONGBLOB
,pCaminhoArquivo TEXT
,pNomeArquivo TEXT
,pTipoArquivo VARCHAR(30))
BEGIN
    DECLARE vId  INT;
    DECLARE vSeq INT;
    SELECT  TA.ID, TA.SEQ INTO vId, vSeq
    FROM 	TBMSGATENDIMENTO TA
    WHERE	TA.ID = pIdAtendimento AND
    TA.NUMERO = pTelefoneContato AND
    TA.CHATID = pIdMensagem AND
    TA.CANAL = pCanal LIMIT 1;
    IF COALESCE(vId, 0) = 0 THEN
        SELECT  MAX(TA.SEQ) INTO vSeq
        FROM 	TBMSGATENDIMENTO TA
        WHERE	TA.ID = pIdAtendimento AND
        TA.NUMERO = pTelefoneContato AND
        TA.CANAL = pCanal;
        SET vSeq = coalesce(vSeq, 0) + 1;
        INSERT INTO TBMSGATENDIMENTO
        (ID
        ,CHATID
        ,SEQ
        ,NUMERO
        ,MSG
        ,RESP_MSG
        ,NOME_CHAT
        ,CANAL
        ,ID_ATEND)
        VALUES
        (pIdAtendimento
        ,pIdMensagem
        ,COALESCE(vSeq, 0)
        ,pTelefoneContato
        ,pMsg
        ,pRespostaMsg
        ,pNomeContato
        ,pCanal
        ,0
        );
    END IF;
    IF COALESCE(TRIM(pCaminhoArquivo), '') <> '' THEN
        SET vId = 0;
        SELECT	TA.ID INTO vId
        FROM	TBANEXOS AS TA
        WHERE	TA.ID = pIdAtendimento AND
        TA.SEQ = vSeq AND
        TA.NUMERO = pTelefoneContato AND
        TA.CANAL = pCanal LIMIT 1;
        IF COALESCE(vId, 0) = 0 THEN
            INSERT INTO TBANEXOS
            (ID
            ,SEQ
            ,NUMERO
            ,NOME_CONTATO
            ,ARQUIVO
            ,NOME_ARQUIVO
            ,NOME_ORIGINAL
            ,TIPO_ARQUIVO
            ,CANAL)
            VALUES
            (pIdAtendimento
            ,COALESCE(vSeq, 0)
            ,pTelefoneContato
            ,pNomeContato
            ,pArquivo
            ,pNomeArquivo
            ,pCaminhoArquivo
            ,pTipoArquivo
            ,pCanal
            );
        END IF;
    END IF;
END $$

-- sprRelatorioAtendimentos
DROP PROCEDURE IF EXISTS sprRelatorioAtendimentos $$
CREATE PROCEDURE sprRelatorioAtendimentos(
pDe date,
pAte date,
pSituacao VARCHAR(2),
pEtiquetas varchar(20),
pNumero varchar(100),
pProtocolo varchar(100)
)
BEGIN
    IF pSituacao = 'A' Then
        SELECT ta.id, ta.situacao, ta.dt_atend, ta.nome, ta.numero, u.nome as nome_atend, '' as cores_etiqueta
        FROM tbatendimento ta
        inner join tbusuario u on u.id = ta.id_atend
        where dt_atend between pDe and pAte
        and ta.situacao = 'A'
        AND ((coalesce(pNumero,0) = 0) OR (pNumero = ta.numero))
        AND ((coalesce(pProtocolo,0) = 0) OR (pProtocolo = ta.protocolo));
    elseif pSituacao = 'F' Then
        SELECT ta.id, ta.dt_atend, ta.nome, ta.numero, ta.nome_atend,
        CONCAT(    GROUP_CONCAT(CONCAT('<span style="border-radius:5px;background-color:',te.cor,'">',te.descricao, '</span>') SEPARATOR ',') ) as etiqueta
        FROM tbatendimento ta
        LEFT JOIN tbatendimentoetiquetas tae ON tae.id_atendimento = ta.id AND tae.numero = ta.numero
        LEFT JOIN tbetiquetas te ON te.id = tae.id_etiqueta
        WHERE dt_atend BETWEEN pDe AND pAte
        AND (ta.situacao = 'F' AND finalizado_por <> 'Transferencia')
        AND ((coalesce(pNumero,0) = 0) OR (pNumero = ta.numero))
        AND ((coalesce(pProtocolo,0) = 0) OR (pProtocolo = ta.protocolo))
        AND ((pEtiquetas = 0) OR (te.id IN (pEtiquetas)))
        GROUP BY ta.id, ta.dt_atend, ta.nome, ta.numero, ta.nome_atend
        ORDER BY dt_atend, nome;
    else
        SELECT ta.id, ta.dt_atend, ta.nome, ta.numero,  u.nome as nome_atend,
        CONCAT(    GROUP_CONCAT(CONCAT('<span style="border-radius:5px;background-color:',te.cor,'">',te.descricao, '</span>') SEPARATOR ',') ) as etiqueta
        FROM tbatendimento ta
        inner join tbusuario u on u.id = ta.id_atend
        LEFT JOIN tbatendimentoetiquetas tae ON tae.id_atendimento = ta.id AND tae.numero = ta.numero
        LEFT JOIN tbetiquetas te ON te.id = tae.id_etiqueta
        WHERE dt_atend BETWEEN pDe AND pAte
        AND ( (ta.situacao = 'A') or (ta.situacao = 'F' AND finalizado_por <> 'Transferencia') )
        AND ((coalesce(pNumero,0) = 0) OR (pNumero = ta.numero))
        AND ((coalesce(pProtocolo,0) = 0) OR (pProtocolo = ta.protocolo))
        AND ((pEtiquetas = 0) OR (te.id IN (pEtiquetas)))
        GROUP BY ta.id, ta.dt_atend, ta.nome, ta.numero, ta.nome_atend
        ORDER BY dt_atend, nome;
    end if;
END $$

DELIMITER ;
