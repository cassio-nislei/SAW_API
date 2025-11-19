<?php
/**
 * SAW API v1 - Model Anexo
 */

class Anexo
{
    /**
     * Cria novo anexo
     */
    public static function create($id, $seq, $numero, $arquivo, $nomeArquivo, $nomeOriginal, $tipoArquivo, $canal = 1, $enviado = 1)
    {
        $sql = "INSERT INTO tbanexos (id, seq, numero, arquivo, nome_arquivo, nome_original, tipo_arquivo, canal, enviado) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        return Database::execute($sql, [
            $id,
            $seq,
            $numero,
            $arquivo,
            $nomeArquivo,
            $nomeOriginal,
            $tipoArquivo,
            $canal,
            $enviado
        ]);
    }

    /**
     * Obtém anexo
     */
    public static function getById($id, $numero, $seq)
    {
        $result = Database::query(
            "SELECT * FROM tbanexos WHERE id = ? AND numero = ? AND seq = ?",
            [$id, $numero, $seq]
        );

        return $result[0] ?? null;
    }

    /**
     * Lista anexos de um atendimento
     */
    public static function listByAtendimento($id, $numero)
    {
        return Database::query(
            "SELECT * FROM tbanexos WHERE id = ? AND numero = ? ORDER BY seq",
            [$id, $numero]
        );
    }

    /**
     * Deleta anexo
     */
    public static function delete($id, $numero, $seq = null)
    {
        $sql = "DELETE FROM tbanexos WHERE id = ? AND numero = ?";
        $params = [$id, $numero];

        if ($seq !== null) {
            $sql .= " AND seq = ?";
            $params[] = $seq;
        }

        return Database::execute($sql, $params);
    }
}
?>
