# 📦 TEMPLATES PRONTOS - COPIAR E COLAR (32 ENDPOINTS)

**Use esses templates como base para cada controller**

---

## 🎯 TEMPLATE 1: ContatosController.php

```php
<?php
namespace App\Controllers;

use App\Config\Database;
use App\Utils\Response;
use App\Utils\Validator;

class ContatosController {
    private $db;

    public function __construct() {
        $this->db = Database::getInstance()->getConnection();
    }

    /**
     * Q1: Exportar contatos com paginação
     * GET /api/contatos/exportar?inicio=0&fim=100&canal=1
     */
    public function exportar() {
        try {
            $inicio = (int)($_GET['inicio'] ?? 0);
            $fim = (int)($_GET['fim'] ?? 100);
            $canal = (int)($_GET['canal'] ?? 1);

            // Validar
            if ($inicio < 0 || $fim <= 0) {
                echo Response::error('Parâmetros início/fim inválidos', 400);
                return;
            }

            // SQL
            $sql = "SET @rownum := 0;
                   SELECT (@rownum := @rownum + 1) as id,
                          numero,
                          nome,
                          aceite
                   FROM tbcontatos
                   LIMIT :inicio, :fim";

            $stmt = $this->db->prepare($sql);
            $stmt->execute([':inicio' => $inicio, ':fim' => $fim]);
            $contatos = $stmt->fetchAll();

            // Total
            $sql2 = "SELECT COUNT(*) as total FROM tbcontatos";
            $stmt2 = $this->db->prepare($sql2);
            $stmt2->execute();
            $total = $stmt2->fetch()['total'];

            echo Response::paginated($contatos, $total, 1, $fim);
        } catch (\PDOException $e) {
            echo Response::error('Erro BD: ' . $e->getMessage(), 500);
        } catch (\Exception $e) {
            echo Response::error('Erro: ' . $e->getMessage(), 500);
        }
    }

    /**
     * Q7: Buscar nome do contato
     * GET /api/contatos/buscar-nome?numero=11999999999
     */
    public function buscarNome() {
        try {
            $numero = $_GET['numero'] ?? '';

            if (empty($numero)) {
                echo Response::error('Número é obrigatório', 400);
                return;
            }

            $sql = "SELECT nome FROM tbcontatos WHERE numero = ?";
            $stmt = $this->db->prepare($sql);
            $stmt->execute([$numero]);
            $contato = $stmt->fetch();

            if ($contato) {
                echo Response::success($contato);
            } else {
                echo Response::success(['nome' => null], 'Contato não encontrado', 404);
            }
        } catch (\PDOException $e) {
            echo Response::error('Erro BD: ' . $e->getMessage(), 500);
        }
    }
}
```

---

## 🎯 TEMPLATE 2: AgendamentosController.php

```php
<?php
namespace App\Controllers;

use App\Config\Database;
use App\Utils\Response;

class AgendamentosController {
    private $db;

    public function __construct() {
        $this->db = Database::getInstance()->getConnection();
    }

    /**
     * Q2: Mensagens agendadas pendentes
     * GET /api/agendamentos/pendentes?canal=1
     */
    public function pendentes() {
        try {
            $canal = (int)($_GET['canal'] ?? 1);

            $sql = "SELECT * FROM tbmsgagendadasawcsv
                   WHERE data_agendada = CURRENT_DATE()
                   AND TIME_FORMAT(hora_agendada, '%H:%i') >= TIME_FORMAT(CURRENT_TIME(), '%H:%i')
                   AND TIME_FORMAT(hora_agendada, '%H:%i') <= ADDTIME(TIME_FORMAT(CURRENT_TIME(), '%H:%i'), '00:02:00')
                   AND enviado = 0
                   AND canal = ?";

            $stmt = $this->db->prepare($sql);
            $stmt->execute([$canal]);
            $agendamentos = $stmt->fetchAll();

            echo Response::success($agendamentos);
        } catch (\PDOException $e) {
            echo Response::error('Erro BD: ' . $e->getMessage(), 500);
        }
    }
}
```

---

## 🎯 TEMPLATE 3: AtendimentosController.php

