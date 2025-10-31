@echo off
chcp 65001 >nul
cls
echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║                                                               ║
echo ║         📧  CONFIGURAÇÃO DE EMAIL - POSTUL  📧                ║
echo ║                                                               ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.
echo.
echo 🎯 Este script vai te guiar pela configuração do email!
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo  PASSO 1: Gerar Senha de App do Gmail
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo  1. Acesse: https://myaccount.google.com/apppasswords
echo  2. Selecione: "Outro (Nome personalizado)"
echo  3. Digite: Postul Backend
echo  4. Clique em "Gerar"
echo  5. Copie a senha gerada (ex: abcd efgh ijkl mnop)
echo.
echo  ⚠️  IMPORTANTE: Você precisa ter a verificação em 2 etapas ativa!
echo      Se não tiver, ative em: https://myaccount.google.com/security
echo.
echo.
pause
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo  PASSO 2: Configurar Credenciais
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo  Abrindo o arquivo .env para você editar...
echo.
timeout /t 2 >nul
start notepad "%~dp0.env"
echo.
echo  📝 INSTRUÇÕES:
echo.
echo  Encontre estas linhas no arquivo .env:
echo      EMAIL_USER=seu_email@gmail.com
echo      EMAIL_PASSWORD=sua_senha_de_app_aqui
echo.
echo  Substitua por suas credenciais:
echo      EMAIL_USER=seu_email_real@gmail.com
echo      EMAIL_PASSWORD=abcd efgh ijkl mnop
echo.
echo  ⚠️  Use a SENHA DE APP gerada, NÃO sua senha real do Gmail!
echo.
echo  Depois de editar:
echo  1. Salve o arquivo (Ctrl + S)
echo  2. Feche o Notepad
echo  3. Volte aqui e pressione qualquer tecla
echo.
pause
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo  PASSO 3: Testar Configuração
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo  Deseja testar o envio de email agora? (S/N)
echo.
set /p teste="  Sua escolha: "
echo.
if /i "%teste%"=="S" (
    echo  🧪 Executando teste...
    echo.
    echo  ⚠️  IMPORTANTE: Antes de continuar, edite o arquivo test-email.js
    echo      e coloque seu email na linha 14 para receber o teste!
    echo.
    pause
    echo.
    node test-email.js
    echo.
    echo  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    echo  📬 Verifique sua caixa de entrada!
    echo  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    echo.
    echo  Se o email chegou: ✅ CONFIGURAÇÃO COMPLETA!
    echo  Se não chegou: ❌ Verifique as credenciais no .env
    echo.
)
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo  PASSO 4: Iniciar o Backend
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo  Deseja iniciar o servidor agora? (S/N)
echo.
set /p iniciar="  Sua escolha: "
echo.
if /i "%iniciar%"=="S" (
    echo.
    echo  🚀 Iniciando o backend...
    echo.
    echo  O servidor ficará rodando. Para parar, pressione Ctrl + C
    echo.
    timeout /t 3 >nul
    npm start
) else (
    echo.
    echo  ✅ Configuração concluída!
    echo.
    echo  Para iniciar o backend manualmente:
    echo     cd d:\postul\backend
    echo     npm start
    echo.
)
echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║                                                               ║
echo ║         ✅  CONFIGURAÇÃO FINALIZADA!  ✅                      ║
echo ║                                                               ║
echo ║  Agora você pode criar contas no app e receberá emails!      ║
echo ║                                                               ║
echo ║  📚 Documentação completa: COMO_CONFIGURAR_EMAIL.md          ║
echo ║                                                               ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.
pause
