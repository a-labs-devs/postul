@echo off
echo Extraindo SHA-1 fingerprint do keystore...
echo.

keytool -exportcert -keystore postul-release-key.jks -alias postul-release-key -storepass Postul2024@Secure!Key# | certutil -hashfile - SHA1

echo.
echo Copie o SHA-1 acima (formato: XX:XX:XX:XX...)
echo.
pause
