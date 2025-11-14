# 🚀 ECONEURA - START LOCAL (Antes de Azure)

**ORDEN CORRECTO**: Local → Validar → Azure → Deploy

---

## 📍 PUERTOS LOCALES

| Servicio | Puerto | URL |
|----------|--------|-----|
| **Backend** | 3001 | http://localhost:3001/api/health |
| **Frontend** | 5173 | http://localhost:5173 |
| **PostgreSQL** | 5432 | localhost:5432 |
| **Redis** | 6379 | localhost:6379 |

---

## ⚡ START RÁPIDO (3 comandos)

### Terminal 1: Backend
```powershell
cd C:\Users\Usuario\ECONEURA-OK\backend
npm start
```

### Terminal 2: Frontend
```powershell
cd C:\Users\Usuario\ECONEURA-OK\frontend
npm run dev
```

### Terminal 3: Abrir navegador
```powershell
start http://localhost:5173
```

---

## 🎯 QUÉ VERÁS

1. **Login ECONEURA** (diseño oficial)
   - Logo con árbol dorado
   - Botones OAuth (Microsoft + GitHub)
   - Animaciones premium

2. **Cockpit** (después de login)
   - 10 NEURA cards
   - 40 Make agents
   - Sidebar izquierda
   - Chat flotante
   - Dark/Light mode
   - Partículas flotantes

---

## ✅ CHECKLIST VISUAL

- [ ] Logo ECONEURA visible
- [ ] Botones OAuth funcionan
- [ ] Diseño responsive
- [ ] Animaciones smooth
- [ ] Sin errores en consola
- [ ] Health check: http://localhost:3001/api/health

---

**Cuando todo funcione local → Procedemos a Azure**


