#!/bin/bash
# Auto-Deploy - Executado pelo Webhook no WSL
# Atualiza o código sem reiniciar o servidor

# Diretório do script
SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
cd "$SCRIPT_DIR"

LOG_FILE="/tmp/postul-deploy.log"

{
    echo "==================================="
    echo "Auto-Deploy - $(date)"
    echo "==================================="
    
    echo "[1/2] Git pull..."
    git pull origin main
    
    if [ $? -eq 0 ]; then
        echo "Git pull concluído com sucesso"
    else
        echo "Erro no git pull"
        exit 1
    fi
    
    echo "[2/2] NPM install..."
    npm install --silent
    
    if [ $? -eq 0 ]; then
        echo "NPM install concluído com sucesso"
    else
        echo "Erro no npm install"
        exit 1
    fi
    
    echo "==================================="
    echo "Deploy concluído com sucesso!"
    echo "==================================="
    
} >> "$LOG_FILE" 2>&1

# Mostra o resultado no console também
tail -n 20 "$LOG_FILE"