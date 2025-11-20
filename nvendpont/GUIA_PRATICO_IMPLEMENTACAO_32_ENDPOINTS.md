# 🚀 GUIA PRÁTICO - IMPLEMENTAR 32 ENDPOINTS PHP (PASSO A PASSO)

**Data:** 20/11/2025  
**Tempo:** 8-10 horas (implementação completa)  
**PHP:** 8.2+  
**Status:** PRONTO PARA COMEÇAR

---

## ⚡ RESUMO RÁPIDO

Você tem:

- ✅ PHP Puro funcionando
- ✅ Documentação completa das 32 queries
- ✅ Estrutura de controllers definida

Você vai fazer:

1. Criar arquivo `src/routes.php` com mapeamento de rotas
2. Implementar cada controller com os 32 métodos
3. Testar com Postman/Insomnia
4. Validar com Delphi

---

## 📂 ESTRUTURA MÍNIMA RECOMENDADA

```
/api
├── public/
│   └── index.php                 ← Ponto de entrada
├── src/
│   ├── config/
│   │   ├── Database.php          ← PDO connection
│   │   └── Config.php            ← Constantes
│   ├── middleware/
│   │   └── JWTAuth.php           ← Validar token
│   ├── controllers/
│   │   ├── ContatosController.php
│   │   ├── AgendamentosController.php
│   │   ├── AtendimentosController.php
│   │   ├── MensagensController.php
│   │   ├── ParametrosController.php
│   │   ├── MenusController.php
│   │   ├── AvisosController.php
│   │   └── HorariosController.php
│   ├── models/
│   │   ├── Contato.php
│   │   ├── Atendimento.php
│   │   ├── Mensagem.php
│   │   └── ...
│   ├── utils/
│   │   ├── Response.php          ← Respostas JSON
│   │   ├── Validator.php         ← Validações
│   │   └── Logger.php            ← Logs
│   └── Router.php                ← Roteador
├── .env                          ← Variáveis ambiente
└── README.md
```

---

## 🔧 PASSO 1: CONFIGURAÇÃO BASE (30 min)

### 1.1 Criar arquivo `src/config/Database.php`

```php
<?php
namespace App\Config;

class Database {
    private static $instance = null;
    private $connection;

    private function __construct() {
        try {
            $host = $_ENV['DB_HOST'] ?? 'localhost';
            $db = $_ENV['DB_NAME'] ?? 'saw_db';
            $user = $_ENV['DB_USER'] ?? 'root';
            $pass = $_ENV['DB_PASS'] ?? '';

            $dsn = "mysql:host=$host;dbname=$db;charset=utf8mb4";
            $this->connection = new \PDO($dsn, $user, $pass, [
                \PDO::ATTR_ERRMODE => \PDO::ERRMODE_EXCEPTION,
                \PDO::ATTR_DEFAULT_FETCH_MODE => \PDO::FETCH_ASSOC,
                \PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4"
            ]);
        } catch (\PDOException $e) {
            die(json_encode(['erro' => 'Erro de conexão: ' . $e->getMessage()]));
        }
    }

    public static function getInstance() {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    public function getConnection() {
        return $this->connection;
    }

    public function query($sql, $params = []) {
        $stmt = $this->connection->prepare($sql);
        $stmt->execute($params);
        return $stmt;
    }

    public function execute($sql, $params = []) {
        return $this->query($sql, $params)->rowCount();
    }

    public function fetchOne($sql, $params = []) {
        return $this->query($sql, $params)->fetch();
    }

    public function fetchAll($sql, $params = []) {
        return $this->query($sql, $params)->fetchAll();
    }
}
```

### 1.2 Criar arquivo `src/utils/Response.php`

```php
<?php
namespace App\Utils;

class Response {
    public static function success($data = null, $message = 'Sucesso', $code = 200) {
        http_response_code($code);
        return json_encode([
            'sucesso' => true,
            'mensagem' => $message,
            'dados' => $data
        ]);
    }

    public static function error($message = 'Erro', $code = 400, $details = null) {
        http_response_code($code);
        return json_encode([
            'sucesso' => false,
            'mensagem' => $message,
            'erros' => $details
        ]);
    }

    public static function paginated($data, $total, $page = 1, $perPage = 10) {
        http_response_code(200);
        return json_encode([
            'sucesso' => true,
            'dados' => $data,
            'paginacao' => [
                'total' => (int)$total,
                'pagina' => (int)$page,
                'por_pagina' => (int)$perPage,
                'total_paginas' => ceil($total / $perPage)
            ]
        ]);
    }
}
```