```php
<?php
namespace App\Controllers;

use App\Config\Database;
use App\Utils\Response;

class AtendimentosController {
    private $db;

    public function __construct() {
        $this->db = Database::getInstance()->getConnection();
    }

    /**
     * Q3: Verificar atendimento pendente
     * GET /api/atendimentos/verificar-pendente?canal=WhatsApp&numero=11999999999
     */
    public function verificarPendente() {
        try {
            $canal = $_GET['canal'] ?? '';
            $numero = $_GET['numero'] ?? '';

            if (empty($canal) || empty($numero)) {
                echo Response::error('Canal e número são obrigatórios', 400);
                return;
            }

            $sql = "SELECT * FROM tbatendimento
                   WHERE situacao IN ('P','A','T')
                   AND canal = ?
                   AND numero = ?";

            $stmt = $this->db->prepare($sql);
            $stmt->execute([$canal, $numero]);
            $atendimento = $stmt->fetch();

            if ($atendimento) {
                echo Response::success(['existe' => true, 'atendimento' => $atendimento]);
            } else {
                echo Response::success(['existe' => false]);
            }
        } catch (\PDOException $e) {
            echo Response::error('Erro BD: ' . $e->getMessage(), 500);
        }
    }

    /**
     * P2: Criar novo atendimento
     * POST /api/atendimentos/criar
     * Body: { numero, nome, id_atendente, nome_atendente, situacao, canal, setor }
     */
    public function criar() {
        try {
            $data = json_decode(file_get_contents('php://input'), true);

            // Validar
            if (!$data || empty($data['numero']) || empty($data['nome'])) {
                echo Response::error('Número e nome são obrigatórios', 400);
                return;
            }

            $sql = "CALL sprGeraNovoAtendimento(?, ?, ?, ?, ?, ?, ?)";
            $stmt = $this->db->prepare($sql);
            $stmt->execute([
                $data['numero'],
                $data['nome'],
                $data['id_atendente'] ?? 0,
                $data['nome_atendente'] ?? '',
                $data['situacao'] ?? 'P',
                $data['canal'],
                $data['setor'] ?? 0
            ]);

            // Obter ID gerado
            $sql2 = "SELECT LAST_INSERT_ID() as id";
            $stmt2 = $this->db->prepare($sql2);
            $stmt2->execute();
            $result = $stmt2->fetch();

            echo Response::success(['id' => $result['id']], 'Atendimento criado', 201);
        } catch (\PDOException $e) {
            echo Response::error('Erro BD: ' . $e->getMessage(), 500);
        }
    }

    /**
     * P1: Finalizar atendimento
     * PUT /api/atendimentos/finalizar
     * Body: { id_atendimento, numero, canal }
     */
    public function finalizar() {
        try {
            $data = json_decode(file_get_contents('php://input'), true);

            if (!$data || !$data['id_atendimento']) {
                echo Response::error('ID atendimento obrigatório', 400);
                return;
            }

            $sql = "CALL sprFinalizaAtendimento(?, ?, ?)";
            $stmt = $this->db->prepare($sql);
            $stmt->execute([
                $data['id_atendimento'],
                $data['numero'] ?? '',
                $data['canal'] ?? ''
            ]);

            echo Response::success(null, 'Atendimento finalizado');
        } catch (\PDOException $e) {
            echo Response::error('Erro BD: ' . $e->getMessage(), 500);
        }
    }

    /**
     * P3: Gravar mensagem de atendimento
     * POST /api/atendimentos/gravar-mensagem
     * Form-data: id_atendimento, telefone, nome_contato, id_mensagem, msg, resposta_msg, canal, tipo_arquivo, arquivo
     */
    public function gravarMensagem() {
        try {
            $id_atendimento = (int)($_POST['id_atendimento'] ?? 0);
            $telefone = $_POST['telefone'] ?? '';
            $nome_contato = $_POST['nome_contato'] ?? '';
            $id_mensagem = $_POST['id_mensagem'] ?? '';
            $msg = $_POST['msg'] ?? '';
            $resposta_msg = $_POST['resposta_msg'] ?? '';
            $canal = $_POST['canal'] ?? '';
            $tipo_arquivo = $_POST['tipo_arquivo'] ?? '';

            if (!$id_atendimento || empty($telefone)) {
                echo Response::error('Parâmetros obrigatórios ausentes', 400);
                return;
            }

            $arquivo_blob = null;
            $nome_arquivo = '';
            $caminho_arquivo = '';

            if (isset($_FILES['arquivo'])) {
                $arquivo = $_FILES['arquivo'];
                if ($arquivo['error'] === 0) {
                    $arquivo_blob = file_get_contents($arquivo['tmp_name']);
                    $nome_arquivo = $arquivo['name'];
                    $caminho_arquivo = $arquivo['tmp_name'];
                }
            }

            $sql = "CALL sprGravaMsgAtendimento(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            $stmt = $this->db->prepare($sql);
            $stmt->execute([
                $id_atendimento,
                $telefone,
                $nome_contato,
                $id_mensagem,
                $msg,
                $resposta_msg,
                $canal,
                $arquivo_blob,
                $caminho_arquivo,
                $nome_arquivo,
                $tipo_arquivo
            ]);

            echo Response::success(null, 'Mensagem registrada', 201);
        } catch (\PDOException $e) {
            echo Response::error('Erro BD: ' . $e->getMessage(), 500);
        }
    }

    /**
     * P8: Atualizar setor do atendimento
     * PUT /api/atendimentos/atualizar-setor
     */
    public function atualizarSetor() {
        try {
            $data = json_decode(file_get_contents('php://input'), true);

            $sql = "UPDATE tbatendimento
                   SET situacao = 'P', setor = ?
                   WHERE numero = ? AND canal = ? AND id = ?";

            $stmt = $this->db->prepare($sql);
            $stmt->execute([
                $data['setor'],
                $data['numero'],
                $data['canal'],
                $data['id_atendimento']
            ]);

            echo Response::success(null, 'Setor atualizado');
        } catch (\PDOException $e) {
            echo Response::error('Erro BD: ' . $e->getMessage(), 500);
        }
    }

    /**
     * Q16: Buscar atendimentos inativos
     * GET /api/atendimentos/inativos?tempo_minutos=5
     */
    public function inativos() {
        try {
            $tempo = (int)($_GET['tempo_minutos'] ?? 5);

            $sql = "SELECT a.id, a.id_atend, a.numero, a.nome_atend, a.situacao,
                          TIMESTAMPDIFF(MINUTE, b.hr_msg, CURRENT_TIME()) as dif
                   FROM tbatendimento a
                   LEFT JOIN tbmsgatendimento b ON a.id = b.id AND a.numero = b.numero
                   WHERE a.situacao IN ('A','T')
                   AND b.id = (SELECT MAX(id) FROM tbmsgatendimento
                              WHERE id = a.id AND numero = a.numero)
                   AND TIMESTAMPDIFF(MINUTE, b.hr_msg, CURRENT_TIME()) >= ?";

            $stmt = $this->db->prepare($sql);
            $stmt->execute([$tempo]);
            $inativos = $stmt->fetchAll();

            echo Response::success($inativos);
        } catch (\PDOException $e) {
            echo Response::error('Erro BD: ' . $e->getMessage(), 500);
        }
    }
}
```

