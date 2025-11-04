@echo off
chcp 65001 > nul
echo ========================================
echo  📸 CAPTURAR SCREENSHOTS - POSTUL
echo ========================================
echo.

REM Criar pasta para screenshots
set SCREENSHOT_DIR=%USERPROFILE%\Desktop\postul_screenshots
if not exist "%SCREENSHOT_DIR%" (
    echo [*] Criando pasta para screenshots...
    mkdir "%SCREENSHOT_DIR%"
    echo ✓ Pasta criada: %SCREENSHOT_DIR%
    echo.
)

echo [1/4] Verificando dispositivos conectados...
adb devices
echo.

if errorlevel 1 (
    echo ❌ ERRO: ADB não encontrado!
    echo.
    echo Certifique-se de que o Android SDK está instalado.
    echo Ou capture manualmente: Power + Volume Down no dispositivo
    echo.
    pause
    exit /b 1
)

echo [2/4] Dispositivo conectado?
set /p conectado="Digite S se um dispositivo está conectado (S/N): "
if /i not "%conectado%"=="S" (
    echo.
    echo Por favor, conecte um dispositivo Android via USB
    echo Ou use o emulador do Android Studio
    echo.
    pause
    exit /b 1
)

echo.
echo [3/4] Como deseja capturar?
echo.
echo  1. Manual - Você pressiona Power+Volume Down no dispositivo
echo  2. Automático - Script captura via ADB
echo.
set /p metodo="Escolha (1/2): "

if "%metodo%"=="1" goto manual
if "%metodo%"=="2" goto automatico

echo Opção inválida!
pause
exit /b 1

:manual
echo.
echo ========================================
echo  MODO MANUAL
echo ========================================
echo.
echo Instruções:
echo 1. Execute o app no dispositivo
echo 2. Navegue até a tela desejada
echo 3. Pressione Power + Volume Down para capturar
echo 4. Screenshots salvos na galeria do dispositivo
echo.
echo Telas recomendadas:
echo  01. Mapa com postos
echo  02. Lista de postos
echo  03. Detalhes do posto
echo  04. Navegação GPS
echo  05. Filtros
echo  06. Favoritos
echo  07. Avaliações
echo  08. Busca
echo.
echo Após capturar todas, transfira para: %SCREENSHOT_DIR%
echo.
pause
exit /b 0

:automatico
echo.
echo ========================================
echo  MODO AUTOMÁTICO (ADB)
echo ========================================
echo.

set contador=1

:loop_captura
cls
echo ========================================
echo  Screenshot %contador%/8
echo ========================================
echo.
echo Navegue até a tela desejada no app e pressione ENTER
echo Ou digite 'Q' para finalizar
echo.
set /p continuar="Pronto para capturar? (ENTER/Q): "

if /i "%continuar%"=="Q" goto fim

echo.
set /p nome_tela="Nome da tela (ex: mapa, lista, detalhes): "

if "%nome_tela%"=="" (
    set arquivo=screenshot_%contador%
) else (
    set arquivo=%contador%_%nome_tela%
)

echo.
echo [*] Capturando screenshot...
adb shell screencap -p /sdcard/%arquivo%.png

if errorlevel 1 (
    echo ❌ Erro ao capturar!
    pause
    goto loop_captura
)

echo [*] Baixando imagem...
adb pull /sdcard/%arquivo%.png "%SCREENSHOT_DIR%\%arquivo%.png" > nul

if errorlevel 1 (
    echo ❌ Erro ao baixar!
    pause
    goto loop_captura
)

echo [*] Limpando arquivo temporário...
adb shell rm /sdcard/%arquivo%.png > nul

echo.
echo ✓ Screenshot salva: %arquivo%.png
echo ✓ Local: %SCREENSHOT_DIR%
echo.

set /a contador+=1

if %contador% LEQ 8 (
    timeout /t 2 /nobreak > nul
    goto loop_captura
)

:fim
echo.
echo ========================================
echo  ✓ CAPTURAS CONCLUÍDAS!
echo ========================================
echo.
echo Total de screenshots: %contador%
echo Pasta: %SCREENSHOT_DIR%
echo.
echo Próximos passos:
echo  1. Revisar qualidade das imagens
echo  2. Renomear se necessário
echo  3. Redimensionar para 1080x1920 (se preciso)
echo  4. Fazer upload na Play Console
echo.
echo Abrir pasta de screenshots?
set /p abrir="(S/N): "
if /i "%abrir%"=="S" (
    explorer "%SCREENSHOT_DIR%"
)

echo.
pause