### 1.3 Criar arquivo `src/utils/Validator.php`

```php
<?php
namespace App\Utils;

class Validator {
    private $errors = [];

    public function validate($data, $rules) {
        foreach ($rules as $field => $fieldRules) {
            foreach (explode('|', $fieldRules) as $rule) {
                $this->applyRule($data, $field, $rule);
            }
        }
        return empty($this->errors);
    }

    private function applyRule($data, $field, $rule) {
        $value = $data[$field] ?? null;

        if (strpos($rule, ':') !== false) {
            [$rule, $param] = explode(':', $rule);
        }

        switch ($rule) {
            case 'required':
                if (empty($value)) {
                    $this->errors[$field] = "$field é obrigatório";
                }
                break;
            case 'email':
                if (!filter_var($value, FILTER_VALIDATE_EMAIL)) {
                    $this->errors[$field] = "$field deve ser um email válido";
                }
                break;
            case 'numeric':
                if (!is_numeric($value)) {
                    $this->errors[$field] = "$field deve ser numérico";
                }
                break;
            case 'min':
                if (strlen($value) < $param) {
                    $this->errors[$field] = "$field deve ter no mínimo $param caracteres";
                }
                break;
            case 'max':
                if (strlen($value) > $param) {
                    $this->errors[$field] = "$field deve ter no máximo $param caracteres";
                }
                break;
        }
    }

    public function getErrors() {
        return $this->errors;
    }
}
```

### 1.4 Criar arquivo `src/middleware/JWTAuth.php`

```php
<?php
namespace App\Middleware;

class JWTAuth {
    private $secret = 'sua_chave_secreta_aqui'; // Use .env!

    public function validate() {
        $headers = getallheaders();
        $token = $headers['Authorization'] ?? null;

        if (!$token) {
            return false;
        }

        // Remove "Bearer "
        $token = str_replace('Bearer ', '', $token);

        try {
            $decoded = $this->decode($token);
            return $decoded;
        } catch (\Exception $e) {
            return false;
        }
    }

    private function decode($token) {
        [$header, $payload, $signature] = explode('.', $token);

        // Verificar assinatura
        $expectedSignature = hash_hmac('sha256', "$header.$payload", $this->secret, true);
        $expectedSignature = rtrim(strtr(base64_encode($expectedSignature), '+/', '-_'), '=');

        if ($signature !== $expectedSignature) {
            throw new \Exception('Assinatura inválida');
        }

        // Decodificar payload
        $decoded = json_decode(base64_decode(strtr($payload, '-_', '+/')), true);
        return $decoded;
    }
}
```

### 1.5 Criar arquivo `public/index.php`

```php
<?php
error_reporting(E_ALL);
ini_set('display_errors', 0);

// Autoload
require_once '../src/autoload.php';

// Carregar .env
require_once '../config/.env.php';

// Middleware CORS
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Router
$router = new \App\Router();
$router->dispatch($_SERVER['REQUEST_METHOD'], $_SERVER['REQUEST_URI']);
```

### 1.6 Criar arquivo `src/Router.php`

