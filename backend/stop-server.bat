@echo off
REM ============================================
REM Script Auxiliar - Parar Servidor
REM ============================================
echo Parando servidor Postul Backend...
echo.

taskkill /F /IM node.exe /FI "WINDOWTITLE eq Postul Backend*" 2>nul

if %errorlevel% equ 0 (
    echo ✓ Servidor parado com sucesso!
) else (
    echo Nenhum processo do servidor encontrado
    echo.
    echo Tentando parar todos os processos Node.js...
    taskkill /F /IM node.exe 2>nul
    if %errorlevel% equ 0 (
        echo ✓ Processos Node.js encerrados
    ) else (
        echo Nenhum processo Node.js encontrado
    )
)
echo.
pause
