# 🌳 ECONEURA - Enterprise AI Ecosystem

**Plataforma SaaS de Inteligencia Colectiva Empresarial**

[![CI](https://github.com/ECONEURA-MAX/ECONEURA-/actions/workflows/ci.yml/badge.svg)](https://github.com/ECONEURA-MAX/ECONEURA-/actions/workflows/ci.yml)
[![License: Proprietary](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)
[![Node](https://img.shields.io/badge/node-20.x-brightgreen.svg)](https://nodejs.org)
[![Azure](https://img.shields.io/badge/Azure-Ready-blue.svg)](https://azure.microsoft.com)

---

## 🎯 Overview

ECONEURA is an **enterprise-grade AI ecosystem** that provides intelligent automation and decision support across all business departments through specialized AI agents.

### Core Features

- 🧠 **11 Specialized NEURA Agents** - AI agents for each C-level role + Innovation
- 🤖 **55+ Automated Connections** - Integrations with N8N, Make.com, and ChatGPT
- 🔄 **Human-in-the-Loop (HITL)** - Critical approvals before execution
- 📚 **RAG Library** - Semantic document search and retrieval
- 💬 **Advanced Chat Interface** - GPT-4/5 powered conversations
- 📊 **Real-time Analytics** - Dashboards with KPIs and metrics
- 🔐 **Enterprise Security** - OAuth 2.0, JWT, rate limiting, audit logs

---

## 🧠 The 11 NEURA

Each NEURA is a specialized AI agent managing 4-5 automated processes:

| NEURA | Department | Focus Areas |
|-------|------------|-------------|
| 👑 **NEURA-CEO** | Executive | Strategic planning, OKRs, board reporting |
| 🤖 **NEURA-IA** | AI Platform | Model management, cost tracking, prompt engineering |
| 🛡️ **NEURA-CSO** | Strategy | Risk management, competitive intelligence, M&A |
| 💻 **NEURA-CTO** | Technology | Infrastructure, CI/CD, observability, incidents |
| 🔒 **NEURA-CISO** | Security | Vulnerability management, compliance, phishing detection |
| ⚙️ **NEURA-COO** | Operations | Process optimization, SLA monitoring, vendor management |
| 👥 **NEURA-CHRO** | HR | Talent management, onboarding, engagement analytics |
| 📢 **NEURA-CMO** | Marketing | Pipeline analysis, lead scoring, campaign optimization |
| 💰 **NEURA-CFO** | Finance | Treasury, variance analysis, cash flow forecasting |
| 📊 **NEURA-CDO** | Data | Data quality, governance, catalog management |
| 💡 **NEURA-CINO** | Innovation | Patent research, startup scouting, prototyping |

**Total**: 11 NEURA + 55 automated agent connections | Scalable to 200+ agents

---

## 🏗️ Architecture

### Technology Stack

| Layer | Technologies |
|-------|-------------|
| **Backend** | Node.js 20.x, Express.js, PostgreSQL 16, Redis 7 |
| **Frontend** | React 18, TypeScript 5, Vite 7, Tailwind CSS 3 |
| **AI/ML** | OpenAI GPT-4/5, N8N, Make.com, Custom Agents |
| **Auth** | JWT, OAuth 2.0 (Microsoft, Google, GitHub) |
| **Cloud** | Azure App Service, Static Web Apps, PostgreSQL Flexible |
| **Monitoring** | Application Insights, Winston logging |
| **Security** | Helmet, Rate Limiting, CORS, Input Validation |

### Monorepo Structure

```
ECONEURA/
├── backend/          # Node.js + Express API
│   ├── routes/       # API endpoints
│   ├── services/     # Business logic
│   ├── middleware/   # Auth, rate limiting
│   └── tests/        # 54/54 tests passing
│
├── frontend/         # React + TypeScript
│   ├── components/   # UI components
│   ├── hooks/        # Custom hooks
│   └── services/     # API clients
│
└── infrastructure/   # Azure deployment scripts
```

---

## 🚀 Quick Start

### Prerequisites

- Node.js 20.x or higher
- npm 10.x or higher
- PostgreSQL 16 (or use Mock DB for development)
- Redis 7 (optional for development)

### Local Development

```bash
# Backend
cd backend
npm install
cp .env.example .env
# Edit .env with your configuration
npm run dev

# Frontend (new terminal)
cd frontend
npm install
cp .env.example .env
# Edit .env with your API URL
npm run dev
```

Access the application:
- Backend API: http://localhost:8080
- Frontend: http://localhost:5173

### Running Tests

```bash
# Backend tests
cd backend
npm test

# Frontend tests
cd frontend
npm test
```

---

## 📊 Integrations

### Automation Platforms

- **N8N**: Self-hosted workflow automation
- **Make.com**: No-code integration scenarios
- **ChatGPT/GPT-4**: OpenAI API for natural language processing
- **Custom Webhooks**: REST API for custom integrations

### Authentication Providers

- Microsoft Azure AD (OAuth 2.0)
- Google Workspace
- GitHub

---

## 🔐 Security

- ✅ JWT Authentication (15min access + 7day refresh tokens)
- ✅ OAuth 2.0 social login
- ✅ Rate limiting (3 levels: Global, Auth, AI Gateway)
- ✅ Helmet security headers
- ✅ CORS configuration per environment
- ✅ Input validation with Joi schemas
- ✅ Bcrypt password hashing (12 rounds)
- ✅ Azure Key Vault for secrets management
- ✅ Audit logs for critical actions

---

## 📈 Performance

- Backend tests: 54/54 passing (100%)
- npm audit: 0 vulnerabilities
- Build time: ~17s (frontend)
- Bundle size: 787 KB gzipped
- Code quality: 9.5/10

---

## 🤝 Contributing

This is a proprietary project. For collaboration inquiries, please contact the ECONEURA team.

See [CONTRIBUTING.md](CONTRIBUTING.md) for technical guidelines.

---

## 📝 License

**Proprietary** - © 2025 ECONEURA. All rights reserved.

---

## 🆘 Support

- 📧 Email: soporte@econeura.com
- 💬 GitHub Issues: For bug reports and feature requests

---

## 🎯 Roadmap

### 2025 Q1-Q2
- ✅ 11 NEURA implemented
- ✅ 55 agent connections
- 🔄 Azure deployment
- 🔄 Scale to 100 agents

### 2025 Q3-Q4
- 🔜 Mobile app (React Native)
- 🔜 Advanced AI features
- 🔜 Scale to 200+ agents
- 🔜 Enterprise SSO/SAML

---

<div align="center">

**Built with ❤️ and 🤖 by the ECONEURA team**

</div>
