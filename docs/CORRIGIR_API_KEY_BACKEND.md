# 🔧 Corrigir Restrições da API Key para Backend

## 📋 Problema Identificado

O erro **REQUEST_DENIED** ocorre porque:

```
Request received from IP address 45.160.114.50, with empty referer
```

**IP 45.160.114.50** = Seu servidor backend (alabsv.ddns.net)

### Por que isso acontece?

O app Flutter está fazendo requisições à API do Google Directions através do **backend como proxy**. Quando você configurou restrições apenas para "Android apps" com SHA-1, o Google bloqueou as requisições vindas do servidor.

**Fluxo atual:**
```
App Flutter → Backend (45.160.114.50) → Google Maps API ❌ BLOQUEADO
```

---

## ✅ SOLUÇÃO: Adicionar IP do Backend às Restrições

### Passo 1: Acessar o Google Cloud Console

1. Abra: https://console.cloud.google.com/
2. Faça login com sua conta Google
3. Selecione o projeto: **postul-440420**

### Passo 2: Abrir a API Key

1. No menu lateral, vá em: **APIs & Services** → **Credentials**
2. Localize a API Key: **AIzaSyD1p9PvEu2CwvKtFbyDUT0ocLjWc5hCJJw**
3. Clique no nome da chave para editar

### Passo 3: Modificar as Restrições de Aplicação

#### Opção A: Mudar para IP Restrictions (RECOMENDADO) ✅

1. Em **Application restrictions**, selecione:
   - ☑️ **IP addresses (web servers, cron jobs, etc.)**

2. Clique em **ADD AN ITEM**

3. Digite o IP do seu servidor backend:
   ```
   45.160.114.50
   ```

4. Clique em **DONE**

5. Clique em **SAVE** no final da página

#### Opção B: Manter Android Apps + Criar Nova Key para Backend

Se você quiser manter a segurança Android separada:

1. Mantenha a key atual **AIzaSyD1p9PvEu2CwvKt...** com restrições Android
2. Crie uma NOVA API Key para o backend:
   - Clique em **CREATE CREDENTIALS** → **API Key**
   - Copie a nova chave
   - Configure com **IP addresses**
   - Adicione: `45.160.114.50`
   - Ative as mesmas 4 APIs
3. Use a nova chave no código do backend

---

## 🔍 Passo 4: Verificar Propagação (5-15 minutos)

Após salvar, aguarde a propagação das mudanças:

### Teste 1: Via Browser (Imediato)

Abra no navegador (substitua ORIGIN e DEST):
```
https://maps.googleapis.com/maps/api/directions/json?origin=-23.4302277,-46.7285062&destination=-23.5809658,-46.730848&key=AIzaSyD1p9PvEu2CwvKtFbyDUT0ocLjWc5hCJJw&language=pt-BR
```

**Resultado esperado:**
- ✅ Status: `OK`
- ✅ Routes: Array com rotas

**Se ainda der erro:**
- ⏳ Aguarde mais 5-10 minutos
- 🔄 Teste novamente

### Teste 2: No App Flutter

1. Abra o app no dispositivo
2. Toque em um posto no mapa
3. Clique em **"Ir"** ou **"Rotas"**
4. Aguarde o cálculo das rotas

**Resultado esperado:**
```
✅ 4 opções de rota exibidas:
   - Rota Rápida
   - Rota Curta
   - Sem Pedágio
   - Sem Rodovia
```

---

## 📊 Verificações Adicionais

### Confirmar IP do Servidor Backend

Execute no PowerShell:
```powershell
nslookup alabsv.ddns.net
```

**Resultado esperado:**
```
Address:  45.160.114.50
```

Se o IP mudou, use o novo IP nas restrições.

---

## 🔐 Segurança

### Restrições de API Habilitadas

Certifique-se de que apenas estas 4 APIs estão habilitadas:

1. ✅ **Maps SDK for Android**
2. ✅ **Places API (New)**
3. ✅ **Directions API**
4. ✅ **Geolocation API**

