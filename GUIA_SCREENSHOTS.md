# 📸 Guia: Como Criar Screenshots para Play Store

Este guia mostra como capturar screenshots profissionais do POSTUL para a Play Store.

---

## 🎯 REQUISITOS

### Especificações Técnicas
- **Quantidade:** Mínimo 2, recomendado 8
- **Dimensões:** 1920x1080 (landscape) ou 1080x1920 (portrait)
- **Formato:** PNG ou JPEG
- **Tamanho máximo:** 8 MB por imagem
- **Orientação:** Portrait (vertical) é mais comum para apps móveis

### Capturas Recomendadas
1. ✅ Tela de Mapa (principal)
2. ✅ Lista de Postos
3. ✅ Detalhes do Posto
4. ✅ Navegação/GPS
5. ⚪ Filtros de Combustível
6. ⚪ Favoritos
7. ⚪ Avaliações
8. ⚪ Tela de Busca

---

## 🖥️ MÉTODO 1: Emulador Android Studio

### Passo 1: Iniciar Emulador
```powershell
# No Android Studio:
# Tools > Device Manager > Criar/Iniciar dispositivo
# Recomendado: Pixel 6 (1080x2400)
```

### Passo 2: Executar App
```powershell
cd C:\Users\jean_\Documents\GitHub\postul\app
flutter run
```

### Passo 3: Capturar Telas
1. No emulador, navegue até a tela desejada
2. Clique no ícone de **câmera** na barra lateral do emulador
3. Ou use: **Ctrl + S** (Windows)
4. Imagens salvas em: `C:\Users\jean_\Pictures\Screenshots\`

### Passo 4: Redimensionar (se necessário)
```powershell
# As capturas do emulador já vêm no tamanho correto
# Se precisar redimensionar, use ferramentas online
```

---

## 📱 MÉTODO 2: Dispositivo Android Real

### Passo 1: Habilitar Depuração USB
1. Configurações > Sobre o telefone
2. Toque 7x em "Número da versão"
3. Volte e entre em "Opções do desenvolvedor"
4. Ative "Depuração USB"

### Passo 2: Conectar Dispositivo
```powershell
# Conecte o cabo USB e execute:
adb devices
# Deve aparecer seu dispositivo
```

### Passo 3: Executar App
```powershell
cd C:\Users\jean_\Documents\GitHub\postul\app
flutter run
```

### Passo 4: Capturar Screenshots
```powershell
# Método A: Botão físico do celular
# Pressione: Power + Volume Down (na maioria dos dispositivos)

# Método B: Via ADB
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png C:\Users\jean_\Desktop\
```

---

## 🎨 MÉTODO 3: Captura com Ferramenta Profissional

### Usando Screenshots.pro (Online)
1. Acesse: https://screenshots.pro/
2. Faça upload das suas capturas simples
3. Escolha modelo de device frame
4. Adicione textos descritivos (opcional)
5. Baixe imagens finalizadas

### Usando Figma (Gratuito)
1. Crie conta em: https://figma.com
2. Use template de device mockup
3. Importe suas capturas
4. Adicione elementos visuais
5. Exporte em alta resolução

---

## ✂️ EDITANDO SCREENSHOTS

### Ferramentas Recomendadas

**Windows Nativo:**
```powershell
# Usar Paint 3D (já instalado)
# Redimensionar para 1080x1920
```

**Online (Gratuito):**
- **Canva** - https://canva.com
- **Photopea** - https://photopea.com (clone do Photoshop)
- **Remove.bg** - Remover fundo (se necessário)

**Software Profissional:**
- **GIMP** (gratuito) - https://gimp.org
- **Adobe Photoshop** (pago)

---

## 📐 REDIMENSIONAR SCREENSHOTS

### Usando PowerShell + ImageMagick
```powershell
# 1. Instalar ImageMagick
winget install ImageMagick.ImageMagick

# 2. Redimensionar imagem
magick convert screenshot.png -resize 1080x1920 screenshot_resized.png

# 3. Redimensionar todas as imagens de uma pasta
Get-ChildItem *.png | ForEach-Object {
    magick convert $_.Name -resize 1080x1920 "resized_$($_.Name)"
}
```

### Usando Paint (Windows)
1. Abrir imagem no Paint
2. Home > Redimensionar
3. Desmarcar "Manter taxa de proporção"
4. Pixels: 1080 x 1920
5. Salvar

---

## 🎯 CHECKLIST DE QUALIDADE

Para cada screenshot, verifique:

### ✅ Técnico
- [ ] Dimensões corretas (1080x1920 ou 1920x1080)
- [ ] Formato PNG ou JPEG
- [ ] Tamanho < 8 MB
- [ ] Imagem nítida (não borrada)
- [ ] Sem informações pessoais sensíveis

### ✅ Conteúdo
- [ ] Interface do app visível e clara
- [ ] Texto legível
- [ ] Ícones e botões visíveis
- [ ] Cores corretas
- [ ] Sem dados de teste estranhos

### ✅ Apresentação
- [ ] Tela completa (sem cortes)
- [ ] Status bar limpo (ou removido)
- [ ] Sem notificações irrelevantes
- [ ] Hora razoável (ex: 10:00, não 03:47)
- [ ] Bateria carregada (>70%)
- [ ] Rede WiFi (não 3G/LTE)

---

## 📋 SCRIPT AUTOMATIZADO

Criei um script para facilitar a captura:

### capturar_screenshots.bat
```batch
@echo off
echo ========================================
echo  CAPTURAR SCREENSHOTS - POSTUL
echo ========================================
echo.

