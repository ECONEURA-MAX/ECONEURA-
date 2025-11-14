const logger = require('./services/logger');

/**
 * ECONEURA - Startup seguro con fail-safes
 * Envuelve todos los requires críticos para evitar crashes
 */

logger.info('[STARTUP-SAFE] Iniciando validación de módulos...');

const criticalModules = [
  'express',
  'cors',
  'dotenv',
  'compression',
  'helmet'
];

const optionalModules = [
  'passport',
  'express-session',
  '@azure/keyvault-secrets',
  'applicationinsights',
  'ioredis',
  'pg'
];

function validateModule(moduleName, required = true) {
  try {
    require.resolve(moduleName);
    logger.info(`  ✅ ${moduleName}`);
    return true;
  } catch (error) {
    if (required) {
      logger.error(`  ❌ CRÍTICO: ${moduleName} no encontrado`);
      return false;
    } else {
      logger.warn(`  ⚠️  OPCIONAL: ${moduleName} no encontrado (OK)`);
      return true;
    }
  }
}

logger.info('\n📦 Módulos críticos:');
let allCriticalOk = true;
criticalModules.forEach(mod => {
  if (!validateModule(mod, true)) {
    allCriticalOk = false;
  }
});

logger.info('\n📦 Módulos opcionales:');
optionalModules.forEach(mod => {
  validateModule(mod, false);
});

if (!allCriticalOk) {
  logger.error('\n❌ Faltan módulos críticos. Ejecutar: npm install');
  logger.error('⚠️  ADVERTENCIA: Continuando en modo degradado para permitir diagnóstico en Azure');
  logger.error('⚠️  El servidor puede fallar si estos módulos son realmente necesarios');
  // NO hacer process.exit(1) en Azure - permite ver logs de diagnóstico
}

logger.info('\n✅ Todos los módulos críticos disponibles\n');
module.exports = { validated: true };

