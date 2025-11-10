# 🔒 Guia: Hospedar Política de Privacidade no GitHub Pages

## ⚠️ Requisito da Play Store
A Play Store exige uma URL pública acessível para a política de privacidade quando o app usa permissões sensíveis como `CAMERA`.

## 📋 Passos para Hospedar no GitHub Pages

### 1️⃣ Preparar o Arquivo
O arquivo `privacy-policy.html` já está pronto na raiz do projeto.

### 2️⃣ Criar Branch gh-pages

```powershell
# No diretório raiz do projeto (postul)
cd C:\Users\Administrator\Documents\GitHub\postul

# Criar e fazer checkout da branch gh-pages
git checkout --orphan gh-pages

# Remover todos os arquivos (exceto privacy-policy.html)
git rm -rf .

# Adicionar apenas o privacy-policy.html
git add privacy-policy.html

# Fazer commit
git commit -m "Adicionar política de privacidade para GitHub Pages"

# Enviar para o GitHub
git push origin gh-pages

# Voltar para a branch main
git checkout main
```

### 3️⃣ Ativar GitHub Pages

1. Acesse: https://github.com/a-labs-devs/postul/settings/pages
2. Em **Source**, selecione: `gh-pages` branch
3. Clique em **Save**

### 4️⃣ URL da Política de Privacidade

Após ativar, a URL será:
```
https://a-labs-devs.github.io/postul/privacy-policy.html
```

⏱️ **Aguarde 2-5 minutos** para o GitHub Pages processar.

### 5️⃣ Adicionar na Play Console

1. Acesse o Google Play Console
2. Vá em **Store presence** → **Privacy policy**
3. Cole a URL: `https://a-labs-devs.github.io/postul/privacy-policy.html`
4. Salve

## ✅ Verificar

Teste a URL no navegador:
```
https://a-labs-devs.github.io/postul/privacy-policy.html
```

Deve exibir a política de privacidade completa do POSTUL.

## 🔄 Alternativa: Script Automático

Execute o script já criado:
```powershell
.\setup_github_pages.bat
```

## 📱 Onde Adicionar na Play Console

**Caminho completo:**
Play Console → Seu App → **Policy** → **App content** → **Privacy policy** → **Start** → Cole a URL

## ⚠️ Importante

- ✅ A URL deve estar acessível publicamente
- ✅ Deve usar HTTPS
- ✅ Deve conter informações sobre coleta de dados da CAMERA
- ✅ Não pode exigir login para visualizar

## 📝 Conteúdo da Política

A política já inclui:

✅ Coleta de dados da câmera (fotos de postos)
✅ Armazenamento de fotos
✅ Uso de localização GPS
✅ Dados de conta do usuário
✅ Contato para dúvidas

## 🆘 Suporte

Se o GitHub Pages não funcionar, alternativas:

1. **Firebase Hosting** (gratuito)
2. **Netlify** (gratuito)
3. **Vercel** (gratuito)
4. **Seu próprio servidor** (http://alabsv.ddns.net)