### Monitoramento de Uso

Configure alertas no Google Cloud Console:

1. Vá em **APIs & Services** → **Dashboard**
2. Clique em **Quotas**
3. Configure alertas para:
   - 90% do limite diário
   - 95% do limite diário

---

## 🚨 Troubleshooting

### Erro persiste após 15 minutos?

#### 1. Verificar se salvou corretamente

- Volte na API Key
- Confirme que `45.160.114.50` está listado
- Status: **Active**

#### 2. Limpar cache do app

```powershell
cd C:\Users\jean_\Documents\GitHub\postul\app
flutter clean
flutter pub get
flutter run -d 0082530777
```

#### 3. Verificar logs do backend

Se você tem acesso SSH ao servidor `alabsv.ddns.net`:

```bash
# Ver logs do Node.js
pm2 logs postul-backend

# Ou se estiver rodando diretamente:
cd /caminho/para/backend
npm run dev
```

Procure por erros de API nas requisições.

#### 4. Testar requisição direta do servidor

No servidor backend, execute:

```bash
curl "https://maps.googleapis.com/maps/api/directions/json?origin=-23.4302277,-46.7285062&destination=-23.5809658,-46.730848&key=AIzaSyD1p9PvEu2CwvKtFbyDUT0ocLjWc5hCJJw&language=pt-BR"
```

**Se der erro:** As restrições não propagaram ainda, aguarde mais.

---

## 📱 Alternativa Temporária (Desenvolvimento)

Se precisar testar AGORA sem esperar propagação:

### Criar API Key SEM Restrições (Apenas Dev)

1. No Google Cloud Console → **Credentials**
2. **CREATE CREDENTIALS** → **API Key**
3. Copie a nova chave: `AIzaSy...XXXXXXX`
4. **NÃO ADICIONE RESTRIÇÕES** (deixe "None")
5. Ative as 4 APIs necessárias

### Usar no AndroidManifest.xml

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSy...XXXXXXX"/>
```

⚠️ **ATENÇÃO:** Esta chave SEM restrições deve ser usada APENAS em desenvolvimento local. **NUNCA faça commit no Git!**

Adicione ao `.gitignore`:
```
app/android/app/src/main/AndroidManifest.xml.dev
```

---

## ✅ Checklist Final

Após configurar, confirme:

- [ ] IP `45.160.114.50` adicionado nas restrições
- [ ] Aguardei 15 minutos de propagação
- [ ] Teste no browser retorna `status: OK`
- [ ] App calcula rotas sem erros
- [ ] 4 opções de rota são exibidas
- [ ] Não há erros `REQUEST_DENIED` nos logs

---

## 📞 Suporte

Se o problema persistir após 30 minutos:

1. **Verificar Status do Google Cloud:**
   - https://status.cloud.google.com/

2. **Abrir ticket de suporte:**
   - Console → ☰ → Support → Create Case

3. **Informações a incluir:**
   - API Key: `AIzaSyD1p9PvEu2CwvKt...`
   - IP: `45.160.114.50`
   - Erro: `REQUEST_DENIED`
   - APIs habilitadas: Directions, Maps SDK, Places, Geolocation

---

## 🎯 Próximos Passos (Após Correção)

1. **Testar todas as funcionalidades:**
   - Cálculo de rotas ✅
   - Navegação GPS ✅
   - Busca de postos ✅
   - Tela de detalhes ✅

2. **Build Release AAB:**
   ```powershell
   cd C:\Users\jean_\Documents\GitHub\postul\app
   flutter clean
   flutter build appbundle --release
   ```

3. **Submeter ao Play Store:**
   - Siga o guia: `SUBMISSAO_PLAY_STORE.md`

---

**Data de criação:** 04/11/2025  
**Problema:** REQUEST_DENIED - IP 45.160.114.50 não autorizado  
**Solução:** Adicionar IP do backend nas restrições da API Key  
**Status:** 🟡 Aguardando propagação (15-30 min)
