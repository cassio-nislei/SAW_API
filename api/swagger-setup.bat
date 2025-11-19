@echo off
REM
REM SAW API - Swagger Setup Script for Windows
REM Configura e inicia a documentacao Swagger
REM
REM Uso: swagger-setup.bat
REM

setlocal enabledelayedexpansion

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║          SAW API - Swagger Documentation Setup                ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

REM Definir diretórios
set "API_DIR=%~dp0"
set "SWAGGER_DIR=%API_DIR%swagger"

echo 📁 Diretório da API: %API_DIR%
echo 📁 Diretório Swagger: %SWAGGER_DIR%
echo.

REM Verificar arquivos
echo 🔍 Verificando arquivos...

if exist "%API_DIR%swagger.json" (
    echo ✓ swagger.json encontrado
) else (
    echo ✗ swagger.json não encontrado
    pause
    exit /b 1
)

if exist "%API_DIR%swagger-ui.html" (
    echo ✓ swagger-ui.html encontrado
) else (
    echo ✗ swagger-ui.html não encontrado
    pause
    exit /b 1
)

if exist "%SWAGGER_DIR%\index.php" (
    echo ✓ swagger\index.php encontrado
) else (
    echo ✗ swagger\index.php não encontrado
    pause
    exit /b 1
)

echo.
echo 🌐 URLs da documentação:
echo.
echo   Swagger UI HTML:
echo     http://localhost/SAW-main/api/swagger-ui.html
echo.
echo   Swagger UI Dinâmica (PHP):
echo     http://localhost/SAW-main/api/swagger/
echo.
echo   Arquivo JSON (OpenAPI):
echo     http://localhost/SAW-main/api/swagger.json
echo.

set /p OPEN="Abrir no navegador? (s/n): "

if /i "%OPEN%"=="s" (
    echo ✓ Abrindo no navegador...
    start http://localhost/SAW-main/api/swagger-ui.html
)

echo.
echo ✅ Setup concluído!
echo.
echo 📚 Para mais informações, leia: DOCUMENTACAO_SWAGGER.md
echo.
pause
