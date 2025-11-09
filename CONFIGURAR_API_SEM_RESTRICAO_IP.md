# 🔐 Configurar API Key sem Restrição de IP

## 📋 Visão Geral

Este guia explica como configurar a API key do Google sem restrições de IP, permitindo que funcione com o backend em IP dinâmico (DDNS: alabsav.ddns.net).

**Vantagens:**
- ✅ Funciona com IP dinâmico (sem manutenção manual)
- ✅ Sem custos adicionais de IP fixo
- ✅ Configuração rápida (15 minutos)

**Segurança:**
- ⚠️ API key pode ser usada de qualquer IP
- ✅ Mitigado com cotas rigorosas e alertas de billing
- ✅ Restrições por API específica mantidas
- ✅ Application restrictions (pacote Android) mantidas

---

## 🎯 Passo 1: Acessar Google Cloud Console

1. Acesse: https://console.cloud.google.com/apis/credentials
2. Faça login com sua conta Google
3. Selecione o projeto: **postul** (ou o nome do seu projeto)
4. Localize a API key: **AIzaSyD1p9PvEu2CwvKtFbyDUT0ocLjWc5hCJJw**

---

## 🔧 Passo 2: Remover Restrições de IP

### 2.1. Editar API Key

1. Clique no **lápis (✏️)** ao lado da API key
2. Role até a seção **"API restrictions"**

### 2.2. Configurar Application Restrictions

**Manter esta configuração (IMPORTANTE):**

```
Application restrictions:
  ✓ Android apps
  
  Package name: com.alabsv.postul
  SHA-1 certificate fingerprint: 
    - C3:80:BF:... (debug - desenvolvimento)
    - [SHA-1 do release keystore]
```

**Ação:** Deixe como está (NÃO ALTERE)

### 2.3. Remover IP Restrictions

**Localizar:**
```
IP addresses:
  Currently set to: 191.17.235.73
```

**Ação:**
1. Clique em **"Edit"** ou **"Remove"** nas restrições de IP
2. **DELETE** a linha com `191.17.235.73`
3. Se houver campo "IP addresses", deixe **vazio** ou selecione **"None"**

### 2.4. Manter API Restrictions

**MANTER ESTAS RESTRIÇÕES (CRÍTICO):**

```
API restrictions:
  ✓ Restrict key
  
  APIs selecionadas:
    ✓ Maps SDK for Android
    ✓ Places API (New)
    ✓ Directions API
    ✓ Geolocation API
```

**Ação:** Deixe marcadas apenas estas 4 APIs

---

## 📊 Passo 3: Configurar Cotas (ESSENCIAL)

### 3.1. Directions API

1. Acesse: https://console.cloud.google.com/apis/api/directions-backend.googleapis.com/quotas
2. Localize **"Requests per day"**
3. Clique em **"Edit quota"**
4. Configure:
   ```
   Daily limit: 1,000 requests/day
   ```
5. Clique em **"Save"**

**Por que 1.000/dia?**
- 100 usuários × 10 rotas/dia = 1.000 requests
- Custo estimado: R$ 0,00 (dentro do free tier)

### 3.2. Maps SDK for Android

1. Acesse: https://console.cloud.google.com/apis/api/maps-android-backend.googleapis.com/quotas
2. Localize **"Map loads per day"**
3. Configure:
   ```
   Daily limit: 10,000 loads/day
   ```
4. Salve

**Por que 10.000/dia?**
- 200 usuários × 50 aberturas/dia = 10.000 loads
- Custo estimado: R$ 0,00 (free tier: 28.500/mês)

### 3.3. Places API (New)

1. Acesse: https://console.cloud.google.com/apis/api/places-backend.googleapis.com/quotas
2. Configure:
   ```
   Daily limit: 5,000 requests/day
   ```

### 3.4. Geolocation API

1. Acesse: https://console.cloud.google.com/apis/api/geolocation.googleapis.com/quotas
2. Configure:
   ```
   Daily limit: 10,000 requests/day
   ```

---

## 💰 Passo 4: Configurar Alertas de Billing (CRÍTICO)

### 4.1. Criar Budget Alert

1. Acesse: https://console.cloud.google.com/billing/budgets
2. Clique em **"CREATE BUDGET"**

### 4.2. Configuração do Budget

**Scope:**
```
Projects: postul
Services: All services
```

**Budget amount:**
```
Budget type: Specified amount
Target amount: R$ 50,00 (ou USD 10)
```

**Thresholds:**
```
✓ 50% of budget ($5)   → Email alert
✓ 90% of budget ($9)   → Email alert
✓ 100% of budget ($10) → Email alert + SMS (se configurado)
```

### 4.3. Alertas Adicionais (Recomendado)

Crie mais 2 budgets:

**Budget 2:**
- Nome: "Postul - Warning"
- Valor: R$ 100,00
- Thresholds: 50%, 90%, 100%

**Budget 3:**
- Nome: "Postul - Critical"
- Valor: R$ 200,00
- Thresholds: 100%
- Ação: Considerar desabilitar APIs automaticamente

### 4.4. Configurar Billing Account Limit (Opcional)

1. Acesse: https://console.cloud.google.com/billing
2. Clique em **"Account management"**
3. Configure **"Spending limit"**: R$ 500,00/mês

---

## 🧪 Passo 5: Testar Configuração

### 5.1. Testar via Browser (Backend)

```bash
# No PowerShell:
$url = "https://maps.googleapis.com/maps/api/directions/json?origin=-23.550520,-46.633308&destination=-23.561684,-46.656139&key=AIzaSyD1p9PvEu2CwvKtFbyDUT0ocLjWc5hCJJw"
Invoke-RestMethod -Uri $url
```

