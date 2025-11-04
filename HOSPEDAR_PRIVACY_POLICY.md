# 🌐 Guia: Hospedar Política de Privacidade no GitHub Pages

## ✅ **SOLUÇÃO RÁPIDA E GRATUITA**

### **Método 1: GitHub Pages (Recomendado)**

#### Passo 1: Criar branch gh-pages
```bash
cd C:\Users\jean_\Documents\GitHub\postul

# Criar branch gh-pages
git checkout --orphan gh-pages
git reset --hard
git commit --allow-empty -m "Initializing gh-pages branch"
git push origin gh-pages
git checkout main
```

#### Passo 2: Configurar GitHub Pages
1. Acesse: https://github.com/a-labs-devs/postul/settings/pages
2. **Source:** Deploy from a branch
3. **Branch:** gh-pages
4. **Folder:** / (root)
5. Clique **Save**

#### Passo 3: Adicionar política ao branch gh-pages
```bash
git checkout gh-pages
cp privacy-policy.html index.html
git add index.html
git commit -m "docs: adiciona política de privacidade"
git push origin gh-pages
git checkout main
```

#### Passo 4: URL da Política
Após alguns minutos, estará disponível em:
```
https://a-labs-devs.github.io/postul/
```

---

### **Método 2: Usar o Servidor alabsv.ddns.net**

#### Opção mais rápida se você já tem acesso SSH:

```bash
# Via SSH no servidor
scp privacy-policy.html user@alabsv.ddns.net:/var/www/html/postul/

# URL ficará:
http://alabsv.ddns.net/postul/privacy-policy.html
```

---

### **Método 3: Netlify (Alternativa Gratuita)**

1. Acesse: https://app.netlify.com/
2. **Add new site** → **Deploy manually**
3. Arraste `privacy-policy.html`
4. URL gerada: `https://postul-privacy.netlify.app`

---

## 📝 **ONDE USAR A URL**

### No Play Console:
```
Privacy Policy URL: https://a-labs-devs.github.io/postul/
```

### No AndroidManifest.xml (opcional):
```xml
<application>
    <meta-data
        android:name="privacy_policy_url"
        android:value="https://a-labs-devs.github.io/postul/" />
</application>
```

---

## ✅ **SCRIPT AUTOMATIZADO**

Criei um script que faz tudo automaticamente:

```bash
# Execute este comando:
cd C:\Users\jean_\Documents\GitHub\postul
./setup_github_pages.bat
```

---

**Recomendação**: Use GitHub Pages (Método 1) - é grátis, confiável e fácil de atualizar.

**Tempo estimado**: 5-10 minutos
