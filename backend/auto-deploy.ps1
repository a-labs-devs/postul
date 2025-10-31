# Auto-Deploy - Executado pelo Webhook
Set-Location $PSScriptRoot

# 1. Git pull
git pull origin main 2>&1 | Out-Null

# 2. NPM install
npm install --silent 2>&1 | Out-Null

# 3. Fechar terminal anterior (porta 3001)
$connections = netstat -ano | Select-String ":3001"
if ($connections) {
    $connections | ForEach-Object {
        $parts = $_.ToString() -split '\s+'
        $pid = $parts[-1]
        if ($pid -match '^\d+$') {
            Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
        }
    }
}

Start-Sleep -Seconds 1

# 4. Abrir novo terminal PowerShell com servidor
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot'; npm run dev"
