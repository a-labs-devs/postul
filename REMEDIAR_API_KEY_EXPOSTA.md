# 🔴 REMEDIAÇÃO - API KEY EXPOSTA NO GITHUB

## ⚠️ Situação
Google detectou API key pública: `AIzaSyCNBbClo1L_0qU4mVxEybrdzbRHVfWfG-A`
- **Projeto:** Postul (id: postul-6049c)
- **Commit:** https://github.com/a-labs-devs/postul/commit/b7395b55281496c7e9d3e4a12c1dec9f84dbb1d1
- **Status:** Key antiga (já rotacionada, mas ainda ativa no Google Cloud)

## ✅ Ações Tomadas

### 1. Verificação de Código ✅
- Key antiga **NÃO está mais no código**
- Key atual em uso: `AIzaSyD1p9PvEu2CwvKtFbyDUT0ocLjWc5hCJJw`

### 2. Deletar Key Comprometida no Google Cloud (URGENTE)

**Passo a passo:**

1. **Acesse o Google Cloud Console:**
   ```
   https://console.cloud.google.com/apis/credentials?project=postul-6049c
   ```

2. **Localize a key comprometida:**
   - Procure por: `AIzaSyCNBbClo1L_0qU4mVxEybrdzbRHVfWfG-A`
   - Ou procure keys criadas antes de hoje

3. **DELETE a key (NÃO regenere!):**
   - Clique nos 3 pontinhos ao lado da key
   - **"Delete API key"**
   - Confirme a exclusão
   - ⚠️ **IMPORTANTE:** Delete completamente, não apenas regenere!

4. **Verifique a key atual está com restrições:**
   - Key atual: `AIzaSyD1p9PvEu2CwvKtFbyDUT0ocLjWc5hCJJw`
   - Status desejado: **Com restrições de aplicativo Android**
   - Package name: `com.alabsv.postul`
   - SHA-1: (do seu keystore)

### 3. Limpar Histórico do Git (Opcional mas Recomendado)

A key antiga ainda está visível no histórico do Git. Para remover:

**Opção A: Reescrever histórico (CUIDADO - afeta colaboradores)**
```bash
# Instalar BFG Repo-Cleaner
# https://rtyley.github.io/bfg-repo-cleaner/

# Baixar BFG
# Executar:
java -jar bfg.jar --replace-text passwords.txt postul.git

# Onde passwords.txt contém:
AIzaSyCNBbClo1L_0qU4mVxEybrdzbRHVfWfG-A
```

**Opção B: Tornar repositório privado (MAIS SIMPLES)**
```
1. Acesse: https://github.com/a-labs-devs/postul/settings
2. Role até "Danger Zone"
3. "Change repository visibility" → "Make private"
```

⚠️ **ATENÇÃO:** Se tornar privado, o GitHub Pages será desativado no plano gratuito!

### 4. Adicionar Restrições à Key Atual

**No Google Cloud Console:**

1. Acesse: https://console.cloud.google.com/apis/credentials?project=postul-6049c
2. Clique na key atual: `AIzaSyD1p9PvEu2CwvKtFbyDUT0ocLjWc5hCJJw`
3. Em **"Application restrictions"**:
   - Selecione: **"Android apps"**
   - Adicione:
     - Package name: `com.alabsv.postul`
     - SHA-1: Pegue com o comando abaixo

**Para obter SHA-1 do release keystore:**
```powershell
cd C:\Users\jean_\Documents\GitHub\postul\app\android
keytool -list -v -keystore ..\..\..\postul-release-key.jks -alias postul
# Senha: postul123456
```

4. Em **"API restrictions"**:
   - Selecione: **"Restrict key"**
   - Marque apenas:
     - ✅ Maps SDK for Android
     - ✅ Places API (New)
     - ✅ Directions API
     - ✅ Geolocation API

5. Clique em **"Save"**

### 5. Monitorar Uso Indevido

**Verificar se houve uso abusivo da key:**

1. Acesse: https://console.cloud.google.com/apis/dashboard?project=postul-6049c
2. Verifique métricas de uso nos últimos 7 dias
3. Procure por:
   - Picos de uso anormais
   - Requisições de locais estranhos
   - Erros 403 (tentativas de uso indevido)

4. Verifique billing:
   - https://console.cloud.google.com/billing?project=postul-6049c
   - Confirme que não há cobranças inesperadas

### 6. Configurar Alertas de Billing

**Prevenir cobranças inesperadas:**

1. Acesse: https://console.cloud.google.com/billing/budgets?project=postul-6049c
2. **"Create Budget"**
3. Configure:
   - Name: "POSTUL - Alert Budget"
   - Budget amount: R$ 50/mês (ou o valor desejado)
   - Alerts: 50%, 90%, 100%
   - Email: jbiersack87@gmail.com

### 7. Adicionar .gitignore (Prevenção)

Já temos `.gitignore` configurado, mas reforce:

```gitignore
# API Keys e Secrets
*.env
.env
.env.*
key.properties
google-services.json
keystore.jks
*.jks
*.keystore
secrets.yaml
secrets.json
```

## 📊 Status Final

- ✅ Key antiga removida do código
- ⏳ **PENDENTE:** Deletar key no Google Cloud Console
- ⏳ **PENDENTE:** Adicionar restrições à key atual
- ⏳ **PENDENTE:** Verificar billing/uso
- ⏳ **PENDENTE:** Configurar alertas

## 🔐 Boas Práticas Futuras

1. **NUNCA commite API keys** no Git
2. Use **variáveis de ambiente** para desenvolvimento
3. Use **restrições de aplicativo** sempre
4. **Monitore uso** regularmente
5. **Rotacione keys** a cada 3-6 meses
6. Use **diferentes keys** para dev/prod

## 📧 Responder ao Google

Após remediar, você pode responder ao email do Google confirmando:

```
Hello,

Thank you for the notification.

Actions taken:
1. ✅ The exposed API key has been deleted from Google Cloud Console
2. ✅ New API key with application restrictions has been generated
3. ✅ Added API and application restrictions to prevent abuse
4. ✅ Monitoring billing and usage for anomalies
5. ✅ Configured budget alerts

The key is no longer present in our codebase and we have implemented 
stricter security measures to prevent future exposure.

Best regards,
A-Labs Devs
```

## 🚨 Links Importantes

- **Google Cloud Console:** https://console.cloud.google.com/
- **API Credentials:** https://console.cloud.google.com/apis/credentials?project=postul-6049c
- **API Dashboard:** https://console.cloud.google.com/apis/dashboard?project=postul-6049c
- **Billing:** https://console.cloud.google.com/billing?project=postul-6049c
- **Security Best Practices:** https://cloud.google.com/docs/security/best-practices

---

**Data:** 04/11/2024  
**Responsável:** A-Labs Devs  
**Projeto:** POSTUL  
**Priority:** 🔴 CRÍTICO
