# ECONEURA Backend - Production Dockerfile
# Node.js 20 LTS Alpine (minimal image)

FROM node:20-alpine AS base

# Metadatos
LABEL maintainer="ECONEURA MAX <devops@econeura.com>"
LABEL version="3.1.0"
LABEL description="ECONEURA Backend API - AI-Powered Business Intelligence"

# Instalar dependencias del sistema
RUN apk add --no-cache \
    dumb-init \
    tini \
    curl \
    && rm -rf /var/cache/apk/*

# Crear usuario no-root
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001

# Directorio de trabajo
WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# ================================
# STAGE 1: Dependencies
# ================================
FROM base AS dependencies

# Instalar TODAS las dependencias (dev + prod)
RUN npm ci --include=dev

# ================================
# STAGE 2: Builder
# ================================
FROM base AS builder

# Copiar node_modules del stage anterior
COPY --from=dependencies /app/node_modules ./node_modules

# Copiar código fuente
COPY . .

# Limpiar archivos innecesarios
RUN rm -rf \
    __tests__ \
    tests \
    *.md \
    .git \
    .github \
    .env.example \
    *.log

# ================================
# STAGE 3: Production
# ================================
FROM base AS production

# Variables de entorno por defecto
ENV NODE_ENV=production \
    PORT=8080 \
    LOG_LEVEL=info

# Copiar solo node_modules de producción
COPY package*.json ./
RUN npm ci --omit=dev --ignore-scripts && npm cache clean --force

# Copiar código desde builder
COPY --from=builder --chown=nodejs:nodejs /app ./

# Cambiar a usuario no-root
USER nodejs

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD node -e "require('http').get('http://localhost:8080/api/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Exponer puerto
EXPOSE 8080

# Usar tini como init system (previene zombies)
ENTRYPOINT ["/sbin/tini", "--"]

# Comando de inicio
CMD ["node", "server.js"]

# ================================
# Build Instructions
# ================================
# Build:
#   docker build -t econeura-backend:latest -t econeura-backend:3.1.0 .
#
# Run locally:
#   docker run -d \
#     --name econeura-backend \
#     -p 8080:8080 \
#     -e DATABASE_URL="postgresql://..." \
#     -e OPENAI_API_KEY="sk-proj-..." \
#     -e JWT_SECRET="..." \
#     econeura-backend:latest
#
# Run with env file:
#   docker run -d \
#     --name econeura-backend \
#     -p 8080:8080 \
#     --env-file .env \
#     econeura-backend:latest
#
# Docker Compose:
#   See docker-compose.yml in project root

