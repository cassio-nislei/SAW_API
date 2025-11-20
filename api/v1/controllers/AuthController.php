<?php
/**
 * AuthController - Autenticação com JWT
 * 
 * Endpoints:
 * - POST /auth/login
 * - POST /auth/refresh
 * - GET /auth/validate
 */

class AuthController {
    
    /**
     * POST /auth/login
     * Autentica usuário e retorna JWT token
     */
    public static function login() {
        try {
            $data = json_decode(file_get_contents('php://input'), true);
            
            // Debug
            error_log("DEBUG: input data: " . print_r($data, true));
            error_log("DEBUG: REQUEST_BODY: " . file_get_contents('php://input'));
            
            // Validação
            if (empty($data['usuario']) || empty($data['senha'])) {
                return Response::error('Usuário e senha são obrigatórios', 400);
            }
            
            // Buscar usuário no banco
            $db = Database::getInstance();
            $stmt = $db->prepare("
                SELECT id, nome, email, login, situacao, senha
                FROM tbusuario 
                WHERE login = ? AND situacao = 'A'
                LIMIT 1
            ");
            $stmt->execute([$data['usuario']]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            
            // Validar credenciais (comparação simples ou hash)
            if (!$user || ($user['senha'] !== $data['senha'] && !password_verify($data['senha'], $user['senha']))) {
                return Response::error('Usuário ou senha incorretos', 401);
            }
            
            // Gerar JWT Token
            $payload = [
                'id' => $user['id'],
                'login' => $user['login'],
                'nome' => $user['nome'],
                'email' => $user['email'],
                'iat' => time(),
                'exp' => time() + 3600 // 1 hora
            ];
            
            $token = JWT::encode($payload);
            
            // Gerar Refresh Token (7 dias)
            $refreshPayload = [
                'id' => $user['id'],
                'tipo' => 'refresh',
                'iat' => time(),
                'exp' => time() + (7 * 24 * 3600)
            ];
            
            $refreshToken = JWT::encode($refreshPayload);
            
            // Registrar login (auditoria)
            self::registerLogin($user['id'], $data['dispositivo'] ?? 'unknown', $_SERVER['REMOTE_ADDR']);
            
            return Response::success([
                'token' => $token,
                'refresh_token' => $refreshToken,
                'expires_in' => 3600,
                'usuario' => [
                    'id' => $user['id'],
                    'nome' => $user['nome'],
                    'email' => $user['email'],
                    'login' => $user['login']
                ]
            ], 'Login realizado com sucesso');
            
        } catch (Exception $e) {
            return Response::error('Erro interno: ' . $e->getMessage(), 500);
        }
    }
    
    /**
     * POST /auth/refresh
     * Renova o JWT token usando refresh token
     */
    public static function refresh() {
        try {
            // Extrair token do header
            $token = self::extractToken();
            
            if (!$token) {
                return Response::error('Token não fornecido', 401);
            }
            
            // Decodificar token
            $decoded = JWT::decode($token);
            
            if (!$decoded || $decoded['tipo'] !== 'refresh') {
                return Response::error('Refresh token inválido ou expirado', 401);
            }
            
            // Buscar usuário
            $db = Database::getInstance();
            $stmt = $db->prepare("
                SELECT id, nome, email, login
                FROM tbusuario 
                WHERE id = ? 
                LIMIT 1
            ");
            $stmt->execute([$decoded['id']]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$user) {
                return Response::error('Usuário não encontrado', 404);
            }
            
            // Gerar novo token
            $newPayload = [
                'id' => $user['id'],
                'login' => $user['login'],
                'nome' => $user['nome'],
                'email' => $user['email'],
                'iat' => time(),
                'exp' => time() + 3600
            ];
            
            $newToken = JWT::encode($newPayload);
            
            return Response::success([
                'token' => $newToken,
                'expires_in' => 3600
            ], 'Token renovado com sucesso');
            
        } catch (Exception $e) {
            return Response::error('Erro interno: ' . $e->getMessage(), 500);
        }
    }
    
    /**
     * GET /auth/validate
     * Valida se o JWT token é válido
     */
    public static function validate() {
        try {
            // Extrair token do header
            $token = self::extractToken();
            
            if (!$token) {
                return Response::error('Token não fornecido', 401);
            }
            
            // Decodificar token
            $decoded = JWT::decode($token);
            
            if (!$decoded) {
                return Response::error('Token inválido ou expirado', 401);
            }
            
            return Response::success([
                'valid' => true,
                'usuario_id' => $decoded['id'],
                'login' => $decoded['login'],
                'expires_at' => date('c', $decoded['exp']),
                'tempo_restante_segundos' => $decoded['exp'] - time()
            ], 'Token válido');
            
        } catch (Exception $e) {
            return Response::error('Erro interno: ' . $e->getMessage(), 500);
        }
    }
    
    /**
     * Extrai token do header Authorization
     */
    private static function extractToken() {
        $header = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
        
        if (empty($header) || !preg_match('/Bearer\s+(.+)/i', $header, $matches)) {
            return null;
        }
        
        return trim($matches[1]);
    }
    
    /**
     * Registra login na auditoria
     */
    private static function registerLogin($userId, $dispositivo, $ip) {
        try {
            $db = Database::getInstance();
            $stmt = $db->prepare("
                INSERT INTO tb_audit_login (usuario_id, dispositivo, ip, login_em)
                VALUES (?, ?, ?, NOW())
            ");
            $stmt->execute([$userId, $dispositivo, $ip]);
        } catch (Exception $e) {
            // Log silently
        }
    }
}
?>
