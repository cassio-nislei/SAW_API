#!/bin/bash
#
# SAW API - Swagger Setup Script
# Configura e inicia a documentação Swagger
#
# Uso: bash swagger-setup.sh
#

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║          SAW API - Swagger Documentation Setup                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Diretórios
API_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SWAGGER_DIR="$API_DIR/swagger"

echo -e "${BLUE}📁 Diretório da API: $API_DIR${NC}"
echo -e "${BLUE}📁 Diretório Swagger: $SWAGGER_DIR${NC}"
echo ""

# Verificar se os arquivos existem
echo -e "${YELLOW}🔍 Verificando arquivos...${NC}"

if [ -f "$API_DIR/swagger.json" ]; then
    echo -e "${GREEN}✓ swagger.json encontrado${NC}"
else
    echo -e "${RED}✗ swagger.json não encontrado${NC}"
    exit 1
fi

if [ -f "$API_DIR/swagger-ui.html" ]; then
    echo -e "${GREEN}✓ swagger-ui.html encontrado${NC}"
else
    echo -e "${RED}✗ swagger-ui.html não encontrado${NC}"
    exit 1
fi

if [ -f "$SWAGGER_DIR/index.php" ]; then
    echo -e "${GREEN}✓ swagger/index.php encontrado${NC}"
else
    echo -e "${RED}✗ swagger/index.php não encontrado${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}🔧 Configurando permissões...${NC}"

# Definir permissões
chmod 644 "$API_DIR/swagger.json"
chmod 644 "$API_DIR/swagger-ui.html"
chmod 755 "$SWAGGER_DIR"
chmod 644 "$SWAGGER_DIR/index.php"

echo -e "${GREEN}✓ Permissões configuradas${NC}"
echo ""

# Detectar SO
OS=$(uname -s)

if [ "$OS" = "Darwin" ]; then
    # macOS
    BROWSER="open"
elif [ "$OS" = "Linux" ]; then
    # Linux
    if command -v xdg-open &> /dev/null; then
        BROWSER="xdg-open"
    else
        BROWSER="echo"
    fi
elif [[ "$OS" == MINGW* ]] || [[ "$OS" == MSYS* ]]; then
    # Windows
    BROWSER="start"
else
    BROWSER="echo"
fi

echo -e "${BLUE}🌐 URLs da documentação:${NC}"
echo ""
echo -e "  ${GREEN}Swagger UI HTML:${NC}"
echo "    http://localhost/SAW-main/api/swagger-ui.html"
echo ""
echo -e "  ${GREEN}Swagger UI Dinâmica (PHP):${NC}"
echo "    http://localhost/SAW-main/api/swagger/"
echo ""
echo -e "  ${GREEN}Arquivo JSON (OpenAPI):${NC}"
echo "    http://localhost/SAW-main/api/swagger.json"
echo ""

# Perguntar se quer abrir no navegador
read -p "Abrir no navegador? (s/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    if [ "$BROWSER" = "echo" ]; then
        echo "Por favor, abra a URL acima no seu navegador"
    else
        $BROWSER "http://localhost/SAW-main/api/swagger-ui.html" 2>/dev/null
        echo -e "${GREEN}✓ Abrindo no navegador...${NC}"
    fi
fi

echo ""
echo -e "${GREEN}✅ Setup concluído!${NC}"
echo ""
echo -e "${YELLOW}📚 Para mais informações, leia:${NC}"
echo "    DOCUMENTACAO_SWAGGER.md"
echo ""
