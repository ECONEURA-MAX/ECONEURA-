# ============================================================================
# ECONEURA - Azure Setup Script WINDOWS POWERSHELL
# Versión: Opción 2 ($53/mes) - SIN BLOQUEOS
# ============================================================================

$ErrorActionPreference = "Stop"

# Colores
function Write-Step { Write-Host "▶ $args" -ForegroundColor Green }
function Write-Info { Write-Host "ℹ $args" -ForegroundColor Cyan }
function Write-Warning { Write-Host "⚠ $args" -ForegroundColor Yellow }
function Write-Error { Write-Host "✗ $args" -ForegroundColor Red }
function Write-Success { Write-Host "✓ $args" -ForegroundColor Green }

Write-Host @"

╔════════════════════════════════════════════════════════════════╗
║         ECONEURA - Azure Setup Windows ($53/mes)               ║
╚════════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Blue

# ============================================================================
# CONFIGURACIÓN
# ============================================================================

$SUBSCRIPTION_ID = "a0991f95-16e0-4f03-85df-db3d69004d94"
$RESOURCE_GROUP = "econeura-resources"
$LOCATION = "northeurope"
$LOCATION_SECONDARY = "westeurope"

# Nombres de recursos
$APP_PLAN_NAME = "econeura-plan-b1"
$BACKEND_NAME = "econeura-backend-prod"
$FRONTEND_NAME = "econeura-frontend-prod"
$DB_SERVER_NAME = "econeura-db-prod"
$DB_NAME = "econeura"
$DB_ADMIN_USER = "econeuroadmin"
$REDIS_NAME = "econeura-redis-prod"
$STORAGE_ACCOUNT = "econeurastorage$(Get-Random -Maximum 9999)"
$INSIGHTS_NAME = "econeura-insights"

# ============================================================================
# VALIDACIONES
# ============================================================================

Write-Step "Validando prerequisitos..."

# Verificar Azure CLI
try {
    $azVersion = az version | ConvertFrom-Json
    Write-Success "Azure CLI instalado: $($azVersion.'azure-cli')"
} catch {
    Write-Error "Azure CLI no está instalado"
    Write-Info "Instalar desde: https://aka.ms/installazurecliwindows"
    exit 1
}

# Verificar login
try {
    $account = az account show | ConvertFrom-Json
    Write-Success "Sesión activa: $($account.user.name)"
} catch {
    Write-Warning "No estás logueado en Azure"
    Write-Step "Iniciando login..."
    az login
}

# Verificar suscripción
$currentSub = az account show --query id -o tsv
if ($currentSub -ne $SUBSCRIPTION_ID) {
    Write-Warning "Cambiando a suscripción correcta..."
    az account set --subscription $SUBSCRIPTION_ID
}
Write-Success "Suscripción correcta seleccionada"

# ============================================================================
# SOLICITAR PASSWORD
# ============================================================================

Write-Step "Configurando credenciales de base de datos..."
$DB_ADMIN_PASS = Read-Host "Password PostgreSQL (min 8 caracteres)" -AsSecureString
$DB_ADMIN_PASS_PLAIN = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($DB_ADMIN_PASS)
)

if ($DB_ADMIN_PASS_PLAIN.Length -lt 8) {
    Write-Error "Password debe tener al menos 8 caracteres"
    exit 1
}

# ============================================================================
# PASO 1: RESOURCE GROUP
# ============================================================================

Write-Step "Paso 1/9: Creando Resource Group..."

try {
    az group show --name $RESOURCE_GROUP 2>&1 | Out-Null
    Write-Warning "Resource Group ya existe"
} catch {
    az group create `
        --name $RESOURCE_GROUP `
        --location $LOCATION `
        --tags Environment=Production Project=ECONEURA | Out-Null
    Write-Success "Resource Group creado: $RESOURCE_GROUP"
}

# ============================================================================
# PASO 2: APP SERVICE PLAN (B1)
# ============================================================================

Write-Step "Paso 2/9: Creando App Service Plan B1..."

try {
    az appservice plan show --name $APP_PLAN_NAME --resource-group $RESOURCE_GROUP 2>&1 | Out-Null
    Write-Warning "App Service Plan ya existe"
} catch {
    az appservice plan create `
        --name $APP_PLAN_NAME `
        --resource-group $RESOURCE_GROUP `
        --location $LOCATION `
        --is-linux `
        --sku B1 | Out-Null
    Write-Success "App Service Plan creado: $APP_PLAN_NAME (B1 ~`$13/mes)"
}

# ============================================================================
# PASO 3: BACKEND WEB APP
# ============================================================================

Write-Step "Paso 3/9: Creando Backend Web App..."

