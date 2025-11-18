# Port Forwarding automático de todas as portas do WSL para Windows
# Permite acesso externo a serviços rodando no WSL
# Requer execução como Administrador

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Este script precisa ser executado como Administrador!"
    exit
}

Write-Host "Configurando Port Forwarding do WSL..."

# Obter IP do WSL
$wslIPRaw = (wsl -- sh -c "ip addr show eth0 | grep 'inet ' | awk '{print `$2}' | cut -d'/' -f1")
$wslIP = ($wslIPRaw -split '\s+')[-1].Trim()

if ([string]::IsNullOrEmpty($wslIP) -or $wslIP -notmatch '^\d+\.\d+\.\d+\.\d+$') {
    Write-Host "Erro: Nao foi possivel obter o IP do WSL"
    Write-Host "IP obtido: $wslIPRaw"
    exit
}

Write-Host "WSL IP: $wslIP"

# Limpar configurações antigas
Write-Host "Limpando configuracoes antigas..."
netsh interface portproxy reset
netsh advfirewall firewall delete rule name="WSL Port 3000" | Out-Null
netsh advfirewall firewall delete rule name="WSL Port 3001" | Out-Null
netsh advfirewall firewall delete rule name="WSL Port 8080" | Out-Null
netsh advfirewall firewall delete rule name="WSL Port 8000" | Out-Null
netsh advfirewall firewall delete rule name="WSL Port 5000" | Out-Null
netsh advfirewall firewall delete rule name="WSL Port 5001" | Out-Null
netsh advfirewall firewall delete rule name="WSL Port 4200" | Out-Null
netsh advfirewall firewall delete rule name="WSL Port 3306" | Out-Null
netsh advfirewall firewall delete rule name="WSL Port 5432" | Out-Null
netsh advfirewall firewall delete rule name="WSL Port 27017" | Out-Null
netsh advfirewall firewall delete rule name="WSL Port 6379" | Out-Null

# Lista de portas comuns para desenvolvimento
$ports = @(3000, 3001, 8080, 8000, 5000, 5001, 4200, 3306, 5432, 27017, 6379)

foreach ($port in $ports) {
    Write-Host "Configurando porta $port..."
    netsh interface portproxy add v4tov4 listenport=$port listenaddress=0.0.0.0 connectport=$port connectaddress=$wslIP
    netsh advfirewall firewall add rule name="WSL Port $port" dir=in action=allow protocol=TCP localport=$port | Out-Null
}

Write-Host ""
Write-Host "Configuracao concluida!"
Write-Host ""
Write-Host "Portas configuradas:"
netsh interface portproxy show v4tov4
Write-Host ""
Write-Host "Todas as portas do WSL estao acessiveis externamente"
Write-Host "O IP do WSL pode mudar apos reiniciar - execute o script novamente se necessario"
