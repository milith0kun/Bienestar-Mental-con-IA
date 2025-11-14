const mongoose = require('mongoose');
require('dotenv').config();

const mongoUri = process.env.MONGODB_URI;

console.log('\n╔════════════════════════════════════════════════════════════╗');
console.log('║   MongoDB Atlas - Prueba de Conexión                      ║');
console.log('╚════════════════════════════════════════════════════════════╝\n');

if (!mongoUri) {
  console.error('❌ Error: MONGODB_URI no está definida en el archivo .env');
  process.exit(1);
}

console.log('🔍 Verificando configuración...');
console.log('📝 URI (oculta):', mongoUri.replace(/:[^:]*@/, ':****@'));
console.log('');

console.log('🔄 Intentando conectar a MongoDB Atlas...\n');

// Configurar timeout de 10 segundos
const timeoutId = setTimeout(() => {
  console.error('❌ Timeout: No se pudo conectar en 10 segundos');
  console.error('\n📋 Posibles causas:');
  console.error('  1. El clúster está pausado en MongoDB Atlas');
  console.error('  2. La IP no está en la lista blanca (Network Access)');
  console.error('  3. Problemas de red o firewall');
  console.error('  4. Credenciales incorrectas');
  console.error('\n📚 Lee MONGODB_SETUP.md para más información\n');
  process.exit(1);
}, 10000);

mongoose.connect(mongoUri)
  .then(() => {
    clearTimeout(timeoutId);
    console.log('✅ ¡Conexión exitosa a MongoDB Atlas!\n');
    console.log('📊 Información de la conexión:');
    console.log('   • Base de datos:', mongoose.connection.name);
    console.log('   • Host:', mongoose.connection.host);
    console.log('   • Estado:', mongoose.connection.readyState === 1 ? 'Conectado' : 'Desconocido');
    console.log('');

    // Listar colecciones
    return mongoose.connection.db.listCollections().toArray();
  })
  .then((collections) => {
    console.log('📚 Colecciones en la base de datos:', collections.length);
    if (collections.length > 0) {
      collections.forEach(col => console.log('   •', col.name));
    } else {
      console.log('   (No hay colecciones aún - se crearán al insertar datos)');
    }
    console.log('');

    return mongoose.connection.close();
  })
  .then(() => {
    console.log('👋 Conexión cerrada correctamente');
    console.log('╔════════════════════════════════════════════════════════════╗');
    console.log('║   ✨ Todo está configurado correctamente                   ║');
    console.log('╚════════════════════════════════════════════════════════════╝\n');
    process.exit(0);
  })
  .catch((err) => {
    clearTimeout(timeoutId);
    console.error('❌ Error al conectar a MongoDB Atlas\n');
    console.error('Detalles del error:');
    console.error('   • Mensaje:', err.message);
    console.error('   • Código:', err.code || 'N/A');
    console.error('');

    // Mensajes de ayuda según el tipo de error
    if (err.message.includes('ECONNREFUSED') || err.message.includes('querySrv')) {
      console.error('💡 Este error generalmente significa:');
      console.error('   1. El clúster está pausado - Actívalo en MongoDB Atlas');
      console.error('   2. Problemas de red - Verifica tu conexión a internet');
      console.error('   3. La URI del clúster es incorrecta');
    } else if (err.message.includes('Authentication failed')) {
      console.error('💡 Credenciales incorrectas:');
      console.error('   1. Verifica el usuario y contraseña en .env');
      console.error('   2. Asegúrate que el usuario existe en Database Access');
    } else if (err.message.includes('IP') || err.message.includes('whitelist')) {
      console.error('💡 IP no autorizada:');
      console.error('   1. Agrega tu IP en Network Access en MongoDB Atlas');
      console.error('   2. O usa 0.0.0.0/0 para desarrollo');
    }

    console.error('\n📚 Lee MONGODB_SETUP.md para más información\n');
    process.exit(1);
  });
