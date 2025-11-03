# 🌐 Configurar Port Forwarding para alabsv.ddns.net:3001

## 📋 O que você precisa fazer:

### 1. **Acessar seu Roteador**
1. Abra o navegador e acesse o IP do roteador (geralmente):
   - `192.168.1.1` ou
   - `192.168.0.1` ou
   - `10.0.0.1`
2. Faça login com usuário e senha do roteador

### 2. **Configurar Port Forwarding / Virtual Server**

Procure por uma dessas opções no menu:
- "Port Forwarding"
- "Virtual Server"
- "NAT Forwarding"
- "Redirecionamento de Porta"

### 3. **Adicionar Regra**

Configure uma nova regra com:

```
Nome: Postul Backend
Porta Externa: 3001
Porta Interna: 3001
Protocolo: TCP
IP do Servidor: 192.168.1.2 (seu IP local)
```

### 4. **Salvar e Reiniciar**

Salve as configurações e reinicie o roteador se necessário.

---

## 🔧 Verificar se Funcionou

Teste do seu celular (usando dados móveis, NÃO WiFi):

```bash
curl http://alabsv.ddns.net:3001/
```

Deve retornar:
```json
{
  "mensagem": "🚀 API Postos de Gasolina está rodando!",
  ...
}
```

---

## ⚡ ALTERNATIVA RÁPIDA: Usar Ngrok

Se você não tem acesso ao roteador ou quer testar rapidamente, use Ngrok:

### 1. **Instalar Ngrok**
```powershell
# Instalar via Chocolatey
choco install ngrok

# OU baixar de: https://ngrok.com/download
```

### 2. **Iniciar Túnel**
```powershell
ngrok http 3001
```

### 3. **Copiar URL Gerada**
Ngrok vai gerar uma URL como:
```
https://abc123.ngrok-free.app
```

### 4. **Atualizar URLs no App**

Edite os arquivos:
- `app/lib/services/postos_service.dart`
- `app/lib/services/auth_service.dart`
- `app/lib/services/favoritos_service.dart`

Substitua `http://alabsv.ddns.net:3001` por `https://abc123.ngrok-free.app`

### 5. **Hot Reload no App**
```powershell
# No Flutter, pressione 'r' para hot reload
```

---

## 📱 Status Atual

- ✅ Servidor backend rodando em `localhost:3001`
- ✅ URLs do app configuradas para `alabsv.ddns.net:3001`
- ⚠️ **Falta configurar**: Port forwarding no roteador OU usar Ngrok

---

## 🎯 Recomendação

**Para Desenvolvimento/Testes**: Use Ngrok (mais rápido, não precisa mexer no roteador)

**Para Produção**: Configure Port Forwarding no roteador (mais estável e permanente)

---

## 🆘 Problemas Comuns

### "Não consigo acessar o roteador"
- Tente todos os IPs listados acima
- Verifique a etiqueta atrás do roteador com usuário/senha
- Contate seu provedor de internet

### "Port forwarding configurado mas não funciona"
- Verifique se seu IP externo é público (não CG-NAT)
- Teste com `curl` do celular usando dados móveis
- Verifique firewall do Windows:
  ```powershell
  New-NetFirewallRule -DisplayName "Postul Backend" -Direction Inbound -LocalPort 3001 -Protocol TCP -Action Allow
  ```

### "Ngrok funciona mas é muito lento"
- Normal na versão gratuita
- Considere plano pago ou configure port forwarding permanente

---

## 📊 Verificar Status

### Servidor Local
```powershell
curl http://localhost:3001/
```

### Servidor na Rede Local
```powershell
curl http://192.168.1.2:3001/
```

### Servidor Externo (após configurar)
```powershell
curl http://alabsv.ddns.net:3001/
```
