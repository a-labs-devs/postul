@echo off
REM ============================================
REM Start Server - Inicia servidor em nova janela
REM ============================================

cd /d "%~dp0"

REM Matar apenas processos Node do backend (porta 3001)
echo Parando servidor backend anterior...
FOR /F "tokens=5" %%P IN ('netstat -ano ^| findstr :3001') DO (
    taskkill /F /PID %%P >nul 2>&1
)

timeout /t 2 /nobreak >nul

REM Iniciar servidor em nova janela VISÍVEL
start "Postul Backend - %date% %time%" cmd /k "npm run dev"

echo Servidor iniciado em nova janela
exit /b 0
