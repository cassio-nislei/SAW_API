<?php
/**
 * SAW API v1 - Index
 * Ponto de entrada da API
 * 
 * Endpoint Base: /SAW-main/api/v1/
 * 
 * Exemplo de uso:
 * GET    /api/v1/atendimentos
 * POST   /api/v1/atendimentos
 * GET    /api/v1/atendimentos/{id}?numero=123456
 * GET    /api/v1/atendimentos/ativos
 * 
 * Data: 19/11/2025
 */

// ============================================
// CORS Headers
// ============================================
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS, PATCH, HEAD');
header('Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept, Authorization');
header('Access-Control-Max-Age: 86400');

// Debug: Log das requisições (remover em produção)
// file_put_contents('/tmp/api.log', date('Y-m-d H:i:s') . " - " . $_SERVER['REQUEST_METHOD'] . " " . $_SERVER['REQUEST_URI'] . "\n", FILE_APPEND);

// Handle OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Carrega configurações
require_once __DIR__ . '/config.php';

// Carrega classes base
require_once __DIR__ . '/Database.php';
require_once __DIR__ . '/Response.php';
require_once __DIR__ . '/Router.php';
require_once __DIR__ . '/JWT.php';

// Carrega modelos
require_once __DIR__ . '/models/Atendimento.php';
require_once __DIR__ . '/models/Mensagem.php';
require_once __DIR__ . '/models/Anexo.php';
require_once __DIR__ . '/models/Parametro.php';
require_once __DIR__ . '/models/Menu.php';
require_once __DIR__ . '/models/Horario.php';
require_once __DIR__ . '/models/Usuario.php';

// Carrega controllers
require_once __DIR__ . '/controllers/AuthController.php';
require_once __DIR__ . '/controllers/AtendimentoController.php';
require_once __DIR__ . '/controllers/MensagemController.php';
require_once __DIR__ . '/controllers/ParametroController.php';
require_once __DIR__ . '/controllers/MenuController.php';
require_once __DIR__ . '/controllers/HorarioController.php';
require_once __DIR__ . '/controllers/DashboardController.php';
require_once __DIR__ . '/controllers/UsuariosController.php';

