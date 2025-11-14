# ✈️ PRE-FLIGHT CHECK - ECONEURA
# Valida TODO localmente ANTES de deployment a Azure
# NO toca Azure, solo valida que estás listo

param(
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"
$checks = @()
$warnings = @()
$errors = @()

Write-Host "`n✈️  ECONEURA PRE-FLIGHT CHECK" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Validando que TODO está listo para deployment...`n" -ForegroundColor Gray

# ============================================================================
# 1. VALIDAR ESTRUCTURA DE ARCHIVOS
# ============================================================================

Write-Host "📁 1. VALIDANDO ESTRUCTURA DE ARCHIVOS..." -ForegroundColor Yellow

$requiredFiles = @(
    "backend/package.json",
    "backend/server.js",
    "backend/.env.example",
    "frontend/package.json",
    "frontend/vite.config.ts",
    "frontend/.env.example",
    ".github/workflows/ci-tests.yml",
    ".github/workflows/azure-backend-staging.yml",
    ".github/workflows/azure-frontend-staging.yml",
    "infrastructure/azure/scripts/setup-azure-staging-v2.ps1",
    "infrastructure/azure/scripts/setup-github-secrets.ps1",
    "infrastructure/azure/scripts/test-deployment.ps1",
    "README.md",
    "HITO_ESTRATEGIA_AZURE_V2_COMPLETADO.md"
)

$missingFiles = @()
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        $checks += "✅ $file"
    } else {
        $missingFiles += $file
        $errors += "❌ FALTA: $file"
    }
}

if ($missingFiles.Count -eq 0) {
    Write-Host "   ✅ Todos los archivos críticos presentes ($($requiredFiles.Count)/$($requiredFiles.Count))" -ForegroundColor Green
} else {
    Write-Host "   ❌ FALTAN $($missingFiles.Count) archivos críticos" -ForegroundColor Red
    $missingFiles | ForEach-Object { Write-Host "      - $_" -ForegroundColor Red }
}

# ============================================================================
# 2. VALIDAR BACKEND
# ============================================================================

Write-Host "`n📦 2. VALIDANDO BACKEND..." -ForegroundColor Yellow

# 2.1 package.json existe y es válido
if (Test-Path "backend/package.json") {
    try {
        $backendPkg = Get-Content "backend/package.json" -Raw | ConvertFrom-Json
        Write-Host "   ✅ package.json válido" -ForegroundColor Green
        
        # Validar scripts críticos
        $requiredScripts = @("start", "dev", "test")
        foreach ($script in $requiredScripts) {
            if ($backendPkg.scripts.PSObject.Properties.Name -contains $script) {
                $checks += "✅ Backend script: $script"
            } else {
                $warnings += "⚠️  Script '$script' no encontrado en backend/package.json"
            }
        }
        
        # Validar dependencies críticas
        $criticalDeps = @("express", "winston", "jsonwebtoken", "bcrypt", "pg", "ioredis")
        foreach ($dep in $criticalDeps) {
            if ($backendPkg.dependencies.PSObject.Properties.Name -contains $dep) {
                $checks += "✅ Backend dep: $dep"
            } else {
                $errors += "❌ Dependency crítica faltante: $dep"
            }
        }
        
    } catch {
        $errors += "❌ backend/package.json es inválido: $_"
    }
}

# 2.2 node_modules instalados
if (Test-Path "backend/node_modules") {
    $moduleCount = (Get-ChildItem "backend/node_modules" -Directory).Count
    Write-Host "   ✅ node_modules instalados ($moduleCount paquetes)" -ForegroundColor Green
} else {
    $errors += "❌ backend/node_modules NO existe - ejecuta: cd backend && npm install"
}

# 2.3 Tests backend
Write-Host "   🧪 Verificando tests backend..." -ForegroundColor Gray
if (Test-Path "backend/tests") {
    $testFiles = (Get-ChildItem "backend/tests" -Filter "*.test.js").Count
    Write-Host "   ✅ $testFiles archivos de test encontrados" -ForegroundColor Green
} else {
    $warnings += "⚠️  No se encontró directorio backend/tests"
}

# ============================================================================
# 3. VALIDAR FRONTEND
# ============================================================================

Write-Host "`n🎨 3. VALIDANDO FRONTEND..." -ForegroundColor Yellow

# 3.1 package.json existe y es válido
if (Test-Path "frontend/package.json") {
    try {
        $frontendPkg = Get-Content "frontend/package.json" -Raw | ConvertFrom-Json
        Write-Host "   ✅ package.json válido" -ForegroundColor Green
        
        # Validar scripts críticos
        $requiredScripts = @("dev", "build", "preview")
        foreach ($script in $requiredScripts) {
            if ($frontendPkg.scripts.PSObject.Properties.Name -contains $script) {
                $checks += "✅ Frontend script: $script"
            } else {
                $errors += "❌ Script '$script' no encontrado en frontend/package.json"
            }
        }
        
        # Validar dependencies críticas
        $criticalDeps = @("react", "react-dom", "vite", "typescript")
        foreach ($dep in $criticalDeps) {
            if ($frontendPkg.dependencies.PSObject.Properties.Name -contains $dep) {
                $checks += "✅ Frontend dep: $dep"
            } else {
                $errors += "❌ Dependency crítica faltante: $dep"
            }
        }
        
    } catch {
        $errors += "❌ frontend/package.json es inválido: $_"
    }
}

# 3.2 node_modules instalados
if (Test-Path "frontend/node_modules") {
    $moduleCount = (Get-ChildItem "frontend/node_modules" -Directory).Count
    Write-Host "   ✅ node_modules instalados ($moduleCount paquetes)" -ForegroundColor Green
} else {
    $errors += "❌ frontend/node_modules NO existe - ejecuta: cd frontend && npm install"
}

# 3.3 Build config
if (Test-Path "frontend/vite.config.ts") {
    Write-Host "   ✅ vite.config.ts presente" -ForegroundColor Green
} else {
    $errors += "❌ frontend/vite.config.ts NO existe"
}

# ============================================================================
# 4. VALIDAR WORKFLOWS CI/CD
# ============================================================================

Write-Host "`n🔄 4. VALIDANDO WORKFLOWS CI/CD..." -ForegroundColor Yellow

$workflows = @(
    ".github/workflows/ci-tests.yml",
    ".github/workflows/azure-backend-staging.yml",
    ".github/workflows/azure-frontend-staging.yml"
)

foreach ($workflow in $workflows) {
    if (Test-Path $workflow) {
        try {
            # Validar que es YAML válido
            $content = Get-Content $workflow -Raw
            if ($content -match "name:" -and $content -match "on:") {
                Write-Host "   ✅ $($workflow.Split('/')[-1])" -ForegroundColor Green
                
                # Verificar que tiene secrets necesarios
                if ($content -match "secrets\.") {
                    $checks += "✅ Workflow usa GitHub Secrets correctamente"
                }
            } else {
                $warnings += "⚠️  $workflow puede tener formato inválido"
            }
        } catch {
            $errors += "❌ Error leyendo $workflow : $_"
        }
    }
}

# ============================================================================
# 5. VALIDAR SCRIPTS AZURE
# ============================================================================

Write-Host "`n☁️  5. VALIDANDO SCRIPTS AZURE..." -ForegroundColor Yellow

$azureScripts = @(
    "infrastructure/azure/scripts/setup-azure-staging-v2.ps1",
    "infrastructure/azure/scripts/setup-github-secrets.ps1",
    "infrastructure/azure/scripts/test-deployment.ps1"
)

foreach ($script in $azureScripts) {
    if (Test-Path $script) {
        $size = (Get-Item $script).Length / 1KB
        Write-Host "   ✅ $($script.Split('/')[-1]) ($([math]::Round($size, 1)) KB)" -ForegroundColor Green
        
        # Verificar que tiene param() block
        $content = Get-Content $script -Raw
        if ($content -match "param\s*\(") {
            $checks += "✅ Script tiene parámetros definidos"
        } else {
            $warnings += "⚠️  $script no tiene param() block"
        }
    }
}

# ============================================================================
# 6. VALIDAR DOCUMENTACIÓN
# ============================================================================

Write-Host "`n📚 6. VALIDANDO DOCUMENTACIÓN..." -ForegroundColor Yellow

$docs = @(
    @{File="README.md"; MinLines=50},
    @{File="HITO_ESTRATEGIA_AZURE_V2_COMPLETADO.md"; MinLines=100},
    @{File="ESTRATEGIA_AZURE_GITHUB_ENTERPRISE.md"; MinLines=500},
    @{File="backend/.env.example"; MinLines=10},
    @{File="frontend/.env.example"; MinLines=5}
)

foreach ($doc in $docs) {
    if (Test-Path $doc.File) {
        $lines = (Get-Content $doc.File).Count
        if ($lines -ge $doc.MinLines) {
            Write-Host "   ✅ $($doc.File) ($lines líneas)" -ForegroundColor Green
        } else {
            $warnings += "⚠️  $($doc.File) tiene solo $lines líneas (esperado: $($doc.MinLines)+)"
        }
    } else {
        $errors += "❌ FALTA: $($doc.File)"
    }
}

# ============================================================================
# 7. VALIDAR ENTORNO LOCAL
# ============================================================================

Write-Host "`n💻 7. VALIDANDO ENTORNO LOCAL..." -ForegroundColor Yellow

# 7.1 Node.js
try {
    $nodeVersion = node --version
    if ($nodeVersion -match "v(\d+)\.") {
        $majorVersion = [int]$matches[1]
        if ($majorVersion -ge 20) {
            Write-Host "   ✅ Node.js $nodeVersion (>= 20 requerido)" -ForegroundColor Green
        } else {
            $errors += "❌ Node.js $nodeVersion es muy antiguo (requiere >= 20)"
        }
    }
} catch {
    $errors += "❌ Node.js NO está instalado"
}

# 7.2 npm
try {
    $npmVersion = npm --version
    Write-Host "   ✅ npm $npmVersion" -ForegroundColor Green
} catch {
    $errors += "❌ npm NO está instalado"
}

# 7.3 Git
try {
    $gitVersion = git --version
    Write-Host "   ✅ $gitVersion" -ForegroundColor Green
    
    # Verificar que estamos en un repo git
    $isGitRepo = git rev-parse --is-inside-work-tree 2>$null
    if ($isGitRepo -eq "true") {
        Write-Host "   ✅ Directorio es un repositorio Git" -ForegroundColor Green
        
        # Verificar remote
        $remote = git remote get-url origin 2>$null
        if ($remote) {
            Write-Host "   ✅ Remote configurado: $remote" -ForegroundColor Green
        } else {
            $warnings += "⚠️  No hay remote 'origin' configurado"
        }
    } else {
        $errors += "❌ Este directorio NO es un repositorio Git"
    }
} catch {
    $errors += "❌ Git NO está instalado"
}

# 7.4 PowerShell version
$psVersion = $PSVersionTable.PSVersion
if ($psVersion.Major -ge 7) {
    Write-Host "   ✅ PowerShell $($psVersion.Major).$($psVersion.Minor)" -ForegroundColor Green
} else {
    $warnings += "⚠️  PowerShell $($psVersion.Major) (recomendado: 7+)"
}

# ============================================================================
# 8. VALIDAR HERRAMIENTAS AZURE (OPCIONAL)
# ============================================================================

Write-Host "`n☁️  8. VALIDANDO HERRAMIENTAS AZURE (opcional)..." -ForegroundColor Yellow

# 8.1 Azure CLI
try {
    $azVersion = az version 2>$null | ConvertFrom-Json
    if ($azVersion.'azure-cli') {
        Write-Host "   ✅ Azure CLI $($azVersion.'azure-cli')" -ForegroundColor Green
        
        # Verificar login
        try {
            $account = az account show 2>$null | ConvertFrom-Json
            if ($account) {
                Write-Host "   ✅ Autenticado en Azure: $($account.user.name)" -ForegroundColor Green
            } else {
                $warnings += "⚠️  Azure CLI instalado pero NO autenticado (ejecuta: az login)"
            }
        } catch {
            $warnings += "⚠️  Azure CLI instalado pero NO autenticado (ejecuta: az login)"
        }
    }
} catch {
    $warnings += "⚠️  Azure CLI NO instalado (necesario para deployment)"
}

# 8.2 GitHub CLI
try {
    $ghVersion = gh --version 2>$null
    if ($ghVersion) {
        Write-Host "   ✅ GitHub CLI instalado" -ForegroundColor Green
        
        # Verificar login
        try {
            $ghUser = gh api user 2>$null | ConvertFrom-Json
            if ($ghUser) {
                Write-Host "   ✅ Autenticado en GitHub: $($ghUser.login)" -ForegroundColor Green
            } else {
                $warnings += "⚠️  GitHub CLI instalado pero NO autenticado (ejecuta: gh auth login)"
            }
        } catch {
            $warnings += "⚠️  GitHub CLI instalado pero NO autenticado (ejecuta: gh auth login)"
        }
    }
} catch {
    $warnings += "⚠️  GitHub CLI NO instalado (necesario para setup-github-secrets.ps1)"
}

# ============================================================================
# 9. VALIDAR GIT STATUS
# ============================================================================

Write-Host "`n📝 9. VALIDANDO GIT STATUS..." -ForegroundColor Yellow

try {
    # Archivos sin commit
    $status = git status --porcelain 2>$null
    if ($status) {
        $changedFiles = ($status | Measure-Object).Count
        Write-Host "   ⚠️  $changedFiles archivos con cambios sin commit" -ForegroundColor Yellow
        if ($Verbose) {
            $status | Select-Object -First 10 | ForEach-Object { Write-Host "      $_" -ForegroundColor Gray }
        }
        $warnings += "⚠️  Hay cambios sin commit - considera hacer commit antes de deployment"
    } else {
        Write-Host "   ✅ Working directory limpio (no hay cambios sin commit)" -ForegroundColor Green
    }
    
    # Branch actual
    $branch = git branch --show-current 2>$null
    if ($branch) {
        Write-Host "   ℹ️  Branch actual: $branch" -ForegroundColor Cyan
        if ($branch -ne "main" -and $branch -ne "master") {
            $warnings += "⚠️  No estás en main/master (branch: $branch)"
        }
    }
} catch {
    $warnings += "⚠️  No se pudo verificar git status"
}

# ============================================================================
# 10. REPORTE FINAL
# ============================================================================

Write-Host "`n═══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "📊 REPORTE FINAL" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════`n" -ForegroundColor Cyan

$totalChecks = $checks.Count
$totalWarnings = $warnings.Count
$totalErrors = $errors.Count

Write-Host "✅ Checks pasados:  $totalChecks" -ForegroundColor Green
Write-Host "⚠️  Advertencias:    $totalWarnings" -ForegroundColor Yellow
Write-Host "❌ Errores:         $totalErrors" -ForegroundColor $(if ($totalErrors -gt 0) { "Red" } else { "Green" })

# Mostrar warnings
if ($totalWarnings -gt 0) {
    Write-Host "`n⚠️  ADVERTENCIAS:" -ForegroundColor Yellow
    $warnings | ForEach-Object { Write-Host "   $_" -ForegroundColor Yellow }
}

# Mostrar errores
if ($totalErrors -gt 0) {
    Write-Host "`n❌ ERRORES CRÍTICOS:" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "   $_" -ForegroundColor Red }
}

