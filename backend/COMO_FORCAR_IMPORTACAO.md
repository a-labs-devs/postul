# 🚀 Como Forçar a Importação de Postos no Servidor

## O Problema
O servidor está rodando mas retornando **0 postos**. A auto-importação deve ter falhado na inicialização.

## ✅ Solução Rápida (Acesso ao Servidor)

### Opção 1: Via SSH/Terminal no Servidor

```bash
# 1. Conectar ao servidor
ssh usuario@alabsv.ddns.net

# 2. Navegar até o diretório do backend
cd /caminho/para/postul/backend

# 3. Executar script de importação forçada
node forcar_importacao.js
```

### Opção 2: Via API (Após Servidor Reiniciar)

Uma vez que o servidor tenha a nova versão com as rotas admin:

```powershell
# Windows PowerShell
Invoke-WebRequest -Uri "http://alabsv.ddns.net:3001/api/admin/forcar-importacao" -Method POST
```

```bash
# Linux/Mac
curl -X POST http://alabsv.ddns.net:3001/api/admin/forcar-importacao
```

### Opção 3: Reiniciar o Servidor

Se o servidor reiniciar, a auto-importação executará automaticamente:

```bash
# No servidor
cd /caminho/para/postul/backend

# Parar o servidor (dependendo de como está rodando)
pm2 restart backend
# ou
systemctl restart postul-backend
# ou
kill <PID> && node src/server.js
```

## 🔧 Verificar Status

### Ver quantos postos existem no banco:

```bash
# No servidor
cd /caminho/para/postul/backend
node verificar_postos.js
```

### Via API (após atualização):

```powershell
Invoke-WebRequest -Uri "http://alabsv.ddns.net:3001/api/admin/status"
```

## 🐛 Troubleshooting

### Webhook Não Está Funcionando?

1. **Verificar se código foi puxado:**
   ```bash
   cd /caminho/para/postul
   git status
   git pull origin main
   ```

2. **Reinstalar dependências (se necessário):**
   ```bash
   cd backend
   npm install
   ```

3. **Reiniciar servidor manualmente:**
   ```bash
   pm2 restart backend
   ```

### Google API Key Não Configurada?

Verifique o arquivo `.env` no servidor:

```bash
cat backend/.env | grep GOOGLE_PLACES_API_KEY
```

Deve mostrar:
```
GOOGLE_PLACES_API_KEY=AIzaSyDV5i7sBbO_C5EJ2VcdGlSOyJkFM5QeXTQ
```

### PostgreSQL Não Está Rodando?

```bash
# Linux
sudo systemctl status postgresql
sudo systemctl start postgresql

# Windows
Get-Service postgresql*
Start-Service postgresql-x64-16
```

## 📊 Após Importação

Verifique no app:
1. Abra o app no celular
2. Recarregue a tela do mapa (pull down)
3. Postos devem aparecer!

## 🎯 Resumo dos Arquivos

| Arquivo | Uso |
|---------|-----|
| `forcar_importacao.js` | Script standalone para executar no servidor |
| `verificar_postos.js` | Script para verificar quantos postos existem |
| `importar_postos_google.js` | Script completo de importação (alternativa) |
| `src/services/autoImportService.js` | Serviço usado pelo servidor automaticamente |

## 🚨 Se Nada Funcionar

Importe manualmente usando o script completo:

```bash
cd backend
node importar_postos_google.js
```

Este script vai importar ~300 postos da região de São Paulo usando a Google Places API.
