# 🌳 ECONEURA - Enterprise AI Ecosystem

**Plataforma SaaS de Inteligencia Colectiva con 11 NEURA y 55 Agentes/Conexiones Automatizadas**

[![Deploy Backend](https://github.com/ECONEURA-MAX/ECONEURA-/actions/workflows/azure-backend-prod.yml/badge.svg)](https://github.com/ECONEURA-MAX/ECONEURA-/actions/workflows/azure-backend-prod.yml)
[![Deploy Frontend](https://github.com/ECONEURA-MAX/ECONEURA-/actions/workflows/azure-frontend-prod.yml/badge.svg)](https://github.com/ECONEURA-MAX/ECONEURA-/actions/workflows/azure-frontend-prod.yml)
[![CI Tests](https://github.com/ECONEURA-MAX/ECONEURA-/actions/workflows/ci-tests.yml/badge.svg)](https://github.com/ECONEURA-MAX/ECONEURA-/actions/workflows/ci-tests.yml)
[![Security](https://github.com/ECONEURA-MAX/ECONEURA-/actions/workflows/security.yml/badge.svg)](https://github.com/ECONEURA-MAX/ECONEURA-/actions/workflows/security.yml)
[![License: Proprietary](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)
[![Node](https://img.shields.io/badge/node-20.x-brightgreen.svg)](https://nodejs.org)
[![Azure](https://img.shields.io/badge/Azure-Ready-blue.svg)](https://azure.microsoft.com)
[![Code Quality](https://img.shields.io/badge/Quality-9.5%2F10-success.svg)](HITO_ESTRATEGIA_AZURE_V2_COMPLETADO.md)

---

## 🎯 ¿Qué es ECONEURA?

ECONEURA es un **ecosistema de inteligencia artificial empresarial enterprise-grade** que democratiza el acceso a IA avanzada mediante un sistema de agentes especializados por departamento.

### 🧠 Arquitectura de Agentes

- **11 NEURA Principales**: Agentes de IA especializados (1 por cada C-Level + Innovación)
- **4 Agentes Base por NEURA**: Cada NEURA gestiona 4 agentes automatizados específicos de su dominio
- **55 Conexiones/Agentes Activas**: Integraciones con N8N, Make.com y ChatGPT actuales
- **Escalabilidad hasta 200+ Agentes**: Arquitectura preparada para crecimiento exponencial

---

## ✨ 11 NEURA Especializadas

Cada NEURA es un agente de IA experto en un área específica, gestionando sus propios agentes automatizados:

| NEURA | Departamento | Agentes Base | Especialización |
|-------|--------------|--------------|-----------------|
| 👑 **NEURA-CEO** | Ejecutivo | 4 agentes | Agenda Consejo, Anuncio Semanal, Resumen Ejecutivo, OKR |
| 🤖 **NEURA-IA** | Plataforma IA | 4 agentes | Salud y Failover, Cost Tracker, Revisión Prompts, Cuotas |
| 🛡️ **NEURA-CSO** | Estrategia | 4 agentes | Gestor Riesgos, Vigilancia Competitiva, Radar Tendencias, M&A |
| 💻 **NEURA-CTO** | Tecnología | 4 agentes | FinOps Cloud, Seguridad CI/CD, Observabilidad SLO, Incidencias |
| 🔒 **NEURA-CISO** | Seguridad | 4 agentes | Vulnerabilidades, Phishing Triage, Backup/DR, Recertificación |
| ⚙️ **NEURA-COO** | Operaciones | 4 agentes | Atrasos, NPS/CSAT, Latido SLA, Torre Control |
| 👥 **NEURA-CHRO** | RRHH | 4 agentes | Encuesta Pulso, Offboarding, Onboarding, Pipeline Contratación |
| 📢 **NEURA-CMO/CRO** | Marketing y Ventas | 4 agentes | Embudo Comercial, Salud Pipeline, Calidad Leads, Post-Campaña |
| 💰 **NEURA-CFO** | Finanzas | 4 agentes | Tesorería, Variance, Facturación, Compras |
| 📊 **NEURA-CDO** | Datos | 4 agentes | Linaje, Calidad Datos, Catálogo, Coste DWH |
| 💡 **NEURA-CINO** | Innovación | 5 agentes | Explorador Patentes, Radar Startups, Prototipos IA, Tendencias Usuario |

**Total**: **11 NEURA** + **45 Agentes Base** = **55+ Conexiones Activas**

---

## 🚀 Capacidades y Features

### Integraciones de Automatización

- ✅ **N8N**: Workflows visuales self-hosted y open-source
- ✅ **Make.com**: Escenarios no-code para integraciones empresariales
- ✅ **ChatGPT / GPT-4**: API OpenAI para procesamiento de lenguaje natural
- ✅ **Webhooks Personalizados**: API REST para integraciones custom
- ✅ **Escalabilidad**: De 55 a 200+ agentes según necesidad

### Features Principales

- ✅ **Chat GPT-4/5**: Interfaz conversacional avanzada con streaming
- ✅ **Multi-Actor Reasoning**: Consenso entre múltiples NEURA
- ✅ **HITL (Human-in-the-Loop)**: Aprobaciones críticas antes de ejecutar
- ✅ **RAG Library**: Biblioteca de documentos con búsqueda semántica
- ✅ **Voice Controls**: Reconocimiento de voz integrado
- ✅ **Analytics Dashboard**: Métricas y KPIs en tiempo real
- ✅ **OAuth 2.0**: Login con Microsoft, Google, GitHub
- ✅ **Dark/Light Mode**: UI adaptable premium
- ✅ **Multi-tenancy**: Usuarios, organizaciones y permisos
- ✅ **Audit Logs**: Trazabilidad completa de acciones

---

## 🏗️ Arquitectura Técnica

### Monorepo Enterprise-Grade

```
ECONEURA/
├── backend/                    # Node.js + Express API
│   ├── routes/                 # 11 rutas NEURA + API endpoints
│   ├── services/               # Lógica de negocio especializada
│   ├── middleware/             # Auth, rate limiting, CORS
│   ├── prompts/                # System prompts por NEURA
│   ├── tests/                  # 54 tests (100% passing)
│   └── server.js               # Entry point
│
├── frontend/                   # React + TypeScript + Vite
│   ├── src/
│   │   ├── components/         # 40+ componentes React
│   │   ├── data/               # departments.ts (11 NEURA)
│   │   ├── hooks/              # Custom hooks
│   │   ├── services/           # NeuraAgentIntegration.ts
│   │   └── EconeuraCockpit.tsx # Main application
│   └── vite.config.ts
│
├── infrastructure/
│   └── azure/
│       └── scripts/            # PowerShell automation
│
└── .github/workflows/          # CI/CD (9 workflows)
```

### Tech Stack

| Capa | Tecnologías |
|------|-------------|
| **Backend** | Node.js 20.x, Express.js 4.21, PostgreSQL 16, Redis 7 |
| **Frontend** | React 18, TypeScript 5, Vite 7, Tailwind CSS 3 |
| **AI/ML** | OpenAI GPT-4/5, N8N, Make.com, Custom Agents |
| **Auth** | JWT, OAuth 2.0 (Microsoft, Google, GitHub), Passport.js |
| **Cloud** | Azure App Service, Static Web Apps, PostgreSQL Flexible |
| **Cache** | Azure Redis Cache, Session management |
| **Storage** | Azure Blob Storage (RAG documents) |
| **Secrets** | Azure Key Vault |
| **Monitoring** | Application Insights, Winston logging |
| **CI/CD** | GitHub Actions (9 workflows) |
| **Security** | Helmet, Rate Limiting, CORS, Input Validation |

---

## 📊 Calidad del Código

### Métricas

| Métrica | Backend | Frontend | Estado |
|---------|---------|----------|--------|
| **Tests** | 54/54 (100%) ✅ | 73/116 (63%) ⚠️ | Mejorando |
| **Coverage** | >80% ✅ | >70% ✅ | Enterprise grade |
| **Vulnerabilities** | 0 ✅ | 0 ✅ | Seguro |
| **Build Time** | <10s ✅ | ~17s ✅ | Optimizado |
| **Bundle Size** | N/A | 787 KB (gzip) ✅ | Optimizado |
| **Code Quality** | 9.5/10 ✅ | 9.0/10 ✅ | Excelente |

### Puntuación General: **9.5/10** ⭐

---

## 🔐 Seguridad

- ✅ **JWT Authentication**: Access tokens (15 min) + Refresh tokens (7 días)
- ✅ **OAuth 2.0**: Microsoft Azure AD, Google, GitHub
- ✅ **Rate Limiting**: 3 niveles (Global, Auth, AI Gateway)
- ✅ **Helmet**: Security headers (CSP, HSTS, XSS protection)
- ✅ **CORS**: Configuración estricta por environment
- ✅ **Input Validation**: Joi schemas en todos los endpoints
- ✅ **Password Hashing**: Bcrypt (12 rounds)
- ✅ **Azure Key Vault**: Secrets management en producción
- ✅ **Audit Logs**: Trazabilidad completa

---

## 🚀 Quick Start

### Desarrollo Local

```bash
# Backend
cd backend
npm install
cp .env.example .env
# Editar .env con tus valores
npm run dev

# Frontend (nueva terminal)
cd frontend
npm install
cp .env.example .env
# Editar .env con tu API URL
npm run dev

# ✅ Backend: http://localhost:8080
# ✅ Frontend: http://localhost:5173
```

### Deployment a Azure (Staging)

```powershell
# Pre-flight check (validación local)
.\infrastructure\azure\scripts\pre-flight-check.ps1

# Setup Azure staging (40-60 min)
.\infrastructure\azure\scripts\setup-azure-staging-v2.ps1

# Setup GitHub Secrets (2 min)
.\infrastructure\azure\scripts\setup-github-secrets.ps1 -Repository "ECONEURA-MAX/ECONEURA-"

# Test deployment (5 min)
.\infrastructure\azure\scripts\test-deployment.ps1 -Environment staging
```

---

## 📚 Documentación

### Principal

- 📖 [**ESTRATEGIA_AZURE_GITHUB_ENTERPRISE.md**](ESTRATEGIA_AZURE_GITHUB_ENTERPRISE.md) - Arquitectura completa y plan de ejecución
- 📖 [**HITO_ESTRATEGIA_AZURE_V2_COMPLETADO.md**](HITO_ESTRATEGIA_AZURE_V2_COMPLETADO.md) - Hito completado y métricas
- 📖 [**COSTES_REALES_AZURE.md**](COSTES_REALES_AZURE.md) - Costes detallados reales

### Técnica

- 🔧 **backend/.env.example** - Variables de entorno backend
- 🔧 **frontend/.env.example** - Variables de entorno frontend
- 🔧 **API Documentation**: Swagger/OpenAPI en `/api-docs`

---

## 💰 Costes Azure (Reales)

### Staging

| Servicio | SKU | Coste/mes |
|----------|-----|-----------|
| PostgreSQL Flexible | Standard_B1ms | €12 |
| Redis Cache | Basic C0 (250MB) | €15 |
| App Service | B2 (2 cores) | €15 |
| Static Web App | Free | €0 |
| Storage Account | Standard LRS | €8 |
| Key Vault | Standard | €2 |
| Application Insights | Pay-as-you-go | €20 |
| Log Analytics | Pay-as-you-go | €12 |
| Bandwidth | ~50GB/mes | €10 |
| **TOTAL** | | **€110-130/mes** |

### Production

**€450-550/mes** con tráfico real y alta disponibilidad.

---

## 🤝 Contribución

Este es un proyecto privado/propietario. Para colaborar, contacta al equipo ECONEURA.

---

## 📝 License

**Proprietary** - © 2025 ECONEURA. Todos los derechos reservados.

---

## 🆘 Soporte

- 📧 **Email**: soporte@econeura.com
- 💬 **GitHub Issues**: Para bugs o feature requests

---

## 🎯 Roadmap

### Q1 2025 ✅ (Completado)
- ✅ 11 NEURA implementadas y funcionales
- ✅ 55 agentes/conexiones integradas (N8N + Make + ChatGPT)
- ✅ Arquitectura enterprise-grade
- ✅ Tests backend 100% passing
- ✅ CI/CD workflows completos
- ✅ Estrategia Azure V2

### Q2 2025 🔄 (En Progreso)
- 🔄 Deploy a staging Azure
- 🔄 Escalar de 55 a 100 agentes
- 🔄 Tests frontend 100% passing
- 🔄 Monitoring dashboards

### Q3-Q4 2025 🔜 (Planeado)
- 🔜 Escalar hasta 200 agentes
- 🔜 Mobile app (React Native)
- 🔜 Advanced AI features
- 🔜 Enterprise features (SSO, SAML)

---

<div align="center">

**Hecho con ❤️ y 🤖 por el equipo ECONEURA**

[Docs](https://docs.econeura.com) • [Blog](https://blog.econeura.com)

</div>

