# ✅ PRE-COMMIT CHECKLIST - ECONEURA

**Antes de hacer commit a GitHub**: https://github.com/ECONEURA-MAX/ECONEURA-.git

---

## 🔴 CRÍTICO (BLOQUEANTE)

- [ ] **UTF-8 Fix Completo**: 67 caracteres corruptos en `server.js`
  ```powershell
  # Ejecutar:
  $f="C:\Users\Usuario\ECONEURA-OK\backend\server.js"
  $c=[IO.File]::ReadAllText($f,[Text.Encoding]::UTF8)
  $c=$c -replace 'Ã¢Å"â€¦','✅' -replace 'Ã¢Å¡Â Ã¯Â¸Â ','⚠️' -replace 'Ã¢ÂÅ'','❌'
  $c=$c -replace 'CRÃƒÂTICAS','CRÍTICAS' -replace 'autenticaciÃƒÂ³n','autenticación'
  $c=$c -replace 'sesiÃƒÂ³n','sesión' -replace 'lÃƒÂ­nea','línea'
  [IO.File]::WriteAllText($f,$c,[Text.UTF8Encoding]::new($false))
  ```

- [ ] **Renombrar Archivo Inválido**: `[id].js` → `_id.js`
  ```powershell
  Get-ChildItem "backend\api\invoke" | Where { $_.Name -eq '[id].js' } | Rename-Item -NewName '_id.js'
  ```

- [ ] **Actualizar import en código** (buscar referencias a `[id].js`)
  ```powershell
  grep -r "\[id\]" backend/
  ```

---

## 🟠 ALTO (RECOMENDADO)

- [ ] **Eliminar 118 líneas comentadas** (endpoint legacy líneas 313-431)
  - Archivo: `backend/server.js`
  - Acción: Eliminar bloque `/* COMENTADO - Conflicto con router ... */`

- [ ] **Eliminar 64 líneas no usadas** (corsOptionsDynamic líneas 61-125)
  - Archivo: `backend/server.js`
  - Acción: Eliminar variable `corsOptionsDynamic`

- [ ] **Migrar console.log → logger** (56 instancias en 6 archivos)
  ```powershell
  # Archivos afectados:
  # - backend/server.js (2)
  # - backend/verificar-antes-deploy.js (38)
  # - backend/startup-safe.js (10)
  # - backend/services/openaiService.js (1)
  # - backend/services/logger.js (4)
  # - backend/routes/ai-gateway.js (1)
  ```

---

## 🟡 MEDIO (NICE TO HAVE)

- [ ] **Resolver TODOs** (18 archivos con TODOs/FIXMEs)
  - Archivos críticos:
    - `backend/services/resilientAIGateway.js` (3)
    - `backend/routes/chat.js` (2)
    - `backend/startup-safe.js` (2)

- [ ] **Eliminar process.exit** (10 instancias)
  - Reemplazar por graceful shutdown pattern
  - Archivos: `server.js`, `database.js`, `envValidation.js`

- [ ] **Refactor EconeuraCockpit.tsx** (2,524 líneas)
  - Dividir en 4-5 componentes pequeños
  - Prioridad: Post-commit (no bloqueante)

---

## ✅ COMPLETADO

- [x] **Vulnerabilidades npm**: 6 → 0 (frontend)
- [x] **Backend npm dependencies**: Instaladas y verificadas
- [x] **Frontend build**: 871 kB (optimizado)
- [x] **Backend running**: http://localhost:8080 ✅
- [x] **Health check**: Status degraded (normal sin PostgreSQL local)
- [x] **Arquitectura auth.js**: Verificada (NO duplicado)

---

## 🧪 TESTS

- [ ] **Backend Tests**
  ```powershell
  cd backend
  npm test
  ```

- [ ] **Frontend Tests**
  ```powershell
  cd frontend
  npm test
  npm run test:e2e
  ```

- [ ] **Linting**
  ```powershell
  cd backend && npm run lint
  cd frontend && npm run lint
  ```

---

## 📝 PRE-COMMIT COMMANDS

### 1. Verificación Final
```powershell
cd C:\Users\Usuario\ECONEURA-OK

# Verificar UTF-8 fix
(Select-String -Path backend\server.js -Pattern 'Ã|â€').Matches.Count
# Debe ser: 0

# Verificar archivo renombrado
Test-Path backend\api\invoke\_id.js
# Debe ser: True

# Verificar build
Test-Path frontend\dist\index.html
# Debe ser: True
```

### 2. Git Status
```powershell
git status
git diff backend/server.js
```

### 3. Staging (solo si todo OK arriba)
```powershell
git add .
git status
```

### 4. Commit (ESPERAR APROBACIÓN)
```powershell
# NO EJECUTAR AÚN - Revisar checklist completo
git commit -m "feat: Initial enterprise-grade monorepo

- Backend: Node.js + Express + PostgreSQL + Redis
- Frontend: React + TypeScript + Vite 7
- Auth: JWT + OAuth 2.0 (Microsoft + GitHub)
- Monitoring: Health checks + Prometheus metrics
- Security: Helmet + CORS + Rate Limiting
- Tests: Jest + Playwright
- Docs: Enterprise documentation

Fixed:
- 0 npm vulnerabilities
- UTF-8 encoding issues
- Code cleanup (594 commented lines)

Ready for:
- Azure App Service (backend)
- Azure Static Web Apps (frontend)
- Azure PostgreSQL + Redis
- CI/CD GitHub Actions"
```

---

## 🚫 NO HACER

- ❌ **NO hacer commit** con UTF-8 corrupto
- ❌ **NO hacer commit** con `[id].js` (nombre inválido)
- ❌ **NO hacer push** sin revisar `git diff`
- ❌ **NO hacer commit** si tests fallan
- ❌ **NO hacer commit** de `node_modules/` (ya en .gitignore)
- ❌ **NO hacer commit** de `.env` (secrets)
- ❌ **NO hacer commit** de `logs/` (ya en .gitignore)

---

## 📊 MÉTRICAS PRE-COMMIT

```
Líneas código:     38,519
Archivos:          177
Backend:           78 .js
Frontend:          99 .tsx/.ts/.jsx
Vulnerabilidades:  0
Tests passing:     ⚠️ (verificar)
Linting:           ⚠️ (verificar)
Build size:        871 kB (frontend)
```

---

## ✅ APROBACIÓN FINAL

Marcar cuando TODO lo anterior esté ✅:

- [ ] **UTF-8 fix verificado** (0 caracteres corruptos)
- [ ] **Archivo renombrado** (`_id.js` existe)
- [ ] **Tests passing** (backend + frontend)
- [ ] **Linting clean** (0 errores)
- [ ] **Build exitoso** (frontend/dist/)
- [ ] **Git diff revisado** (sin sorpresas)
- [ ] **README actualizado** (si aplica)

**Aprobado por**: _______________  
**Fecha**: _______________  
**Hora**: _______________

---

**Siguiente paso**: `git push origin main` (después de commit aprobado)

