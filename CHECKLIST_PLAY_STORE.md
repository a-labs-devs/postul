# ✅ CHECKLIST - Preparação para Play Store

## 🎯 PROGRESSO ATUAL: 40%

---

## ✅ FASE 1 - SEGURANÇA (CONCLUÍDA)

- [x] JWT_SECRET rotacionado
- [x] WEBHOOK_SECRET rotacionado  
- [x] DB_PASSWORD rotacionado
- [x] .env removido do Git
- [x] .env.example criado
- [x] .gitignore atualizado
- [x] Script de geração de secrets criado
- [x] Documentação de segurança criada

---

## ✅ FASE 2 - CONFIGURAÇÃO ANDROID (CONCLUÍDA)

- [x] ApplicationId mudado: `com.example.postul` → `com.alabsv.postul`
- [x] Namespace atualizado
- [x] AndroidManifest.xml atualizado
- [x] TargetSdk ajustado: 36 → 34
- [x] ProGuard habilitado
- [x] Configuração de signing release criada
- [x] key.properties.example criado
- [x] Keystore protegido no .gitignore
- [x] Guia de assinatura criado

---

## ⏳ FASE 3 - AÇÕES MANUAIS PENDENTES

### 🔴 CRÍTICAS (Faça AGORA):

#### 1. Atualizar Senha do PostgreSQL
```sql
-- Conecte no servidor alabsv.ddns.net
psql -U admin -d postos_db
ALTER USER admin WITH PASSWORD 'wvuWh1ecP4A5brgycr9w';
\q
```

#### 2. Gerar Keystore de Release
```powershell
cd C:\Users\jean_\Documents\GitHub\postul\app\android

keytool -genkey -v `
  -keystore postul-release-key.jks `
  -keyalg RSA `
  -keysize 2048 `
  -validity 10000 `
  -alias postul-release-key
```

#### 3. Criar key.properties
```properties
# Criar em: app/android/key.properties
storePassword=SUA_SENHA_FORTE
keyPassword=SUA_SENHA_FORTE
keyAlias=postul-release-key
storeFile=../postul-release-key.jks
```

#### 4. Rotacionar Google API Keys
🔗 https://console.cloud.google.com/apis/credentials

**Deletar e recriar:**
- Places API (backend)
- Maps SDK for Android (app)

**Configurar restrições:**
- Places API: IP do servidor
- Maps Android: Package `com.alabsv.postul`

**Atualizar em:**
- `backend/.env` → GOOGLE_PLACES_API_KEY
- `app/android/app/src/main/AndroidManifest.xml` → API_KEY

#### 5. Gerar Nova App Password do Gmail
🔗 https://myaccount.google.com/apppasswords

1. Revogar senha antiga
2. Gerar nova
3. Atualizar em `backend/.env`

---

## 🟡 FASE 4 - TESTES E BUILD

- [ ] Testar app com novo applicationId
- [ ] Resolver erros de compilação
- [ ] Testar em dispositivo Android real
- [ ] Build de teste: `flutter build apk --debug`
- [ ] Build de release: `flutter build appbundle --release`
- [ ] Verificar assinatura do AAB
- [ ] Testar AAB instalado em dispositivo

---

## 🟠 FASE 5 - ASSETS E MARKETING

### Ícone do App:
- [ ] Criar ícone 512x512px (PNG)
- [ ] Gerar adaptive icon
- [ ] Atualizar `mipmap-*` folders

### Screenshots:
- [ ] Tirar 2-8 screenshots (1920x1080 ou 1280x720)
- [ ] Capturas de: Mapa, Lista, Navegação, Detalhes

### Textos:
- [ ] Título: "POSTUL - Posto Mais Barato" (30 caracteres)
- [ ] Descrição curta (80 caracteres)
- [ ] Descrição completa (até 4000 caracteres)
- [ ] Feature graphic (1024x500px)

---

## 🟢 FASE 6 - LEGAL E COMPLIANCE

### Política de Privacidade:
- [ ] Criar documento de política de privacidade
- [ ] Hospedar em HTTPS (sugestão: GitHub Pages)
- [ ] URL: `https://a-labs-devs.github.io/postul/privacy-policy.html`