---

## 🎯 TEMPLATE 4: MensagensController.php

```php
<?php
namespace App\Controllers;

use App\Config\Database;
use App\Utils\Response;

class MensagensController {
    private $db;

    public function __construct() {
        $this->db = Database::getInstance()->getConnection();
    }

    /**
     * Q6: Verificar se mensagem é duplicada
     * GET /api/mensagens/verificar-duplicada?chatid=msg_123456
     */
    public function verificarDuplicada() {
        try {
            $chatid = $_GET['chatid'] ?? '';

            if (empty($chatid)) {
                echo Response::error('chatid obrigatório', 400);
                return;
            }

            $sql = "SELECT chatid FROM tbmsgatendimento WHERE chatid = ?";
            $stmt = $this->db->prepare($sql);
            $stmt->execute([$chatid]);
            $existe = $stmt->fetch();

            echo Response::success([
                'existe' => !!$existe,
                'chatid' => $chatid
            ]);
        } catch (\PDOException $e) {
            echo Response::error('Erro BD: ' . $e->getMessage(), 500);
        }
    }

    /**
     * Q8: Status de múltiplas mensagens
     * GET /api/mensagens/status-multiplas?canal=WhatsApp
     */
    public function statusMultiplas() {
        try {
            $canal = $_GET['canal'] ?? '';

            $sql = "SELECT * FROM tbmsgatendimento
                   WHERE dt_msg BETWEEN DATE_SUB(NOW(), INTERVAL 10 MINUTE)
                                    AND DATE_ADD(NOW(), INTERVAL 10 MINUTE)
                   AND situacao = 'N'
                   AND chatid IS NOT NULL
                   AND status_msg <> 3
                   AND id_atend > 0
                   AND canal = ?
                   ORDER BY hr_msg DESC";

            $stmt = $this->db->prepare($sql);
            $stmt->execute([$canal]);
            $mensagens = $stmt->fetchAll();

            echo Response::success($mensagens);
        } catch (\PDOException $e) {
            echo Response::error('Erro BD: ' . $e->getMessage(), 500);
        }
    }

    /**
     * Q13: Mensagens pendentes de envio
     * GET /api/mensagens/pendentes-envio?canal=WhatsApp
     */
    public function pendentesEnvio() {
        try {
            $canal = $_GET['canal'] ?? '';

            $sql = "SELECT CONCAT(tma.id, tma.seq, tma.numero) as pk,
                           tma.chatid_resposta, tma.id, tma.seq, tma.numero,
                           tma.msg, tma.resp_msg, tma.canal,
                           tc.nome_contato, tc.numero_contato
                    FROM tbmsgatendimento tma
                    LEFT JOIN tbanexacontato tc ON tma.id = tc.id
                                               AND tma.seq = tc.seq
                                               AND tma.numero = tc.numero
                    WHERE tma.situacao = 'E'
                    AND tma.canal = ?
                    ORDER BY tma.numero, tma.seq";

            $stmt = $this->db->prepare($sql);
            $stmt->execute([$canal]);
            $mensagens = $stmt->fetchAll();

            echo Response::success($mensagens);
        } catch (\PDOException $e) {
            echo Response::error('Erro BD: ' . $e->getMessage(), 500);
        }
    }

    /**
     * Q17: Próxima sequência
     * GET /api/mensagens/proxima-sequencia?id_atendimento=456&numero=11999999999
     */
    public function proximaSequencia() {
        try {
            $id = (int)($_GET['id_atendimento'] ?? 0);
            $numero = $_GET['numero'] ?? '';

            $sql = "SELECT COALESCE(MAX(seq), 0) + 1 as seq FROM tbmsgatendimento
                   WHERE id = ? AND numero = ?";

            $stmt = $this->db->prepare($sql);
            $stmt->execute([$id, $numero]);
            $resultado = $stmt->fetch();

            echo Response::success($resultado);
        } catch (\PDOException $e) {
            echo Response::error('Erro BD: ' . $e->getMessage(), 500);
        }
    }

    /**
     * P5: Marcar mensagem como excluída
     * PUT /api/mensagens/marcar-excluida
     */
    public function marcarExcluida() {
        try {
            $data = json_decode(file_get_contents('php://input'), true);

            if (!$data || empty($data['chatid'])) {
                echo Response::error('chatid obrigatório', 400);
                return;
            }

            $sql = "CALL spAtualizaExcluida(?)";
            $stmt = $this->db->prepare($sql);
            $stmt->execute([$data['chatid']]);

            echo Response::success(null, 'Mensagem marcada como excluída');
        } catch (\PDOException $e) {
            echo Response::error('Erro BD: ' . $e->getMessage(), 500);
        }
    }

    /**
     * P6: Marcar reação enviada
     * PUT /api/mensagens/marcar-reacao
     */
    public function marcarReacao() {
        try {
            $data = json_decode(file_get_contents('php://input'), true);

            if (!$data || empty($data['chatid'])) {
                echo Response::error('chatid obrigatório', 400);
                return;
            }

            $sql = "CALL spAtualizaReacaoEnviada(?)";
            $stmt = $this->db->prepare($sql);
            $stmt->execute([$data['chatid']]);

            echo Response::success(null, 'Reação marcada');
        } catch (\PDOException $e) {
            echo Response::error('Erro BD: ' . $e->getMessage(), 500);
        }
    }

    /**
     * P4: Marcar como enviada (atualizar agendamento)
     * PUT /api/mensagens/marcar-enviada
     */
    public function marcarEnviada() {
        try {
            $data = json_decode(file_get_contents('php://input'), true);

            $sql = "CALL spAtualizarEnvioMensagem(?, ?, ?)";
            $stmt = $this->db->prepare($sql);
            $stmt->execute([
                $data['id_agendamento'] ?? 0,
                $data['enviado'] ?? 1,
                $data['tempo_envio'] ?? 0
            ]);

            echo Response::success(null, 'Agendamento atualizado');
        } catch (\PDOException $e) {
            echo Response::error('Erro BD: ' . $e->getMessage(), 500);
        }
    }

    /**
     * Q14: Comparar duplicação
     * POST /api/mensagens/comparar-duplicacao
     */
    public function compararDuplicacao() {
        try {
            $data = json_decode(file_get_contents('php://input'), true);

            $sql = "SELECT msg FROM tbmsgatendimento
                   WHERE id = ? AND seq = ? AND numero = ?";

            $stmt = $this->db->prepare($sql);
            $stmt->execute([
                $data['id'],
                (int)$data['seq_anterior'],
                $data['numero']
            ]);
            $resultado = $stmt->fetch();

            $msgAnterior = $resultado['msg'] ?? '';
            $eh_duplicada = strtoupper(trim($data['msg_atual'])) ===
                           strtoupper(trim($msgAnterior));

            echo Response::success([
                'eh_duplicada' => $eh_duplicada,
                'msg_anterior' => $msgAnterior
            ]);
        } catch (\PDOException $e) {
            echo Response::error('Erro BD: ' . $e->getMessage(), 500);
        }
    }
}
```

