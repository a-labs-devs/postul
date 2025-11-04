# 🏗️ Arquitetura de Requisições - Google Maps API

## 📊 Diagrama do Fluxo Atual

```
┌─────────────────┐
│   APP FLUTTER   │
│  (com.alabsv.   │
│    postul)      │
└────────┬────────┘
         │ HTTP Request
         │ GET /api/routes/calculate
         │
         ▼
┌─────────────────────────┐
│   BACKEND NODE.JS       │
│   alabsv.ddns.net:3001  │
│   IP: 45.160.114.50     │
└───────────┬─────────────┘
            │ HTTPS Request
            │ https://maps.googleapis.com/maps/api/directions/json
            │ ?origin=...&destination=...
            │ &key=AIzaSyD1p9PvEu2CwvKt...
            │
            ▼
┌─────────────────────────┐
│   GOOGLE MAPS API       │
│   Directions API        │
│                         │
│   ✅ Valida API Key     │
│   ✅ Verifica IP origem │
│   ✅ Checa restrições   │
└─────────────────────────┘
```

---

## 🔍 Análise do Problema

### Como o Google Vê a Requisição

Quando você configurou restrições para "Android apps only":

```json
{
  "restrictions": {
    "androidKeyRestrictions": {
      "allowedApplications": [
        {
          "sha1Fingerprint": "87:4E:02:9B:D7:CD:F9:0D:D0:2A:4F:22:7A:1A:4C:06:16:E5:AB:7A",
          "packageName": "com.alabsv.postul"
        },
        {
          "sha1Fingerprint": "DC:59:1B:E0:49:62:C9:B2:DF:0B:8C:E3:CD:14:2D:74:04:5F:71:CA",
          "packageName": "com.alabsv.postul"
        }
      ]
    }
  }
}
```

**Google espera:**
- Requisição vinda de um app Android
- Com certificado SHA-1 válido
- Package name correto

**Google recebe:**
- ❌ Requisição vinda de IP 45.160.114.50 (servidor web)
- ❌ Sem referer (header HTTP vazio)
- ❌ Sem assinatura SHA-1 do app

**Resultado:** `REQUEST_DENIED`

---

## 🔐 Tipos de Restrições da API Key

### 1️⃣ Android Apps (Atual - Não Funciona com Backend)

```
Restrictions Type: Android apps
Allowed Applications:
  - com.alabsv.postul (SHA1: 87:4E:02...)
  - com.alabsv.postul (SHA1: DC:59:1B...)

✅ Aceita: Requisições do app Android assinado
❌ Rejeita: Requisições de servidores web (backend)
```

### 2️⃣ IP Addresses (Necessário para Backend)

```
Restrictions Type: IP addresses
Allowed IPs:
  - 45.160.114.50

✅ Aceita: Requisições vindas do servidor backend
❌ Rejeita: Requisições de outros IPs
```

### 3️⃣ HTTP Referrers (Para Sites)

```
Restrictions Type: HTTP referrers (web sites)
Allowed Referrers:
  - https://alabsv.ddns.net/*
  - http://alabsv.ddns.net/*

✅ Aceita: Requisições de páginas web do domínio
❌ Rejeita: Requisições sem header "Referer"
```

### 4️⃣ None (Sem Restrições - Perigoso)

```
Restrictions Type: None

✅ Aceita: Qualquer requisição de qualquer origem
⚠️  RISCO: Chave pode ser roubada e usada por terceiros
💰 CUSTO: Pode gerar cobranças inesperadas
```

---

## 🎯 Soluções Possíveis

### Solução 1: IP Restrictions (RECOMENDADA) ✅

**Configuração:**
```
Restrictions Type: IP addresses
Allowed IPs:
  - 45.160.114.50
```

**Prós:**
- ✅ Protege contra uso não autorizado
- ✅ Backend pode fazer requisições
- ✅ Fácil de configurar

**Contras:**
- ⚠️ Se o IP do servidor mudar, precisa atualizar
- ⚠️ Não funciona se backend usar proxy/load balancer

---

### Solução 2: Duas API Keys Separadas ⚡

**Key 1 - Android Apps:**
```
Name: postul-android-key
Type: Android apps
SHA-1: 87:4E:02... e DC:59:1B...
Package: com.alabsv.postul
APIs: Maps SDK for Android, Places API
```

**Key 2 - Backend:**
```
Name: postul-backend-key
Type: IP addresses
IP: 45.160.114.50
APIs: Directions API, Geolocation API
```

