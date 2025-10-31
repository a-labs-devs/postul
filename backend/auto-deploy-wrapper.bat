@echo off
REM ============================================
REM Auto-Deploy Wrapper - Garante janela visível
REM ============================================

cd /d "%~dp0"

REM Executar o deploy principal em modo "detached" para não bloquear
start "Auto-Deploy Postul" /MIN cmd /c auto-deploy.bat

REM Aguardar um momento para o script principal executar
timeout /t 5 /nobreak >nul

echo Deploy iniciado em background
exit /b 0
