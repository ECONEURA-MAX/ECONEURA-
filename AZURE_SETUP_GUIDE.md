# 🚀 AZURE SETUP GUIDE - ECONEURA

Guía completa para configurar ECONEURA en Azure desde cero.

---

## 📋 PREREQUISITOS

- ✅ Cuenta de Azure activa
- ✅ Azure CLI instalado
- ✅ Código en GitHub (ECONEURA-MAX/ECONEURA-)
- ✅ Dominio econeura.com (opcional)

---

## 🔧 PASO 1: CREAR RECURSOS EN AZURE

### 1.1 Login en Azure

```bash
az login
az account list --output table
az account set --subscription "TU_SUBSCRIPTION_ID"
```

### 1.2 Crear Resource Group

```bash
az group create \
  --name econeura-resources \
  --location northeurope \
  --tags Environment=Production Project=ECONEURA
```

### 1.3 Crear App Service Plan

```bash
# Plan Basic (B1) - ~€50/mes
az appservice plan create \
  --name econeura-plan \
  --resource-group econeura-resources \
  --location northeurope \
  --sku B1 \
  --is-linux

# O Plan Free (F1) - Gratis para testing
az appservice plan create \
  --name econeura-plan-free \
  --resource-group econeura-resources \
  --location northeurope \
  --sku F1 \
  --is-linux
```

### 1.4 Crear Web App para Backend

```bash
az webapp create \
  --name econeura-backend-prod \
  --resource-group econeura-resources \
  --plan econeura-plan \
  --runtime "NODE:20-lts"

# Configurar Node.js
az webapp config set \
  --name econeura-backend-prod \
  --resource-group econeura-resources \
  --startup-file "node server.js"

# Habilitar logs
az webapp log config \
  --name econeura-backend-prod \
  --resource-group econeura-resources \
  --application-logging filesystem \
  --detailed-error-messages true \
  --failed-request-tracing true \
  --web-server-logging filesystem
```

### 1.5 Crear Static Web App para Frontend

```bash
az staticwebapp create \
  --name econeura-frontend-prod \
  --resource-group econeura-resources \
  --location westeurope \
  --source https://github.com/ECONEURA-MAX/ECONEURA- \
  --branch main \
  --app-location "frontend" \
  --output-location "dist" \
  --sku Free

# Obtener deployment token
az staticwebapp secrets list \
  --name econeura-frontend-prod \
  --resource-group econeura-resources \
  --query "properties.apiKey" -o tsv
```

### 1.6 Crear PostgreSQL Database (Opcional)

```bash
# PostgreSQL Flexible Server
az postgres flexible-server create \
  --name econeura-db-prod \
  --resource-group econeura-resources \
  --location northeurope \
  --admin-user econeuroadmin \
  --admin-password "TU_PASSWORD_SEGURO" \
  --sku-name Standard_B1ms \
  --tier Burstable \
  --storage-size 32 \
  --version 15

# Crear base de datos
az postgres flexible-server db create \
  --resource-group econeura-resources \
  --server-name econeura-db-prod \
  --database-name econeura

# Permitir acceso desde Azure services
az postgres flexible-server firewall-rule create \
  --resource-group econeura-resources \
  --name econeura-db-prod \
  --rule-name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0
```

### 1.7 Crear Redis Cache (Opcional)

```bash
az redis create \
  --name econeura-redis-prod \
  --resource-group econeura-resources \
  --location northeurope \
  --sku Basic \
  --vm-size c0

# Obtener connection string
az redis list-keys \
  --name econeura-redis-prod \
  --resource-group econeura-resources
```

---

## 🔐 PASO 2: CONFIGURAR VARIABLES DE ENTORNO

### 2.1 Backend Environment Variables

```bash
az webapp config appsettings set \
  --name econeura-backend-prod \
  --resource-group econeura-resources \
  --settings \
    NODE_ENV=production \
    PORT=8080 \
    DATABASE_URL="postgresql://econeuroadmin:PASSWORD@econeura-db-prod.postgres.database.azure.com:5432/econeura?sslmode=require" \
    REDIS_URL="redis://:PRIMARY_KEY@econeura-redis-prod.redis.cache.windows.net:6380?ssl=true" \
    JWT_ACCESS_SECRET="$(openssl rand -base64 64)" \
    JWT_REFRESH_SECRET="$(openssl rand -base64 64)" \
    SESSION_SECRET="$(openssl rand -base64 32)" \
    OPENAI_API_KEY="tu-api-key" \
    APPLICATIONINSIGHTS_CONNECTION_STRING="tu-app-insights-connection-string"
```

