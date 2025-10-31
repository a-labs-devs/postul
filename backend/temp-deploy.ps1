Set-Location 'C:\Users\Administrator\Documents\GitHub\postul\backend'
Write-Host '=== Auto-Deploy ===' -ForegroundColor Cyan
Write-Host '[1/3] Git pull...' -ForegroundColor Yellow
git pull origin main
Write-Host '[2/3] NPM install...' -ForegroundColor Yellow
npm install --silent
Write-Host '[3/3] Iniciando servidor...' -ForegroundColor Green
npm run dev