try {
    az webapp show --name $BACKEND_NAME --resource-group $RESOURCE_GROUP 2>&1 | Out-Null
    Write-Warning "Backend ya existe"
} catch {
    az webapp create `
        --name $BACKEND_NAME `
        --resource-group $RESOURCE_GROUP `
        --plan $APP_PLAN_NAME `
        --runtime "NODE:20-lts" | Out-Null
    
    az webapp config set `
        --name $BACKEND_NAME `
        --resource-group $RESOURCE_GROUP `
        --startup-file "node server.js" `
        --always-on true | Out-Null
    
    az webapp log config `
        --name $BACKEND_NAME `
        --resource-group $RESOURCE_GROUP `
        --application-logging filesystem `
        --detailed-error-messages true `
        --web-server-logging filesystem | Out-Null
    
    Write-Success "Backend creado: https://$BACKEND_NAME.azurewebsites.net"
}

# ============================================================================
# PASO 4: FRONTEND STATIC WEB APP
# ============================================================================

Write-Step "Paso 4/9: Creando Frontend Static Web App..."

try {
    az staticwebapp show --name $FRONTEND_NAME --resource-group $RESOURCE_GROUP 2>&1 | Out-Null
    Write-Warning "Frontend ya existe"
} catch {
    az staticwebapp create `
        --name $FRONTEND_NAME `
        --resource-group $RESOURCE_GROUP `
        --location $LOCATION_SECONDARY `
        --source "https://github.com/ECONEURA-MAX/ECONEURA-" `
        --branch main `
        --app-location "frontend" `
        --output-location "dist" `
        --sku Free | Out-Null
    
    Write-Success "Frontend creado (`$0/mes Free)"
    
    $STATIC_TOKEN = az staticwebapp secrets list `
        --name $FRONTEND_NAME `
        --resource-group $RESOURCE_GROUP `
        --query "properties.apiKey" -o tsv
    
    Write-Info "Deployment Token (GitHub Secret AZURE_STATIC_WEB_APPS_API_TOKEN_PROD):"
    Write-Host $STATIC_TOKEN -ForegroundColor Yellow
}

# ============================================================================
# PASO 5: POSTGRESQL FLEXIBLE SERVER
# ============================================================================

Write-Step "Paso 5/9: Creando PostgreSQL Flexible Server..."

try {
    az postgres flexible-server show --name $DB_SERVER_NAME --resource-group $RESOURCE_GROUP 2>&1 | Out-Null
    Write-Warning "PostgreSQL ya existe"
} catch {
    az postgres flexible-server create `
        --name $DB_SERVER_NAME `
        --resource-group $RESOURCE_GROUP `
        --location $LOCATION `
        --admin-user $DB_ADMIN_USER `
        --admin-password $DB_ADMIN_PASS_PLAIN `
        --sku-name Standard_B1ms `
        --tier Burstable `
        --storage-size 32 `
        --version 15 `
        --public-access 0.0.0.0 `
        --yes | Out-Null
    
    az postgres flexible-server db create `
        --resource-group $RESOURCE_GROUP `
        --server-name $DB_SERVER_NAME `
        --database-name $DB_NAME | Out-Null
    
    az postgres flexible-server firewall-rule create `
        --resource-group $RESOURCE_GROUP `
        --name $DB_SERVER_NAME `
        --rule-name AllowAzureServices `
        --start-ip-address 0.0.0.0 `
        --end-ip-address 0.0.0.0 | Out-Null
    
    Write-Success "PostgreSQL creado (`$0/mes Free Tier B1MS)"
    
    $DB_CONN_STRING = "postgresql://${DB_ADMIN_USER}:${DB_ADMIN_PASS_PLAIN}@${DB_SERVER_NAME}.postgres.database.azure.com:5432/${DB_NAME}?sslmode=require"
    Write-Info "Connection String:"
    Write-Host $DB_CONN_STRING -ForegroundColor Yellow
}

# ============================================================================
# PASO 6: REDIS CACHE
# ============================================================================

Write-Step "Paso 6/9: Creando Redis Cache..."

try {
    az redis show --name $REDIS_NAME --resource-group $RESOURCE_GROUP 2>&1 | Out-Null
    Write-Warning "Redis ya existe"
} catch {
    az redis create `
        --name $REDIS_NAME `
        --resource-group $RESOURCE_GROUP `
        --location $LOCATION `
        --sku Standard `
        --vm-size c1 `
        --enable-non-ssl-port false | Out-Null
    
    Write-Success "Redis creado (~`$25/mes Standard C1)"
    
    $REDIS_KEYS = az redis list-keys `
        --name $REDIS_NAME `
        --resource-group $RESOURCE_GROUP | ConvertFrom-Json
    
    $PRIMARY_KEY = $REDIS_KEYS.primaryKey
    $REDIS_URL = "rediss://:${PRIMARY_KEY}@${REDIS_NAME}.redis.cache.windows.net:6380"
    
    Write-Info "Redis Connection String:"
    Write-Host $REDIS_URL -ForegroundColor Yellow
}