### Termos de Uso:
- [ ] Criar termos de uso
- [ ] Hospedar em HTTPS

### Declarações Play Store:
- [ ] Justificar uso de localização em background
- [ ] Declarar coleta de dados
- [ ] Preencher questionário de conteúdo
- [ ] Definir classificação etária (Livre)

---

## 🔵 FASE 7 - PLAY CONSOLE

### Conta e Configuração:
- [ ] Criar conta Google Play Developer (US$ 25)
- [ ] Preencher informações da empresa/desenvolvedor
- [ ] Configurar email de contato
- [ ] Configurar website (opcional)

### Criação do App:
- [ ] Criar novo app no Play Console
- [ ] Nome: POSTUL - Posto Mais Barato
- [ ] Idioma padrão: Português (Brasil)
- [ ] Tipo: App
- [ ] Gratuito ou pago: Gratuito

### Configurações:
- [ ] Selecionar categoria: Mapas & Navegação
- [ ] Tags: gasolina, preços, combustível, navegação
- [ ] Países de distribuição: Brasil (inicial)
- [ ] Configurar faixa de teste (teste fechado)

### Upload:
- [ ] Upload do AAB
- [ ] Preencher notas da versão
- [ ] Enviar para revisão interna
- [ ] Testar versão interna
- [ ] Promover para produção

---

## 📊 ESTIMATIVA DE TEMPO RESTANTE

| Fase | Tempo | Status |
|------|-------|--------|
| Fase 1 - Segurança | ✅ | CONCLUÍDO |
| Fase 2 - Config Android | ✅ | CONCLUÍDO |
| Fase 3 - Ações Manuais | 2-3 horas | PENDENTE |
| Fase 4 - Testes e Build | 3-4 horas | PENDENTE |
| Fase 5 - Assets | 4-6 horas | PENDENTE |
| Fase 6 - Legal | 2-3 horas | PENDENTE |
| Fase 7 - Play Console | 1-2 horas | PENDENTE |
| **TOTAL RESTANTE** | **12-18 horas** | **60% FALTA** |

---

## 🚨 BLOQUEADORES ATUAIS

### Não pode buildar release sem:
1. ❌ Keystore gerado
2. ❌ key.properties configurado
3. ❌ Nova Google Maps API key

### Não pode publicar sem:
1. ❌ Política de privacidade
2. ❌ Screenshots
3. ❌ Ícones personalizados
4. ❌ Conta Play Developer

---

## 📝 PRÓXIMOS PASSOS IMEDIATOS

### 🔴 AGORA (30 minutos):
1. Gerar keystore
2. Criar key.properties
3. Testar build: `flutter build apk --debug`

### 🟡 HOJE (2-3 horas):
4. Rotacionar Google API keys
5. Atualizar senha PostgreSQL
6. Gerar nova App Password Gmail
7. Build de release

### 🟢 ESTA SEMANA (1-2 dias):
8. Criar política de privacidade
9. Tirar screenshots
10. Criar ícones
11. Escrever descrições

### 🔵 SEMANA QUE VEM:
12. Criar conta Play Developer
13. Configurar app no Play Console
14. Upload e revisão

---

## 💡 DICAS FINAIS

### Para acelerar o processo:
- ✅ Use templates de política de privacidade
- ✅ Contrate designer para ícones (Fiverr, 99designs)
- ✅ Use Canva para screenshots com overlays
- ✅ Copie descrições de apps similares (adapte)

### Para evitar rejeição:
- ✅ Teste MUITO antes de enviar
- ✅ Preencha TUDO no Play Console
- ✅ Seja honesto sobre permissões
- ✅ Responda perguntas detalhadamente

### Recursos úteis:
- 📖 https://developer.android.com/distribute
- 🎨 https://romannurik.github.io/AndroidAssetStudio/
- 📝 https://www.privacypolicytemplate.net/
- 🖼️ https://www.canva.com/templates/screenshots/

---

**Última atualização**: 2024-11-04  
**Status**: 40% Completo | 60% Restante  
**Próxima revisão**: Após gerar keystore
