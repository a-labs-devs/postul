@echo off
echo ============================================
echo Auto-Deploy Backend - Postul
echo ============================================
echo.
echo [%date% %time%] Iniciando atualizacao...
echo.

cd /d "%~dp0"

REM Criar diretório de logs se não existir
if not exist "logs" mkdir logs

REM Redirecionar saída para arquivo de log
set LOGFILE=logs\deploy-%date:~-4,4%%date:~-10,2%%date:~-7,2%-%time:~0,2%%time:~3,2%%time:~6,2%.log
set LOGFILE=%LOGFILE: =0%

echo Iniciando deploy... >> %LOGFILE% 2>&1
echo ============================================ >> %LOGFILE% 2>&1

echo [1/3] Atualizando codigo do repositorio...
git pull origin main >> %LOGFILE% 2>&1
if %errorlevel% neq 0 (
    echo ERRO: Falha ao executar git pull
    echo Verifique o log: %LOGFILE%
    exit /b 1
)
echo OK - Codigo atualizado

echo [2/3] Instalando/atualizando dependencias...
call npm install --silent >> %LOGFILE% 2>&1
if %errorlevel% neq 0 (
    echo ERRO: Falha ao instalar dependencias
    echo Verifique o log: %LOGFILE%
    exit /b 1
)
echo OK - Dependencias atualizadas

echo [3/3] Reiniciando servico...
echo.

echo Parando processo Node.js anterior...
taskkill /F /IM node.exe >nul 2>&1
taskkill /F /IM nodemon.exe >nul 2>&1
timeout /t 3 /nobreak >nul

echo Iniciando servidor em nova janela...
REM Usar PowerShell para garantir que a janela seja criada no desktop do usuário
powershell -Command "Start-Process cmd -ArgumentList '/k','cd','/d','%~dp0','&&','npm','run','dev' -WindowStyle Normal"
timeout /t 2 /nobreak >nul

echo.
echo ============================================
echo ✓ Deploy concluido com sucesso!
echo [%date% %time%]
echo ============================================
echo.
echo Log completo salvo em: %LOGFILE%
echo Servidor iniciado em nova janela
echo.

exit /b 0
