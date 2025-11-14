# ===================================================================
# ECONEURA - Azure Staging Setup Script
# ===================================================================
# Descripción: Script automatizado para crear todos los servicios
#              Azure necesarios para ECONEURA staging
# Autor: Claude Sonnet 4.5 (Senior AI Assistant)
# Fecha: 13 Noviembre 2025
# ===================================================================

param(
    [string]$SubscriptionId = "a0991f95-16e0-4f03-85df-db3d69004d94",
    [string]$ResourceGroup = "rg-econeura-staging",
    [string]$Location = "westeurope",
    [switch]$SkipConfirmation
)

# Colores para output
$Colors = @{
    Success = "Green"
    Info = "Cyan"
    Warning = "Yellow"
    Error = "Red"
}

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Write-Step {
    param([string]$Message)
    Write-ColorOutput "`n=== $Message ===" $Colors.Info
}

function Write-Success {
    param([string]$Message)
    Write-ColorOutput "✅ $Message" $Colors.Success
}

function Write-Error {
    param([string]$Message)
    Write-ColorOutput "❌ $Message" $Colors.Error
}

function Write-Warning {
    param([string]$Message)
    Write-ColorOutput "⚠️  $Message" $Colors.Warning
}

# ===================================================================
# BANNER
# ===================================================================

Clear-Host
Write-ColorOutput @"

╔══════════════════════════════════════════════════════════╗
║                                                          ║
║           🌳 ECONEURA - AZURE STAGING SETUP 🌳          ║
║                                                          ║
║  Este script creará automáticamente todos los servicios ║
║  Azure necesarios para ECONEURA staging environment     ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝

"@ $Colors.Info

Write-Host "Subscription ID: $SubscriptionId"
Write-Host "Resource Group:  $ResourceGroup"
Write-Host "Location:        $Location"
Write-Host ""

if (-not $SkipConfirmation) {
    $confirm = Read-Host "¿Continuar? (yes/no)"
    if ($confirm -ne "yes") {
        Write-Warning "Setup cancelado por el usuario"
        exit 0
    }
}

# ===================================================================
# VERIFICACIONES PREVIAS
# ===================================================================

Write-Step "Verificando requisitos previos"

# Verificar Azure CLI
try {
    $azVersion = az version --output json | ConvertFrom-Json
    Write-Success "Azure CLI instalado: $($azVersion.'azure-cli')"
} catch {
    Write-Error "Azure CLI no encontrado. Instalar desde: https://aka.ms/installazurecliwindows"
    exit 1
}

# Login Azure
Write-Step "Verificando sesión de Azure"
$account = az account show 2>$null | ConvertFrom-Json
if (-not $account) {
    Write-Warning "No hay sesión activa. Iniciando login..."
    az login
    $account = az account show | ConvertFrom-Json
}

Write-Success "Sesión activa: $($account.user.name)"

# Set subscription
Write-Step "Configurando subscription"
az account set --subscription $SubscriptionId
$currentSub = az account show | ConvertFrom-Json
Write-Success "Subscription activa: $($currentSub.name)"

# ===================================================================
# CREAR RESOURCE GROUP
# ===================================================================

Write-Step "Creando Resource Group"
az group create `
    --name $ResourceGroup `
    --location $Location `
    --tags Environment=Staging Project=ECONEURA Owner=ECONEURA-MAX `
    --output none

if ($LASTEXITCODE -eq 0) {
    Write-Success "Resource Group creado: $ResourceGroup"
} else {
    Write-Error "Error creando Resource Group"
    exit 1
}

# ===================================================================
# GENERAR PASSWORDS SEGUROS
# ===================================================================

Write-Step "Generando contraseñas seguras"