```php
<?php
namespace App;

use App\Middleware\JWTAuth;
use App\Utils\Response;

class Router {
    private $routes = [];
    private $middleware = [];

    public function __construct() {
        $this->loadRoutes();
    }

    private function loadRoutes() {
        // CONTATOS
        $this->get('/api/contatos/exportar', 'ContatosController@exportar');

        // AGENDAMENTOS
        $this->get('/api/agendamentos/pendentes', 'AgendamentosController@pendentes');

        // ATENDIMENTOS
        $this->get('/api/atendimentos/verificar-pendente', 'AtendimentosController@verificarPendente');
        $this->post('/api/atendimentos/criar', 'AtendimentosController@criar');
        $this->post('/api/atendimentos/gravar-mensagem', 'AtendimentosController@gravarMensagem');
        $this->put('/api/atendimentos/finalizar', 'AtendimentosController@finalizar');
        $this->put('/api/atendimentos/atualizar-setor', 'AtendimentosController@atualizarSetor');
        $this->get('/api/atendimentos/inativos', 'AtendimentosController@inativos');

        // MENSAGENS
        $this->get('/api/mensagens/verificar-duplicada', 'MensagensController@verificarDuplicada');
        $this->get('/api/mensagens/status-multiplas', 'MensagensController@statusMultiplas');
        $this->get('/api/mensagens/pendentes-envio', 'MensagensController@pendentesEnvio');
        $this->get('/api/mensagens/proxima-sequencia', 'MensagensController@proximaSequencia');
        $this->put('/api/mensagens/marcar-excluida', 'MensagensController@marcarExcluida');
        $this->put('/api/mensagens/marcar-reacao', 'MensagensController@marcarReacao');
        $this->put('/api/mensagens/marcar-enviada', 'MensagensController@marcarEnviada');
        $this->post('/api/mensagens/comparar-duplicacao', 'MensagensController@compararDuplicacao');

        // PARÂMETROS
        $this->get('/api/parametros/sistema', 'ParametrosController@sistema');
        $this->get('/api/parametros/verificar-expediente', 'ParametrosController@verificarExpediente');

        // MENUS
        $this->get('/api/menus/principal', 'MenusController@principal');
        $this->get('/api/menus/submenus', 'MenusController@submenus');

        // RESPOSTAS
        $this->get('/api/respostas-automaticas', 'RespostasController@buscar');

        // DEPARTAMENTOS
        $this->get('/api/departamentos/por-menu', 'DepartamentosController@porMenu');

        // CONTATOS NOME
        $this->get('/api/contatos/buscar-nome', 'ContatosController@buscarNome');

        // AVISOS
        $this->post('/api/avisos/registrar-sem-expediente', 'AvisosController@registrar');
        $this->delete('/api/avisos/limpar-antigos', 'AvisosController@limparAntigos');
        $this->delete('/api/avisos/limpar-numero', 'AvisosController@limparNumero');
        $this->get('/api/avisos/verificar-existente', 'AvisosController@verificarExistente');
    }

    public function get($path, $handler) {
        $this->routes['GET'][$path] = $handler;
    }

    public function post($path, $handler) {
        $this->routes['POST'][$path] = $handler;
    }

    public function put($path, $handler) {
        $this->routes['PUT'][$path] = $handler;
    }

    public function delete($path, $handler) {
        $this->routes['DELETE'][$path] = $handler;
    }

    public function dispatch($method, $path) {
        // Remove query string
        $path = explode('?', $path)[0];

        // Validar JWT
        $jwt = new JWTAuth();
        if (!$jwt->validate() && $path !== '/api/auth/login') {
            http_response_code(401);
            echo json_encode(['erro' => 'Não autorizado']);
            exit;
        }

        // Buscar rota
        if (isset($this->routes[$method][$path])) {
            $handler = $this->routes[$method][$path];
            $this->execute($handler);
        } else {
            http_response_code(404);
            echo json_encode(['erro' => 'Rota não encontrada']);
        }
    }

    private function execute($handler) {
        [$controller, $method] = explode('@', $handler);
        $class = "App\\Controllers\\$controller";

        if (!class_exists($class)) {
            throw new \Exception("Controller $class não existe");
        }

        $instance = new $class();
        $instance->$method();
    }
}
```

---

## 🎯 PASSO 2: IMPLEMENTAR CONTROLLERS (4-5 horas)

