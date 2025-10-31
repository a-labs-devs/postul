@echo off
REM ============================================
REM Script Auxiliar - Iniciar Servidor
REM ============================================
cd /d "%~dp0"

echo Iniciando servidor Postul Backend...
echo.

REM Iniciar servidor em janela visível
start "Postul Backend" cmd /k "npm run dev"

echo Servidor iniciado em nova janela!
echo Mantenha a janela aberta para o servidor continuar rodando
echo.