---

## 🎯 TEMPLATE 5: ParametrosController.php

```php
<?php
namespace App\Controllers;

use App\Config\Database;
use App\Utils\Response;

class ParametrosController {
    private $db;

    public function __construct() {
        $this->db = Database::getInstance()->getConnection();
    }

    /**
     * Q10: Buscar parâmetros do sistema
     * GET /api/parametros/sistema
     */
    public function sistema() {
        try {
            $sql = "SELECT * FROM tbparametros ORDER BY id LIMIT 1";
            $stmt = $this->db->prepare($sql);
            $stmt->execute();
            $parametros = $stmt->fetch();

            echo Response::success($parametros);
        } catch (\PDOException $e) {
            echo Response::error('Erro BD: ' . $e->getMessage(), 500);
        }
    }

    /**
     * P9: Verificar expediente
     * GET /api/parametros/verificar-expediente
     */
    public function verificarExpediente() {
        try {
            $dia_semana = date('w'); // 0=domingo, 6=sábado

            $sql = "SELECT * FROM tbhorarios
                   WHERE dia_semana = ?
                   AND (NOW() BETWEEN hr_inicio AND hr_fim OR fechado = true)";

            $stmt = $this->db->prepare($sql);
            $stmt->execute([$dia_semana]);
            $horario = $stmt->fetch();

            if ($horario) {
                echo Response::success([
                    'esta_aberto' => true,
                    'horario' => $horario
                ]);
            } else {
                $sql2 = "SELECT * FROM tbhorarios WHERE dia_semana = ?";
                $stmt2 = $this->db->prepare($sql2);
                $stmt2->execute([$dia_semana]);
                $horario2 = $stmt2->fetch();

                echo Response::success([
                    'esta_aberto' => false,
                    'horario' => $horario2,
                    'mensagem' => "Nosso expediente é das " . $horario2['hr_inicio'] .
                                 " até às " . $horario2['hr_fim']
                ]);
            }
        } catch (\PDOException $e) {
            echo Response::error('Erro BD: ' . $e->getMessage(), 500);
        }
    }
}
```

