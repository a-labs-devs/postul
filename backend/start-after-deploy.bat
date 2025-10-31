@echo off
REM ============================================
REM Iniciar Servidor - Postul Backend
REM ============================================

cd /d "%~dp0"

echo [%date% %time%] Iniciando servidor Postul Backend...
echo.

REM Aguardar um momento para garantir que a porta foi liberada
timeout /t 2 /nobreak >nul

REM Iniciar o servidor
npm run dev

REM Se o servidor parar, pausar para ver o erro
pause
