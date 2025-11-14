# 🔥 MEGA PROMPT - CUMPLIR CONTRATOS 10/10

**ECONEURA MAX** - Análisis Exhaustivo y Ejecución

---

## ❌ DIAGNÓSTICO BRUTAL - MIS ERRORES

### 1. **NO ANALICÉ TODO EL MONOREPO**
- ❌ Me bloqueé en paths de `logger.js`
- ❌ NO leí `PRE_COMMIT_CHECKLIST.md`
- ❌ NO leí `verificar-antes-deploy.js`
- ❌ NO leí `1_VISION_OBJETIVO_MONOREPO_10DE10.md`
- ❌ NO ejecuté CONTRATOS de calidad

### 2. **NO CUMPLÍ CHECKLIST CRÍTICO**

```markdown
PRE_COMMIT_CHECKLIST.md:
- [ ] Backend npm start OK
- [ ] Backend health check 200 OK
- [ ] Frontend npm run dev OK
- [ ] Login funcional
- [ ] Tests passing
- [ ] Linting clean
```

### 3. **BACKEND NO ARRANCA POR:**
- ❌ `backend/.env` NO EXISTE
- ❌ Paths de `logger` incorrectos en múltiples archivos
- ❌ NO ejecuté `verificar-antes-deploy.js`

### 4. **FRONTEND CARGA PERO NO MUESTRA LOGIN POR:**
- ❌ Backend NO corre → API calls fallan
- ❌ Login.tsx necesita backend funcional
- ❌ NO verifiqué en navegador

---

## ✅ CONTRATOS QUE DEBO CUMPLIR

### **CONTRATO 1: VERIFICACIÓN LOCAL OBLIGATORIA**

```bash
# PRE-COMMIT (BLOQUEANTE):
1. cd backend && npm install
2. cd backend && npm start  # → PORT 3001 escuchando
3. curl http://localhost:3001/api/health  # → 200 OK
4. cd frontend && npm install
5. cd frontend && npm run dev  # → PORT 5173
6. Abrir http://localhost:5173  # → Ver LOGIN
7. Login con credenciales mock → Ver COCKPIT
```

### **CONTRATO 2: TESTS 100% PASSING**

```bash
cd backend && npm test  # → ALL PASS
cd frontend && npm test  # → ALL PASS
```

### **CONTRATO 3: LINTING 0 ERRORES**

```bash
cd backend && npm run lint  # → 0 errors
cd frontend && npm run lint  # → 0 errors
```

### **CONTRATO 4: BUILD EXITOSO**

```bash
cd frontend && npm run build  # → dist/ generado
```

### **CONTRATO 5: VERIFICAR-ANTES-DEPLOY PASS**

```bash
cd backend && node verificar-antes-deploy.js  # → EXIT 0
```

---

## 🎯 PLAN DE ACCIÓN INMEDIATO

### **PASO 1: CORREGIR PATHS DE LOGGER (30 archivos)**

**Problema**: `services/*.js` usan `require('./services/logger')` (incorrecto)  
**Solución**: Debe ser `require('./logger')`

**Script**:
```javascript
// fix-logger-paths-all.js
const fs = require('fs');
const path = require('path');
const glob = require('glob');

// Pattern 1: services/*.js
glob.sync('backend/services/*.js').forEach(file => {
  let content = fs.readFileSync(file, 'utf8');
  content = content.replace(/require\(['"]\.\/services\/logger['"]\)/g, "require('./logger')");
  fs.writeFileSync(file, content, 'utf8');
});

// Pattern 2: backend/startup-safe.js (YA CORREGIDO)
// Pattern 3: backend/verificar-antes-deploy.js
let content = fs.readFileSync('backend/verificar-antes-deploy.js', 'utf8');
content = content.replace(/require\(['"]\.\.\/services\/logger['"]\)/g, "require('./services/logger')");
fs.writeFileSync('backend/verificar-antes-deploy.js', content, 'utf8');

console.log('✅ Logger paths corregidos');
```

### **PASO 2: CREAR `.env` EN BACKEND**

```bash
# backend/.env
NODE_ENV=development
PORT=3001
USE_MOCK_DB=true
JWT_ACCESS_SECRET=dev_secret_local_only
JWT_REFRESH_SECRET=dev_secret_local_only
SESSION_SECRET=dev_secret_local_only
LOG_LEVEL=info
DATABASE_URL=
REDIS_URL=
OPENAI_API_KEY=
```

### **PASO 3: ARRANCAR BACKEND**

```powershell
cd C:\Users\Usuario\ECONEURA-OK\backend
npm start
```

**Esperado**:
```
[STARTUP] PORT: 3001
✅ ECONEURA Backend v3.0.0 STARTING
Server listening on port 3001
```

### **PASO 4: VERIFICAR HEALTH CHECK**

```powershell
curl http://localhost:3001/api/health
```

