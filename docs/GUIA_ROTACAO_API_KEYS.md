# 🔑 Guia: Rotacionar Google API Keys

## 🚨 **POR QUE ROTACIONAR?**

As seguintes keys foram **EXPOSTAS PUBLICAMENTE** no GitHub:

### ❌ Keys Comprometidas:
```
Places API (Backend): AIzaSyDV5i7sBbO_C5EJ2VcdGlSOyJkFM5QeXTQ
Maps Android (App):    AIzaSyDTIpHb1i5mrduNAwRHFV1zamBhWrhhgXc
```

**Riscos:**
- Qualquer pessoa pode usar suas keys
- Cobrança indevida na sua conta Google Cloud
- Ataques de negação de serviço (DoS)
- Violação de limites de quota

---

## 📋 **PASSO A PASSO**

### **1. Acessar Google Cloud Console**

🔗 https://console.cloud.google.com/

1. Login com sua conta Google
2. Selecione o projeto do POSTUL (ou crie um novo)

---

### **2. Deletar Keys Antigas (CRÍTICO)**

#### 2.1. Ir para Credentials:
```
APIs & Services → Credentials
```

#### 2.2. Encontrar as keys antigas:
- `AIzaSyDV5i7sBbO_C5EJ2VcdGlSOyJkFM5QeXTQ`
- `AIzaSyDTIpHb1i5mrduNAwRHFV1zamBhWrhhgXc`

#### 2.3. Para cada key:
1. Clique nos 3 pontos (⋮)
2. **Delete**
3. Confirme

---

### **3. Criar Nova Key para Places API (Backend)**

#### 3.1. Criar Key:
1. Clique em **"+ CREATE CREDENTIALS"**
2. Selecione **"API key"**
3. Uma nova key será gerada

#### 3.2. Configurar Restrições:
1. Clique em **"RESTRICT KEY"**
2. **Nome:** `POSTUL Backend - Places API`
3. **Application restrictions:**
   - Selecione: **"IP addresses"**
   - Adicione o IP do servidor: 
     ```
     # Descobrir IP do servidor:
     # SSH no alabsv.ddns.net e execute:
     curl ifconfig.me
     
     # Ou use o domínio se suportado:
     alabsv.ddns.net
     ```

4. **API restrictions:**
   - Selecione: **"Restrict key"**
   - Habilite apenas:
     - ✅ **Places API**
     - ✅ **Geocoding API** (se usar)
     - ✅ **Directions API** (se usar)

5. Clique **"SAVE"**

#### 3.3. Copiar Nova Key:
```
GOOGLE_PLACES_API_KEY=SUA_NOVA_KEY_AQUI
```

---

### **4. Criar Nova Key para Maps Android (App)**

#### 4.1. Criar Key:
1. **"+ CREATE CREDENTIALS"** → **"API key"**

#### 4.2. Configurar Restrições:
1. Clique em **"RESTRICT KEY"**
2. **Nome:** `POSTUL Android - Maps SDK`
3. **Application restrictions:**
   - Selecione: **"Android apps"**
   - Clique **"+ ADD AN ITEM"**
   - **Package name:** `com.alabsv.postul`
   - **SHA-1 certificate fingerprint:**
     ```bash
     # No Windows PowerShell:
     cd C:\Users\jean_\Documents\GitHub\postul\app\android
     
     keytool -list -v -keystore postul-release-key.jks -alias postul-release-key
     # Senha: Postul2024@Secure!Key#
     
     # Copie o SHA-1 que aparece em "Certificate fingerprints"
     ```

4. **API restrictions:**
   - Selecione: **"Restrict key"**
   - Habilite apenas:
     - ✅ **Maps SDK for Android**
     - ✅ **Directions API**
     - ✅ **Geocoding API**

5. Clique **"SAVE"**

#### 4.3. Copiar Nova Key:
```
GOOGLE_MAPS_ANDROID_KEY=SUA_NOVA_KEY_AQUI
```

---

### **5. Verificar APIs Habilitadas**

Vá em: **APIs & Services → Library**

Certifique-se que estão habilitadas:
- ✅ **Places API**
- ✅ **Maps SDK for Android**
- ✅ **Directions API**
- ✅ **Geocoding API**

Se não estiver, clique em cada uma e clique **"ENABLE"**

---

### **6. Atualizar no Código**

#### 6.1. Backend (.env):
```bash
# Edite: backend/.env
GOOGLE_PLACES_API_KEY=SUA_NOVA_PLACES_KEY_AQUI
```

**⚠️ NÃO COMMITE .env NO GIT!**