### 2.2 Ver variables configuradas

```bash
az webapp config appsettings list \
  --name econeura-backend-prod \
  --resource-group econeura-resources \
  --output table
```

---

## 🔑 PASO 3: CONFIGURAR GITHUB SECRETS

### 3.1 Obtener Azure Credentials

```bash
# Crear Service Principal
az ad sp create-for-rbac \
  --name "econeura-github-actions" \
  --role contributor \
  --scopes /subscriptions/TU_SUBSCRIPTION_ID/resourceGroups/econeura-resources \
  --sdk-auth
```

Copiar el JSON completo → GitHub Secret: `AZURE_CREDENTIALS`

### 3.2 Obtener Publish Profile (Backend)

```bash
az webapp deployment list-publishing-profiles \
  --name econeura-backend-prod \
  --resource-group econeura-resources \
  --xml
```

Copiar el XML → GitHub Secret: `AZURE_WEBAPP_PUBLISH_PROFILE_PROD`

### 3.3 Obtener Static Web Apps Token (Frontend)

Ya lo obtuvimos en el paso 1.5.

Copiar el token → GitHub Secret: `AZURE_STATIC_WEB_APPS_API_TOKEN_PROD`

### 3.4 Lista de Secrets a crear en GitHub

Ve a: `https://github.com/ECONEURA-MAX/ECONEURA-/settings/secrets/actions`

Crea estos secrets:

| Secret Name | Description | Command |
|-------------|-------------|---------|
| `AZURE_CREDENTIALS` | Service Principal JSON | Ver 3.1 |
| `AZURE_WEBAPP_PUBLISH_PROFILE_PROD` | Backend publish profile | Ver 3.2 |
| `AZURE_STATIC_WEB_APPS_API_TOKEN_PROD` | Frontend deployment token | Ver 3.3 |

---

## 🚀 PASO 4: DEPLOY MANUAL (Primera vez)

### 4.1 Deploy Backend

```bash
cd backend

# Install production dependencies
npm ci --omit=dev

# Create deployment package
zip -r ../backend-prod.zip . \
  -x "*.git*" -x "*node_modules*" -x "*coverage*" \
  -x "*__tests__*" -x "*.test.js" -x "*.log"

# Deploy to Azure
az webapp deployment source config-zip \
  --name econeura-backend-prod \
  --resource-group econeura-resources \
  --src ../backend-prod.zip

# Check logs
az webapp log tail \
  --name econeura-backend-prod \
  --resource-group econeura-resources
```

### 4.2 Deploy Frontend

```bash
cd frontend

# Install dependencies
npm ci

# Build production
VITE_API_URL=https://econeura-backend-prod.azurewebsites.net/api npm run build

# Deploy (usando GitHub Actions es más fácil)
# O usar el portal de Azure Static Web Apps
```

---

## ✅ PASO 5: VERIFICAR DEPLOYMENT

### 5.1 Health Checks

```bash
# Backend health
curl https://econeura-backend-prod.azurewebsites.net/api/health | jq

# Frontend
curl -I https://econeura.com
```

### 5.2 Ver Logs en Tiempo Real

```bash
# Backend logs
az webapp log tail \
  --name econeura-backend-prod \
  --resource-group econeura-resources

# Ver logs históricos
az webapp log download \
  --name econeura-backend-prod \
  --resource-group econeura-resources \
  --log-file backend-logs.zip
```

---

## 🔧 PASO 6: CONFIGURAR DOMINIO (Opcional)

### 6.1 Configurar dominio en Static Web App

```bash
# Agregar dominio personalizado
az staticwebapp hostname set \
  --name econeura-frontend-prod \
  --resource-group econeura-resources \
  --hostname econeura.com

# Habilitar HTTPS
az staticwebapp hostname set \
  --name econeura-frontend-prod \
  --resource-group econeura-resources \
  --hostname econeura.com \
  --validation-method cname-delegation
```

### 6.2 Configurar DNS

En tu proveedor de DNS (Namecheap, GoDaddy, etc):

```
Type: CNAME
Name: @
Value: econeura-frontend-prod.azurestaticapps.net
TTL: 3600

Type: TXT  
Name: asuid
Value: [el valor que te dio Azure]
```

---

## 📊 PASO 7: MONITOREO Y OBSERVABILIDAD

