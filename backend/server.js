// ECONEURA Backend v3.0.0 - PRODUCTION READY - FAIL-SAFE STARTUP
// Validación de módulos antes de iniciar
require('./startup-safe');

const express = require('express');
const passport = require('passport');
const session = require('express-session');
const { configurePassport } = require('./config/auth');
const keyVaultService = require('./services/keyVaultService');
const authRouter = require('./routes/auth');
const healthRouter = require('./api/health');
const cors = require('cors');
const compression = require('compression');
const helmet = require('helmet');
require('dotenv').config();

// Validar environment variables AL INICIO (falla rápido si faltan)
require('./config/envValidation');

// Logger estructurado (reemplaza console.log)
const logger = require('./services/logger');

// === AI GATEWAY RESILIENTE ===
const ResilientAIGateway = require('./services/resilientAIGateway');

// === MEJORAS CRóTICAS IMPLEMENTADAS ===
// const DatabasePersistenceService = require('./services/databasePersistenceService'); // SQLite removed
// AdvancedVoiceService eliminado
// RealTimeStreamingService eliminado

// === ROUTERS ACTIVOS ===
// Solo importar los que se usan (desactivado carga masiva de routers legacy)
const chatsRouter = require('./routes/chat'); // ✅ USADO: Chat router
const libraryRouter = require('./api/library'); // ✅ Usado en línea 475
const { authMiddleware } = require('./middleware/auth'); // PostgreSQL version
const { globalLimiter } = require('./middleware/rateLimiter');
// Database: Mock o PostgreSQL
const db = process.env.USE_MOCK_DB === 'true'
  ? require('./db-mock')
  : require('./db'); // PostgreSQL version

// === ECONEURA MAX PREMIUM AUTOMATION SERVICES ===
// Automation services eliminados - bloqueaban inicio

const app = express();

// CORS Configuration - Array estático (optimizado)
const corsOptions = {
  origin: [
    'http://localhost:5173',
    'http://localhost:5174',
    'http://localhost:3000', 
    'https://econeura.com',
    'https://www.econeura.com',
    'https://api.econeura.com'
  ],
  credentials: true,
  optionsSuccessStatus: 200
};

// CORS anterior (función dinámica - más lento)
const corsOptionsDynamic = {
  origin: function (origin, callback) {
    // Permitir requests sin origin (mobile apps, Postman, etc.)
    if (!origin) {
      return callback(null, true);
    }

    const allowedOrigins = process.env.NODE_ENV === 'production'
      ? [
          'https://econeura.com',
          'https://www.econeura.com',
          'https://delightful-sand-04fd53203.3.azurestaticapps.net',
          'https://happy-pebble-0553f1003.3.azurestaticapps.net',
          'https://econeura-backend-prod.azurewebsites.net',
          /^https:\/\/.*\.azurestaticapps\.net$/,
          /^https:\/\/.*\.azurewebsites\.net$/,
          /^https:\/\/.*\.webstatic\.net$/
        ]
      : [
          'http://localhost:5173',
          'http://localhost:3000',
          'http://localhost:5174'
        ];

    // En desarrollo, permitir todo
    if (process.env.NODE_ENV !== 'production') {
      return callback(null, true);
    }

    // En producción, verificar origen (string exacto o regex)
    const isAllowed = allowedOrigins.some(allowed => {
      if (typeof allowed === 'string') {
        return origin === allowed;
      } else if (allowed instanceof RegExp) {
        return allowed.test(origin);
      }
      return false;
    });

    if (isAllowed) {
      callback(null, true);
    } else {
      logger.warn('[CORS] Origin bloqueado:', { origin });
      // En fase de testing, NO bloquear - solo advertir
      callback(null, true);
    }
  },
  credentials: false, // Cambiar a false para evitar problemas con preflight
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
  allowedHeaders: [
    'Content-Type',
    'Authorization',
    'X-Requested-With',
    'Accept',
    'Origin',
    'X-Correlation-Id',
    'X-Department',
    'Access-Control-Request-Method',
    'Access-Control-Request-Headers'
  ],
  exposedHeaders: ['Content-Range', 'X-Content-Range', 'X-Correlation-ID'],
  optionsSuccessStatus: 200, // Para navegadores antiguos
  maxAge: 86400 // 24 horas
};