#### 6.2. Android (AndroidManifest.xml):
```xml
<!-- Edite: app/android/app/src/main/AndroidManifest.xml -->

<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="SUA_NOVA_MAPS_ANDROID_KEY_AQUI"/>
```

---

### **7. Configurar Billing (se necessário)**

#### 7.1. Verificar Quota:
```
APIs & Services → Dashboard → Quota
```

#### 7.2. Habilitar Billing:
Se ainda não habilitou:
1. **Billing → Link a billing account**
2. Cartão de crédito necessário
3. **Não se preocupe:** Google dá $200/mês de crédito grátis
4. Configure alertas de budget

---

### **8. Testar Novas Keys**

#### 8.1. Testar Backend:
```bash
# Reinicie o servidor
pm2 restart all

# Teste o endpoint
curl http://alabsv.ddns.net:3001/api/postos/proximos?lat=-23.5505&lng=-46.6333
```

#### 8.2. Testar App:
```bash
cd C:\Users\jean_\Documents\GitHub\postul\app

flutter clean
flutter pub get
flutter run
```

---

### **9. Configurar Alertas de Quota**

#### 9.1. Criar Alerta:
```
APIs & Services → Dashboard → Quotas → SET QUOTA ALERTS
```

#### 9.2. Configurar:
- **Places API:** Alerta em 80% da quota
- **Maps API:** Alerta em 80% da quota
- **Email:** jbiersack87@gmail.com

---

### **10. Monitorar Uso**

#### 10.1. Dashboard:
```
APIs & Services → Dashboard
```

Monitore:
- Requisições por dia
- Erros
- Latência
- Custos

#### 10.2. Configurar Budget:
```
Billing → Budgets & Alerts
```

Configure budget mensal (ex: $50) com alertas em:
- 50% do budget
- 90% do budget
- 100% do budget

---

## ✅ **CHECKLIST FINAL**

- [ ] Keys antigas deletadas do Google Cloud Console
- [ ] Nova Places API key criada com restrições de IP
- [ ] Nova Maps Android key criada com restrições de package
- [ ] SHA-1 fingerprint adicionado à key Android
- [ ] APIs necessárias habilitadas
- [ ] backend/.env atualizado com nova Places key
- [ ] AndroidManifest.xml atualizado com nova Maps key
- [ ] .env NÃO commitado no Git
- [ ] Billing configurado (se necessário)
- [ ] Alertas de quota configurados
- [ ] Budget configurado
- [ ] Backend testado e funcionando
- [ ] App testado e funcionando
- [ ] Monitoramento ativo

---

## 🔒 **BOAS PRÁTICAS**

### ✅ FAÇA:
- Sempre use restrições de API
- Rotacione keys a cada 6 meses
- Monitore uso diariamente
- Configure alertas de budget
- Use keys diferentes para dev/prod
- Documente mudanças

### ❌ NÃO FAÇA:
- Commitar keys no Git
- Compartilhar keys por email/Slack
- Usar mesma key para tudo
- Deixar keys sem restrições
- Ignorar alertas de quota
- Expor keys em logs

---

## 💰 **CUSTOS ESPERADOS**

### Limites Gratuitos (por mês):
- **Places API:** $200 crédito = ~28.500 requisições
- **Maps SDK:** $200 crédito = ~28.500 carregamentos
- **Directions API:** $200 crédito = ~40.000 requisições

### Estimativa POSTUL:
Com 1.000 usuários ativos/dia:
- Places API: ~2.000 req/dia = ~60.000/mês
- Maps: ~1.000 carregamentos/dia = ~30.000/mês
- **Custo estimado:** $40-60/mês

**Dica:** Configure limite de gastos para não ter surpresas!

---

## 🆘 **TROUBLESHOOTING**

### Erro: "API key not found"
**Solução:** Verifique se copiou a key corretamente

### Erro: "This API key is not authorized"
**Solução:** Verifique restrições de IP/package name

### Erro: "Quota exceeded"
**Solução:** Aumente quota ou otimize requisições

### Maps não carrega no app
**Solução:** 
1. Verifique SHA-1 fingerprint
2. Verifique package name exato
3. Aguarde 5-10 minutos após criar key

---

## 📞 **SUPORTE GOOGLE CLOUD**

- 🔗 https://console.cloud.google.com/support
- 📧 Abrir ticket de suporte
- 💬 Community: https://stackoverflow.com/questions/tagged/google-maps

---

**Última atualização**: 2024-11-04  
**Tempo estimado**: 30-45 minutos  
**Dificuldade**: Média
