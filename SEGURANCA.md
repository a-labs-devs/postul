# 🔒 Guia de Segurança - POSTUL

## ⚠️ AÇÕES CRÍTICAS REALIZADAS

### ✅ 1. Secrets Rotacionados
- **JWT_SECRET**: Novo secret de 64 caracteres gerado
- **WEBHOOK_SECRET**: Novo secret de 64 caracteres gerado
- **DB_PASSWORD**: Nova senha forte gerada

### ✅ 2. Arquivo .env Protegido
- ❌ Removido do Git: `git rm --cached backend/.env`
- ✅ .gitignore configurado para bloquear
- ✅ .env.example criado com placeholders

---

## 🚨 AÇÕES PENDENTES (VOCÊ PRECISA FAZER)

### 1. **Atualizar Senha do PostgreSQL**
```sql
-- Conecte no PostgreSQL e execute:
ALTER USER admin WITH PASSWORD 'wvuWh1ecP4A5brgycr9w';
```

### 2. **Rotacionar Google API Keys**
🔗 https://console.cloud.google.com/apis/credentials

**API Key Atual (EXPOSTA NO GITHUB!):**
- ❌ `AIzaSyDV5i7sBbO_C5EJ2VcdGlSOyJkFM5QeXTQ` (Places API)
- ❌ `AIzaSyDTIpHb1i5mrduNAwRHFV1zamBhWrhhgXc` (Maps Android)

**Ações necessárias:**
```bash
1. Google Cloud Console → APIs & Services → Credentials
2. DELETAR as keys antigas
3. Criar novas keys:
   - Google Places API (backend)
   - Maps SDK for Android (app)
4. Configurar RESTRIÇÕES:
   - Places API: Restringir por IP do servidor (alabsv.ddns.net)
   - Maps Android: Restringir por package name (com.alabsv.postul)
5. Atualizar em:
   - backend/.env → GOOGLE_PLACES_API_KEY
   - app/android/app/src/main/AndroidManifest.xml → API_KEY
```

### 3. **Gerar Nova App Password do Gmail**
🔗 https://myaccount.google.com/apppasswords

**Password Atual (EXPOSTA!):**
- ❌ `acaa rnqd bpya arfc`

**Ações necessárias:**
```bash
1. Acesse: https://myaccount.google.com/apppasswords
2. REVOGUE a senha antiga
3. Gere nova App Password
4. Atualize em backend/.env → EMAIL_PASSWORD
```

### 4. **Configurar GitHub Secrets (CI/CD)**
🔗 https://github.com/a-labs-devs/postul/settings/secrets/actions

Adicione estes secrets no GitHub:
```
DB_HOST=localhost
DB_PORT=5432
DB_USER=admin
DB_PASSWORD=wvuWh1ecP4A5brgycr9w
DB_NAME=postos_db
PORT=3001
JWT_SECRET=623b640b4350699e48c205e8620b78be8fca5dc15ae5aa5bf013893fab17bd42
JWT_EXPIRES_IN=7d
GOOGLE_PLACES_API_KEY=<NOVA_KEY_AQUI>
EMAIL_USER=jbiersack87@gmail.com
EMAIL_PASSWORD=<NOVA_APP_PASSWORD_AQUI>
WEBHOOK_SECRET=de06ae1ac10cfb271b16536f60f6652d9f02f4ca1788c97df600b096908cda8f
```

### 5. **Limpar Histórico do Git (Opcional mas Recomendado)**
⚠️ Isso reescreve o histórico! Coordene com a equipe.

```bash
# Remover .env de TODO o histórico
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch backend/.env" \
  --prune-empty --tag-name-filter cat -- --all

# Force push (CUIDADO!)
git push origin --force --all
git push origin --force --tags
```

**Alternativa mais segura:**
- Considere começar um novo repositório privado
- Ou aceite que as keys antigas vazaram e apenas rotacione

---

## 📋 CHECKLIST DE SEGURANÇA

### Backend:
- [x] JWT_SECRET rotacionado
- [x] WEBHOOK_SECRET rotacionado
- [x] DB_PASSWORD rotacionado
- [x] .env removido do Git
- [x] .env.example criado
- [ ] Senha do PostgreSQL atualizada no servidor
- [ ] Google Places API key rotacionada
- [ ] Email App Password rotacionada
- [ ] GitHub Secrets configurados

### Frontend (App):
- [ ] Google Maps Android API key rotacionada
- [ ] AndroidManifest.xml atualizado com nova key
- [ ] Package name mudado de `com.example.postul`

### Servidor (alabsv.ddns.net):
- [ ] Atualizar .env no servidor com novos valores
- [ ] Reiniciar serviços: `pm2 restart all`
- [ ] Testar conexão com banco de dados
- [ ] Verificar logs: `pm2 logs`

---

## 🔐 BOAS PRÁTICAS DE SEGURANÇA

### Para Desenvolvimento Local:
1. ✅ Use `.env` para variáveis sensíveis
2. ✅ NUNCA commite `.env` no Git
3. ✅ Sempre use `.env.example` com placeholders
4. ✅ Rotacione secrets regularmente (3-6 meses)

### Para Produção:
1. ✅ Use variáveis de ambiente do sistema
2. ✅ Configure secrets no GitHub Actions
3. ✅ Use gestores de secrets (AWS Secrets Manager, etc)
4. ✅ Habilite logs de auditoria

### Para API Keys:
1. ✅ Configure RESTRIÇÕES no console da API
2. ✅ Use keys diferentes para dev/staging/prod
3. ✅ Monitore uso e custos
4. ✅ Configure alertas de quota

---

## 🚨 O QUE FAZER SE KEYS VAZAREM

### Resposta Imediata (< 1 hora):
1. ✅ REVOGUE a key imediatamente
2. ✅ Gere nova key com restrições
3. ✅ Atualize em todos os ambientes
4. ✅ Monitore uso indevido

### Investigação (< 24 horas):
1. ✅ Verifique logs de acesso da API
2. ✅ Identifique possíveis abusos
3. ✅ Documente o incidente
4. ✅ Implemente medidas preventivas

### Prevenção Futura:
1. ✅ Use git-secrets ou similar
2. ✅ Configure pre-commit hooks
3. ✅ Treine equipe em segurança
4. ✅ Faça auditorias regulares

---

## 📞 CONTATOS DE EMERGÊNCIA

### Google Cloud Support:
- 🔗 https://console.cloud.google.com/support

### GitHub Support:
- 🔗 https://support.github.com/

### PostgreSQL:
- Administrador local do servidor

---

## 📝 LOGS DE SEGURANÇA

### 2024-11-04 - Rotação de Secrets
- ✅ JWT_SECRET rotacionado
- ✅ WEBHOOK_SECRET rotacionado
- ✅ DB_PASSWORD rotacionado
- ✅ .env removido do Git
- ⏳ Aguardando: Rotação de API Keys externas

---

## 🎯 PRÓXIMA REVISÃO

**Data**: 2025-05-04 (6 meses)

**Ações planejadas:**
- [ ] Rotação completa de secrets
- [ ] Auditoria de segurança
- [ ] Revisão de permissões
- [ ] Atualização de dependências

---

**Última atualização**: 2024-11-04  
**Responsável**: DevOps Team