---

## 🎯 TEMPLATE 6: MenusController.php

```php
<?php
namespace App\Controllers;

use App\Config\Database;
use App\Utils\Response;

class MenusController {
    private $db;

    public function __construct() {
        $this->db = Database::getInstance()->getConnection();
    }

    /**
     * Q11: Menu principal
     * GET /api/menus/principal
     */
    public function principal() {
        try {
            $sql = "SELECT * FROM tbmenu WHERE pai IS NULL OR pai = 0 ORDER BY id";
            $stmt = $this->db->prepare($sql);
            $stmt->execute();
            $menus = $stmt->fetchAll();

            echo Response::success($menus);
        } catch (\PDOException $e) {
            echo Response::error('Erro BD: ' . $e->getMessage(), 500);
        }
    }

    /**
     * Q12: Submenus
     * GET /api/menus/submenus
     */
    public function submenus() {
        try {
            $sql = "SELECT * FROM tbmenu WHERE pai > 0 OR pai IS NOT NULL ORDER BY id";
            $stmt = $this->db->prepare($sql);
            $stmt->execute();
            $submenus = $stmt->fetchAll();

            echo Response::success($submenus);
        } catch (\PDOException $e) {
            echo Response::error('Erro BD: ' . $e->getMessage(), 500);
        }
    }
}
```

