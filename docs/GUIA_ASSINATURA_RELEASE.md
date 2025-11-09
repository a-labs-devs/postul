# 🔑 Guia de Assinatura de Release - Play Store

## 📋 Pré-requisitos
- Java JDK instalado
- Android Studio ou linha de comando

---

## 🔐 PASSO 1: Gerar Keystore de Release

### Windows (PowerShell):
```powershell
cd C:\Users\jean_\Documents\GitHub\postul\app\android

keytool -genkey -v `
  -keystore postul-release-key.jks `
  -keyalg RSA `
  -keysize 2048 `
  -validity 10000 `
  -alias postul-release-key
```

### Linux/Mac:
```bash
cd ~/postul/app/android

keytool -genkey -v \
  -keystore postul-release-key.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias postul-release-key
```

### Informações a preencher:
```
Nome e sobrenome: A-Labs Devs
Unidade organizacional: Desenvolvimento
Organização: A-Labs
Cidade: São Paulo
Estado: SP
Código do país: BR
```

⚠️ **IMPORTANTE**: Anote a senha! Você NÃO pode recuperá-la.

---

## 📝 PASSO 2: Criar key.properties

Crie o arquivo `app/android/key.properties`:

```properties
storePassword=SUA_SENHA_ESCOLHIDA
keyPassword=SUA_SENHA_ESCOLHIDA
keyAlias=postul-release-key
storeFile=../postul-release-key.jks
```

⚠️ **NUNCA commite este arquivo no Git!**

---

## 🔒 PASSO 3: Proteger Keystore

### Adicione ao .gitignore:
```bash
# Keystore (CRÍTICO - NÃO VERSIONAR)
*.jks
*.keystore
key.properties
```

### Faça backup seguro:
```bash
# Backup em local seguro (não no Git!)
1. Google Drive (criptografado)
2. Pen drive físico
3. Gerenciador de senhas (1Password, LastPass)
```

⚠️ **SE PERDER O KEYSTORE, NUNCA MAIS PODERÁ ATUALIZAR O APP!**

---

## 🏗️ PASSO 4: Build de Release

### App Bundle (AAB) - Recomendado:
```bash
cd C:\Users\jean_\Documents\GitHub\postul\app

flutter clean
flutter pub get
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### APK (se necessário):
```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## ✅ PASSO 5: Verificar Assinatura

```bash
# Verificar AAB
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab

# Verificar APK
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk
```

Deve mostrar: `jar verified.`

---

## 📦 PASSO 6: Preparar para Upload

### Checklist antes do upload:
- [ ] Keystore gerado e backup feito
- [ ] key.properties criado e NÃO commitado
- [ ] ApplicationId mudado para `com.alabsv.postul`
- [ ] VersionCode e VersionName corretos
- [ ] Build de release criado (AAB)
- [ ] Assinatura verificada
- [ ] App testado em dispositivo real
- [ ] ProGuard habilitado e testado

### Arquivo para upload:
📦 `build/app/outputs/bundle/release/app-release.aab`

### Tamanho esperado:
- AAB: ~20-40 MB
- APK instalado: ~50-80 MB

---

## 🔄 Atualizações Futuras

Quando atualizar o app:

1. **Incrementar versionCode** em `pubspec.yaml`:
   ```yaml
   version: 1.0.1+2  # 1.0.1 = versionName, 2 = versionCode
   ```

2. **Build novamente**:
   ```bash
   flutter build appbundle --release
   ```

3. **Upload no Play Console**

⚠️ **SEMPRE use o mesmo keystore!**

---

## 🆘 Troubleshooting

### Erro: "Keystore not found"
**Solução**: Verifique o caminho em `key.properties`

### Erro: "Incorrect password"
**Solução**: Verifique as senhas em `key.properties`

### Erro: "Duplicate resources"
**Solução**: Execute `flutter clean` antes de buildar

### Erro: "ProGuard rule missing"
**Solução**: Verifique `proguard-rules.pro`

### Build muito grande (> 100 MB)
**Solução**: 
- Habilite ProGuard
- Remova assets não usados
- Use AAB (Play Store reduz tamanho automaticamente)

---

## 📞 Suporte

### Flutter:
- 🔗 https://docs.flutter.dev/deployment/android

### Play Console:
- 🔗 https://support.google.com/googleplay/android-developer

### Keystore perdido:
- ⚠️ Crie novo app com novo package name
- ⚠️ Não é possível recuperar

---

## 🔐 Segurança do Keystore

### ✅ FAÇA:
- Backup em local seguro offline
- Use senhas fortes (16+ caracteres)
- Limite acesso (apenas desenvolvedores principais)
- Documente localização do backup

### ❌ NÃO FAÇA:
- Commitar no Git
- Compartilhar por email/Slack
- Armazenar em nuvem não criptografada
- Usar mesma senha para tudo

---

**Última atualização**: 2024-11-04  
**Versão do guia**: 1.0
