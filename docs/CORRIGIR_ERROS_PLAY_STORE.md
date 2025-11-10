# ✅ Problemas Resolvidos - Upload Play Store

## 📦 Novo AAB Gerado

**Arquivo**: `app/build/app/outputs/bundle/release/app-release.aab`
**Tamanho**: 48.0 MB
**Versão**: 1.0.0+2 (versionCode: 2)
**targetSdk**: 35 ✅

---

## 🔧 Problema 1: Código de Versão Duplicado

### ❌ Erro Original:
```
O código de versão 1 já foi usado. Tente outro.
```

### ✅ Solução Aplicada:
Atualizado `pubspec.yaml`:
```yaml
version: 1.0.0+2  # Era 1.0.0+1
```

**versionCode** agora é **2** (incrementado de 1 para 2)

---

## 🔒 Problema 2: Política de Privacidade Obrigatória

### ❌ Erro Original:
```
Seu APK ou Android App Bundle usa permissões que exigem uma política de privacidade: (android.permission.CAMERA)
```

### ✅ Solução:

#### Opção 1: GitHub Pages (Recomendado - Gratuito)

1. **Executar o script automático:**
```powershell
cd C:\Users\Administrator\Documents\GitHub\postul
.\setup_github_pages.bat
```

2. **Ou fazer manualmente:**
```powershell
cd C:\Users\Administrator\Documents\GitHub\postul

# Criar branch gh-pages
git checkout --orphan gh-pages
git reset --hard
git commit --allow-empty -m "Initializing gh-pages branch"

# Adicionar política de privacidade
copy privacy-policy.html index.html
git add index.html
git commit -m "docs: adiciona política de privacidade"

# Fazer push
git push origin gh-pages

# Voltar para main
git checkout main
```

3. **Ativar no GitHub:**
   - Acesse: https://github.com/a-labs-devs/postul/settings/pages
   - Source: `gh-pages` branch
   - Salvar

4. **URL Gerada:**
```
https://a-labs-devs.github.io/postul/
ou
https://a-labs-devs.github.io/postul/index.html
```

#### Opção 2: Hospedar no Servidor Próprio

Se preferir usar seu servidor (http://alabsv.ddns.net):

```powershell
# Copiar arquivo para servidor
scp privacy-policy.html usuario@alabsv.ddns.net:/var/www/html/postul/
```

URL ficaria: `http://alabsv.ddns.net/postul/privacy-policy.html`

⚠️ **Importante**: A Play Store prefere HTTPS. Use certificado SSL se hospedar em servidor próprio.

---

## 📱 Adicionar URL na Play Console

1. **Acesse**: Google Play Console → Seu App
2. **Navegue**: Policy → App content → Privacy policy
3. **Clique**: Start (ou Manage se já existe)
4. **Cole a URL**:
   - GitHub Pages: `https://a-labs-devs.github.io/postul/`
   - Ou servidor: `http://alabsv.ddns.net/postul/privacy-policy.html`
5. **Salve**

---

## 🎯 Checklist Final

Antes de fazer upload do novo AAB:

- [x] ✅ versionCode atualizado para 2
- [x] ✅ targetSdk 35 (Android 15)
- [x] ✅ AAB gerado e assinado
- [ ] ⏳ Política de privacidade hospedada
- [ ] ⏳ URL adicionada na Play Console
- [ ] ⏳ Upload do novo AAB (versionCode 2)

---

## 📋 Conteúdo da Política de Privacidade

O arquivo `privacy-policy.html` já inclui:

✅ **Permissão CAMERA**
- Coleta de fotos de postos
- Armazenamento temporário
- Não compartilhamento com terceiros

✅ **Outras Permissões**
- LOCATION (GPS)
- INTERNET
- ACCESS_NETWORK_STATE

✅ **Dados do Usuário**
- E-mail e senha
- Postos favoritos
- Preferências

✅ **Contato**
- suporte@alabsv.com.br

---

## 🚀 Próximos Passos

### 1. Hospedar Política de Privacidade
Escolha uma opção acima e hospede o arquivo.

### 2. Testar URL
Abra no navegador e verifique se carrega corretamente.

### 3. Adicionar na Play Console
Cole a URL na seção Privacy Policy.

### 4. Upload do AAB
Faça upload do novo arquivo (versionCode 2).

### 5. Submeter para Revisão
Complete todas as seções obrigatórias e envie para análise.

---

## 📞 Suporte

Se tiver problemas:
1. Verifique se a URL está acessível publicamente
2. Teste em modo anônimo do navegador
3. Aguarde 5 minutos após configurar GitHub Pages
4. Limpe cache do navegador

**Documentação completa**: `docs/HOSPEDAR_PRIVACY_POLICY_GITHUB_PAGES.md`