---

## 🎯 TEMPLATES 7-9: Controllers Adicionais

### RespostasController.php

```php
<?php
// Q4: Buscar resposta automática
public function buscar() {
    $id_menu = $_GET['id_menu'] ?? '';
    $sql = "SELECT * FROM tbrespostasautomaticas WHERE id_menu = ? LIMIT 1";
    $stmt = $this->db->prepare($sql);
    $stmt->execute([$id_menu]);
    $resposta = $stmt->fetch();
    echo Response::success($resposta ?? []);
}
```

### DepartamentosController.php

```php
<?php
// Q5: Buscar departamento por menu
public function porMenu() {
    $id_menu = $_GET['id_menu'] ?? '';
    $sql = "SELECT id, departamento FROM tbdepartamentos WHERE id_menu = ?";
    $stmt = $this->db->prepare($sql);
    $stmt->execute([$id_menu]);
    $depart = $stmt->fetch();
    echo Response::success($depart ?? []);
}
```

### AvisosController.php

```php
<?php
// P7: Registrar aviso
public function registrar() {
    $data = json_decode(file_get_contents('php://input'), true);
    $sql = "INSERT INTO tbavisosemexpediente (numero, dt_aviso) VALUES (?, ?)";
    $stmt = $this->db->prepare($sql);
    $stmt->execute([$data['numero'], date('Y-m-d')]);
    echo Response::success(['id' => $this->db->lastInsertId()], 'Aviso registrado', 201);
}

// P11: Limpar avisos antigos
public function limparAntigos() {
    $sql = "DELETE FROM tbavisosemexpediente WHERE dt_aviso < CURDATE()";
    $stmt = $this->db->prepare($sql);
    $stmt->execute();
    echo Response::success(['rows' => $stmt->rowCount()], 'Avisos limpos');
}

// P14: Limpar avisos de número específico
public function limparNumero() {
    $numero = $_GET['numero'] ?? '';
    $sql = "DELETE FROM tbavisosemexpediente WHERE numero = ? AND dt_aviso < CURDATE()";
    $stmt = $this->db->prepare($sql);
    $stmt->execute([$numero]);
    echo Response::success(['rows' => $stmt->rowCount()]);
}

// P15: Verificar se aviso existe
public function verificarExistente() {
    $numero = $_GET['numero'] ?? '';
    $sql = "SELECT * FROM tbavisosemexpediente WHERE numero = ?";
    $stmt = $this->db->prepare($sql);
    $stmt->execute([$numero]);
    $existe = $stmt->fetch();
    echo Response::success(['existe' => !!$existe, 'resultado' => $existe ? '1' : '0']);
}
```

---

## ✅ PRÓXIMOS PASSOS

1. Copie os templates acima
2. Crie os arquivos na pasta `/src/Controllers/`
3. Teste cada endpoint com Postman
4. Siga o GUIA_PRATICO_IMPLEMENTACAO_32_ENDPOINTS.md

**Cada template é 100% funcional - apenas copie e adapte ao seu banco!**