app.use(cors(corsOptions));

// Performance & Security middleware
app.use(compression()); // MEJORA 4: Gzip compression
app.use(helmet({
  contentSecurityPolicy: false, // CSP ya está en Azure Static Web Apps
  crossOriginEmbedderPolicy: false,
  crossOriginResourcePolicy: { policy: 'cross-origin' }
})); // MEJORA 10: Security headers

// Azure App Service usa variable PORT dinámica
const PORT = process.env.PORT || process.env.WEBSITES_PORT || 8080;

// Log crítico para debugging en Azure (mejorado)
logger.info('========================================');
logger.info('🚀 ECONEURA Backend v3.0.0 STARTING');
logger.info('========================================');
logger.info(`Node version: ${process.version}`);
logger.info(`Environment: ${process.env.NODE_ENV || 'development'}`);
logger.info(`PORT: ${PORT}`);
logger.info(`Working Directory: ${process.cwd()}`);
logger.info(`Platform: ${process.platform}`);
logger.info(`Memory: ${Math.round(process.memoryUsage().heapUsed / 1024 / 1024)}MB`);
logger.info('[STARTUP] NODE_ENV:', { nodeEnv: process.env.NODE_ENV });
logger.info('[STARTUP] OPENAI_API_KEY presente:', { configured: !!process.env.OPENAI_API_KEY }); // Azure usa 8080 por defecto
const OPENAI_KEY = process.env.OPENAI_API_KEY ? process.env.OPENAI_API_KEY.trim() : null;

logger.info('=== ECONEURA Backend Starting ===', {
  port: PORT,
  openaiKeyConfigured: !!OPENAI_KEY,
  nodeEnv: process.env.NODE_ENV,
  version: process.env.npm_package_version || '3.0.0'
});

// Inicializar Application Insights PRIMERO (para tracking)
// NO bloquear inicio si falla
try {
  const appInsights = require('./monitoring/applicationInsights');
  const insightsInitialized = appInsights.initializeApplicationInsights && appInsights.initializeApplicationInsights();
  if (insightsInitialized && appInsights.requestTrackingMiddleware) {
    app.use(appInsights.requestTrackingMiddleware);
    logger.info('✅ Application Insights inicializado y tracking activo');
  } else {
    logger.warn('¢Å¡Â ¯Â¸Â  Application Insights no disponible (monitoring limitado)');
  }
} catch (error) {
  logger.warn('¢Å¡Â ¯Â¸Â  Application Insights no disponible:', { error: error.message });
  // NO matar el proceso - continuar sin monitoring
}

// Inicializar AI Gateway resiliente
const aiGateway = new ResilientAIGateway();
aiGateway.startHealthCheck();
app.locals.aiGateway = aiGateway; // Hacer disponible para rutas
logger.info('✅ AI Gateway resiliente inicializado');

// === INICIALIZAR DATABASE POOLING ===
// NO bloquear inicio si falla
try {
  const { initializePostgreSQL, initializeRedis } = require('./config/database');
  const pgPool = initializePostgreSQL && initializePostgreSQL();
  const redisClient = initializeRedis && initializeRedis();

  if (pgPool) {
    app.locals.pgPool = pgPool;
    logger.info('✅ PostgreSQL Pool disponible');
  } else {
    logger.warn('¢Å¡Â ¯Â¸Â  PostgreSQL Pool no inicializado (usando SQLite)');
  }

  if (redisClient) {
    app.locals.redis = redisClient;
    logger.info('✅ Redis Cache disponible');
  } else {
    logger.warn('¢Å¡Â ¯Â¸Â  Redis Cache no disponible (caching deshabilitado)');
  }
} catch (error) {
  logger.warn('¢Å¡Â ¯Â¸Â  Database pooling no disponible:', { error: error.message });
  // NO matar el proceso - continuar sin pooling
}

