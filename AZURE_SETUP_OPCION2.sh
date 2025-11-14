#!/bin/bash
###############################################################################
# ECONEURA - Azure Setup Script (Opción 2: Básico Profesional $53/mes)
# 
# Este script crea todos los recursos necesarios en Azure
# Tiempo estimado: 15-20 minutos
###############################################################################

set -e  # Exit on error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         ECONEURA - Azure Setup (Opción 2: $53/mes)            ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

###############################################################################
# CONFIGURACIÓN
###############################################################################

SUBSCRIPTION_ID="a0991f95-16e0-4f03-85df-db3d69004d94"
RESOURCE_GROUP="econeura-resources"
LOCATION="northeurope"  # Más barato que westeurope
LOCATION_SECONDARY="westeurope"  # Para Static Web Apps

# Nombres de recursos
APP_PLAN_NAME="econeura-plan-b1"
BACKEND_NAME="econeura-backend-prod"
FRONTEND_NAME="econeura-frontend-prod"
DB_SERVER_NAME="econeura-db-prod"
DB_NAME="econeura"
DB_ADMIN_USER="econeuroadmin"
DB_ADMIN_PASS=""  # Se pedirá de forma segura
REDIS_NAME="econeura-redis-prod"
STORAGE_ACCOUNT="econeurastorage"
INSIGHTS_NAME="econeura-insights"

###############################################################################
# FUNCIONES HELPER
###############################################################################

