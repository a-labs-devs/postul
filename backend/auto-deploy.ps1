# Auto-Deploy Script - PowerShell Version
$ErrorActionPreference = "Continue"

# Criar pasta de logs se não existir
if (-not (Test-Path "logs")) {
    New-Item -ItemType Directory -Path "logs" | Out-Null
}

# Nome do arquivo de log
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile = "logs\deploy-$timestamp.log"

Write-Host "=== Auto-Deploy Iniciado ===" -ForegroundColor Cyan
Write-Host "Log: $logFile" -ForegroundColor Gray

# Git pull
Write-Host "`n[1/3] Git pull..." -ForegroundColor Yellow
git pull origin main *>> $logFile

# NPM install
Write-Host "[2/3] NPM install..." -ForegroundColor Yellow
npm install --silent *>> $logFile

# Parar servidor na porta 3001
Write-Host "[3/3] Parando servidor anterior..." -ForegroundColor Yellow
$connections = netstat -ano | Select-String ":3001"
if ($connections) {
    $connections | ForEach-Object {
        $line = $_.ToString()
        $parts = $line -split '\s+'
        $pid = $parts[-1]
        if ($pid -match '^\d+$') {
            Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
            "Processo $pid encerrado" >> $logFile
        }
    }
}

Start-Sleep -Seconds 2

# Iniciar servidor em nova janela
Write-Host "`nIniciando servidor..." -ForegroundColor Green
Start-Process cmd -ArgumentList "/k", "npm run dev" -WindowStyle Normal

Write-Host "`n=== Deploy Concluído ===" -ForegroundColor Green
Write-Host "Servidor iniciado em nova janela`n" -ForegroundColor Gray
