# 🔧 PLAN DE REFACTORING - EconeuraCockpit.tsx

## 📊 ESTADO ACTUAL
- **Archivo**: `frontend/src/EconeuraCockpit.tsx`
- **Líneas**: 2,738 líneas
- **Problema**: Componente monolítico, difícil de testear
- **Objetivo**: Dividir en 10-15 componentes pequeños y testeables

---

## 🎯 COMPONENTES A EXTRAER

### 1. **EconeuraChatPanel.tsx** (500-600 líneas)
```typescript
// Chat principal + mensajes + input
- Estado: messages, loading, streaming
- Funciones: sendMessage, handleStream
- UI: MessageList, ChatInput, StreamingIndicator
```

### 2. **EconeuraSidebar.tsx** (400-500 líneas)
```typescript
// Sidebar con NEURAs
- DepartmentList
- DepartmentButton (ya existe)
- Sidebar toggle
```

### 3. **EconeuraHeader.tsx** (200-300 líneas)
```typescript
// Header con controles
- Logo
- User menu
- Settings
- Dark mode toggle
```

### 4. **EconeuraAgentPanel.tsx** (300-400 líneas)
```typescript
// Panel de ejecución de agentes
- AgentList
- AgentExecutionCard (ya existe)
- Agent triggers
```

### 5. **EconeuraLibraryPanel.tsx** (ya existe)
```typescript
// Panel biblioteca RAG
- Document upload
- Document search
- Ya está en componente separado ✅
```

### 6. **EconeuraProposalPanel.tsx** (200-300 líneas)
```typescript
// Panel HITL proposals
- Proposal list
- Approval/Reject actions
```

### 7. **EconeuraActivityPanel.tsx** (150-200 líneas)
```typescript
// Panel de actividad NEURA
- Activity log
- Real-time updates
```

### 8. **EconeuraAnalyticsPanel.tsx** (ya existe)
```typescript
// Dashboard analytics
- Ya está en componente separado ✅
```

### 9. **hooks/useCockpitState.ts** (300-400 líneas)
```typescript
// Custom hook para estado global del cockpit
- Estado centralizado
- Funciones de negocio
- Lógica extraída del componente
```

### 10. **hooks/useChatOperations.ts** (200-300 líneas)
```typescript
// Custom hook para operaciones de chat
- sendMessage
- handleStream
- API calls
```

---

## 📂 NUEVA ESTRUCTURA

```
frontend/src/
├── EconeuraCockpit.tsx (300-400 líneas) ← ORQUESTADOR
├── components/
│   ├── cockpit/
│   │   ├── EconeuraChatPanel.tsx
│   │   ├── EconeuraSidebar.tsx
│   │   ├── EconeuraHeader.tsx
│   │   ├── EconeuraAgentPanel.tsx
│   │   ├── EconeuraProposalPanel.tsx
│   │   ├── EconeuraActivityPanel.tsx
│   │   └── __tests__/
│   │       ├── ChatPanel.test.tsx
│   │       ├── Sidebar.test.tsx
│   │       └── Header.test.tsx
│   ├── EconeuraHeader.tsx (ya existe)
│   ├── EconeuraSidebar.tsx (ya existe)
│   └── ...
├── hooks/
│   ├── useCockpitState.ts
│   ├── useChatOperations.ts
│   └── useNeuraExecution.ts
└── types/
    └── cockpit.ts (tipos compartidos)
```

---

## 🔄 PROCESO DE REFACTORING (PASO A PASO)

### PASO 1: Crear tipos compartidos (10 min)
```typescript
// types/cockpit.ts
export interface CockpitState {
  darkMode: boolean;
  sidebarOpen: boolean;
  activePanel: string;
  activeDept: number;
  // ... más tipos
}
```

### PASO 2: Extraer custom hooks (1h)
1. `useCockpitState.ts` - Estado global
2. `useChatOperations.ts` - Operaciones chat
3. `useNeuraExecution.ts` - Ejecución NEURAs

### PASO 3: Extraer componentes UI (2h)
1. EconeuraHeader.tsx
2. EconeuraSidebar.tsx
3. EconeuraChatPanel.tsx
4. EconeuraAgentPanel.tsx
5. EconeuraProposalPanel.tsx
6. EconeuraActivityPanel.tsx

### PASO 4: Refactorizar Cockpit principal (30 min)
- Importar componentes
- Orquestar estado
- Layout y composición

### PASO 5: Tests unitarios (1h)
- Test cada componente pequeño
- Mocks más fáciles
- Coverage >90%

---

## ✅ CHECKLIST DE VERIFICACIÓN

### Antes de empezar:
- [ ] Backup de EconeuraCockpit.tsx actual
- [ ] Git commit del estado actual
- [ ] Crear branch `refactor/cockpit-components`

### Durante refactoring:
- [ ] Cada componente compila sin errores
- [ ] Funcionalidad se mantiene igual
- [ ] Tests pasan después de cada extracción
- [ ] No hay console errors en browser

### Al finalizar:
- [ ] Cockpit principal <400 líneas
- [ ] Todos los componentes <500 líneas
- [ ] Tests 100% passing
- [ ] Build frontend exitoso
- [ ] Aplicación funciona igual que antes
- [ ] Dark mode funciona
- [ ] Chat funciona
- [ ] NEURAs funcionan
- [ ] Agentes funcionan

---

## 🎯 RESULTADO ESPERADO

```
Antes:
- EconeuraCockpit.tsx: 2,738 líneas
- Difícil de testear
- Difícil de mantener

Después:
- EconeuraCockpit.tsx: 300-400 líneas (orquestador)
- 8-10 componentes: 200-500 líneas cada uno
- 3-4 custom hooks: 200-400 líneas cada uno
- Tests unitarios para cada componente
- Fácil de mantener y extender
```

---

## ⏱️ TIEMPO ESTIMADO

- **Preparación**: 10 min
- **Tipos compartidos**: 10 min
- **Custom hooks**: 1 hora
- **Componentes UI**: 2 horas
- **Refactor Cockpit**: 30 min
- **Tests**: 1 hora
- **Validación**: 30 min

**TOTAL**: 4-5 horas

---

## 🚀 EMPEZAMOS AHORA

¿Listo para empezar?

Voy a:
1. ✅ Crear backup
2. ✅ Crear branch git
3. ✅ Extraer tipos compartidos
4. ✅ Crear primer custom hook
5. ✅ Extraer primer componente
6. ... continuar paso a paso

**¿Empezamos? Responde "SÍ" y arranco sin parar hasta terminar.**