try {
    // Cria router
    $router = new Router();

    // ============================================
    // ROTAS - AUTENTICAÇÃO
    // ============================================

    // POST - Login com JWT
    $router->post('/auth/login', function () {
        AuthController::login();
    });

    // POST - Renovar token JWT
    $router->post('/auth/refresh', function () {
        AuthController::refresh();
    });

    // GET - Validar token JWT
    $router->get('/auth/validate', function () {
        AuthController::validate();
    });

    // ============================================
    // ROTAS - ATENDIMENTOS
    // ============================================

    // GET - Lista atendimentos com filtros
    $router->get('/atendimentos', function () {
        AtendimentoController::list();
    });

    // POST - Cria novo atendimento
    $router->post('/atendimentos', function () {
        AtendimentoController::create();
    });

    // GET - Lista atendimentos ativos
    $router->get('/atendimentos/ativos', function () {
        AtendimentoController::listActive();
    });

    // GET - Busca atendimento por número de telefone
    $router->get('/atendimentos/por-numero/{numero}', function ($numero) {
        AtendimentoController::getByNumber($numero);
    });

    // GET - Obtém atendimento específico
    $router->get('/atendimentos/{id}', function ($id) {
        AtendimentoController::getById($id);
    });

    // GET - Lista anexos de um atendimento
    $router->get('/atendimentos/{id}/anexos', function ($id) {
        AtendimentoController::getAnexos($id);
    });

    // PUT - Atualiza situação do atendimento
    $router->put('/atendimentos/{id}/situacao', function ($id) {
        AtendimentoController::updateSituacao($id);
    });

    // PUT - Atualiza setor do atendimento
    $router->put('/atendimentos/{id}/setor', function ($id) {
        AtendimentoController::updateSetor($id);
    });

    // POST - Finaliza atendimento
    $router->post('/atendimentos/{id}/finalizar', function ($id) {
        AtendimentoController::finalize($id);
    });

    // ============================================
    // ROTAS - MENSAGENS
    // ============================================

    // GET - Lista mensagens de um atendimento
    $router->get('/atendimentos/{id}/mensagens', function ($id) {
        MensagemController::list($id);
    });

    // POST - Cria nova mensagem
    $router->post('/atendimentos/{id}/mensagens', function ($id) {
        MensagemController::create($id);
    });

    // GET - Lista mensagens pendentes
    $router->get('/atendimentos/{id}/mensagens/pendentes', function ($id) {
        MensagemController::listPending($id);
    });

    // PUT - Atualiza situação da mensagem
    $router->put('/mensagens/{id}/situacao', function ($id) {
        MensagemController::updateSituacao($id);
    });

    // PUT - Marca mensagens como visualizadas
    $router->put('/mensagens/{id}/visualizar', function ($id) {
        MensagemController::markAsViewed($id);
    });

    // POST - Adiciona reação a mensagem
    $router->post('/mensagens/{id}/reacao', function ($id) {
        MensagemController::addReaction($id);
    });

    // DELETE - Deleta mensagem
    $router->delete('/mensagens/{id}', function ($id) {
        MensagemController::delete($id);
    });

    // ============================================
    // ROTAS - ANEXOS
    // ============================================

    // POST - Cria novo anexo
    $router->post('/atendimentos/{id}/anexos', function ($id) {
        MensagemController::createAnexo($id);
    });

    // GET - Download de anexo
    $router->get('/anexos/{id}/download', function ($id) {
        MensagemController::downloadAnexo($id);
    });

    // ============================================
    // ROTAS - PARÂMETROS
    // ============================================

    // GET - Obtém todos os parâmetros
    $router->get('/parametros', function () {
        ParametroController::getAll();
    });

    // PUT - Atualiza parâmetros
    $router->put('/parametros/{id}', function ($id) {
        ParametroController::update($id);
    });

    // ============================================
    // ROTAS - MENUS
    // ============================================

    // GET - Lista menus
    $router->get('/menus', function () {
        MenuController::list();
    });

    // GET - Obtém menu específico
    $router->get('/menus/{id}', function ($id) {
        MenuController::getById($id);
    });

    // GET - Obtém resposta automática do menu
    $router->get('/menus/{id}/resposta-automatica', function ($id) {
        MenuController::getAutoResponser($id);
    });

    // GET - Lista submenus
    $router->get('/menus/submenus/{idPai}', function ($idPai) {
        MenuController::listSubmenus($idPai);
    });

    // ============================================
    // ROTAS - HORÁRIOS
    // ============================================

    // GET - Obtém horários de funcionamento
    $router->get('/horarios/funcionamento', function () {
        HorarioController::getFuncionamento();
    });

    // GET - Verifica se está aberto
    $router->get('/horarios/aberto', function () {
        HorarioController::isOpen();
    });

    // ============================================
    // ROTAS - DASHBOARD
    // ============================================

    // GET - Estatísticas do ano atual
    $router->get('/dashboard/ano-atual', function () {
        DashboardController::yearStats();
    });

    // GET - Atendimentos por mês
    $router->get('/dashboard/atendimentos-mensais', function () {
        DashboardController::monthlyStats();
    });

    // ============================================
    // ROTAS - USUÁRIOS
    // ============================================

    // GET - Lista usuários
    $router->get('/usuarios', function () {
        UsuariosController::list();
    });

    // GET - Usuário autenticado
    $router->get('/usuarios/me', function () {
        UsuariosController::me();
    });

    // ============================================
    // ROTA - HEALTH CHECK
    // ============================================

    $router->get('/', function () {
        Response::success([
            'api' => 'SAW API',
            'version' => API_VERSION,
            'status' => 'running',
            'timestamp' => date('Y-m-d H:i:s')
        ], "API funcionando corretamente");
    });

    // Dispara a rota
    $router->dispatch();

} catch (Exception $e) {
    Response::internalError($e->getMessage());
} finally {
    Database::close();
}
?>