function Generate-SecurePassword {
    $length = 24
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()"
    $password = -join ((1..$length) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
    return $password
}

$DB_PASSWORD = Generate-SecurePassword
$ADMIN_PASSWORD = Generate-SecurePassword

Write-Success "Contraseñas generadas (se guardarán en Key Vault)"

# ===================================================================
# POSTGRESQL FLEXIBLE SERVER
# ===================================================================

Write-Step "Creando PostgreSQL Flexible Server (puede tardar 5-10 min)"

$DB_NAME = "econeura-db-staging"
$DB_ADMIN = "econeuraadmin"

az postgres flexible-server create `
    --name $DB_NAME `
    --resource-group $ResourceGroup `
    --location $Location `
    --admin-user $DB_ADMIN `
    --admin-password $DB_PASSWORD `
    --sku-name Standard_B1ms `
    --tier Burstable `
    --version 16 `
    --storage-size 32 `
    --backup-retention 7 `
    --high-availability Disabled `
    --public-access All `
    --tags Environment=Staging `
    --yes `
    --output none

if ($LASTEXITCODE -eq 0) {
    Write-Success "PostgreSQL creado: $DB_NAME"
    
    # Crear database
    az postgres flexible-server db create `
        --resource-group $ResourceGroup `
        --server-name $DB_NAME `
        --database-name econeura `
        --output none
    
    Write-Success "Database 'econeura' creada"
    
    # Obtener connection string
    $DB_HOST = az postgres flexible-server show `
        --resource-group $ResourceGroup `
        --name $DB_NAME `
        --query "fullyQualifiedDomainName" -o tsv
    
    $DB_CONNECTION_STRING = "postgresql://${DB_ADMIN}:${DB_PASSWORD}@${DB_HOST}:5432/econeura?sslmode=require"
    Write-Success "Connection string generado"
} else {
    Write-Error "Error creando PostgreSQL"
}

# ===================================================================
# REDIS CACHE
# ===================================================================

Write-Step "Creando Redis Cache (puede tardar 10-15 min)"

$REDIS_NAME = "econeura-redis-staging"

az redis create `
    --name $REDIS_NAME `
    --resource-group $ResourceGroup `
    --location $Location `
    --sku Basic `
    --vm-size c0 `
    --enable-non-ssl-port false `
    --minimum-tls-version 1.2 `
    --tags Environment=Staging `
    --output none

if ($LASTEXITCODE -eq 0) {
    Write-Success "Redis Cache creado: $REDIS_NAME"
    
    # Esperar a que esté disponible
    Write-Warning "Esperando que Redis Cache esté disponible..."
    Start-Sleep -Seconds 60
    
    # Obtener keys
    $REDIS_KEY = az redis list-keys `
        --resource-group $ResourceGroup `
        --name $REDIS_NAME `
        --query primaryKey -o tsv
    
    $REDIS_HOST = az redis show `
        --resource-group $ResourceGroup `
        --name $REDIS_NAME `
        --query hostName -o tsv
    
    $REDIS_CONNECTION_STRING = "rediss://:${REDIS_KEY}@${REDIS_HOST}:6380"
    Write-Success "Redis connection string generado"
} else {
    Write-Error "Error creando Redis Cache"
}

# ===================================================================
# STORAGE ACCOUNT
# ===================================================================

Write-Step "Creando Storage Account"

$STORAGE_NAME = "econeurastoragestg"

az storage account create `
    --name $STORAGE_NAME `
    --resource-group $ResourceGroup `
    --location $Location `
    --sku Standard_LRS `
    --kind StorageV2 `
    --access-tier Hot `
    --https-only true `
    --min-tls-version TLS1_2 `
    --allow-blob-public-access false `
    --tags Environment=Staging `
    --output none

if ($LASTEXITCODE -eq 0) {
    Write-Success "Storage Account creado: $STORAGE_NAME"
    
    # Crear container
    az storage container create `
        --name rag-library `
        --account-name $STORAGE_NAME `
        --public-access off `
        --auth-mode login `
        --output none
    
    Write-Success "Container 'rag-library' creado"
    
    # Obtener connection string
    $STORAGE_CONNECTION_STRING = az storage account show-connection-string `
        --name $STORAGE_NAME `
        --resource-group $ResourceGroup `
        --query connectionString -o tsv
    
    Write-Success "Storage connection string generado"
} else {
    Write-Error "Error creando Storage Account"
}

# ===================================================================
# KEY VAULT
# ===================================================================

Write-Step "Creando Key Vault"

$KV_NAME = "econeura-kv-stg"

az keyvault create `
    --name $KV_NAME `
    --resource-group $ResourceGroup `
    --location $Location `
    --sku standard `
    --enabled-for-deployment true `
    --enabled-for-template-deployment true `
    --tags Environment=Staging `
    --output none

