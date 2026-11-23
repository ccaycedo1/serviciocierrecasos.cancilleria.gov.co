# Script para hacer push a GitHub
# Ejecutar después de crear el repositorio en GitHub

param(
    [string]$Action = "push"  # push o setup
)

$projectPath = "C:\ApostillaCcaycedo\ServicioCierreCasos"
$username = "ccaycedo1"
$reponame = "serviciocierrecasos.cancilleria.gov.co"

# Colores
$Green = "Green"
$Yellow = "Yellow"
$Red = "Red"
$Cyan = "Cyan"

Write-Host "
╔════════════════════════════════════════════════════════════════════════════╗
║               Script de Push a GitHub - ServicioCierreCasos                ║
╚════════════════════════════════════════════════════════════════════════════╝
" -ForegroundColor $Cyan

# Verificar que estamos en el directorio correcto
if (-not (Test-Path "$projectPath\.git")) {
    Write-Host "❌ Error: No se encontró repositorio Git en $projectPath" -ForegroundColor $Red
    exit 1
}

cd $projectPath

# Mostrar estado actual
Write-Host "`n📊 Estado actual del repositorio:
" -ForegroundColor $Cyan
git status --short

Write-Host "`n📍 Remoto configurado:
" -ForegroundColor $Cyan
git remote -v

if ($Action -eq "push") {
    Write-Host "`n🚀 Preparando para hacer push..." -ForegroundColor $Cyan
    
    # Verificar que haya commits
    $commits = git log --oneline 2>&1
    if ($commits -match "fatal") {
        Write-Host "❌ No hay commits en el repositorio" -ForegroundColor $Red
        exit 1
    }
    
    # Verificar estado del repositorio
    $status = git status --porcelain
    if ($status) {
        Write-Host "`n⚠️  Hay cambios sin commitear. Commitéalos primero:" -ForegroundColor $Yellow
        Write-Host "    git add ." -ForegroundColor $Yellow
        Write-Host "    git commit -m `"Tu mensaje`"" -ForegroundColor $Yellow
        exit 1
    }
    
    Write-Host "`n📋 VERIFICACIÓN PRE-PUSH:
" -ForegroundColor $Cyan
    Write-Host "   ✓ Repositorio Git: OK" -ForegroundColor $Green
    Write-Host "   ✓ Cambios: Nada pendiente" -ForegroundColor $Green
    Write-Host "   ✓ Commits: $(git log --oneline -n 1 | wc -l) commits" -ForegroundColor $Green
    Write-Host "   ✓ Remoto: https://github.com/$username/$reponame.git" -ForegroundColor $Green
    
    Write-Host "`n🔐 Autenticación..." -ForegroundColor $Yellow
    Write-Host "   Git usará el credential manager (o te pedirá credenciales)" -ForegroundColor $Cyan
    
    Write-Host "`n⏳ Haciendo push..." -ForegroundColor $Cyan
    git push -u origin master 2>&1
    $exitCode = $LASTEXITCODE
    
    Write-Host "`n" -ForegroundColor $Cyan
    if ($exitCode -eq 0) {
        Write-Host "✅ PUSH EXITOSO" -ForegroundColor $Green
        Write-Host "
🎉 Tu código está en GitHub:
   https://github.com/$username/$reponame

Próximos pasos:
   1. Verifica en GitHub que todo esté bien
   2. Puedes hacer push de cambios futuros con: git push
   3. Para guardar credenciales localmente:
      git config --global credential.helper wincred
" -ForegroundColor $Green
    } else {
        Write-Host "❌ Error en push (código: $exitCode)" -ForegroundColor $Red
        Write-Host "
Posibles causas:
   1. El repositorio no existe en GitHub
   2. Las credenciales son incorrectas
   3. No hay conexión a Internet
   4. GitHub detectó un secreto en los commits

Próximos pasos:
   1. Crea el repositorio en: https://github.com/new
   2. Nombre: $reponame
   3. Click: Create repository
   4. Vuelve a ejecutar este script
" -ForegroundColor $Yellow
        exit 1
    }
} else {
    Write-Host "`nUso: .\PushAGitHub.ps1 [push]" -ForegroundColor $Yellow
    Write-Host "
  push   - Hacer push al repositorio (default)
" -ForegroundColor $Yellow
}