**Implementação:**

`AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSy...ANDROID_KEY"/>
```

`backend/.env`:
```
GOOGLE_MAPS_API_KEY=AIzaSy...BACKEND_KEY
```

**Prós:**
- ✅ Separação de responsabilidades
- ✅ Segurança máxima
- ✅ Fácil monitorar uso por origem

**Contras:**
- ⚠️ Precisa gerenciar 2 keys
- ⚠️ Mais complexo de manter

---

### Solução 3: Requisições Diretas do App 🔄

Eliminar o backend como intermediário para rotas:

**Antes (Atual):**
```
App → Backend → Google API
```

**Depois:**
```
App → Google API (direto)
Backend → Apenas para dados de postos/preços
```

**Mudanças necessárias:**

`lib/services/route_service.dart`:
```dart
// ANTES: Chama backend
final response = await http.get(
  Uri.parse('http://alabsv.ddns.net:3001/api/routes/calculate'),
);

// DEPOIS: Chama Google direto
final response = await http.get(
  Uri.parse('https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$dest&key=$apiKey'),
);
```

**Prós:**
- ✅ Funciona com restrições Android
- ✅ Reduz carga no backend
- ✅ Menor latência

**Contras:**
- ⚠️ API key exposta no app (mas protegida por SHA-1)
- ⚠️ Precisa reescrever código
- ⚠️ Teste complexo

---

## 🔎 Como o Google Identifica a Origem

### Requisições de Apps Android

```http
GET /maps/api/directions/json?... HTTP/1.1
Host: maps.googleapis.com
X-Android-Package: com.alabsv.postul
X-Android-Cert: 874E029BD7CDF90DD02A4F227A1A4C0616E5AB7A
```

Google verifica:
1. ✅ Package name corresponde?
2. ✅ SHA-1 certificate corresponde?
3. ✅ API habilitada para Android?

### Requisições de Servidores (Backend)

```http
GET /maps/api/directions/json?... HTTP/1.1
Host: maps.googleapis.com
X-Forwarded-For: 45.160.114.50
```

Google verifica:
1. ✅ IP está na allowlist?
2. ✅ API habilitada para IPs?
3. ❌ Não há X-Android-Package (requisição web)

---

## 📈 Recomendação Final

Para seu caso específico (app pronto para Play Store):

### ✅ Usar Solução 1: IP Restrictions

**Motivo:**
- Rápido de implementar (5 minutos)
- Não precisa alterar código
- Funciona imediatamente após propagação

**Passos:**
1. Google Cloud Console → API Key
2. Mudar de "Android apps" para "IP addresses"
3. Adicionar: `45.160.114.50`
4. Salvar e aguardar 15 minutos

**Quando usar Solução 2 (duas keys):**
- Se você quiser segurança máxima
- Se tiver tempo para configurar
- Se planeja escalar o backend (múltiplos IPs)

**Quando usar Solução 3 (direto do app):**
- Se você NÃO confia no backend atual
- Se quer reduzir dependências
- Se tem tempo para refatorar código

---

## 🔐 Segurança das Soluções

| Solução | Segurança | Facilidade | Risco de Vazamento |
|---------|-----------|------------|-------------------|
| IP Restrictions | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Baixo |
| Duas Keys | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | Muito Baixo |
| Direto do App | ⭐⭐⭐⭐ | ⭐⭐ | Baixo (SHA-1) |
| Sem Restrições | ⭐ | ⭐⭐⭐⭐⭐ | ALTO ⚠️ |

---

## 📝 Logs para Debug

### No App Flutter (logcat)

```bash
adb logcat -s flutter:I
```

Procure por:
```
I/flutter: 🔍 Buscando rota...
I/flutter: 🔗 URL: https://maps.googleapis.com/...
I/flutter: 📡 Status HTTP: 200
I/flutter: 📦 Response status: REQUEST_DENIED  ← ERRO AQUI
```

### No Backend Node.js

```javascript
// backend/src/routes/routes.js
app.get('/api/routes/calculate', async (req, res) => {
  console.log('📍 IP do cliente:', req.ip);
  console.log('📍 X-Forwarded-For:', req.headers['x-forwarded-for']);
  
  const response = await fetch(googleMapsUrl);
  console.log('📡 Google status:', response.status);
  const data = await response.json();
  console.log('📦 Google response:', data.status);
});
```

---

**Data:** 04/11/2025  
**Versão:** 1.0  
**Status:** ✅ Documentação completa