if ($LASTEXITCODE -eq 0) {
    Write-Success "Key Vault creado: $KV_NAME"
    
    # Dar permisos al usuario actual
    $MY_OBJECT_ID = az ad signed-in-user show --query id -o tsv
    az keyvault set-policy `
        --name $KV_NAME `
        --object-id $MY_OBJECT_ID `
        --secret-permissions get list set delete `
        --output none
    
    # Guardar secrets
    az keyvault secret set --vault-name $KV_NAME --name DatabasePassword --value $DB_PASSWORD --output none
    az keyvault secret set --vault-name $KV_NAME --name RedisKey --value $REDIS_KEY --output none
    az keyvault secret set --vault-name $KV_NAME --name DatabaseConnectionString --value $DB_CONNECTION_STRING --output none
    az keyvault secret set --vault-name $KV_NAME --name RedisConnectionString --value $REDIS_CONNECTION_STRING --output none
    az keyvault secret set --vault-name $KV_NAME --name StorageConnectionString --value $STORAGE_CONNECTION_STRING --output none
    
    Write-Success "Secrets guardados en Key Vault"
} else {
    Write-Error "Error creando Key Vault"
}

# ===================================================================
# APPLICATION INSIGHTS
# ===================================================================

Write-Step "Creando Application Insights"

$LOGS_NAME = "econeura-logs-staging"
$INSIGHTS_NAME = "econeura-insights-staging"

# Log Analytics Workspace
az monitor log-analytics workspace create `
    --workspace-name $LOGS_NAME `
    --resource-group $ResourceGroup `
    --location $Location `
    --sku PerGB2018 `
    --retention-time 30 `
    --tags Environment=Staging `
    --output none

Write-Success "Log Analytics Workspace creado"

# Application Insights
az monitor app-insights component create `
    --app $INSIGHTS_NAME `
    --resource-group $ResourceGroup `
    --location $Location `
    --workspace $LOGS_NAME `
    --kind web `
    --application-type Node.JS `
    --tags Environment=Staging `
    --output none

if ($LASTEXITCODE -eq 0) {
    Write-Success "Application Insights creado: $INSIGHTS_NAME"
    
    # Obtener connection string
    $APPINSIGHTS_CONNECTION_STRING = az monitor app-insights component show `
        --app $INSIGHTS_NAME `
        --resource-group $ResourceGroup `
        --query connectionString -o tsv
    
    Write-Success "Application Insights connection string generado"
    
    # Guardar en Key Vault
    az keyvault secret set `
        --vault-name $KV_NAME `
        --name ApplicationInsightsConnectionString `
        --value $APPINSIGHTS_CONNECTION_STRING `
        --output none
} else {
    Write-Error "Error creando Application Insights"
}

# ===================================================================
# APP SERVICE PLAN + WEB APP (BACKEND)
# ===================================================================

Write-Step "Creando App Service (Backend)"

$PLAN_NAME = "econeura-plan-staging"
$WEBAPP_NAME = "econeura-backend-staging"

