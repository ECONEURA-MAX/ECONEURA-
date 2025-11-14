# ECONEURA API Documentation v3.1

## 🎯 Overview

ECONEURA provides a RESTful API for managing AI-powered business intelligence through 10 specialized executive NEURAs and integration with automation platforms (Make.com, n8n, Zapier).

**Base URL (Production):** `https://econeura-backend-prod.azurewebsites.net/api`  
**Base URL (Staging):** `https://econeura-backend-staging.azurewebsites.net/api`  
**Base URL (Local):** `http://localhost:8080/api`

**Authentication:** Bearer JWT Token (via `Authorization: Bearer <token>` header)

**Rate Limiting:** 100 requests per 15 minutes per IP

---

## 📚 Table of Contents

1. [Authentication](#authentication)
2. [NEURAs (AI Agents)](#neuras-ai-agents)
3. [Chat & Conversations](#chat--conversations)
4. [Agents Management](#agents-management)
5. [Proposals (HITL)](#proposals-hitl)
6. [Library (RAG)](#library-rag)
7. [FinOps & Analytics](#finops--analytics)
8. [Health & Status](#health--status)
9. [Error Codes](#error-codes)
10. [Webhooks](#webhooks)

---

## 🔐 Authentication

### POST /auth/login

Login with email and password.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}
```

**Response (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "usr_abc123",
    "email": "user@example.com",
    "name": "John Doe",
    "role": "user",
    "created_at": "2025-01-01T00:00:00.000Z"
  }
}
```

**Errors:**
- `400 Bad Request` - Missing fields
- `401 Unauthorized` - Invalid credentials
- `429 Too Many Requests` - Rate limit exceeded

---

### POST /auth/register

Register a new user account.

**Request:**
```json
{
  "email": "newuser@example.com",
  "password": "SecurePassword123!",
  "name": "Jane Smith"
}
```

**Response (201):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "usr_xyz789",
    "email": "newuser@example.com",
    "name": "Jane Smith",
    "role": "user",
    "created_at": "2025-01-15T12:00:00.000Z"
  }
}
```

**Errors:**
- `400 Bad Request` - Missing fields or weak password
- `409 Conflict` - Email already registered

---

### GET /auth/oauth/:provider

OAuth login with Google/Microsoft.

**Supported providers:** `google`, `microsoft`

**Flow:**
1. Redirect user to: `GET /api/auth/oauth/google`
2. User authenticates with provider
3. Callback to: `GET /api/auth/oauth/google/callback`
4. Redirect to frontend with token: `https://econeura.com/?token=<jwt>`

---

## 🧠 NEURAs (AI Agents)

ECONEURA provides 10 specialized executive NEURAs:

| NEURA ID | Name | Model | Use Case |
|----------|------|-------|----------|
| `a-ceo-01` | NEURA CEO | Claude Sonnet 4.5 | Strategic vision, company-wide decisions |
| `a-ia-01` | NEURA CTO IA | GPT-5 | AI development, technical strategy |
| `a-cfo-01` | NEURA CFO | Claude Opus 4 | Financial analysis, budget optimization |
| `a-legal-01` | NEURA CDO Legal | Mistral Large | GDPR compliance, legal review |
| `a-hr-01` | NEURA CHRO | GPT-5 Mini | HR policies, talent management |
| `a-retail-01` | NEURA COO Retail | GPT-5 Nano | Retail operations, supply chain |
| `a-supply-01` | NEURA CSO | Gemini 2.5 Flash | Supply chain optimization |
| `a-mkt-01` | NEURA CMO | Claude Sonnet 4.5 | Marketing campaigns, brand strategy |
| `a-sec-01` | NEURA CISO | Claude Sonnet 4.5 | Cybersecurity, risk assessment |
| `a-ma-01` | NEURA CTO M&A | Claude Opus 4 | M&A due diligence, valuations |

### POST /invoke/:neuraId

Invoke a NEURA with a question.

**Headers:**
- `Authorization: Bearer <token>`

**Request:**
```json
{
  "question": "¿Cuál es la estrategia óptima para Q1 2026?",
  "context": {
    "companySize": "500-1000",
    "industry": "retail",
    "budget": 200000
  },
  "stream": false
}
```

**Response (200):**
```json
{
  "id": "msg_abc123",
  "neuraId": "a-ceo-01",
  "question": "¿Cuál es la estrategia óptima para Q1 2026?",
  "answer": "Basándome en tu contexto (retail, 500-1000 empleados, presupuesto €200K), recomiendo...",
  "model": "claude-sonnet-4.5",
  "usage": {
    "prompt_tokens": 350,
    "completion_tokens": 1200,
    "total_tokens": 1550
  },
  "reasoning": {
    "steps": [
      {
        "actor": "NEURA CEO",
        "thought": "Analizando contexto de empresa retail...",
        "decision": "Priorizar omnicanalidad"
      }
    ]
  },
  "agentsSuggested": [
    {
      "id": "make_inventory_optimizer",
      "confidence": 0.92,
      "reason": "Optimizar stock en Q1"
    }
  ],
  "timestamp": "2025-01-15T14:30:00.000Z"
}
```

**Errors:**
- `401 Unauthorized` - Missing or invalid token
- `404 Not Found` - Invalid NEURA ID
- `429 Too Many Requests` - Rate limit exceeded
- `500 Internal Server Error` - AI service unavailable

---

### POST /ai-gateway

Main chat endpoint with multi-actor reasoning.

**Request:**
```json
{
  "message": "¿Cómo reduzco costos operativos en 15%?",
  "neuraId": "a-cfo-01",
  "chatId": "chat_xyz123",
  "multiActor": true,
  "useLibrary": true
}
```

**Response (200):**
```json
{
  "response": "Analizando tus datos financieros...",
  "chatId": "chat_xyz123",
  "messageId": "msg_789",
  "reasoning": {
    "multiActor": [
      {
        "actor": "NEURA CFO",
        "analysis": "Costos operativos actuales: €1.2M/año..."
      },
      {
        "actor": "NEURA COO Retail",
        "analysis": "Optimizaciones logísticas pueden ahorrar 8%..."
      },
      {
        "actor": "NEURA CEO",
        "synthesis": "Plan integrado: 15% reducción factible..."
      }
    ]
  },
  "references": [
    {
      "documentId": "doc_456",
      "title": "Informe Financiero Q4 2025",
      "excerpt": "Gastos operativos: €1.2M...",
      "relevance": 0.94
    }
  ],
  "usage": {
    "total_tokens": 2340
  }
}
```

---

## 💬 Chat & Conversations

### GET /chats

Get user's chat history.

**Headers:**
- `Authorization: Bearer <token>`

**Query Parameters:**
- `limit` (optional, default: 20) - Number of chats to return
- `offset` (optional, default: 0) - Pagination offset
- `neuraId` (optional) - Filter by NEURA
- `search` (optional) - Search in chat titles

**Response (200):**
```json
{
  "chats": [
    {
      "id": "chat_abc123",
      "title": "Estrategia Q1 2026",
      "neuraId": "a-ceo-01",
      "messageCount": 15,
      "lastMessage": "Perfecto, procederé con el plan.",
      "created_at": "2025-01-10T09:00:00.000Z",
      "updated_at": "2025-01-15T14:30:00.000Z"
    }
  ],
  "total": 47,
  "limit": 20,
  "offset": 0
}
```

---

### GET /chats/:chatId

Get specific chat with full message history.

**Response (200):**
```json
{
  "id": "chat_abc123",
  "title": "Estrategia Q1 2026",
  "neuraId": "a-ceo-01",
  "messages": [
    {
      "id": "msg_001",
      "role": "user",
      "content": "¿Cuál es la estrategia óptima?",
      "timestamp": "2025-01-10T09:00:00.000Z"
    },
    {
      "id": "msg_002",
      "role": "assistant",
      "content": "Basándome en tu contexto...",
      "model": "claude-sonnet-4.5",
      "usage": { "total_tokens": 1550 },
      "timestamp": "2025-01-10T09:00:15.000Z"
    }
  ],
  "created_at": "2025-01-10T09:00:00.000Z",
  "updated_at": "2025-01-15T14:30:00.000Z"
}
```

---

### DELETE /chats/:chatId

Delete a chat and all its messages.

**Response (200):**
```json
{
  "success": true,
  "message": "Chat deleted successfully"
}
```

---

## 🤖 Agents Management

### GET /agents

Get user's connected agents (Make/n8n/Zapier).

**Headers:**
- `Authorization: Bearer <token>`

**Response (200):**
```json
{
  "agents": [
    {
      "id": "agent_make_001",
      "name": "Inventory Optimizer",
      "provider": "make",
      "webhookUrl": "https://hook.us2.make.com/xyz123",
      "status": "active",
      "executions": 47,
      "lastExecution": "2025-01-15T12:00:00.000Z",
      "created_at": "2024-12-01T00:00:00.000Z"
    },
    {
      "id": "agent_n8n_002",
      "name": "Email Automator",
      "provider": "n8n",
      "webhookUrl": "https://n8n.econeura.com/webhook/abc456",
      "status": "active",
      "executions": 152,
      "lastExecution": "2025-01-15T14:00:00.000Z",
      "created_at": "2024-11-15T00:00:00.000Z"
    }
  ],
  "total": 23
}
```

---

### POST /agents

Connect a new agent.

**Request:**
```json
{
  "name": "New Automation",
  "provider": "make",
  "webhookUrl": "https://hook.us2.make.com/new123",
  "description": "Automates customer onboarding"
}
```

**Response (201):**
```json
{
  "id": "agent_make_024",
  "name": "New Automation",
  "provider": "make",
  "webhookUrl": "https://hook.us2.make.com/new123",
  "status": "active",
  "created_at": "2025-01-15T15:00:00.000Z"
}
```

**Errors:**
- `400 Bad Request` - Invalid webhook URL
- `409 Conflict` - Agent already connected

---

### DELETE /agents/:agentId

Disconnect an agent.

**Response (200):**
```json
{
  "success": true,
  "message": "Agent disconnected successfully"
}
```

---

### POST /agents/:agentId/execute

Manually execute an agent.

**Request:**
```json
{
  "data": {
    "customerId": "cust_123",
    "action": "optimize_inventory"
  }
}
```

**Response (200):**
```json
{
  "executionId": "exec_abc123",
  "status": "running",
  "startedAt": "2025-01-15T15:10:00.000Z"
}
```

---

## 📋 Proposals (HITL)

Human-in-the-Loop system for critical decisions.

### GET /proposals

Get pending/approved/rejected proposals.

**Query Parameters:**
- `status` (optional) - Filter by status: `pending`, `approved`, `rejected`

**Response (200):**
```json
{
  "proposals": [
    {
      "id": "prop_abc123",
      "title": "Budget Increase for Marketing",
      "description": "NEURA CMO suggests increasing marketing budget by 20% for Q2.",
      "neuraId": "a-mkt-01",
      "status": "pending",
      "impact": "high",
      "estimatedROI": 1.8,
      "data": {
        "currentBudget": 50000,
        "proposedBudget": 60000,
        "expectedRevenue": 108000
      },
      "created_at": "2025-01-15T10:00:00.000Z"
    }
  ],
  "total": 12
}
```

---

### PUT /proposals/:proposalId/approve

Approve a proposal.

**Request:**
```json
{
  "comment": "Approved for Q2 2026"
}
```

**Response (200):**
```json
{
  "id": "prop_abc123",
  "status": "approved",
  "approvedAt": "2025-01-15T15:30:00.000Z",
  "approvedBy": "usr_xyz789",
  "comment": "Approved for Q2 2026"
}
```

---

### PUT /proposals/:proposalId/reject

Reject a proposal.

**Request:**
```json
{
  "reason": "Budget constraints for Q2"
}
```

**Response (200):**
```json
{
  "id": "prop_abc123",
  "status": "rejected",
  "rejectedAt": "2025-01-15T15:35:00.000Z",
  "rejectedBy": "usr_xyz789",
  "reason": "Budget constraints for Q2"
}
```

---

## 📚 Library (RAG)

Document management for Retrieval-Augmented Generation.

### GET /library

Get uploaded documents.

**Response (200):**
```json
{
  "documents": [
    {
      "id": "doc_abc123",
      "filename": "Financial_Report_Q4_2025.pdf",
      "title": "Financial Report Q4 2025",
      "size": 2457600,
      "chunks": 47,
      "uploadedAt": "2025-01-10T00:00:00.000Z",
      "blobUrl": "https://econeurastorage.blob.core.windows.net/library/doc_abc123.pdf"
    }
  ],
  "total": 23
}
```

---

### POST /library/upload

Upload a new document (PDF).

**Request:** `multipart/form-data`
- `file` (required) - PDF file (max 10 MB)
- `title` (optional) - Document title

**Response (201):**
```json
{
  "id": "doc_new456",
  "filename": "Strategy_2026.pdf",
  "title": "Strategy 2026",
  "size": 1234567,
  "chunks": 32,
  "uploadedAt": "2025-01-15T16:00:00.000Z"
}
```

**Errors:**
- `400 Bad Request` - Invalid file format or size exceeded
- `413 Payload Too Large` - File > 10 MB

---

### DELETE /library/:documentId

Delete a document.

**Response (200):**
```json
{
  "success": true,
  "message": "Document deleted successfully"
}
```

---

## 💰 FinOps & Analytics

### GET /finops/roi

Get ROI metrics per automation.

**Response (200):**
```json
{
  "totalAutomations": 47,
  "totalExecutions": 12847,
  "totalCost": 2340.50,
  "totalRevenue": 18500.00,
  "roi": 6.91,
  "byAgent": [
    {
      "agentId": "agent_make_001",
      "name": "Inventory Optimizer",
      "executions": 523,
      "cost": 104.60,
      "revenue": 3200.00,
      "roi": 29.59
    }
  ]
}
```

---

### GET /finops/usage

Get AI usage metrics.

**Response (200):**
```json
{
  "period": "last_30_days",
  "totalTokens": 15847230,
  "totalCost": 236.71,
  "byNeura": [
    {
      "neuraId": "a-ceo-01",
      "name": "NEURA CEO",
      "tokens": 2340500,
      "cost": 35.11
    }
  ]
}
```

---

## 🏥 Health & Status

### GET /health

Health check endpoint (no auth required).

**Response (200):**
```json
{
  "status": "ok",
  "timestamp": "2025-01-15T16:30:00.000Z",
  "uptime": 345678,
  "services": {
    "database": "ok",
    "redis": "ok",
    "openai": "ok",
    "blobStorage": "ok"
  },
  "version": "3.1.0"
}
```

**Response (503) - Service Degraded:**
```json
{
  "status": "degraded",
  "timestamp": "2025-01-15T16:30:00.000Z",
  "services": {
    "database": "ok",
    "redis": "error",
    "openai": "ok",
    "blobStorage": "ok"
  },
  "errors": ["Redis connection timeout"]
}
```

---

## ❌ Error Codes

| Code | Message | Description |
|------|---------|-------------|
| `400` | Bad Request | Invalid request parameters |
| `401` | Unauthorized | Missing or invalid authentication token |
| `403` | Forbidden | Insufficient permissions |
| `404` | Not Found | Resource not found |
| `409` | Conflict | Resource already exists |
| `413` | Payload Too Large | Request body exceeds size limit |
| `429` | Too Many Requests | Rate limit exceeded |
| `500` | Internal Server Error | Server error, retry later |
| `503` | Service Unavailable | Service temporarily unavailable |

**Error Response Format:**
```json
{
  "error": {
    "code": "INVALID_REQUEST",
    "message": "Missing required field: email",
    "details": {
      "field": "email",
      "type": "required"
    }
  },
  "timestamp": "2025-01-15T16:40:00.000Z",
  "requestId": "req_abc123"
}
```

---

## 🔗 Webhooks

ECONEURA can receive webhooks from Make.com, n8n, and Zapier.

### POST /integration/make

Receive webhook from Make.com.

**Request:**
```json
{
  "executionId": "exec_make_123",
  "scenarioId": "scenario_456",
  "status": "success",
  "data": {
    "customerId": "cust_789",
    "orderId": "order_101"
  }
}
```

**Response (200):**
```json
{
  "received": true,
  "executionId": "exec_make_123",
  "timestamp": "2025-01-15T17:00:00.000Z"
}
```

---

### POST /integration/n8n

Receive webhook from n8n.

**Request:**
```json
{
  "workflowId": "workflow_n8n_123",
  "executionId": "exec_n8n_456",
  "status": "success",
  "data": {
    "leadId": "lead_789"
  }
}
```

**Response (200):**
```json
{
  "received": true,
  "executionId": "exec_n8n_456",
  "timestamp": "2025-01-15T17:05:00.000Z"
}
```

---

## 📦 Postman Collection

Download our Postman collection for easy API testing:

👉 [ECONEURA API v3.1 - Postman Collection](./postman_collection.json)

**Quick Start:**
1. Import `postman_collection.json` into Postman
2. Set environment variable `baseUrl` to your API endpoint
3. Set environment variable `token` after login
4. Test all endpoints with pre-configured requests

---

## 🔒 Security

- All endpoints use HTTPS in production
- JWT tokens expire after 7 days
- Rate limiting: 100 requests per 15 minutes
- Input validation via Zod schemas
- SQL injection prevention (parameterized queries)
- XSS prevention (sanitized inputs)
- CORS configured for allowed origins only

---

## 📞 Support

- **Email:** api-support@econeura.com
- **Docs:** https://docs.econeura.com
- **Status:** https://status.econeura.com
- **GitHub Issues:** https://github.com/ECONEURA-MAX/econeura-perfecto/issues

---

**Version:** 3.1.0  
**Last Updated:** January 15, 2026  
**License:** Proprietary - See LICENSE file

