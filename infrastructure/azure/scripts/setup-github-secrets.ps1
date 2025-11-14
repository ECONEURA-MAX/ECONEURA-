# ===================================================================
# ECONEURA - GitHub Secrets Setup (AUTOMATIZADO)
# ===================================================================
# Versión: 1.0
# Propósito: Configurar TODOS los GitHub Secrets automáticamente
# Requiere: GitHub CLI (gh)
# ===================================================================

param(
    [string]$RepoOwner = "ECONEURA-MAX",
    [string]$RepoName = "ECONEURA-",
    [string]$SecretsFile = "github-secrets.txt"
)

$ErrorActionPreference = "Stop"

# ===================================================================
# FUNCIONES
# ===================================================================

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Cyan
}

# ===================================================================
# BANNER
# ===================================================================

Clear-Host
Write-Host @"

╔══════════════════════════════════════════════════════════╗
║                                                          ║
║       🔐 GITHUB SECRETS SETUP (AUTOMATIZADO) 🔐         ║
║                                                          ║
║  Este script configura TODOS los GitHub Secrets         ║
║  automáticamente usando GitHub CLI                      ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

Write-Host "Repository: $RepoOwner/$RepoName"
Write-Host ""

# ===================================================================
# VERIFICAR GITHUB CLI
# ===================================================================

Write-Info "Verificando GitHub CLI..."

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "GitHub CLI no encontrado"
    Write-Host ""
    Write-Host "Instalar con:"
    Write-Host "  winget install GitHub.cli"
    Write-Host ""
    Write-Host "O descargar de: https://cli.github.com/"
    exit 1
}

Write-Success "GitHub CLI encontrado"

# ===================================================================
# VERIFICAR AUTENTICACIÓN
# ===================================================================

Write-Info "Verificando autenticación GitHub..."

$authStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Info "No estás autenticado. Iniciando login..."
    gh auth login
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Login failed"
        exit 1
    }
}

Write-Success "Autenticación OK"

# ===================================================================
# LEER ARCHIVO DE SECRETS
# ===================================================================

Write-Info "Leyendo archivo de secrets: $SecretsFile"

if (-not (Test-Path $SecretsFile)) {
    Write-Error "Archivo no encontrado: $SecretsFile"
    Write-Host ""
    Write-Host "Este archivo debe ser generado por setup-azure-staging-v2.ps1"
    exit 1
}

$secretsContent = Get-Content $SecretsFile -Raw

# ===================================================================
# EXTRAER Y CONFIGURAR SECRETS
# ===================================================================

Write-Info "Configurando GitHub Secrets..."
Write-Host ""

# Lista de secrets esperados
$secrets = @{
    "AZURE_CREDENTIALS" = $null
    "AZURE_SUBSCRIPTION_ID" = $null
    "AZURE_TENANT_ID" = $null
    "AZURE_WEBAPP_BACKEND_NAME" = $null
    "AZURE_STATIC_WEB_APPS_API_TOKEN" = $null
    "DATABASE_URL" = $null
    "REDIS_URL" = $null
    "AZURE_STORAGE_CONNECTION_STRING" = $null
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = $null
    "VITE_API_URL" = $null
    "AZURE_KEY_VAULT_NAME" = $null
}

# Parse secrets from file
foreach ($secretName in $secrets.Keys) {
    # Buscar el secret en el archivo
    $pattern = "$secretName=(.+?)(?=\r?\n[A-Z_]+=|\r?\n\r?\n|\$)"
    if ($secretsContent -match $pattern) {
        $secretValue = $Matches[1].Trim()
        
        try {
            Write-Host "Setting: $secretName..." -NoNewline
            
            # Crear archivo temporal para el valor
            $tempFile = [System.IO.Path]::GetTempFileName()
            $secretValue | Out-File -FilePath $tempFile -Encoding UTF8 -NoNewline
            
            # Set secret
            gh secret set $secretName --repo "$RepoOwner/$RepoName" < $tempFile
            
            # Eliminar archivo temporal
            Remove-Item $tempFile -Force
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host " ✅" -ForegroundColor Green
            } else {
                Write-Host " ❌" -ForegroundColor Red
            }
        } catch {
            Write-Host " ❌ Error: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "⚠️  $secretName not found in file" -ForegroundColor Yellow
    }
}

Write-Host ""

# ===================================================================
# VERIFICAR SECRETS CONFIGURADOS
# ===================================================================

Write-Info "Verificando secrets configurados..."

$configuredSecrets = gh secret list --repo "$RepoOwner/$RepoName" --json name | ConvertFrom-Json

Write-Host ""
Write-Host "Secrets configurados en GitHub:"
foreach ($secret in $configuredSecrets) {
    Write-Host "  ✅ $($secret.name)" -ForegroundColor Green
}

Write-Host ""

# ===================================================================
# RESUMEN
# ===================================================================

Write-Success "GitHub Secrets configurados exitosamente"
Write-Host ""
Write-Host "Próximos pasos:"
Write-Host "  1. Verificar en GitHub: https://github.com/$RepoOwner/$RepoName/settings/secrets/actions"
Write-Host "  2. Push código a GitHub: git push origin main"
Write-Host "  3. Workflows se ejecutarán automáticamente"
Write-Host ""