# Veredicto final
Write-Host "`n═══════════════════════════════════════════════════" -ForegroundColor Cyan

if ($totalErrors -eq 0 -and $totalWarnings -eq 0) {
    Write-Host "🎉 ¡PERFECTO! TODO LISTO PARA DEPLOYMENT" -ForegroundColor Green
    Write-Host "`nPróximos pasos:" -ForegroundColor Cyan
    Write-Host "   1. cd infrastructure/azure/scripts" -ForegroundColor Gray
    Write-Host "   2. .\setup-azure-staging-v2.ps1" -ForegroundColor Gray
    Write-Host "   3. .\setup-github-secrets.ps1 -Repository 'ECONEURA-MAX/ECONEURA-'" -ForegroundColor Gray
    Write-Host "   4. .\test-deployment.ps1 -Environment staging`n" -ForegroundColor Gray
    exit 0
} elseif ($totalErrors -eq 0 -and $totalWarnings -gt 0) {
    Write-Host "✅ LISTO PARA DEPLOYMENT (con advertencias menores)" -ForegroundColor Yellow
    Write-Host "`nLas advertencias no bloquean el deployment, pero revísalas." -ForegroundColor Gray
    Write-Host "`nPróximos pasos:" -ForegroundColor Cyan
    Write-Host "   1. cd infrastructure/azure/scripts" -ForegroundColor Gray
    Write-Host "   2. .\setup-azure-staging-v2.ps1" -ForegroundColor Gray
    Write-Host "   3. .\setup-github-secrets.ps1 -Repository 'ECONEURA-MAX/ECONEURA-'" -ForegroundColor Gray
    Write-Host "   4. .\test-deployment.ps1 -Environment staging`n" -ForegroundColor Gray
    exit 0
} else {
    Write-Host "❌ HAY ERRORES CRÍTICOS - ARREGLAR ANTES DE DEPLOYMENT" -ForegroundColor Red
    Write-Host "`nCorrige los errores listados arriba y vuelve a ejecutar:`n" -ForegroundColor Gray
    Write-Host "   .\pre-flight-check.ps1`n" -ForegroundColor Yellow
    exit 1
}

