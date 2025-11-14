const fs = require('fs');
const path = require('path');

/**
 * ECONEURA - Corrección masiva de paths de logger
 * 
 * PROBLEMA DETECTADO:
 * - services/*.js usan require('./services/logger') ❌
 * - Debe ser require('./logger') ✅
 */

console.log('🔧 ECONEURA - Corrección masiva de logger paths\n');

let totalFixed = 0;
let errors = [];

// ========================================
// GRUPO 1: services/*.js
// ========================================
console.log('📁 Grupo 1: backend/services/*.js');
console.log('   Pattern: ./services/logger → ./logger\n');

try {
  const servicesDir = path.join(__dirname, 'backend', 'services');
  const files = fs.readdirSync(servicesDir).filter(f => f.endsWith('.js'));
  
  files.forEach(file => {
    const filePath = path.join(servicesDir, file);
    let content = fs.readFileSync(filePath, 'utf8');
    const originalContent = content;
    
    // Replace: require('./services/logger') → require('./logger')
    content = content.replace(/require\(['"]\.\/services\/logger['"]\)/g, "require('./logger')");
    
    if (content !== originalContent) {
      fs.writeFileSync(filePath, content, 'utf8');
      console.log(`   ✅ Fixed: services/${file}`);
      totalFixed++;
    }
  });
} catch (err) {
  console.error(`   ❌ Error processing services/: ${err.message}`);
  errors.push(`services/: ${err.message}`);
}

// ========================================
// GRUPO 2: Archivos root backend
// ========================================
console.log('\n📁 Grupo 2: backend/*.js');
console.log('   Pattern: ../services/logger → ./services/logger\n');

const rootFiles = [
  'verificar-antes-deploy.js',
  'startup-safe.js',
  'db-mock.js'
];

rootFiles.forEach(file => {
  try {
    const filePath = path.join(__dirname, 'backend', file);
    
    if (!fs.existsSync(filePath)) {
      console.log(`   ⚠️  Skip: ${file} (no existe)`);
      return;
    }
    
    let content = fs.readFileSync(filePath, 'utf8');
    const originalContent = content;
    
    // Replace: require('../services/logger') → require('./services/logger')
    content = content.replace(/require\(['"]\.\.\/services\/logger['"]\)/g, "require('./services/logger')");
    
    if (content !== originalContent) {
      fs.writeFileSync(filePath, content, 'utf8');
      console.log(`   ✅ Fixed: ${file}`);
      totalFixed++;
    } else {
      console.log(`   ✓ OK: ${file} (sin cambios)`);
    }
  } catch (err) {
    console.error(`   ❌ Error: ${file} - ${err.message}`);
    errors.push(`${file}: ${err.message}`);
  }
});

// ========================================
// RESUMEN
// ========================================
console.log('\n' + '='.repeat(60));
console.log(`✅ Total archivos corregidos: ${totalFixed}`);

if (errors.length > 0) {
  console.log(`\n⚠️  Errores encontrados: ${errors.length}`);
  errors.forEach(err => console.log(`   - ${err}`));
}

console.log('='.repeat(60));

process.exit(errors.length > 0 ? 1 : 0);

