#!/bin/bash

# Script para reiniciar Docker Compose - Resolve conflitos de porta

echo "========================================"
echo "SAW API - Docker Compose Restart"
echo "========================================"
echo ""

echo "[1/4] Parando containers existentes..."
docker-compose down
sleep 2

echo ""
echo "[2/4] Removendo volume antigo (opcional)"
read -p "Remover dados? (y/n): " remove_data
if [ "$remove_data" = "y" ] || [ "$remove_data" = "Y" ]; then
    docker-compose down -v
    echo "Dados removidos!"
fi

sleep 2

echo ""
echo "[3/4] Iniciando novos containers..."
docker-compose up -d

sleep 5

echo ""
echo "[4/4] Verificando status..."
docker-compose ps

echo ""
echo "========================================"
echo "Setup Concluído!"
echo "========================================"
echo ""
echo "URLs:"
echo "  Web:   http://localhost:7080"
echo "  MySQL: localhost:3307 (alterado de 3306)"
echo ""
echo "Credenciais:"
echo "  User:     saw_user"
echo "  Password: Ncm@647534"
echo "  Database: saw15"
echo ""
echo "Para conectar ao MySQL:"
echo "  mysql -h 127.0.0.1 -P 3307 -u saw_user -p"
echo ""
echo "Logs:"
echo "  docker-compose logs -f web   (PHP/Apache)"
echo "  docker-compose logs -f db    (MySQL)"
echo ""