### 2.1 Exemplo: `src/Controllers/ContatosController.php`

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

    // Q1: Exportar contatos com paginação
    public function exportar() {
        $inicio = $_GET['inicio'] ?? 0;
        $fim = $_GET['fim'] ?? 100;
        $canal = $_GET['canal'] ?? 1;

        $validator = new Validator();
        if (!$validator->validate($_GET, [
            'inicio' => 'required|numeric',
            'fim' => 'required|numeric'
        ])) {
            echo Response::error('Parâmetros inválidos', 400, $validator->getErrors());
            return;
        }

        try {
            $sql = "SELECT (@rownum := @rownum + 1) as id, numero, nome, aceite
                    FROM (SELECT @rownum := 0) r, tbcontatos
                    LIMIT :inicio, :fim";

            $stmt = $this->db->prepare($sql);
            $stmt->execute([':inicio' => (int)$inicio, ':fim' => (int)$fim]);
            $contatos = $stmt->fetchAll();

            echo Response::success($contatos, 'Contatos exportados', 200);
        } catch (\PDOException $e) {
            echo Response::error('Erro ao exportar: ' . $e->getMessage(), 500);
        }
    }

    // Q7: Buscar nome do contato
    public function buscarNome() {
        $numero = $_GET['numero'] ?? '';

        if (empty($numero)) {
            echo Response::error('Número é obrigatório', 400);
            return;
        }

        try {
            $sql = "SELECT nome FROM tbcontatos WHERE numero = ?";
            $stmt = $this->db->prepare($sql);
            $stmt->execute([$numero]);
            $contato = $stmt->fetch();

            if ($contato) {
                echo Response::success($contato);
            } else {
                echo Response::error('Contato não encontrado', 404);
            }
        } catch (\PDOException $e) {
            echo Response::error('Erro: ' . $e->getMessage(), 500);
        }
    }
}
```

### 2.2 Exemplo: `src/Controllers/AtendimentosController.php`

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

    // Q3: Verificar atendimento pendente
    public function verificarPendente() {
        $canal = $_GET['canal'] ?? '';
        $numero = $_GET['numero'] ?? '';

        try {
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
            echo Response::error('Erro: ' . $e->getMessage(), 500);
        }
    }

    // P2: Criar novo atendimento
    public function criar() {
        $data = json_decode(file_get_contents('php://input'), true);

        try {
            $sql = "CALL sprGeraNovoAtendimento(?, ?, ?, ?, ?, ?, ?)";
            $stmt = $this->db->prepare($sql);
            $stmt->execute([
                $data['numero'] ?? '',
                $data['nome'] ?? '',
                $data['id_atendente'] ?? 0,
                $data['nome_atendente'] ?? '',
                $data['situacao'] ?? 'P',
                $data['canal'] ?? '',
                $data['setor'] ?? 0
            ]);

            // Obter último ID
            $sql = "SELECT LAST_INSERT_ID() as id";
            $stmt = $this->db->prepare($sql);
            $stmt->execute();
            $result = $stmt->fetch();

            echo Response::success(['id' => $result['id']], 'Atendimento criado', 201);
        } catch (\PDOException $e) {
            echo Response::error('Erro: ' . $e->getMessage(), 500);
        }
    }

    // P1: Finalizar atendimento
    public function finalizar() {
        $data = json_decode(file_get_contents('php://input'), true);

        try {
            $sql = "CALL sprFinalizaAtendimento(?, ?, ?)";
            $stmt = $this->db->prepare($sql);
            $stmt->execute([
                $data['id_atendimento'] ?? 0,
                $data['numero'] ?? '',
                $data['canal'] ?? ''
            ]);

            echo Response::success(null, 'Atendimento finalizado');
        } catch (\PDOException $e) {
            echo Response::error('Erro: ' . $e->getMessage(), 500);
        }
    }

    // P3: Gravar mensagem de atendimento
    public function gravarMensagem() {
        // Para upload de arquivo, use multipart/form-data
        $id_atendimento = $_POST['id_atendimento'] ?? 0;
        $telefone = $_POST['telefone'] ?? '';
        $nome_contato = $_POST['nome_contato'] ?? '';
        $id_mensagem = $_POST['id_mensagem'] ?? '';
        $msg = $_POST['msg'] ?? '';
        $resposta_msg = $_POST['resposta_msg'] ?? '';
        $canal = $_POST['canal'] ?? '';
        $tipo_arquivo = $_POST['tipo_arquivo'] ?? '';

        $arquivo_blob = null;
        $nome_arquivo = '';
        $caminho_arquivo = '';

        // Se houver arquivo
        if (isset($_FILES['arquivo'])) {
            $arquivo = $_FILES['arquivo'];
            $arquivo_blob = file_get_contents($arquivo['tmp_name']);
            $nome_arquivo = $arquivo['name'];
            $caminho_arquivo = $arquivo['tmp_name'];
        }

        try {
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
            echo Response::error('Erro: ' . $e->getMessage(), 500);
        }
    }
}
```