**Resultado esperado:**
```json
{
  "routes": [...],
  "status": "OK"
}
```

### 5.2. Testar no App

1. Compile o app:
   ```powershell
   cd C:\Users\jean_\Documents\GitHub\postul\app
   flutter run -d 0082530777
   ```

2. No app:
   - Faça login
   - Selecione um posto
   - Clique em "Ir até o posto"
   - Teste os 3 tipos de rota:
     * ⚡ Rota Rápida
     * 💰 Sem Pedágio
     * 🏙️ Sem Rodovia

**Resultado esperado:**
```
I/flutter: ✅ Rota rapida: 368 m • 1 min
I/flutter: ✅ Rota sem_pedagio: 404 m • 1 min
I/flutter: ✅ Rota sem_rodovia: 441 m • 2 min
```

### 5.3. Verificar Logs do Backend

Se tiver acesso SSH ao servidor:
```bash
ssh user@alabsv.ddns.net
cd /path/to/backend
pm2 logs postul-backend
```

**Buscar por:**
```
✅ Rota calculada com sucesso
Status: OK
```

---

## 📈 Passo 6: Monitoramento Contínuo

### 6.1. Dashboard de Uso

1. Acesse: https://console.cloud.google.com/apis/dashboard
2. Selecione período: **Last 30 days**
3. Monitore:
   - **Directions API**: < 1.000/dia
   - **Maps SDK**: < 10.000/dia
   - **Places API**: < 5.000/dia

### 6.2. Alertas por Email

Configure em: https://console.cloud.google.com/monitoring/alerting

**Alert 1: Uso anormal de API**
```yaml
Condition:
  Metric: API usage
  Threshold: > 80% of quota
  Duration: 1 hour
  
Action:
  Send email to: seu-email@gmail.com
```

**Alert 2: Custo elevado**
```yaml
Condition:
  Metric: Billing amount
  Threshold: > R$ 10,00/day
  
Action:
  Send email + SMS
```

### 6.3. Revisão Semanal

**Checklist semanal:**
- [ ] Verificar dashboard de uso
- [ ] Confirmar que custos estão zerados
- [ ] Revisar logs do backend para erros de API
- [ ] Testar app em produção (1 rota)

---

## 🚨 Plano de Contingência

### Se API Key for Comprometida

**Sinais de comprometimento:**
- Uso de API > 1000% acima do normal
- Custo inesperado (> R$ 50/dia)
- Alertas de billing críticos

**Ações imediatas:**

1. **Desabilitar API key (5 minutos):**
   ```
   Google Cloud Console → API Credentials
   → Click na key → "Disable"
   ```

2. **Gerar nova key (10 minutos):**
   ```powershell
   # No backend, atualizar .env:
   GOOGLE_MAPS_API_KEY=AIzaSy...NOVA_KEY
   
   # Reiniciar backend:
   ssh user@alabsv.ddns.net
   pm2 restart postul-backend
   ```

3. **Atualizar app (se necessário):**
   ```powershell
   # Se key estiver hardcoded no app
   cd C:\Users\jean_\Documents\GitHub\postul\app
   # Atualizar arquivo com nova key
   flutter build appbundle --release
   # Publicar update urgente na Play Store
   ```

### Se Cota Exceder

**Ações:**
1. Investigar causa (logs do backend)
2. Aumentar cota temporariamente
3. Adicionar cache no backend (reduzir requests)
4. Implementar rate limiting por usuário

---

## ✅ Checklist Final

Antes de submeter ao Play Store:

- [ ] Restrições de IP **removidas**
- [ ] Application restrictions (pacote Android) **configuradas**
- [ ] API restrictions (4 APIs) **configuradas**
- [ ] Cotas diárias **configuradas** (Directions: 1K, Maps: 10K)
- [ ] Budget alerts **criados** (R$ 50, 100, 200)
- [ ] Billing limit **configurado** (R$ 500/mês)
- [ ] Teste via browser **OK** (status: "OK")
- [ ] Teste no app **OK** (3 rotas calculando)
- [ ] Dashboard de uso **verificado**
- [ ] Email de alertas **confirmado**

---

## 📞 Suporte

**Documentação Google:**
- API Key Best Practices: https://cloud.google.com/docs/authentication/api-keys
- Directions API: https://developers.google.com/maps/documentation/directions
- Billing: https://cloud.google.com/billing/docs

**Custos:**
- Directions API: R$ 0,025/request (após free tier)
- Maps SDK: R$ 0,035/load (após 28.500/mês)
- Free tier mensal:
  - Directions: R$ 1.000 em créditos ($200 × 0.005)
  - Maps: 28.500 loads grátis

**Estimativa mensal (100 usuários ativos):**
- Directions: 30.000 requests/mês → **R$ 0,00** (dentro do free tier)
- Maps: 150.000 loads/mês → R$ 4.200 **× 0 = R$ 0,00** (dentro do free tier)
- **Total estimado: R$ 0,00/mês** (tráfego baixo a médio)

---

## 🎯 Próximos Passos

Após configurar a API key:

1. **Testar em produção** (30 minutos)
   - Build release: `flutter build appbundle --release`
   - Testar no device real com AAB
   - Confirmar 3 tipos de rota funcionando

2. **Submeter ao Play Store** (2 horas)
   - Seguir guia: `SUBMISSAO_PLAY_STORE.md`
   - Upload do AAB (42.8 MB)
   - Preencher Store Listing
   - Screenshots e assets

3. **Monitorar após lançamento** (primeiros 7 dias)
   - Verificar dashboard diariamente
   - Confirmar custos zerados
   - Ajustar cotas se necessário

---

**Status:** ✅ Configuração pronta para produção com IP dinâmico

**Última atualização:** 5 de novembro de 2025
