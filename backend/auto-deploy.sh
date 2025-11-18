#!/bin/bash
# Auto-Deploy - Git Pull e NPM Install

cd /mnt/c/Users/Administrator/Documents/GitHub/postul/backend

echo "=== Auto-Deploy Iniciado ==="
echo "Diretório: $(pwd)"
echo ""

echo "[1/2] Git pull..."
git pull origin main
PULL_STATUS=$?

if [ $PULL_STATUS -eq 0 ]; then
    echo "Git pull concluído"
else
    echo "Erro no git pull (código: $PULL_STATUS)"
    exit 1
fi

echo ""
echo "[2/2] NPM install..."
npm install
INSTALL_STATUS=$?

if [ $INSTALL_STATUS -eq 0 ]; then
    echo "NPM install concluído"
else
    echo "Erro no npm install (código: $INSTALL_STATUS)"
    exit 1
fi

echo ""
echo "=== Deploy Concluído com Sucesso ==="