### 7.1 Application Insights

```bash
# Crear Application Insights
az monitor app-insights component create \
  --app econeura-insights \
  --location northeurope \
  --resource-group econeura-resources \
  --application-type web

# Obtener connection string
az monitor app-insights component show \
  --app econeura-insights \
  --resource-group econeura-resources \
  --query connectionString -o tsv
```

Agregar a las variables de entorno del backend:
```bash
APPLICATIONINSIGHTS_CONNECTION_STRING="el-connection-string"
```

### 7.2 Configurar Alerts

```bash
# Alert si el backend está down
az monitor metrics alert create \
  --name backend-down-alert \
  --resource-group econeura-resources \
  --scopes /subscriptions/SUBSCRIPTION_ID/resourceGroups/econeura-resources/providers/Microsoft.Web/sites/econeura-backend-prod \
  --condition "avg Percentage CPU > 90" \
  --window-size 5m \
  --evaluation-frequency 1m
```

---

## 💰 PASO 8: OPTIMIZAR COSTOS

### Recursos Recomendados por Presupuesto:

#### Opción FREE (€0/mes)
```
✅ App Service Plan: F1 (Free)
✅ Static Web Apps: Free tier
❌ PostgreSQL: SQLite local
❌ Redis: Sin cache
❌ Application Insights: Sin monitoring
```

#### Opción BÁSICA (~€50/mes)
```
✅ App Service Plan: B1 (€13/mes)
✅ Static Web Apps: Free tier
✅ PostgreSQL Flexible: Standard_B1ms (€25/mes)
❌ Redis: Sin cache o Basic C0 (€15/mes)
✅ Application Insights: Básico incluido
```

#### Opción PRO (~€150/mes)
```
✅ App Service Plan: P1V2 (€70/mes)
✅ Static Web Apps: Standard (€9/mes)
✅ PostgreSQL Flexible: Standard_D2s_v3 (€50/mes)
✅ Redis: Standard C1 (€25/mes)
✅ Application Insights: Pro
```

---

## 🔄 PASO 9: CI/CD CON GITHUB ACTIONS

Los workflows ya están creados en `.github/workflows/`:
- `ci-tests.yml` - Tests automáticos
- `azure-backend-prod.yml` - Deploy backend
- `azure-frontend-prod.yml` - Deploy frontend

**Para activar CI/CD:**
1. Configura los secrets (Paso 3)
2. Haz commit y push a `main`
3. Los workflows se ejecutarán automáticamente

---

## 📝 COMANDOS ÚTILES

### Ver estado de recursos
```bash
az resource list \
  --resource-group econeura-resources \
  --output table
```

### Restart backend
```bash
az webapp restart \
  --name econeura-backend-prod \
  --resource-group econeura-resources
```

### Ver costos
```bash
az consumption usage list \
  --start-date 2025-11-01 \
  --end-date 2025-11-30 \
  --output table
```

### Eliminar todo (CUIDADO!)
```bash
az group delete \
  --name econeura-resources \
  --yes --no-wait
```

---

## ✅ CHECKLIST FINAL

- [ ] Resource Group creado
- [ ] App Service Plan creado
- [ ] Backend Web App creada
- [ ] Frontend Static Web App creada
- [ ] PostgreSQL Database creada (opcional)
- [ ] Redis Cache creado (opcional)
- [ ] Variables de entorno configuradas
- [ ] GitHub Secrets configurados
- [ ] Application Insights configurado
- [ ] Primer deploy manual exitoso
- [ ] Health checks pasando
- [ ] CI/CD funcionando
- [ ] Dominio configurado (opcional)
- [ ] Monitoring activo
- [ ] Presupuesto configurado

---

## 🆘 TROUBLESHOOTING

### Backend no arranca
```bash
# Ver logs
az webapp log tail --name econeura-backend-prod --resource-group econeura-resources

# Verificar variables
az webapp config appsettings list --name econeura-backend-prod --resource-group econeura-resources
```

### Frontend 404
```bash
# Verificar build
cd frontend && npm run build

# Verificar deployment
az staticwebapp show --name econeura-frontend-prod --resource-group econeura-resources
```

### Database connection error
```bash
# Verificar firewall rules
az postgres flexible-server firewall-rule list \
  --name econeura-db-prod \
  --resource-group econeura-resources
```

---

**¿Necesitas ayuda?** Revisa la documentación de Azure o contacta soporte.

**ECONEURA** - Enterprise Ready 10/10 ✅