### 2.3 Exemplo: `src/Controllers/MensagensController.php`

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

    // Q6: Verificar mensagem duplicada
    public function verificarDuplicada() {
        $chatid = $_GET['chatid'] ?? '';

        try {
            $sql = "SELECT chatid FROM tbmsgatendimento WHERE chatid = ?";
            $stmt = $this->db->prepare($sql);
            $stmt->execute([$chatid]);
            $existe = $stmt->fetch();

            echo Response::success([
                'existe' => !!$existe,
                'chatid' => $chatid
            ]);
        } catch (\PDOException $e) {
            echo Response::error('Erro: ' . $e->getMessage(), 500);
        }
    }

    // Q8: Status de mensagens com datetime
    public function statusMultiplas() {
        $canal = $_GET['canal'] ?? '';

        try {
            $sql = "SELECT * FROM tbmsgatendimento
                   WHERE dt_msg BETWEEN DATE_SUB(NOW(), INTERVAL 10 MINUTE) AND DATE_ADD(NOW(), INTERVAL 10 MINUTE)
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
            echo Response::error('Erro: ' . $e->getMessage(), 500);
        }
    }

    // Q17: Próxima sequência
    public function proximaSequencia() {
        $id_atendimento = $_GET['id_atendimento'] ?? 0;
        $numero = $_GET['numero'] ?? '';

        try {
            $sql = "SELECT COALESCE(MAX(seq), 0) + 1 as seq FROM tbmsgatendimento
                   WHERE id = ? AND numero = ?";

            $stmt = $this->db->prepare($sql);
            $stmt->execute([$id_atendimento, $numero]);
            $resultado = $stmt->fetch();

            echo Response::success($resultado);
        } catch (\PDOException $e) {
            echo Response::error('Erro: ' . $e->getMessage(), 500);
        }
    }

    // P5: Marcar como excluída
    public function marcarExcluida() {
        $data = json_decode(file_get_contents('php://input'), true);

        try {
            $sql = "CALL spAtualizaExcluida(?)";
            $stmt = $this->db->prepare($sql);
            $stmt->execute([$data['chatid'] ?? '']);

            echo Response::success(null, 'Mensagem marcada como excluída');
        } catch (\PDOException $e) {
            echo Response::error('Erro: ' . $e->getMessage(), 500);
        }
    }

    // P6: Marcar reação enviada
    public function marcarReacao() {
        $data = json_decode(file_get_contents('php://input'), true);

        try {
            $sql = "CALL spAtualizaReacaoEnviada(?)";
            $stmt = $this->db->prepare($sql);
            $stmt->execute([$data['chatid'] ?? '']);

            echo Response::success(null, 'Reação marcada');
        } catch (\PDOException $e) {
            echo Response::error('Erro: ' . $e->getMessage(), 500);
        }
    }

    // P4: Marcar como enviada (atualizar agendamento)
    public function marcarEnviada() {
        $data = json_decode(file_get_contents('php://input'), true);

        try {
            $sql = "CALL spAtualizarEnvioMensagem(?, ?, ?)";
            $stmt = $this->db->prepare($sql);
            $stmt->execute([
                $data['id_agendamento'] ?? 0,
                $data['enviado'] ?? 1,
                $data['tempo_envio'] ?? 0
            ]);

            echo Response::success(null, 'Agendamento atualizado');
        } catch (\PDOException $e) {
            echo Response::error('Erro: ' . $e->getMessage(), 500);
        }
    }
}
```

---

## 🧪 PASSO 3: TESTES (1-2 horas)

### 3.1 Teste via Postman

#### Teste GET - Verificar Duplicada

```
GET http://localhost/api/mensagens/verificar-duplicada?chatid=msg_123456

Headers:
- Authorization: Bearer seu_token_jwt
- Content-Type: application/json

Response esperado:
{
  "sucesso": true,
  "mensagens": "Sucesso",
  "dados": {
    "existe": false,
    "chatid": "msg_123456"
  }
}
```

#### Teste POST - Criar Atendimento

```
POST http://localhost/api/atendimentos/criar

Headers:
- Authorization: Bearer seu_token_jwt
- Content-Type: application/json

Body:
{
  "numero": "11999999999",
  "nome": "João Silva",
  "id_atendente": 0,
  "nome_atendente": "",
  "situacao": "P",
  "canal": "WhatsApp",
  "setor": 10
}

Response esperado:
{
  "sucesso": true,
  "mensagem": "Atendimento criado",
  "dados": {
    "id": 789
  }
}
```

#### Teste PUT - Finalizar

```
PUT http://localhost/api/atendimentos/finalizar

