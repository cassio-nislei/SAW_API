#!/bin/bash
# Test Script for Swagger JSON Route
# Usage: bash test-swagger.sh

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  TESTE - Swagger JSON Route via API Router                    ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Configurações
SERVER_IP="104.234.173.305"
PORT="7080"
BASE_URL="http://${SERVER_IP}:${PORT}/api/v1"

echo "📡 Testando contra: $BASE_URL"
echo ""

# Teste 1: GET /swagger.json
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1️⃣  Teste: GET /swagger.json"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

curl -s -i "$BASE_URL/swagger.json" | head -20
echo ""
echo ""

# Teste 2: OPTIONS preflight
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2️⃣  Teste: OPTIONS /swagger.json (CORS Preflight)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

curl -s -i -X OPTIONS \
  -H "Origin: http://localhost:3000" \
  -H "Access-Control-Request-Method: GET" \
  "$BASE_URL/swagger.json" | head -15
echo ""
echo ""

# Teste 3: Validar JSON
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3️⃣  Teste: Validar JSON retornado"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

JSON_RESPONSE=$(curl -s "$BASE_URL/swagger.json")

if echo "$JSON_RESPONSE" | python -m json.tool > /dev/null 2>&1; then
    echo "✅ JSON válido"
    echo ""
    echo "📊 Estatísticas:"
    echo "   • Endpoints: $(echo "$JSON_RESPONSE" | python -c "import sys, json; print(len(json.load(sys.stdin).get('paths', {})))")"
    echo "   • Tamanho: $(echo -n "$JSON_RESPONSE" | wc -c) bytes"
    echo "   • Versão API: $(echo "$JSON_RESPONSE" | python -c "import sys, json; print(json.load(sys.stdin).get('info', {}).get('version', 'N/A'))")"
else
    echo "❌ JSON inválido"
fi
echo ""
echo ""

# Teste 4: Verificar Headers CORS
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4️⃣  Teste: Verificar Headers CORS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

HEADERS=$(curl -s -i "$BASE_URL/swagger.json" | grep -i "access-control")

if [ -z "$HEADERS" ]; then
    echo "⚠️  Nenhum header CORS encontrado"
else
    echo "✅ Headers CORS detectados:"
    echo "$HEADERS"
fi
echo ""
echo ""

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  ✅ Testes Completos                                           ║"
echo "╚════════════════════════════════════════════════════════════════╝"

# Acesso via navegador
echo ""
echo "🌐 Para acessar via navegador:"
echo "   http://${SERVER_IP}:${PORT}/api/swagger-ui.html"
echo ""
echo "🧪 Para testar com o arquivo de teste HTML:"
echo "   http://${SERVER_IP}:${PORT}/api/test-swagger-route.html"
