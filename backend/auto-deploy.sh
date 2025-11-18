#!/bin/bash
# Auto-Deploy - Executado pelo Webhook no WSL

# Diretório do script
SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
cd "$SCRIPT_DIR"

echo "=== Auto-Deploy ==="
echo "[1/4] Parando processo na porta 3001..."

# Mata processo na porta 3001 (se existir)
PID=$(lsof -ti:3001)
if [ ! -z "$PID" ]; then
    kill -9 $PID 2>/dev/null
    echo "Processo $PID finalizado"
    sleep 2
fi

echo "[2/4] Git pull..."
git pull origin main

echo "[3/4] NPM install..."
npm install --silent

echo "[4/4] Iniciando servidor..."
# Inicia o servidor em background
nohup npm run dev > /tmp/postul-deploy.log 2>&1 &

echo "Deploy concluído! PID: $!"
echo "Log: /tmp/postul-deploy.log"