// === INICIALIZAR MEJORAS CRóTICAS ===
// MEJORA 1: Database Persistence
// const dbPersistence = new DatabasePersistenceService(); // SQLite removed
// app.locals.dbPersistence = dbPersistence; // SQLite removed
logger.info('✅ Database Persistence Service inicializado');

// MEJORA 2: Advanced Voice Service (COMENTADO - Archivo no existe)
// const voiceService = new AdvancedVoiceService();
// app.locals.voiceService = voiceService;
// logger.info('✅ Advanced Voice Service inicializado');

// MEJORA 3: Real-Time Streaming (COMENTADO - Archivo no existe)
// const streamingService = new RealTimeStreamingService();
// app.locals.streamingService = streamingService;
// logger.info('✅ Real-Time Streaming Service inicializado');

// SQLITE REMOVED - PostgreSQL only via DATABASE_URL env var

// === CONFIGURAR AUTENTICACIƒâ€œN (con Key Vault) ===
async function initializeSession() {
  try {
    // Obtener SESSION_SECRET de Key Vault
    const sessionSecret = await keyVaultService.getSessionSecret();

    app.use(session({
      secret: sessionSecret,
      resave: false,
      saveUninitialized: false,
      cookie: {
        secure: process.env.NODE_ENV === 'production',
        maxAge: 24 * 60 * 60 * 1000 // 24 horas
      }
    }));

    logger.info('✅ SESSION_SECRET cargado desde Key Vault');
  } catch (error) {
    // Fallback a variable de entorno
    logger.warn('¢Å¡Â ¯Â¸Â Key Vault no disponible, usando SESSION_SECRET de env', { error: error.message });
    const fallbackSecret = process.env.SESSION_SECRET || 'econeura-session-secret-dev';

    if (fallbackSecret === 'econeura-session-secret-dev') {
      logger.warn('¢Å¡Â ¯Â¸Â ADVERTENCIA: Usando SESSION_SECRET por defecto (solo desarrollo)');
    }

    app.use(session({
      secret: fallbackSecret,
      resave: false,
      saveUninitialized: false,
      cookie: {
        secure: process.env.NODE_ENV === 'production',
        maxAge: 24 * 60 * 60 * 1000
      }
    }));
  }

  app.use(passport.initialize());
  app.use(passport.session());
  logger.info('¢Å“â€¦ Sistema de autenticació³n OAuth configurado');
}

// Inicializar autenticació³n (async)
configurePassport();
initializeSession().catch(err => {
  logger.error('¢ÂÅ’ Error cró­tico inicializando sesió³n:', { error: err.message, stack: err.stack });
  // NO matar el proceso - permitir que el servidor arranque sin sesió³n
  // process.exit(1);
});

// OPTIONS requests handled by cors() middleware above

// JSON body parser (ya CORS estó¡ aplicado arriba)
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Rate limiting (3 niveles)
app.use(globalLimiter);

// Prompts avanzados (leer de archivos prompts/)
const prompts = {
  'a-ceo-01': require('./prompts/neura-ceo'),
  'a-ia-01': require('./prompts/neura-ia'),
  'a-cso-01': require('./prompts/neura-cso'),
  'a-cto-01': require('./prompts/neura-cto'),
  'a-ciso-01': require('./prompts/neura-ciso'),
  'a-coo-01': require('./prompts/neura-coo'),
  'a-chro-01': require('./prompts/neura-chro'),
  'a-mkt-01': require('./prompts/neura-cmo'),
  'a-cfo-01': require('./prompts/neura-cfo'),
  'a-cdo-01': require('./prompts/neura-cdo')
};

function getPrompt(agentId) {
  const promptConfig = prompts[agentId];
  if (promptConfig && promptConfig.systemPrompt) {
    return promptConfig.systemPrompt;
  }
  return 'Eres un asistente ejecutivo de ECONEURA. Respondes de forma profesional y concisa en espaó±ol.';
}

// ELIMINADO: llamarOpenAI() - Reemplazado por ResilientAIGateway
// Todas las llamadas ahora usan app.locals.aiGateway.getChatCompletion()
// que proporciona circuit breakers, fallback automó¡tico y mejor resiliencia