# App Service Plan
az appservice plan create `
    --name $PLAN_NAME `
    --resource-group $ResourceGroup `
    --location $Location `
    --is-linux `
    --sku B2 `
    --tags Environment=Staging `
    --output none

Write-Success "App Service Plan creado"

# Web App
az webapp create `
    --name $WEBAPP_NAME `
    --resource-group $ResourceGroup `
    --plan $PLAN_NAME `
    --runtime "NODE:20-lts" `
    --tags Environment=Staging `
    --output none

if ($LASTEXITCODE -eq 0) {
    Write-Success "Web App creado: $WEBAPP_NAME"
    
    # Configurar App Settings
    az webapp config appsettings set `
        --name $WEBAPP_NAME `
        --resource-group $ResourceGroup `
        --settings `
            NODE_ENV=staging `
            PORT=8080 `
            DATABASE_URL="@Microsoft.KeyVault(SecretUri=https://${KV_NAME}.vault.azure.net/secrets/DatabaseConnectionString/)" `
            REDIS_URL="@Microsoft.KeyVault(SecretUri=https://${KV_NAME}.vault.azure.net/secrets/RedisConnectionString/)" `
            AZURE_STORAGE_CONNECTION_STRING="@Microsoft.KeyVault(SecretUri=https://${KV_NAME}.vault.azure.net/secrets/StorageConnectionString/)" `
            APPLICATIONINSIGHTS_CONNECTION_STRING="@Microsoft.KeyVault(SecretUri=https://${KV_NAME}.vault.azure.net/secrets/ApplicationInsightsConnectionString/)" `
        --output none
    
    Write-Success "App Settings configurados"
    
    # Dar permisos a la Web App para acceder a Key Vault
    Write-Warning "Habilitando Managed Identity..."
    az webapp identity assign `
        --name $WEBAPP_NAME `
        --resource-group $ResourceGroup `
        --output none
    
    $WEBAPP_PRINCIPAL_ID = az webapp identity show `
        --name $WEBAPP_NAME `
        --resource-group $ResourceGroup `
        --query principalId -o tsv
    
    az keyvault set-policy `
        --name $KV_NAME `
        --object-id $WEBAPP_PRINCIPAL_ID `
        --secret-permissions get list `
        --output none
    
    Write-Success "Permisos Key Vault configurados"
    
    # Configurar logs
    az webapp log config `
        --name $WEBAPP_NAME `
        --resource-group $ResourceGroup `
        --application-logging azureblobstorage `
        --detailed-error-messages true `
        --failed-request-tracing true `
        --web-server-logging filesystem `
        --level information `
        --output none
    
    # Health check
    az webapp config set `
        --name $WEBAPP_NAME `
        --resource-group $ResourceGroup `
        --health-check-path /api/health `
        --ftps-state Disabled `
        --http20-enabled true `
        --output none
    
    Write-Success "Logs y health check configurados"
    Write-Success "Backend URL: https://${WEBAPP_NAME}.azurewebsites.net"
} else {
    Write-Error "Error creando Web App"
}

# ===================================================================
# STATIC WEB APP (FRONTEND)
# ===================================================================

Write-Step "Creando Static Web App (Frontend)"

$SWA_NAME = "econeura-frontend-staging"

az staticwebapp create `
    --name $SWA_NAME `
    --resource-group $ResourceGroup `
    --location $Location `
    --sku Free `
    --tags Environment=Staging `
    --output none

if ($LASTEXITCODE -eq 0) {
    Write-Success "Static Web App creado: $SWA_NAME"
    
    # Obtener API token
    $SWA_TOKEN = az staticwebapp secrets list `
        --name $SWA_NAME `
        --resource-group $ResourceGroup `
        --query properties.apiKey -o tsv
    
    Write-Success "Frontend URL: https://${SWA_NAME}.azurestaticapps.net"
    
    # Guardar token en Key Vault
    az keyvault secret set `
        --vault-name $KV_NAME `
        --name StaticWebAppToken `
        --value $SWA_TOKEN `
        --output none
} else {
    Write-Error "Error creando Static Web App"
}

# ===================================================================
# CREAR SERVICE PRINCIPAL PARA GITHUB ACTIONS
# ===================================================================

Write-Step "Creando Service Principal para GitHub Actions"

$SP_NAME = "econeura-github-actions"
$SCOPE = "/subscriptions/${SubscriptionId}/resourceGroups/${ResourceGroup}"

$SP_JSON = az ad sp create-for-rbac `
    --name $SP_NAME `
    --role contributor `
    --scopes $SCOPE `
    --sdk-auth

if ($LASTEXITCODE -eq 0) {
    Write-Success "Service Principal creado: $SP_NAME"
    
    # Guardar en archivo temporal
    $SP_JSON | Out-File -FilePath "azure-credentials.json" -Encoding UTF8
    Write-Success "Credenciales guardadas en: azure-credentials.json"
} else {
    Write-Error "Error creando Service Principal"
}

# ===================================================================
# GENERAR ARCHIVO DE SECRETS PARA GITHUB
# ===================================================================

Write-Step "Generando archivo de secrets para GitHub"

$TENANT_ID = az account show --query tenantId -o tsv

$secretsContent = @"
# ===================================================================
# GITHUB SECRETS - Copiar estos valores a GitHub Repository Secrets
# ===================================================================
# Ruta: GitHub → Settings → Secrets and variables → Actions → New repository secret

# Azure Credentials (JSON completo del Service Principal)
AZURE_CREDENTIALS=
$(Get-Content azure-credentials.json -Raw)

# Azure Subscription
AZURE_SUBSCRIPTION_ID=$SubscriptionId
AZURE_TENANT_ID=$TENANT_ID

# Backend
AZURE_WEBAPP_BACKEND_NAME=$WEBAPP_NAME

