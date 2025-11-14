require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../src/models/User.model');
const Meditation = require('../src/models/Meditation.model');
const config = require('../src/config');

// Datos de meditaciones de ejemplo
const meditationsData = [
  {
    title: 'Respiración Consciente',
    description:
      'Una meditación guiada para principiantes enfocada en la respiración consciente.',
    category: 'general',
    duration: 300, // 5 minutos
    difficulty: 'beginner',
    audioUrl: 's3://mindflow-audio/general/respiracion-consciente.mp3',
    thumbnailUrl: '',
    isPremium: false,
    tags: ['respiración', 'relajación', 'principiante'],
    instructor: 'MindFlow',
  },
  {
    title: 'Calma para la Ansiedad',
    description:
      'Meditación diseñada para reducir la ansiedad y encontrar paz interior.',
    category: 'anxiety',
    duration: 600, // 10 minutos
    difficulty: 'intermediate',
    audioUrl: 's3://mindflow-audio/anxiety/calma-ansiedad.mp3',
    thumbnailUrl: '',
    isPremium: false,
    tags: ['ansiedad', 'calma', 'paz'],
    instructor: 'MindFlow',
  },
  {
    title: 'Liberación de Estrés',
    description:
      'Guía para liberar el estrés acumulado y recuperar la tranquilidad.',
    category: 'stress',
    duration: 720, // 12 minutos
    difficulty: 'intermediate',
    audioUrl: 's3://mindflow-audio/stress/liberacion-estres.mp3',
    thumbnailUrl: '',
    isPremium: false,
    tags: ['estrés', 'relajación', 'tranquilidad'],
    instructor: 'MindFlow',
  },
  {
    title: 'Sueño Profundo',
    description:
      'Meditación para conciliar el sueño y disfrutar de un descanso reparador.',
    category: 'sleep',
    duration: 900, // 15 minutos
    difficulty: 'beginner',
    audioUrl: 's3://mindflow-audio/sleep/sueno-profundo.mp3',
    thumbnailUrl: '',
    isPremium: false,
    tags: ['sueño', 'descanso', 'relajación'],
    instructor: 'MindFlow',
  },
  {
    title: 'Enfoque y Concentración',
    description:
      'Mejora tu capacidad de concentración y mantén el enfoque en tus tareas.',
    category: 'focus',
    duration: 480, // 8 minutos
    difficulty: 'intermediate',
    audioUrl: 's3://mindflow-audio/focus/enfoque-concentracion.mp3',
    thumbnailUrl: '',
    isPremium: false,
    tags: ['enfoque', 'concentración', 'productividad'],
    instructor: 'MindFlow',
  },
  {
    title: 'Autoestima y Confianza',
    description:
      'Fortalece tu autoestima y desarrolla una mayor confianza en ti mismo.',
    category: 'self-esteem',
    duration: 720, // 12 minutos
    difficulty: 'intermediate',
    audioUrl: 's3://mindflow-audio/self-esteem/autoestima-confianza.mp3',
    thumbnailUrl: '',
    isPremium: true,
    tags: ['autoestima', 'confianza', 'crecimiento personal'],
    instructor: 'MindFlow',
  },
  {
    title: 'Gratitud Diaria',
    description:
      'Cultiva la gratitud y aprecia las bendiciones de tu vida cotidiana.',
    category: 'gratitude',
    duration: 360, // 6 minutos
    difficulty: 'beginner',
    audioUrl: 's3://mindflow-audio/gratitude/gratitud-diaria.mp3',
    thumbnailUrl: '',
    isPremium: true,
    tags: ['gratitud', 'apreciación', 'bienestar'],
    instructor: 'MindFlow',
  },
  {
    title: 'Meditación Avanzada de Mindfulness',
    description:
      'Una práctica profunda de mindfulness para meditadores experimentados.',
    category: 'general',
    duration: 1800, // 30 minutos
    difficulty: 'advanced',
    audioUrl: 's3://mindflow-audio/general/mindfulness-avanzado.mp3',
    thumbnailUrl: '',
    isPremium: true,
    tags: ['mindfulness', 'avanzado', 'conciencia plena'],
    instructor: 'MindFlow',
  },
];

// Usuario de prueba
const testUser = {
  email: 'test@mindflow.com',
  password: 'Password123',
  name: 'Usuario de Prueba',
  authProvider: 'email',
};

async function seedDatabase() {
  try {
    // Conectar a la base de datos
    await mongoose.connect(config.mongoUri, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log('✓ Conectado a MongoDB');

    // Limpiar colecciones existentes
    console.log('\n🗑️  Limpiando base de datos...');
    await User.deleteMany({});
    await Meditation.deleteMany({});
    console.log('✓ Base de datos limpiada');

    // Crear usuario de prueba
    console.log('\n👤 Creando usuario de prueba...');
    const user = await User.create(testUser);
    console.log(`✓ Usuario creado: ${user.email}`);

    // Crear meditaciones
    console.log('\n🧘 Creando meditaciones...');
    for (const meditationData of meditationsData) {
      const meditation = await Meditation.create(meditationData);
      console.log(
        `  ✓ ${meditation.title} (${meditation.category}, ${meditation.isPremium ? 'Premium' : 'Gratuita'})`
      );
    }

    console.log(`\n✅ Se crearon ${meditationsData.length} meditaciones`);

    // Estadísticas
    const totalMeditations = await Meditation.countDocuments();
    const freeMeditations = await Meditation.countDocuments({ isPremium: false });
    const premiumMeditations = await Meditation.countDocuments({
      isPremium: true,
    });
    const totalUsers = await User.countDocuments();

    console.log('\n📊 Estadísticas:');
    console.log(`  • Usuarios: ${totalUsers}`);
    console.log(`  • Meditaciones totales: ${totalMeditations}`);
    console.log(`  • Meditaciones gratuitas: ${freeMeditations}`);
    console.log(`  • Meditaciones premium: ${premiumMeditations}`);

    console.log('\n🎉 ¡Base de datos inicializada con éxito!');
    console.log('\n📝 Credenciales de prueba:');
    console.log(`  Email: ${testUser.email}`);
    console.log(`  Password: ${testUser.password}`);

    process.exit(0);
  } catch (error) {
    console.error('\n❌ Error al inicializar la base de datos:', error);
    process.exit(1);
  }
}

// Ejecutar el seed
seedDatabase();
