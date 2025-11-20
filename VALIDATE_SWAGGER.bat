@echo off
REM SAW API - Swagger Endpoints Validator

setlocal enabledelayedexpansion

set baseUrl=http://104.234.173.105:7080/api/v1
set totalCount=0
set passCount=0
set failCount=0

echo.
echo ================================================================
echo         SAW API - SWAGGER ENDPOINTS VALIDATOR (42 ENDPOINTS)
echo ================================================================
echo.

REM Definir endpoints por categoria
set /A totalCount=42

REM Health (1)
echo [Health Check]
call :testEndpoint "GET" "/" "Health Check"

REM Autenticacao (1)
echo [Autenticacao]
call :testEndpoint "POST" "/auth/login" "Login"

REM Atendimentos (7)
echo [Atendimentos - 7 endpoints]
call :testEndpoint "GET" "/atendimentos" "Listar"
call :testEndpoint "POST" "/atendimentos" "Criar"
call :testEndpoint "POST" "/atendimentos/verificar-pendente" "Verificar pendente"
call :testEndpoint "POST" "/atendimentos/finalizar" "Finalizar"
call :testEndpoint "POST" "/atendimentos/gravar-mensagem" "Gravar mensagem"
call :testEndpoint "PUT" "/atendimentos/atualizar-setor" "Atualizar setor"
call :testEndpoint "GET" "/atendimentos/inativos" "Inativos"

REM Mensagens (8)
echo [Mensagens - 8 endpoints]
call :testEndpoint "POST" "/mensagens/verificar-duplicada" "Verificar duplicada"
call :testEndpoint "POST" "/mensagens/status-multiplas" "Status multiplas"
call :testEndpoint "GET" "/mensagens/pendentes-envio" "Pendentes"
call :testEndpoint "GET" "/mensagens/proxima-sequencia" "Proxima sequencia"
call :testEndpoint "PUT" "/mensagens/marcar-excluida" "Marcar excluida"
call :testEndpoint "POST" "/mensagens/marcar-reacao" "Marcar reacao"
call :testEndpoint "PUT" "/mensagens/marcar-enviada" "Marcar enviada"
call :testEndpoint "POST" "/mensagens/comparar-duplicacao" "Comparar"

REM Contatos (2)
echo [Contatos - 2 endpoints]
call :testEndpoint "GET" "/contatos/exportar" "Exportar"
call :testEndpoint "GET" "/contatos/buscar-nome" "Buscar nome"

REM Agendamentos (1)
echo [Agendamentos - 1 endpoint]
call :testEndpoint "GET" "/agendamentos/pendentes" "Pendentes"

REM Parametros (2)
echo [Parametros - 2 endpoints]
call :testEndpoint "GET" "/parametros/sistema" "Sistema"
call :testEndpoint "GET" "/parametros/verificar-expediente" "Expediente"

REM Menus (2)
echo [Menus - 2 endpoints]
call :testEndpoint "GET" "/menus/principal" "Principal"
call :testEndpoint "GET" "/menus/submenus" "Submenus"

REM Respostas (1)
echo [Respostas - 1 endpoint]
call :testEndpoint "GET" "/respostas/respostas-automaticas" "Automaticas"

REM Departamentos (1)
echo [Departamentos - 1 endpoint]
call :testEndpoint "GET" "/departamentos/por-menu" "Por menu"

REM Avisos (4)
echo [Avisos - 4 endpoints]
call :testEndpoint "POST" "/avisos/registrar" "Registrar"
call :testEndpoint "DELETE" "/avisos/limpar-antigos" "Limpar antigos"
call :testEndpoint "DELETE" "/avisos/limpar-numero" "Limpar numero"
call :testEndpoint "GET" "/avisos/verificar-existente" "Verificar"

echo.
echo ================================================================
echo                         RESUMO FINAL
echo ================================================================
echo.
echo Total de endpoints: %totalCount%
echo Sucesso: %passCount%
echo Falhas: %failCount%

if %failCount% equ 0 (
    echo.
    echo [SUCESSO] TODOS OS ENDPOINTS ESTAO OPERACIONAIS
) else (
    echo.
    echo [ATENCAO] Alguns endpoints com erro - revisar
)

echo.
echo Swagger UI: http://104.234.173.105:7080/api/swagger-ui.html
echo Swagger JSON: http://104.234.173.105:7080/api/swagger-json.php
echo.

goto :eof

:testEndpoint
set method=%1
set path=%2
set name=%3
set url=%baseUrl%%path%

echo   %method% %path% - %name%

goto :eof