# ============================================================================
# PASO 7: STORAGE ACCOUNT
# ============================================================================

Write-Step "Paso 7/9: Creando Storage Account..."

try {
    az storage account show --name $STORAGE_ACCOUNT --resource-group $RESOURCE_GROUP 2>&1 | Out-Null
    Write-Warning "Storage ya existe"
} catch {
    az storage account create `
        --name $STORAGE_ACCOUNT `
        --resource-group $RESOURCE_GROUP `
        --location $LOCATION `
        --sku Standard_LRS `
        --kind StorageV2 `
        --access-tier Hot | Out-Null
    
    Write-Success "Storage creado (~`$5/mes)"
}

# ============================================================================
# PASO 8: APPLICATION INSIGHTS
# ============================================================================

Write-Step "Paso 8/9: Creando Application Insights..."

try {
    az monitor app-insights component show --app $INSIGHTS_NAME --resource-group $RESOURCE_GROUP 2>&1 | Out-Null
    Write-Warning "Application Insights ya existe"
} catch {
    az monitor app-insights component create `
        --app $INSIGHTS_NAME `
        --location $LOCATION `
        --resource-group $RESOURCE_GROUP `
        --application-type web | Out-Null
    
    $INSIGHTS_KEY = az monitor app-insights component show `
        --app $INSIGHTS_NAME `
        --resource-group $RESOURCE_GROUP `
        --query connectionString -o tsv
    
    Write-Success "Application Insights creado (~`$5/mes)"
    Write-Info "Connection String:"
    Write-Host $INSIGHTS_KEY -ForegroundColor Yellow
}

# ============================================================================
# PASO 9: CONFIGURAR ENV VARS
# ============================================================================

Write-Step "Paso 9/9: Configurando variables de entorno..."

# Generar secrets
$JWT_ACCESS_SECRET = [Convert]::ToBase64String([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(64))
$JWT_REFRESH_SECRET = [Convert]::ToBase64String([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(64))
$SESSION_SECRET = [Convert]::ToBase64String([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(32))

az webapp config appsettings set `
    --name $BACKEND_NAME `
    --resource-group $RESOURCE_GROUP `
    --settings `
        NODE_ENV=production `
        PORT=8080 `
        DATABASE_URL="$DB_CONN_STRING" `
        REDIS_URL="$REDIS_URL" `
        JWT_ACCESS_SECRET="$JWT_ACCESS_SECRET" `
        JWT_REFRESH_SECRET="$JWT_REFRESH_SECRET" `
        SESSION_SECRET="$SESSION_SECRET" `
        APPLICATIONINSIGHTS_CONNECTION_STRING="$INSIGHTS_KEY" | Out-Null

Write-Success "Variables configuradas"

# ============================================================================
# RESUMEN FINAL
# ============================================================================

Write-Host @"

╔════════════════════════════════════════════════════════════════╗
║                   ✓ SETUP COMPLETADO                           ║
╚════════════════════════════════════════════════════════════════╝

📊 RECURSOS CREADOS:
───────────────────────────────────────────────────────────────
1. Resource Group:    $RESOURCE_GROUP
2. App Service Plan:  $APP_PLAN_NAME (B1)
3. Backend Web App:   https://$BACKEND_NAME.azurewebsites.net
4. Frontend:          https://$FRONTEND_NAME.azurestaticapps.net
5. PostgreSQL:        $DB_SERVER_NAME
6. Redis Cache:       $REDIS_NAME
7. Storage Account:   $STORAGE_ACCOUNT
8. App Insights:      $INSIGHTS_NAME

💰 COSTO MENSUAL:
───────────────────────────────────────────────────────────────
App Service B1:          ~`$13/mes
Static Web App:           `$0/mes (Free)
PostgreSQL B1MS:          `$0/mes (Free 750h)
Redis Standard C1:       ~`$25/mes
Storage + Monitoring:    ~`$15/mes
───────────────────────────────────────────────────────────────
TOTAL:                   ~`$53/mes
MARGEN RESTANTE:         `$147/mes

🔑 PRÓXIMOS PASOS:
───────────────────────────────────────────────────────────────
1. Configurar GitHub Secrets (ver AZURE_SETUP_GUIDE.md)
2. git push origin main (deploy automático)
3. Verificar: https://$BACKEND_NAME.azurewebsites.net/api/health

✓ Setup completo. ¡Listo para deploy!

"@ -ForegroundColor Green


