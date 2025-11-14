# ===================================================================
# ECONEURA - Post-Deployment Tests
# ===================================================================
# Versión: 1.0
# Propósito: Validar que el deployment funcionó correctamente
# ===================================================================

param(
    [string]$BackendUrl = "https://econeura-backend-staging.azurewebsites.net",
    [string]$FrontendUrl = "https://econeura-frontend-staging.azurestaticapps.net",
    [string]$Environment = "staging"
)

$ErrorActionPreference = "Continue"
$FailedTests = 0
$PassedTests = 0

# ===================================================================
# FUNCIONES
# ===================================================================

function Test-Endpoint {
    param(
        [string]$Name,
        [string]$Url,
        [string]$ExpectedStatus = "200",
        [scriptblock]$Validation
    )
    
    Write-Host "`nTest: $Name" -ForegroundColor Cyan
    Write-Host "URL: $Url"
    
    try {
        $response = Invoke-WebRequest -Uri $Url -Method GET -TimeoutSec 30 -UseBasicParsing
        
        if ($response.StatusCode -eq $ExpectedStatus) {
            Write-Host "✅ Status: $($response.StatusCode)" -ForegroundColor Green
            
            if ($Validation) {
                $validationResult = & $Validation $response
                if ($validationResult) {
                    Write-Host "✅ Validation: PASSED" -ForegroundColor Green
                    $script:PassedTests++
                    return $true
                } else {
                    Write-Host "❌ Validation: FAILED" -ForegroundColor Red
                    $script:FailedTests++
                    return $false
                }
            } else {
                $script:PassedTests++
                return $true
            }
        } else {
            Write-Host "❌ Status: $($response.StatusCode) (esperado: $ExpectedStatus)" -ForegroundColor Red
            $script:FailedTests++
            return $false
        }
    } catch {
        Write-Host "❌ Error: $_" -ForegroundColor Red
        $script:FailedTests++
        return $false
    }
}

# ===================================================================
# BANNER
# ===================================================================

Clear-Host
Write-Host @"

╔══════════════════════════════════════════════════════════╗
║                                                          ║
║          🧪 POST-DEPLOYMENT TESTS 🧪                    ║
║                                                          ║
║  Validando que el deployment funcionó correctamente     ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

Write-Host "Environment: $Environment"
Write-Host "Backend:     $BackendUrl"
Write-Host "Frontend:    $FrontendUrl"
Write-Host ""
Write-Host "Iniciando tests..."

# ===================================================================
# TESTS
# ===================================================================

Write-Host "`n╔══════════════════════════════════════════════════════════╗"
Write-Host "║                    BACKEND TESTS                         ║"
Write-Host "╚══════════════════════════════════════════════════════════╝"

# Test 1: Health Check
Test-Endpoint `
    -Name "Backend Health Check" `
    -Url "$BackendUrl/api/health" `
    -Validation {
        param($response)
        $json = $response.Content | ConvertFrom-Json
        return ($json.status -eq "ok")
    }

# Test 2: Database Connection
Test-Endpoint `
    -Name "Database Connection (via health)" `
    -Url "$BackendUrl/api/health" `
    -Validation {
        param($response)
        $json = $response.Content | ConvertFrom-Json
        return ($json.database -eq "connected")
    }

# Test 3: Redis Connection
Test-Endpoint `
    -Name "Redis Connection (via health)" `
    -Url "$BackendUrl/api/health" `
    -Validation {
        param($response)
        $json = $response.Content | ConvertFrom-Json
        return ($json.redis -eq "connected")
    }

# Test 4: NEURA Agents Endpoint
Test-Endpoint `
    -Name "NEURA Agents List" `
    -Url "$BackendUrl/api/neura-agents"

# Test 5: Metrics Endpoint
Test-Endpoint `
    -Name "Metrics Endpoint" `
    -Url "$BackendUrl/api/metrics"

Write-Host "`n╔══════════════════════════════════════════════════════════╗"
Write-Host "║                    FRONTEND TESTS                        ║"
Write-Host "╚══════════════════════════════════════════════════════════╝"

# Test 6: Frontend Loads
Test-Endpoint `
    -Name "Frontend Loads" `
    -Url $FrontendUrl

# Test 7: Frontend Assets
Test-Endpoint `
    -Name "Frontend Assets (CSS)" `
    -Url "$FrontendUrl/assets/index.css" `
    -ExpectedStatus "200"

Write-Host "`n╔══════════════════════════════════════════════════════════╗"
Write-Host "║                 INTEGRATION TESTS                        ║"
Write-Host "╚══════════════════════════════════════════════════════════╝"

# Test 8: CORS Configuration
Test-Endpoint `
    -Name "CORS Headers" `
    -Url "$BackendUrl/api/health" `
    -Validation {
        param($response)
        $corsHeader = $response.Headers["Access-Control-Allow-Origin"]
        return ($null -ne $corsHeader)
    }

# Test 9: Response Time
Write-Host "`nTest: Backend Response Time" -ForegroundColor Cyan
$startTime = Get-Date
try {
    Invoke-WebRequest -Uri "$BackendUrl/api/health" -Method GET -UseBasicParsing | Out-Null
    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalMilliseconds
    
    if ($duration -lt 2000) {
        Write-Host "✅ Response time: $([math]::Round($duration))ms (< 2s)" -ForegroundColor Green
        $script:PassedTests++
    } else {
        Write-Host "⚠️  Response time: $([math]::Round($duration))ms (> 2s)" -ForegroundColor Yellow
        $script:PassedTests++
    }
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
    $script:FailedTests++
}

# ===================================================================
# RESUMEN
# ===================================================================

Write-Host "`n╔══════════════════════════════════════════════════════════╗"
Write-Host "║                      RESUMEN                             ║"
Write-Host "╚══════════════════════════════════════════════════════════╝"
Write-Host ""

$totalTests = $PassedTests + $FailedTests
$passRate = [math]::Round(($PassedTests / $totalTests) * 100, 1)

Write-Host "Total tests:   $totalTests"
Write-Host "Passed:        $PassedTests" -ForegroundColor Green
Write-Host "Failed:        $FailedTests" $(if ($FailedTests -gt 0) { "-ForegroundColor Red" } else { "-ForegroundColor Green" })
Write-Host "Pass rate:     $passRate%"
Write-Host ""

if ($FailedTests -eq 0) {
    Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║                                                          ║" -ForegroundColor Green
    Write-Host "║        ✅ DEPLOYMENT EXITOSO - TODO FUNCIONANDO ✅      ║" -ForegroundColor Green
    Write-Host "║                                                          ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Green
    exit 0
} else {
    Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║                                                          ║" -ForegroundColor Red
    Write-Host "║     ⚠️  DEPLOYMENT CON ERRORES - REVISAR LOGS ⚠️       ║" -ForegroundColor Red
    Write-Host "║                                                          ║" -ForegroundColor Red
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Red
    
    Write-Host "`nPróximos pasos:"
    Write-Host "1. Revisar logs: az webapp log tail --name econeura-backend-staging --resource-group rg-econeura-staging"
    Write-Host "2. Verificar App Settings: az webapp config appsettings list --name econeura-backend-staging"
    Write-Host "3. Verificar Application Insights para más detalles"
    exit 1
}

