# Auto-Deploy - Executado pelo Webhook
Set-Location $PSScriptRoot

# 1. Fechar terminal anterior (porta 3001)
$connections = netstat -ano | Select-String ":3001"
if ($connections) {
    $connections | ForEach-Object {
        $parts = $_.ToString() -split '\s+'
        $pid = $parts[-1]
        if ($pid -match '^\d+$') {
            Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
        }
    }
    Start-Sleep -Seconds 2
}

# 2. Abrir novo terminal PowerShell que faz pull, install e roda servidor
$commands = @"
cd '$PSScriptRoot'
Write-Host '=== Auto-Deploy ===' -ForegroundColor Cyan
Write-Host '[1/3] Git pull...' -ForegroundColor Yellow
git pull origin main
Write-Host '[2/3] NPM install...' -ForegroundColor Yellow
npm install --silent
Write-Host '[3/3] Iniciando servidor...' -ForegroundColor Green
npm run dev
"@

Start-Process powershell -ArgumentList "-NoExit", "-Command", $commands
