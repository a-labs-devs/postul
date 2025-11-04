@echo off
REM Script para gerar keystore do POSTUL com senha pré-definida
REM Execute este arquivo e depois ANOTE A SENHA gerada!

echo.
echo ========================================
echo  GERADOR DE KEYSTORE - POSTUL
echo ========================================
echo.
echo Gerando senha aleatoria...
echo.

REM Gera senha aleatória (você pode mudar se quiser)
set KEYSTORE_PASSWORD=Postul2024@Secure!Key#

echo Senha gerada: %KEYSTORE_PASSWORD%
echo.
echo ANOTE ESTA SENHA EM LOCAL SEGURO!
echo Voce NAO podera recupera-la depois.
echo.
pause

echo.
echo Gerando keystore...
echo.

keytool -genkey -v ^
  -keystore postul-release-key.jks ^
  -keyalg RSA ^
  -keysize 2048 ^
  -validity 10000 ^
  -alias postul-release-key ^
  -storepass %KEYSTORE_PASSWORD% ^
  -keypass %KEYSTORE_PASSWORD% ^
  -dname "CN=A-Labs Devs, OU=Desenvolvimento, O=A-Labs, L=Sao Paulo, ST=SP, C=BR"

echo.
echo ========================================
echo  KEYSTORE GERADO COM SUCESSO!
echo ========================================
echo.
echo Arquivo: postul-release-key.jks
echo Senha: %KEYSTORE_PASSWORD%
echo Alias: postul-release-key
echo.
echo PROXIMOS PASSOS:
echo 1. Criar arquivo key.properties com:
echo.
echo storePassword=%KEYSTORE_PASSWORD%
echo keyPassword=%KEYSTORE_PASSWORD%
echo keyAlias=postul-release-key
echo storeFile=../postul-release-key.jks
echo.
echo 2. NUNCA commite o keystore no Git!
echo 3. Faca backup em local seguro!
echo.
pause
