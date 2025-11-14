#!/usr/bin/env node
/**
 * ECONEURA - Script de verificación PRE-DEPLOY
 * Ejecutar antes de hacer commit/push/deploy
 */

const fs = require('fs');
const path = require('path');
const logger = require('./services/logger');

logger.info('🔍 VERIFICACIÓN PRE-DEPLOY ECONEURA\n');

let errors = 0;
let warnings = 0;

// 1. Verificar archivos críticos
const criticalFiles = [
  'server.js',
  'package.json',
  'package-lock.json',
  '.deployment',
  'deploy.sh',
  'web.config',
  '.nvmrc',
  'config/envValidation.js',
  'services/logger.js',
  'api/health.js'
];

logger.info('📁 Verificando archivos críticos...');
criticalFiles.forEach(file => {
  if (!fs.existsSync(path.join(__dirname, file))) {
    logger.info(`  ❌ Falta: ${file}`);
    errors++;
  } else {
    logger.info(`  ✅ ${file}`);
  }
});

// 2. Verificar package.json
logger.info('\n📦 Verificando package.json...');
const pkg = require('./package.json');

if (!pkg.engines || !pkg.engines.node) {
  logger.info('  ⚠️  No hay engines.node especificado');
  warnings++;
} else {
  logger.info(`  ✅ Node: ${pkg.engines.node}`);
}

if (!pkg.scripts || !pkg.scripts.start) {
  logger.info('  ❌ Falta script "start"');
  errors++;
} else {
  logger.info(`  ✅ start: ${pkg.scripts.start}`);
}

// 3. Verificar que NO haya SQLite
logger.info('\n🗄️  Verificando NO SQLite...');
const lockfile = fs.readFileSync(path.join(__dirname, 'package-lock.json'), 'utf8');
if (lockfile.includes('sqlite') || lockfile.includes('better-sqlite3')) {
  logger.info('  ❌ SQLite encontrado en package-lock.json');
  errors++;
} else {
  logger.info('  ✅ No hay SQLite');
}

// 4. Verificar .env.example
logger.info('\n📝 Verificando env.example.txt...');
if (!fs.existsSync(path.join(__dirname, 'env.example.txt'))) {
  logger.info('  ⚠️  No existe env.example.txt');
  warnings++;
} else {
  logger.info('  ✅ env.example.txt existe');
}

// 5. Verificar que .env NO esté en Git
logger.info('\n🔒 Verificando .env no está en Git...');
try {
  const { execSync } = require('child_process');
  const gitFiles = execSync('git ls-files', { encoding: 'utf8' });
  if (gitFiles.includes('.env') && !gitFiles.includes('.env.example')) {
    logger.info('  ❌ .env está en Git (PELIGRO)');
    errors++;
  } else {
    logger.info('  ✅ .env no está en Git');
  }
} catch (e) {
  logger.info('  ⚠️  No se puede verificar (no es repo Git)');
}

// 6. Verificar server.js básico
logger.info('\n🖥️  Verificando server.js...');
const serverJs = fs.readFileSync(path.join(__dirname, 'server.js'), 'utf8');
if (!serverJs.includes('process.env.PORT')) {
  logger.info('  ⚠️  server.js no usa process.env.PORT');
  warnings++;
} else {
  logger.info('  ✅ Usa process.env.PORT');
}

if (!serverJs.includes('app.listen')) {
  logger.info('  ❌ No hay app.listen');
  errors++;
} else {
  logger.info('  ✅ Tiene app.listen');
}

// 7. Verificar logging
logger.info('\n📊 Verificando sistema de logging...');
if (!fs.existsSync(path.join(__dirname, 'services/logger.js'))) {
  logger.info('  ❌ Falta services/logger.js');
  errors++;
} else {
  logger.info('  ✅ Logger configurado');
}

// 8. Verificar health check
logger.info('\n🏥 Verificando health check...');
const healthJs = fs.readFileSync(path.join(__dirname, 'api/health.js'), 'utf8');
if (!healthJs.includes('/simple') && !healthJs.includes('router.get')) {
  logger.info('  ⚠️  Health check puede ser demasiado complejo');
  warnings++;
} else {
  logger.info('  ✅ Health check configurado');
}

// Resumen
logger.info('\n' + '='.repeat(50));
if (errors === 0 && warnings === 0) {
  logger.info('✅ VERIFICACIÓN COMPLETA - LISTO PARA DEPLOY');
  logger.info('='.repeat(50));
  process.exit(0);
} else if (errors === 0) {
  logger.info(`⚠️  ${warnings} ADVERTENCIAS - Revisar antes de deploy`);
  logger.info('='.repeat(50));
  process.exit(0);
} else {
  logger.info(`❌ ${errors} ERRORES, ${warnings} ADVERTENCIAS`);
  logger.info('='.repeat(50));
  logger.info('\n🚨 NO DEPLOYAR HASTA RESOLVER ERRORES');
  process.exit(1);
}