echo [1/4] Verificando dispositivos conectados...
adb devices
echo.

echo [2/4] Iniciando app...
cd /d C:\Users\jean_\Documents\GitHub\postul\app
start flutter run
echo.

echo [3/4] Aguarde o app abrir no dispositivo...
echo Pressione ENTER quando estiver pronto para capturar
pause > nul

echo.
echo [4/4] Instruções:
echo - Navegue até a tela desejada no app
echo - Pressione Power + Volume Down no dispositivo
echo - OU digite 'S' aqui e pressione ENTER para capturar via ADB
echo.
echo Digite 'S' para screenshot via ADB ou 'Q' para sair:

:loop
set /p opcao="> "

if /i "%opcao%"=="S" (
    set /p nome="Nome do arquivo (ex: tela_mapa): "
    adb shell screencap -p /sdcard/%nome%.png
    adb pull /sdcard/%nome%.png C:\Users\jean_\Desktop\postul_screenshots\
    echo Screenshot salva em: Desktop\postul_screenshots\%nome%.png
    echo.
    echo Capturar outra? (S/Q):
    goto loop
)

if /i "%opcao%"=="Q" (
    echo.
    echo Screenshots capturadas com sucesso!
    pause
    exit
)

echo Opção inválida. Use S ou Q.
goto loop
```

### Como usar:
```powershell
# 1. Criar pasta para screenshots
New-Item -Path "C:\Users\jean_\Desktop\postul_screenshots" -ItemType Directory

# 2. Executar script (após conectar dispositivo)
.\capturar_screenshots.bat
```

---

## 🎬 PREPARAÇÃO ANTES DE CAPTURAR

### Configurar Dispositivo/Emulador

1. **Hora do Sistema**
   ```
   Configure para: 10:00 ou 14:00
   ```

2. **Bateria**
   ```
   Configure para: 100% ou remova ícone
   ```

3. **Rede**
   ```
   Use WiFi em vez de dados móveis
   ```

4. **Notificações**
   ```
   Limpe todas as notificações
   Ative "Não Perturbe"
   ```

5. **Dados de Teste**
   ```
   Use postos reais da sua região
   Preços realistas
   Sem dados de debug visíveis
   ```

---

## 📊 ORGANIZAÇÃO DOS ARQUIVOS

### Estrutura Recomendada
```
postul_screenshots/
├── 01_tela_mapa.png
├── 02_lista_postos.png
├── 03_detalhes_posto.png
├── 04_navegacao.png
├── 05_filtros.png
├── 06_favoritos.png
├── 07_avaliacoes.png
└── 08_busca.png
```

### Nomenclatura
- Use números sequenciais (01, 02, 03...)
- Nome descritivo em português
- Sem espaços (use underscore _)
- Formato: `##_descricao.png`

---

## 🚀 APÓS CAPTURAR

### Checklist Final
1. [ ] Verificar todas as 8 screenshots
2. [ ] Confirmar dimensões corretas
3. [ ] Renomear arquivos sequencialmente
4. [ ] Criar cópia de backup
5. [ ] Mover para pasta do projeto

### Mover para Projeto
```powershell
# Criar pasta no projeto
New-Item -Path "C:\Users\jean_\Documents\GitHub\postul\store_assets\screenshots" -ItemType Directory -Force

# Copiar screenshots
Copy-Item "C:\Users\jean_\Desktop\postul_screenshots\*.png" "C:\Users\jean_\Documents\GitHub\postul\store_assets\screenshots\"
```

---

## 💡 DICAS PROFISSIONAIS

### Para Melhor Qualidade:
1. ✅ Use emulador em vez de dispositivo real (melhor qualidade)
2. ✅ Capture em horário "normal" (10:00-16:00)
3. ✅ Bateria sempre acima de 70%
4. ✅ Use dados reais (não Lorem Ipsum)
5. ✅ Evite informações sensíveis (CPF, telefone, endereço completo)

### Para Destaque na Store:
1. 🎨 Adicione moldura de dispositivo (device frame)
2. 📝 Inclua texto descritivo curto em cada imagem
3. 🌈 Use cores que contrastem com o fundo
4. ⭐ Destaque recursos principais
5. 📱 Mantenha consistência visual

---

## 🆘 SOLUÇÃO DE PROBLEMAS

### Screenshot fica preta no ADB
```powershell
# Solução: Desabilitar proteção de tela
adb shell settings put global stay_on_while_plugged_in 7
```

### Qualidade baixa no emulador
```
# Android Studio > AVD Manager
# Edit > Show Advanced Settings
# Graphics: Hardware - GLES 2.0
```

### Dimensões incorretas
```powershell
# Verificar dimensões da imagem
magick identify screenshot.png
```

---

## 📞 RECURSOS ADICIONAIS

### Templates Gratuitos
- **AppMockUp** - https://app-mockup.com/
- **MockUPhone** - https://mockuphone.com/
- **Smartmockups** - https://smartmockups.com/

### Tutoriais em Vídeo
- YouTube: "Como fazer screenshots para Play Store"
- YouTube: "App Store screenshots best practices"

---

## ✅ PRÓXIMO PASSO

Após capturar todas as screenshots:
1. Revisar qualidade de cada imagem
2. Criar ícone do app (512x512)
3. Criar feature graphic (1024x500)
4. Fazer upload na Play Console

**Tempo estimado:** 1-2 horas

---

**Última atualização:** 04/11/2025