Headers:
- Authorization: Bearer seu_token_jwt
- Content-Type: application/json

Body:
{
  "id_atendimento": 456,
  "numero": "11999999999",
  "canal": "WhatsApp"
}
```

#### Teste POST com Arquivo - Gravar Mensagem

```
POST http://localhost/api/atendimentos/gravar-mensagem

Headers:
- Authorization: Bearer seu_token_jwt

Body (multipart/form-data):
- id_atendimento: 789
- telefone: 11999999999
- nome_contato: João Silva
- id_mensagem: msg_123456
- msg: Olá cliente
- resposta_msg: Recebido!
- canal: WhatsApp
- tipo_arquivo: image
- arquivo: [selecionar arquivo]
```

---

## 📋 PASSO 4: CHECKLIST IMPLEMENTAÇÃO

### Controladores a Implementar (Priority Order)

- [ ] **ContatosController.php** (2 métodos)

  - [ ] exportar() - Q1
  - [ ] buscarNome() - Q7

- [ ] **AtendimentosController.php** (6 métodos)

  - [ ] verificarPendente() - Q3
  - [ ] criar() - P2
  - [ ] finalizar() - P1
  - [ ] gravarMensagem() - P3
  - [ ] atualizarSetor() - P8
  - [ ] inativos() - Q16

- [ ] **MensagensController.php** (8 métodos)

  - [ ] verificarDuplicada() - Q6
  - [ ] statusMultiplas() - Q8
  - [ ] pendentesEnvio() - Q13
  - [ ] proximaSequencia() - Q17
  - [ ] marcarExcluida() - P5
  - [ ] marcarReacao() - P6
  - [ ] marcarEnviada() - P4
  - [ ] compararDuplicacao() - Q14

- [ ] **AgendamentosController.php** (1 método)

  - [ ] pendentes() - Q2

- [ ] **ParametrosController.php** (2 métodos)

  - [ ] sistema() - Q10
  - [ ] verificarExpediente() - P9

- [ ] **MenusController.php** (2 métodos)

  - [ ] principal() - Q11
  - [ ] submenus() - Q12

- [ ] **RespostasController.php** (1 método)

  - [ ] buscar() - Q4

- [ ] **DepartamentosController.php** (1 método)

  - [ ] porMenu() - Q5

- [ ] **AvisosController.php** (4 métodos)

  - [ ] registrar() - P7
  - [ ] limparAntigos() - P11
  - [ ] limparNumero() - P14
  - [ ] verificarExistente() - P15

- [ ] **HorariosController.php** (1 método)
  - [ ] verificarExpediente() - P9

### Teste Funcional

- [ ] Testar cada endpoint com Postman
- [ ] Validar respostas JSON
- [ ] Testar com arquivo (gravar-mensagem)
- [ ] Testar paginação
- [ ] Testar errors/exceptions

### Integração Delphi

- [ ] Atualizar SAWAPIClient.pas
- [ ] Testar chamadas da API
- [ ] Validar retornos
- [ ] Teste UAT completo

---

## 🚀 RESUMO TEMPO ESTIMADO

| Fase      | Tarefa                               | Tempo          |
| --------- | ------------------------------------ | -------------- |
| 1         | Setup Base (DB, Utils, JWT)          | 30 min         |
| 2         | Implementar Controllers (32 métodos) | 4-5 horas      |
| 3         | Testes com Postman                   | 1-2 horas      |
| 4         | Ajustes e validação                  | 30 min         |
| 5         | Integração Delphi                    | 1 hora         |
| **TOTAL** |                                      | **8-10 horas** |

---

## 💡 DICAS PRÁTICAS

1. **Comece pelos GET** (mais simples)
2. **Depois POST** (com validações)
3. **Depois PUT/DELETE** (atualizações)
4. **Deixe multipart por último** (arquivos)

5. **Use ferramentas:**

   - Postman para testar
   - Xdebug para debugar
   - Monolog para logs

6. **Padrão de resposta:**

   - Sempre `{ "sucesso": bool, "mensagem": string, "dados": object }`

7. **Tratamento de erros:**
   - Sempre try/catch
   - Sempre validar entrada
   - Sempre retornar código HTTP correto

---

**Pronto para começar? Implemente o PASSO 1 e teste!**
