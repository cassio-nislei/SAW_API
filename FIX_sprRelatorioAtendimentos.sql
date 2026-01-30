-- Fix para sprRelatorioAtendimentos - Corrigir erro de GROUP BY
-- Problema: Coluna 'u.nome' não estava no GROUP BY com only_full_group_by=ON

DROP PROCEDURE IF EXISTS sprRelatorioAtendimentos;

DELIMITER $$

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
        SELECT ta.id, ta.situacao, ta.dt_atend, ta.nome, ta.numero, u.nome as nome_atend, '' as colors_etiqueta
        FROM tbatendimento ta
        inner join tbusuario u on u.id = ta.id_atend
        where dt_atend between pDe and pAte
        and ta.situacao = 'A'
        AND ((coalesce(pNumero,0) = 0) OR (pNumero = ta.numero))
        AND ((coalesce(pProtocolo,0) = 0) OR (pProtocolo = ta.protocolo));
    
    elseif pSituacao = 'F' Then
        SELECT ta.id, ta.dt_atend, ta.nome, ta.numero, ta.nome_atend,
        CONCAT(GROUP_CONCAT(CONCAT('<span style="border-radius:5px;background-color:',te.cor,'">',te.descricao, '</span>') SEPARATOR ',')) as etiqueta
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
        SELECT ta.id, ta.dt_atend, ta.nome, ta.numero, u.nome as nome_atend,
        CONCAT(GROUP_CONCAT(CONCAT('<span style="border-radius:5px;background-color:',te.cor,'">',te.descricao, '</span>') SEPARATOR ',')) as etiqueta
        FROM tbatendimento ta
        inner join tbusuario u on u.id = ta.id_atend
        LEFT JOIN tbatendimentoetiquetas tae ON tae.id_atendimento = ta.id AND tae.numero = ta.numero
        LEFT JOIN tbetiquetas te ON te.id = tae.id_etiqueta
        WHERE dt_atend BETWEEN pDe AND pAte
        AND ( (ta.situacao = 'A') or (ta.situacao = 'F' AND finalizado_por <> 'Transferencia') )
        AND ((coalesce(pNumero,0) = 0) OR (pNumero = ta.numero))
        AND ((coalesce(pProtocolo,0) = 0) OR (pProtocolo = ta.protocolo))
        AND ((pEtiquetas = 0) OR (te.id IN (pEtiquetas)))
        GROUP BY ta.id, ta.dt_atend, ta.nome, ta.numero, ta.nome_atend, u.id
        ORDER BY dt_atend, nome;
    
    end if;
END $$

DELIMITER ;
