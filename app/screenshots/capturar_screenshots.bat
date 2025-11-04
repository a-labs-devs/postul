@echo off
echo ========================================
echo  CAPTURA DE SCREENSHOTS PARA PLAY STORE
echo ========================================
echo.
echo Este script vai capturar screenshots do app no seu celular.
echo.
echo INSTRUCOES:
echo 1. Abra o app no celular (deve estar rodando)
echo 2. Navegue ate a tela que quer capturar
echo 3. Pressione ENTER neste terminal
echo 4. Aguarde 3 segundos e a screenshot sera capturada
echo.
echo Pressione CTRL+C para sair a qualquer momento.
echo.
echo ========================================

set /a contador=1

:LOOP
echo.
echo [Screenshot %contador%] Prepare a tela no celular e pressione ENTER...
pause > nul

echo Capturando em 3 segundos...
timeout /t 3 /nobreak > nul

adb exec-out screencap -p > screenshot_%contador%.png

if errorlevel 1 (
    echo [ERRO] Falha ao capturar screenshot. Verifique se o celular esta conectado.
    goto FIM
) else (
    echo [OK] Screenshot %contador% salva como: screenshot_%contador%.png
)

set /a contador+=1

echo.
choice /c SN /m "Deseja capturar mais uma screenshot? (S/N)"
if errorlevel 2 goto FIM
if errorlevel 1 goto LOOP

:FIM
echo.
echo ========================================
echo Total de screenshots capturadas: %contador%
echo Localizacao: %CD%
echo.
echo Proximos passos:
echo 1. Renomeie os arquivos com nomes descritivos
echo 2. Verifique a resolucao (minimo 320px, maximo 3840px)
echo 3. Formatos aceitos: PNG ou JPEG
echo ========================================
pause