print_step() {
    echo -e "\n${GREEN}▶ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

###############################################################################
# VALIDACIONES INICIALES
###############################################################################

print_step "Validando prerequisitos..."

# Verificar Azure CLI
if ! command -v az &> /dev/null; then
    print_error "Azure CLI no está instalado"
    echo "Instalar desde: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi
print_success "Azure CLI instalado"

# Verificar login
if ! az account show &> /dev/null; then
    print_warning "No estás logueado en Azure"
    print_step "Iniciando login..."
    az login
fi
print_success "Sesión de Azure activa"

# Verificar suscripción
CURRENT_SUB=$(az account show --query id -o tsv)
if [ "$CURRENT_SUB" != "$SUBSCRIPTION_ID" ]; then
    print_warning "Suscripción diferente detectada"
    print_step "Cambiando a suscripción correcta..."
    az account set --subscription "$SUBSCRIPTION_ID"
fi
print_success "Suscripción correcta seleccionada"

###############################################################################
# SOLICITAR PASSWORD DE BASE DE DATOS
###############################################################################

if [ -z "$DB_ADMIN_PASS" ]; then
    print_step "Configurando credenciales de base de datos..."
    read -sp "Ingresa password para PostgreSQL (mínimo 8 caracteres): " DB_ADMIN_PASS
    echo
    if [ ${#DB_ADMIN_PASS} -lt 8 ]; then
        print_error "Password debe tener al menos 8 caracteres"
        exit 1
    fi
fi

###############################################################################
# PASO 1: RESOURCE GROUP
###############################################################################

print_step "Paso 1/9: Creando Resource Group..."

if az group show --name "$RESOURCE_GROUP" &> /dev/null; then
    print_warning "Resource Group ya existe, usando existente"
else
    az group create \
        --name "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --tags Environment=Production Project=ECONEURA CostCenter=Main
    print_success "Resource Group creado: $RESOURCE_GROUP"
fi

###############################################################################
# PASO 2: APP SERVICE PLAN (B1)
###############################################################################

print_step "Paso 2/9: Creando App Service Plan B1..."

if az appservice plan show --name "$APP_PLAN_NAME" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
    print_warning "App Service Plan ya existe"
else
    az appservice plan create \
        --name "$APP_PLAN_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --is-linux \
        --sku B1
    print_success "App Service Plan creado: $APP_PLAN_NAME (B1)"
    print_info "Costo: ~\$13/mes"
fi

###############################################################################
# PASO 3: BACKEND WEB APP
###############################################################################

print_step "Paso 3/9: Creando Backend Web App..."

if az webapp show --name "$BACKEND_NAME" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
    print_warning "Backend Web App ya existe"
else
    az webapp create \
        --name "$BACKEND_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --plan "$APP_PLAN_NAME" \
        --runtime "NODE:20-lts"
    
    # Configurar startup
    az webapp config set \
        --name "$BACKEND_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --startup-file "node server.js" \
        --always-on true
    
    # Habilitar logs
    az webapp log config \
        --name "$BACKEND_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --application-logging filesystem \
        --detailed-error-messages true \
        --failed-request-tracing true \
        --web-server-logging filesystem
    
    print_success "Backend Web App creado: $BACKEND_NAME"
    print_info "URL: https://$BACKEND_NAME.azurewebsites.net"
fi

###############################################################################
# PASO 4: FRONTEND STATIC WEB APP (FREE)
###############################################################################

print_step "Paso 4/9: Creando Frontend Static Web App..."

if az staticwebapp show --name "$FRONTEND_NAME" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
    print_warning "Frontend Static Web App ya existe"
else
    az staticwebapp create \
        --name "$FRONTEND_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION_SECONDARY" \
        --source https://github.com/ECONEURA-MAX/ECONEURA- \
        --branch main \
        --app-location "frontend" \
        --output-location "dist" \
        --sku Free
    
    print_success "Frontend Static Web App creado: $FRONTEND_NAME"
    print_info "Costo: \$0/mes (Free Tier)"
    
    # Obtener deployment token
    STATIC_TOKEN=$(az staticwebapp secrets list \
        --name "$FRONTEND_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --query "properties.apiKey" -o tsv)
    
    print_info "Deployment Token (guardar en GitHub Secret AZURE_STATIC_WEB_APPS_API_TOKEN_PROD):"
    echo "$STATIC_TOKEN"
fi

###############################################################################
# PASO 5: POSTGRESQL FLEXIBLE SERVER (FREE B1MS)
###############################################################################

print_step "Paso 5/9: Creando PostgreSQL Flexible Server..."

if az postgres flexible-server show --name "$DB_SERVER_NAME" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
    print_warning "PostgreSQL Server ya existe"
else
    # Crear servidor
    az postgres flexible-server create \
        --name "$DB_SERVER_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --admin-user "$DB_ADMIN_USER" \
        --admin-password "$DB_ADMIN_PASS" \
        --sku-name Standard_B1ms \
        --tier Burstable \
        --storage-size 32 \
        --version 15 \
        --public-access 0.0.0.0
    
    # Crear base de datos
    az postgres flexible-server db create \
        --resource-group "$RESOURCE_GROUP" \
        --server-name "$DB_SERVER_NAME" \
        --database-name "$DB_NAME"
    
    # Firewall: permitir Azure services
    az postgres flexible-server firewall-rule create \
        --resource-group "$RESOURCE_GROUP" \
        --name "$DB_SERVER_NAME" \
        --rule-name AllowAzureServices \
        --start-ip-address 0.0.0.0 \
        --end-ip-address 0.0.0.0
    
    print_success "PostgreSQL Server creado: $DB_SERVER_NAME"
    print_info "Costo: \$0/mes (750 horas B1MS + 32 GB storage FREE)"
    
    # Connection string
    DB_CONN_STRING="postgresql://$DB_ADMIN_USER:$DB_ADMIN_PASS@$DB_SERVER_NAME.postgres.database.azure.com:5432/$DB_NAME?sslmode=require"
    print_info "Connection String (guardar seguro):"
    echo "$DB_CONN_STRING"
fi

###############################################################################
# PASO 6: REDIS CACHE (STANDARD C1)
###############################################################################

print_step "Paso 6/9: Creando Redis Cache..."

if az redis show --name "$REDIS_NAME" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
    print_warning "Redis Cache ya existe"
else
    az redis create \
        --name "$REDIS_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --sku Standard \
        --vm-size c1 \
        --enable-non-ssl-port false
    
    print_success "Redis Cache creado: $REDIS_NAME"
    print_info "Costo: ~\$25/mes (Standard C1)"
    
    # Obtener keys
    REDIS_KEYS=$(az redis list-keys \
        --name "$REDIS_NAME" \
        --resource-group "$RESOURCE_GROUP")
    
    PRIMARY_KEY=$(echo $REDIS_KEYS | jq -r '.primaryKey')
    REDIS_URL="rediss://:$PRIMARY_KEY@$REDIS_NAME.redis.cache.windows.net:6380"
    
    print_info "Redis Connection String (guardar seguro):"
    echo "$REDIS_URL"
fi

###############################################################################
# PASO 7: STORAGE ACCOUNT (HOT LRS)
###############################################################################

print_step "Paso 7/9: Creando Storage Account..."

if az storage account show --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
    print_warning "Storage Account ya existe"
else
    az storage account create \
        --name "$STORAGE_ACCOUNT" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --sku Standard_LRS \
        --kind StorageV2 \
        --access-tier Hot \
        --allow-blob-public-access false
    
    print_success "Storage Account creado: $STORAGE_ACCOUNT"
    print_info "Costo: ~\$5/mes (20 GB estimado)"
fi

###############################################################################
# PASO 8: APPLICATION INSIGHTS
###############################################################################

print_step "Paso 8/9: Creando Application Insights..."

if az monitor app-insights component show --app "$INSIGHTS_NAME" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
    print_warning "Application Insights ya existe"
else
    az monitor app-insights component create \
        --app "$INSIGHTS_NAME" \
        --location "$LOCATION" \
        --resource-group "$RESOURCE_GROUP" \
        --application-type web
    
    INSIGHTS_KEY=$(az monitor app-insights component show \
        --app "$INSIGHTS_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --query connectionString -o tsv)
    
    print_success "Application Insights creado: $INSIGHTS_NAME"
    print_info "Costo: ~\$5/mes (3-5 GB estimado)"
    print_info "Connection String (guardar en env vars):"
    echo "$INSIGHTS_KEY"
fi

###############################################################################
# PASO 9: CONFIGURAR VARIABLES DE ENTORNO EN BACKEND
###############################################################################

print_step "Paso 9/9: Configurando variables de entorno en Backend..."

# Generar secrets
JWT_ACCESS_SECRET=$(openssl rand -base64 64 | tr -d '\n')
JWT_REFRESH_SECRET=$(openssl rand -base64 64 | tr -d '\n')
SESSION_SECRET=$(openssl rand -base64 32 | tr -d '\n')

az webapp config appsettings set \
    --name "$BACKEND_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --settings \
        NODE_ENV=production \
        PORT=8080 \
        DATABASE_URL="$DB_CONN_STRING" \
        REDIS_URL="$REDIS_URL" \
        JWT_ACCESS_SECRET="$JWT_ACCESS_SECRET" \
        JWT_REFRESH_SECRET="$JWT_REFRESH_SECRET" \
        SESSION_SECRET="$SESSION_SECRET" \
        APPLICATIONINSIGHTS_CONNECTION_STRING="$INSIGHTS_KEY"

print_success "Variables de entorno configuradas"

###############################################################################
# RESUMEN FINAL
###############################################################################

echo -e "\n${GREEN}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                   ✓ SETUP COMPLETADO                           ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "\n${BLUE}📊 RECURSOS CREADOS:${NC}\n"
echo "1. Resource Group: $RESOURCE_GROUP"
echo "2. App Service Plan: $APP_PLAN_NAME (B1)"
echo "3. Backend Web App: https://$BACKEND_NAME.azurewebsites.net"
echo "4. Frontend Static Web App: https://$FRONTEND_NAME.azurestaticapps.net"
echo "5. PostgreSQL Server: $DB_SERVER_NAME"
echo "6. Redis Cache: $REDIS_NAME"
echo "7. Storage Account: $STORAGE_ACCOUNT"
echo "8. Application Insights: $INSIGHTS_NAME"

echo -e "\n${BLUE}💰 COSTO ESTIMADO MENSUAL:${NC}\n"
echo "App Service B1:          ~\$13/mes"
echo "Static Web App:           \$0/mes (Free)"
echo "PostgreSQL B1MS:          \$0/mes (Free 750h)"
echo "PostgreSQL Storage:      ~\$5/mes (extra)"
echo "Redis Standard C1:       ~\$25/mes"
echo "Storage Account:         ~\$5/mes"
echo "Application Insights:    ~\$5/mes"
echo "───────────────────────────────────"
echo "TOTAL:                   ~\$53/mes"
echo "MARGEN RESTANTE:         \$147/mes"

echo -e "\n${BLUE}🔑 PRÓXIMOS PASOS:${NC}\n"
echo "1. Guardar secrets en GitHub:"
echo "   - AZURE_CREDENTIALS (crear Service Principal)"
echo "   - AZURE_STATIC_WEB_APPS_API_TOKEN_PROD (arriba)"
echo ""
echo "2. Configurar GitHub Actions:"
echo "   - Ya tienes workflows en .github/workflows/"
echo ""
echo "3. Deploy inicial:"
echo "   - git push origin main"
echo ""
echo "4. Verificar:"
echo "   - Backend: https://$BACKEND_NAME.azurewebsites.net/api/health"
echo "   - Frontend: https://$FRONTEND_NAME.azurestaticapps.net"

echo -e "\n${GREEN}✓ Setup completo. ¡Listo para deploy!${NC}\n"

###############################################################################
# FIN
###############################################################################


