<?php
/**
 * Swagger JSON Loader
 * Serve o arquivo swagger.json com headers CORS e cache corretos
 */

// Headers CORS
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept, Authorization');

// Tipo de conteúdo e cache
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: public, max-age=3600'); // Cache de 1 hora
header('Pragma: public');

// Arquivo swagger.json
$swaggerFile = __DIR__ . '/swagger.json';

if (!file_exists($swaggerFile)) {
    header('HTTP/1.1 404 Not Found');
    echo json_encode([
        'error' => 'Swagger specification not found',
        'file' => $swaggerFile
    ]);
    exit;
}

// Ler e servir o arquivo
$swaggerContent = file_get_contents($swaggerFile);

// Validar se é JSON válido
$decoded = json_decode($swaggerContent);
if ($decoded === null && json_last_error() !== JSON_ERROR_NONE) {
    header('HTTP/1.1 500 Internal Server Error');
    echo json_encode([
        'error' => 'Invalid JSON in swagger.json',
        'message' => json_last_error_msg()
    ]);
    exit;
}

// Servir o conteúdo
echo $swaggerContent;
?>
