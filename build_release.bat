@echo off
echo ========================================
echo  POSTUL - BUILD RELEASE AAB
echo ========================================
echo.

cd /d "C:\Users\jean_\Documents\GitHub\postul\app"

echo [1/3] Limpando build anterior...
call flutter clean
echo.

echo [2/3] Obtendo dependencias...
call flutter pub get
echo.

echo [3/3] Gerando AAB release...
call flutter build appbundle --release
echo.

if %ERRORLEVEL% EQU 0 (
    echo ========================================
    echo  BUILD CONCLUIDO COM SUCESSO!
    echo ========================================
    echo.
    echo Arquivo AAB criado em:
    echo C:\Users\jean_\Documents\GitHub\postul\app\build\app\outputs\bundle\release\app-release.aab
    echo.
    explorer "C:\Users\jean_\Documents\GitHub\postul\app\build\app\outputs\bundle\release"
) else (
    echo ========================================
    echo  ERRO NO BUILD!
    echo ========================================
    echo.
    echo Verifique os erros acima e tente novamente.
)

echo.
pause