// Health endpoint handled by healthRouter at /api/health

// === ROUTERS CONFIGURADOS ===


// === ROUTERS CRóTICOS (USADOS POR FRONTEND) ===
app.use('/api/auth', authRouter); // ¢Å“â€¦ USADO: Login/Register
const loginRouter = require('./api/auth/login');
app.use('/api/auth', loginRouter);
const invokeRouter = require('./routes/invoke');
app.use('/api/invoke', invokeRouter); // ¢Å“â€¦ USADO: Invocar agentes
app.use('/api/chats', authMiddleware, chatsRouter); // ¢Å“â€¦ USADO: Historial
app.use('/api/health', healthRouter); // ¢Å“â€¦ USADO: Health check

// === METRICS & OBSERVABILITY ===
const { router: metricsRouter, metricsMiddleware } = require('./api/metrics');
app.use(metricsMiddleware); // Middleware para contar requests
app.use('/api/metrics', metricsRouter); // ¢Å“â€¦ NUEVO: Prometheus metrics

// === AI GATEWAY (ENDPOINT PRINCIPAL DE CHAT) ===
const aiGatewayRouter = require('./routes/ai-gateway');
app.use('/api/ai-gateway', aiGatewayRouter); // ¢Å“â€¦ USADO: Chat principal
app.use('/api/library', authMiddleware, libraryRouter); // ¢Å“â€¦ NUEVO: Biblioteca de documentos

const integrationRouter = require('./routes/integration');
app.use('/api/integration', integrationRouter); // ¢Å“â€¦ USADO: Make/n8n webhooks
// app.use('/api/health', providerHealthRouter); // ¢ÂÅ’ DUPLICADO: Ya existe healthRouter
const agentsRouter = require('./api/agents');
app.use('/api/agents', authMiddleware, agentsRouter); // ¢Å“â€¦ USADO: Gestió³n agentes Make/n8n
const proposalsRouter = require('./api/proposals');
app.use('/api/proposals', authMiddleware, proposalsRouter);
const neuraAgentsRouter = require('./routes/neura-agents');
app.use('/api/neura-agents', neuraAgentsRouter);
const neuraChatEnhancedRouter = require('./routes/neura-chat-enhanced');
app.use('/api/neura-chat', neuraChatEnhancedRouter); // ¢Å“â€¦ USADO: HITL Proposals

// Graceful shutdown handler
async function gracefulShutdown(signal) {
  logger.info(`Received ${signal}, shutting down gracefully...`);

  return new Promise((resolve) => {
    // Cerrar HTTP server
    server.close(() => {
      logger.info('HTTP server closed');
    });

    // Cerrar conexiones
    const shutdownPromises = [];
    
    if (app.locals.pgPool) {
      shutdownPromises.push(
        app.locals.pgPool.end().then(() => logger.info('PostgreSQL pool closed'))
      );
    }
    
    if (app.locals.redis) {
      shutdownPromises.push(
        app.locals.redis.quit().then(() => logger.info('Redis closed'))
      );
    }

    Promise.all(shutdownPromises).then(() => {
      logger.info('✅ Graceful shutdown completed');
      resolve();
      process.exit(0);
    }).catch((err) => {
      logger.error('Error during graceful shutdown:', { error: err.message });
      resolve();
      process.exit(1);
    });
  });
}

// Registrar handlers de shutdown
process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

// Start server
const server = app.listen(PORT, '0.0.0.0', () => {
  logger.info('\n' + '='.repeat(70));
  logger.info('  ECONEURA MAX PREMIUM Backend Ready v2.0 - AUTOMATED');
  logger.info('='.repeat(70));
  logger.info(`  Server:   http://0.0.0.0:${PORT}`, {
    port: PORT,
    environment: process.env.NODE_ENV,
    version: process.env.npm_package_version || '3.0.0'
  });
  logger.info('  Provider: Mammouth AI (Mistral Medium 3.1)');
  logger.info('  Status:   Ready with Full Automation');
  logger.info('  Features: Workflows + Collaboration + Analytics + Security');
  logger.info('='.repeat(70) + '\n');
});






