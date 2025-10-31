@echo off
REM ============================================
REM Start Server - Inicia servidor em nova janela
REM ============================================

cd /d "%~dp0"

REM Matar processos anteriores
taskkill /F /IM node.exe >nul 2>&1
taskkill /F /IM nodemon.exe >nul 2>&1
timeout /t 2 /nobreak >nul

REM Iniciar servidor em nova janela VISÍVEL
start "Postul Backend - %date% %time%" cmd /k "npm run dev"

echo Servidor iniciado em nova janela
exit /b 0