**Esperado**:
```json
{"status":"ok","database":"mock","redis":"not_configured"}
```

### **PASO 5: ARRANCAR FRONTEND**

```powershell
cd C:\Users\Usuario\ECONEURA-OK\frontend
npm run dev
```

**Esperado**:
```
VITE ready in 234 ms
➜  Local:   http://localhost:5173/
```

### **PASO 6: VERIFICAR LOGIN EN NAVEGADOR**

1. Abrir `http://localhost:5173`
2. **DEBE MOSTRAR**: Login screen de ECONEURA
3. Ingresar credenciales mock: `test@econeura.com` / `mock`
4. **DEBE MOSTRAR**: Cockpit principal

---

## 🔧 COMANDOS CONSOLIDADOS (WINDOWS)

```powershell
# 1. FIX LOGGER PATHS
cd C:\Users\Usuario\ECONEURA-OK
node fix-logger-paths-all.js

# 2. CREAR .env
cd C:\Users\Usuario\ECONEURA-OK\backend
@"
NODE_ENV=development
PORT=3001
USE_MOCK_DB=true
JWT_ACCESS_SECRET=dev_secret
JWT_REFRESH_SECRET=dev_secret
SESSION_SECRET=dev_secret
LOG_LEVEL=info
"@ | Out-File -Encoding utf8 .env

# 3. VERIFICAR PRE-DEPLOY
node verificar-antes-deploy.js
# Debe: ✅ VERIFICACIÓN COMPLETA - LISTO PARA DEPLOY

# 4. ARRANCAR BACKEND (ventana separada)
Start-Process pwsh -ArgumentList "-NoExit","-Command","cd C:\Users\Usuario\ECONEURA-OK\backend; npm start"

# 5. WAIT + HEALTH CHECK
Start-Sleep -Seconds 8
curl http://localhost:3001/api/health

# 6. ARRANCAR FRONTEND (ventana separada)
Start-Process pwsh -ArgumentList "-NoExit","-Command","cd C:\Users\Usuario\ECONEURA-OK\frontend; npm run dev"

# 7. ABRIR NAVEGADOR
Start-Sleep -Seconds 3
Start-Process "http://localhost:5173"
```

---

## ✅ CHECKLIST FINAL ANTES DE AZURE

### **VERIFICACIÓN LOCAL (BLOQUEANTE)**
- [ ] Backend corre en puerto 3001
- [ ] Health check responde 200 OK
- [ ] Frontend corre en puerto 5173
- [ ] Login screen visible en navegador
- [ ] Login funcional (mock user)
- [ ] Cockpit se muestra correctamente

### **TESTS (BLOQUEANTE)**
- [ ] `cd backend && npm test` → 54/54 passing
- [ ] `cd frontend && npm test` → No errors críticos

### **CALIDAD (BLOQUEANTE)**
- [ ] `node verificar-antes-deploy.js` → EXIT 0
- [ ] UTF-8 fix completo (0 caracteres corruptos)
- [ ] Logger paths corregidos (31 archivos)
- [ ] `.env` creado en backend

### **BUILD (BLOQUEANTE)**
- [ ] `cd frontend && npm run build` → dist/ generado
- [ ] Build size < 1 MB

### **LINTING (RECOMENDADO)**
- [ ] `cd backend && npm run lint` → Ejecutado
- [ ] `cd frontend && npm run lint` → Ejecutado

---

## 🚀 DESPUÉS DE VERIFICACIÓN LOCAL → AZURE

**SOLO SI** todos los checks anteriores pasan:

1. Ejecutar `AZURE_SETUP_WINDOWS.ps1` (crear recursos $53/mes)
2. Configurar GitHub Secrets
3. Git commit + push
4. Workflows CI/CD automáticos

---

## 📊 MÉTRICAS ESPERADAS

| Métrica | Esperado | Bloqueante |
|---------|----------|------------|
| Backend start | PORT 3001 | ✅ SÍ |
| Health check | 200 OK | ✅ SÍ |
| Frontend start | PORT 5173 | ✅ SÍ |
| Login visible | SÍ | ✅ SÍ |
| Cockpit visible | SÍ | ✅ SÍ |
| Tests backend | 54/54 | ✅ SÍ |
| Build frontend | dist/ | ✅ SÍ |
| Verificar-antes-deploy | EXIT 0 | ✅ SÍ |

---

## 🔥 EJECUCIÓN AHORA

**Próximos pasos**:
1. Crear `fix-logger-paths-all.js`
2. Ejecutarlo
3. Crear `backend/.env`
4. Arrancar backend
5. Arrancar frontend
6. Verificar en navegador
7. Reportar resultado

**NO PARAR hasta ver Login + Cockpit funcionando localmente**

---

**Guardado**: 13 Nov 2025 20:35 UTC  
**Status**: MEGA PROMPT LISTO PARA EJECUCIÓN