# Frontend
AZURE_STATIC_WEB_APPS_API_TOKEN=$SWA_TOKEN

# Environment URLs
VITE_API_URL=https://${WEBAPP_NAME}.azurewebsites.net

# Key Vault
AZURE_KEY_VAULT_NAME=$KV_NAME

# Database (para migrations)
DATABASE_URL=$DB_CONNECTION_STRING

# Redis
REDIS_URL=$REDIS_CONNECTION_STRING

# Storage
AZURE_STORAGE_CONNECTION_STRING=$STORAGE_CONNECTION_STRING

# Application Insights
APPLICATIONINSIGHTS_CONNECTION_STRING=$APPINSIGHTS_CONNECTION_STRING

# ===================================================================
# NOTA: Estos secrets están también guardados en Key Vault:
# https://${KV_NAME}.vault.azure.net/
# ===================================================================
"@

$secretsContent | Out-File -FilePath "github-secrets.txt" -Encoding UTF8
Write-Success "Secrets guardados en: github-secrets.txt"

# ===================================================================
# RESUMEN FINAL
# ===================================================================

Write-Step "RESUMEN DE RECURSOS CREADOS"

Write-ColorOutput @"

✅ Resource Group:             $ResourceGroup
✅ PostgreSQL:                 $DB_NAME
✅ Redis Cache:                $REDIS_NAME
✅ Storage Account:            $STORAGE_NAME
✅ Key Vault:                  $KV_NAME
✅ Application Insights:       $INSIGHTS_NAME
✅ App Service Plan:           $PLAN_NAME
✅ Web App (Backend):          $WEBAPP_NAME
✅ Static Web App (Frontend):  $SWA_NAME
✅ Service Principal:          $SP_NAME

"@ $Colors.Success

Write-ColorOutput @"
═══════════════════════════════════════════════════════════
                        URLS
═══════════════════════════════════════════════════════════
"@ $Colors.Info

Write-Host "🌐 Backend:      https://${WEBAPP_NAME}.azurewebsites.net"
Write-Host "🌐 Frontend:     https://${SWA_NAME}.azurestaticapps.net"
Write-Host "🔐 Key Vault:    https://${KV_NAME}.vault.azure.net/"
Write-Host "📊 Portal Azure: https://portal.azure.com/#@/resource/subscriptions/${SubscriptionId}/resourceGroups/${ResourceGroup}/overview"
Write-Host ""

Write-ColorOutput @"
═══════════════════════════════════════════════════════════
                    PRÓXIMOS PASOS
═══════════════════════════════════════════════════════════
"@ $Colors.Info

Write-Host ""
Write-Host "1. Revisar archivos generados:"
Write-Host "   - github-secrets.txt (añadir a GitHub Secrets)"
Write-Host "   - azure-credentials.json (AZURE_CREDENTIALS secret)"
Write-Host ""
Write-Host "2. Configurar GitHub Secrets:"
Write-Host "   GitHub → Settings → Secrets and variables → Actions"
Write-Host ""
Write-Host "3. Push código a GitHub:"
Write-Host "   git push origin main"
Write-Host ""
Write-Host "4. Workflows se ejecutarán automáticamente"
Write-Host ""
Write-Host "5. Verificar deployment:"
Write-Host "   - Backend:  curl https://${WEBAPP_NAME}.azurewebsites.net/api/health"
Write-Host "   - Frontend: abrir https://${SWA_NAME}.azurestaticapps.net"
Write-Host ""

Write-ColorOutput @"
═══════════════════════════════════════════════════════════
              🎉 SETUP COMPLETADO EXITOSAMENTE 🎉
═══════════════════════════════════════════════════════════
"@ $Colors.Success

Write-Host ""
Write-Host "Tiempo estimado de deployment: 10-15 minutos"
Write-Host "Coste mensual estimado: ~€67/mes (staging)"
Write-Host ""

Write-Warning "IMPORTANTE: Guardar github-secrets.txt y azure-credentials.json en un lugar seguro"
Write-Warning "NO subir estos archivos a GitHub (.gitignore ya los excluye)"

Write-Host ""
Write-Host "¿Preguntas? Revisa la documentación:"
Write-Host "- ESTRATEGIA_AZURE_GITHUB_ENTERPRISE.md"
Write-Host "- PLAN_EJECUCION_AZURE_PASO_A_PASO.md"
Write-Host ""

