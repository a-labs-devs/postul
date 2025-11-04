@echo off
REM Script para configurar GitHub Pages com política de privacidade

echo.
echo ========================================
echo  SETUP GITHUB PAGES - POSTUL
echo ========================================
echo.
echo Este script vai:
echo 1. Criar branch gh-pages
echo 2. Adicionar privacy-policy.html
echo 3. Fazer push para GitHub
echo.
pause

echo.
echo [1/4] Salvando branch atual...
git branch --show-current > .current_branch
set /p CURRENT_BRANCH=<.current_branch
del .current_branch

echo.
echo [2/4] Criando branch gh-pages...
git checkout --orphan gh-pages
git reset --hard
git commit --allow-empty -m "Initializing gh-pages branch"

echo.
echo [3/4] Adicionando política de privacidade...
copy privacy-policy.html index.html
git add index.html
git commit -m "docs: adiciona política de privacidade"

echo.
echo [4/4] Fazendo push para GitHub...
git push origin gh-pages

echo.
echo Voltando para branch %CURRENT_BRANCH%...
git checkout %CURRENT_BRANCH%

echo.
echo ========================================
echo  SUCESSO!
echo ========================================
echo.
echo Sua política de privacidade estará disponível em:
echo https://a-labs-devs.github.io/postul/
echo.
echo PRÓXIMOS PASSOS:
echo 1. Aguarde 2-5 minutos para GitHub Pages processar
echo 2. Acesse a URL acima para verificar
echo 3. Configure no Play Console:
echo    Store Settings ^> Privacy Policy
echo    URL: https://a-labs-devs.github.io/postul/
echo.
pause
