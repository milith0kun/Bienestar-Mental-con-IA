MindFlow
Aplicación de Bienestar Mental con IA
Especificación Técnica de Requerimientos



Documento de Desarrollo
Stack: Flutter + Node.js + MongoDB Atlas + AWS EC2
Versión 1.0 - Noviembre 2025
 
Tabla de Contenidos
(Se generará automáticamente al abrir el documento en Word)
 
1. Introducción
1.1 Contexto del Proyecto
El mercado de aplicaciones de salud mental y bienestar digital representa una oportunidad significativa de crecimiento, alcanzando los 7.48 mil millones de dólares en 2024 con proyección a 17.52 mil millones para 2030. Según la Organización Mundial de la Salud, una de cada ocho personas sufre trastornos de salud mental, pero la terapia tradicional presenta barreras importantes como costos elevados (150-300 USD por sesión), largas listas de espera y limitaciones geográficas.
MindFlow surge como una solución tecnológica innovadora que democratiza el acceso al bienestar mental mediante la combinación de meditaciones guiadas, seguimiento emocional inteligente y análisis personalizado impulsado por inteligencia artificial. La aplicación busca establecerse en el mercado latinoamericano aprovechando la creciente demanda de herramientas digitales de salud mental y la disposición de usuarios a adoptar tecnologías de autocuidado.
1.2 Objetivos del Proyecto
•	Desarrollar una aplicación multiplataforma nativa usando Flutter para Android, iOS y Web
•	Implementar un backend escalable en Node.js con base de datos MongoDB Atlas
•	Integrar servicios de inteligencia artificial para análisis de sentimientos y recomendaciones personalizadas
•	Configurar infraestructura cloud en AWS EC2 para hosting del backend
•	Publicar la aplicación en Google Play Store y Apple App Store
•	Implementar modelo freemium de monetización con suscripción premium
1.3 Alcance del Documento
Este documento técnico detalla la especificación completa de requerimientos funcionales y no funcionales, arquitectura del sistema, modelo de datos, endpoints del API REST, configuración de infraestructura y roadmap de desarrollo por sprints. Está diseñado para servir como guía integral durante todo el ciclo de desarrollo desde la implementación inicial hasta la publicación en las tiendas de aplicaciones.
 
2. Descripción General del Sistema
2.1 Visión del Producto
MindFlow es una aplicación móvil y web de bienestar mental que combina contenido guiado de meditación con análisis inteligente del estado emocional del usuario. A través de un diario emocional potenciado por IA, la aplicación identifica patrones, tendencias y factores desencadenantes, ofreciendo recomendaciones personalizadas de prácticas de mindfulness adaptadas a las necesidades específicas de cada usuario.
2.2 Características Principales
Biblioteca de Meditaciones
Catálogo curado de sesiones de meditación guiada en español, organizadas por categorías temáticas como ansiedad, estrés, sueño, enfoque y bienestar general. Cada meditación incluye descripción, duración, nivel de dificultad y reproductor de audio en streaming desde AWS S3.
Diario Emocional con IA
Herramienta de registro diario que permite a los usuarios documentar sus pensamientos, emociones y experiencias. Integración con OpenAI API para análisis automático de sentimientos, identificación de patrones emocionales y generación de insights personalizados sobre el estado mental del usuario.
Seguimiento de Estado de Ánimo
Sistema de registro rápido del estado emocional mediante escala numérica de 1 a 10 o selección de emociones predefinidas. Visualización de tendencias históricas mediante gráficas interactivas que permiten al usuario comprender la evolución de su bienestar mental a lo largo del tiempo.
Dashboard de Estadísticas
Panel personalizado que presenta métricas clave como racha de días consecutivos de práctica, tiempo total de meditación, entradas de diario completadas, evolución del estado de ánimo y logros desbloqueados. Incluye recomendaciones generadas por IA basadas en los patrones detectados.
 
3. Requerimientos Funcionales
Los requerimientos funcionales describen las capacidades específicas que debe proporcionar el sistema, incluyendo las interacciones del usuario, procesamiento de datos y respuestas del sistema.
3.1 Módulo de Autenticación y Gestión de Usuarios
RF-01 - Registro de Usuario con Email: El sistema debe permitir que nuevos usuarios creen una cuenta proporcionando nombre completo, correo electrónico y contraseña. La contraseña debe cumplir requisitos mínimos de seguridad: al menos 8 caracteres, una mayúscula, una minúscula y un número.
RF-02 - Registro con Google OAuth: El sistema debe permitir registro e inicio de sesión mediante cuentas de Google, utilizando el protocolo OAuth 2.0 para autenticación segura sin manejo directo de credenciales.
RF-03 - Inicio de Sesión: Los usuarios registrados deben poder acceder a la aplicación mediante su correo electrónico y contraseña, o a través de su cuenta de Google si se registraron con ese método.
RF-04 - Recuperación de Contraseña: El sistema debe enviar un enlace de restablecimiento de contraseña al correo electrónico del usuario cuando este lo solicite. El enlace debe tener validez temporal de 1 hora.
RF-05 - Perfil de Usuario: Los usuarios deben poder visualizar y editar su información personal incluyendo nombre, foto de perfil, fecha de nacimiento y objetivos de bienestar.
RF-06 - Gestión de Sesiones: El sistema debe mantener la sesión activa del usuario mediante tokens JWT con expiración de 7 días. Al cerrar sesión, los tokens deben invalidarse.
3.2 Módulo de Biblioteca de Meditaciones
RF-07 - Catálogo de Meditaciones: El sistema debe mostrar todas las meditaciones disponibles organizadas por categorías: Ansiedad, Estrés, Sueño, Enfoque, Autoestima, Gratitud y Bienestar General.
RF-08 - Reproductor de Audio: El sistema debe proporcionar un reproductor de audio integrado con controles de play/pausa, barra de progreso, ajuste de velocidad y temporizador. El audio debe transmitirse en streaming desde AWS S3.
RF-09 - Búsqueda y Filtrado: Los usuarios deben poder buscar meditaciones por palabra clave y filtrar por categoría, duración o nivel de dificultad.
RF-10 - Favoritos: Los usuarios deben poder marcar meditaciones como favoritas para acceso rápido.
RF-11 - Historial de Reproducción: El sistema debe registrar cada sesión de meditación completada, almacenando fecha, hora, meditación reproducida y duración.
RF-12 - Restricciones de Contenido Gratuito: Los usuarios con cuenta gratuita deben tener acceso a 5 meditaciones específicas. Al intentar reproducir contenido premium, mostrar mensaje promocional.
3.3 Módulo de Diario Emocional con IA
RF-13 - Creación de Entrada de Diario: Los usuarios deben poder crear nuevas entradas de diario proporcionando título, contenido de texto libre y selección de estado de ánimo general.
RF-14 - Análisis de Sentimientos con IA: Cada entrada debe enviarse automáticamente a OpenAI API para análisis de sentimiento, extrayendo emociones principales y nivel de positividad/negatividad.
RF-15 - Visualización de Entradas: Los usuarios deben poder ver todas sus entradas en orden cronológico inverso, con vista previa del contenido y resultados del análisis de IA.
RF-16 - Edición y Eliminación: Los usuarios deben poder editar el contenido de entradas existentes (dispara nuevo análisis) y eliminar entradas permanentemente con confirmación.
RF-17 - Generación de Insights: El sistema debe utilizar OpenAI API para generar insights semanales basados en el conjunto de entradas del usuario.
RF-18 - Limitación Plan Gratuito: Los usuarios gratuitos deben poder crear máximo 10 entradas de diario al mes.
3.4 Módulo de Seguimiento de Estado de Ánimo
RF-19 - Registro Diario de Estado de Ánimo: El sistema debe permitir que los usuarios registren su estado de ánimo diario mediante escala numérica de 1 a 10. Solo un registro por día.
RF-20 - Gráfica de Tendencias: El sistema debe generar gráficas interactivas que muestren la evolución del estado de ánimo en períodos de 7, 30 y 90 días.
RF-21 - Calendario Emocional: El sistema debe presentar una vista de calendario donde cada día muestra el estado de ánimo registrado mediante código de colores.
RF-22 - Recordatorios: El sistema debe enviar notificación push diaria recordando al usuario registrar su estado de ánimo.
 
4. Requerimientos No Funcionales
4.1 Rendimiento
RNF-01 - Tiempo de Respuesta del API: El 95% de las peticiones al backend deben responderse en menos de 500 milisegundos bajo carga normal.
RNF-02 - Inicio de Reproducción: El audio de meditación debe comenzar a reproducirse en menos de 2 segundos después de presionar play.
RNF-03 - Carga de Interfaz: La aplicación debe cargar la pantalla principal en menos de 3 segundos en dispositivos con especificaciones medias.
RNF-04 - Concurrencia: El sistema debe soportar al menos 1000 usuarios concurrentes sin degradación significativa del rendimiento.
4.2 Seguridad
RNF-05 - Encriptación de Datos: Todas las comunicaciones deben realizarse mediante HTTPS con certificado SSL/TLS válido. Las contraseñas deben almacenarse hasheadas con bcrypt.
RNF-06 - Autenticación Segura: El sistema debe implementar tokens JWT con firma HMAC-SHA256. Los tokens deben incluir fecha de expiración.
RNF-07 - Protección contra Ataques: El backend debe implementar rate limiting de 100 peticiones por minuto por IP, protección contra SQL injection y validación de entrada.
RNF-08 - Privacidad de Datos: Las entradas de diario y datos emocionales deben estar encriptados en reposo. Los usuarios deben poder solicitar eliminación completa de su cuenta.
4.3 Escalabilidad
RNF-09 - Arquitectura Escalable: El backend debe diseñarse con arquitectura stateless que permita agregar instancias de servidor adicionales sin modificar código.
RNF-10 - Almacenamiento: El sistema de almacenamiento de archivos de audio en AWS S3 debe configurarse con CDN CloudFront para distribución global eficiente.
RNF-11 - Crecimiento de Datos: La base de datos debe poder crecer hasta 100GB sin impacto en rendimiento.
4.4 Disponibilidad y Confiabilidad
RNF-12 - Uptime: El sistema debe mantener disponibilidad del 99.5% mensual, excluyendo ventanas de mantenimiento programadas.
RNF-13 - Respaldos: MongoDB Atlas debe configurarse con respaldos automáticos diarios con retención de 7 días.
RNF-14 - Recuperación ante Desastres: El sistema debe incluir plan de recuperación documentado con RTO de 4 horas y RPO de 24 horas.
RNF-15 - Manejo de Errores: La aplicación debe manejar errores de red y servidor con mensajes informativos al usuario.
 
5. Arquitectura del Sistema
La arquitectura del sistema MindFlow sigue un modelo cliente-servidor con separación clara entre frontend, backend y servicios externos. La aplicación Flutter multiplataforma se comunica con un backend API REST desarrollado en Node.js, el cual interactúa con MongoDB Atlas para persistencia de datos, AWS S3 para almacenamiento de archivos de audio y OpenAI API para procesamiento de inteligencia artificial.
5.1 Capas de la Arquitectura
•	Capa de Presentación:
•	Aplicación Flutter compilada nativamente para Android, iOS y Web
•	Gestión de estado mediante Provider o Riverpod
•	Almacenamiento local con SharedPreferences para cache
•	Navegación mediante Navigator 2.0 con rutas nombradas
•	Capa de Lógica de Negocio:
•	Backend API REST en Node.js con Express.js
•	Arquitectura en capas: Controladores, Servicios, Modelos
•	Middleware para autenticación JWT, validación y manejo de errores
•	Integración con servicios externos mediante adaptadores
•	Capa de Datos:
•	MongoDB Atlas en cluster compartido (M10) con réplicas
•	Mongoose como ODM para modelado de datos y validaciones
•	Índices optimizados en campos de búsqueda frecuente
•	Servicios Externos:
•	AWS S3: Almacenamiento de archivos de audio de meditación
•	OpenAI API: Análisis de sentimientos, generación de insights
•	Stripe API: Procesamiento de pagos y gestión de suscripciones
•	Firebase Cloud Messaging: Envío de notificaciones push
•	Google OAuth: Autenticación mediante cuentas de Google
 
6. Stack Tecnológico Completo
6.1 Frontend - Flutter
Flutter SDK 3.16+ con Dart 3.2+ como lenguaje principal. Provider/Riverpod para gestión de estado, http/dio para networking, just_audio para reproducción de audio, firebase_messaging para notificaciones push, fl_chart para visualización de datos.
6.2 Backend - Node.js
Node.js 18 LTS con Express.js 4.18+ como framework web. Mongoose 8.1+ como ODM para MongoDB. jsonwebtoken para autenticación JWT, bcrypt para hashing de contraseñas, joi para validación de esquemas. AWS SDK para integración con servicios AWS, OpenAI SDK oficial, Stripe SDK para pagos.
6.3 Base de Datos
MongoDB 7.0+ hospedado en MongoDB Atlas con cluster M10 en región us-east-1. Configuración con 3 nodos para alta disponibilidad, respaldos automáticos diarios y alertas de monitoreo.
6.4 Infraestructura AWS
EC2 t3.medium con Ubuntu Server 22.04 LTS para backend. PM2 5.3+ como process manager. Nginx 1.24+ como proxy reverso. AWS S3 con bucket privado para almacenamiento de audio. CloudFront como CDN para distribución global. Route 53 para gestión DNS. Certificados SSL con Let's Encrypt.
6.5 Servicios Externos
OpenAI API (GPT-4) para análisis de sentimientos e insights. Stripe para procesamiento de pagos y suscripciones. Firebase para notificaciones push. Google Cloud para OAuth. Sentry para tracking de errores.
 
7. Modelo de Datos MongoDB
7.1 Colección: users

{
  _id: ObjectId,
  email: String (único, requerido),
  password: String (hasheado),
  name: String (requerido),
  profilePicture: String (URL),
  authProvider: String (enum: ['email', 'google']),
  googleId: String (único),
  subscription: {
    plan: String (enum: ['free', 'premium']),
    status: String,
    startDate: Date,
    endDate: Date,
    stripeCustomerId: String
  },
  preferences: {
    notificationsEnabled: Boolean,
    meditationReminder: { enabled: Boolean, time: String },
    moodReminder: { enabled: Boolean, time: String }
  },
  stats: {
    totalMeditations: Number,
    totalMeditationTime: Number,
    consecutiveDays: Number,
    journalEntries: Number
  },
  createdAt: Date,
  updatedAt: Date
}

7.2 Colección: meditations

{
  _id: ObjectId,
  title: String (requerido),
  description: String,
  category: String (enum: ['anxiety', 'stress', 'sleep', 'focus', ...]),
  duration: Number (segundos),
  difficulty: String (enum: ['beginner', 'intermediate', 'advanced']),
  audioUrl: String (S3 key),
  thumbnailUrl: String,
  isPremium: Boolean,
  tags: [String],
  instructor: String,
  plays: Number,
  averageRating: Number,
  isActive: Boolean,
  createdAt: Date
}

7.3 Colección: journal_entries

{
  _id: ObjectId,
  userId: ObjectId (ref: 'users'),
  title: String,
  content: String (máx 5000 chars),
  mood: String (enum: ['very-bad', 'bad', 'neutral', 'good', 'very-good']),
  aiAnalysis: {
    status: String (enum: ['pending', 'processing', 'completed', 'error']),
    sentiment: {
      overall: String (enum: ['negative', 'neutral', 'positive']),
      score: Number (-1 a 1),
      emotions: [{ emotion: String, confidence: Number }]
    },
    themes: [String],
    insights: String,
    processedAt: Date
  },
  createdAt: Date,
  updatedAt: Date
}

7.4 Colección: mood_logs

{
  _id: ObjectId,
  userId: ObjectId (ref: 'users'),
  date: Date (solo fecha),
  mood: Number (1-10),
  emotions: [String],
  notes: String (máx 500 chars),
  createdAt: Date
}

 
8. Especificación de API REST
Base URL: https://api.mindflow.com/api/v1
Formato de Respuesta: JSON
Autenticación: JWT Bearer Token en header Authorization
8.1 Endpoints de Autenticación
POST /auth/register: Registra un nuevo usuario con email y contraseña
POST /auth/login: Inicia sesión con credenciales existentes
POST /auth/google: Autenticación mediante Google OAuth
POST /auth/forgot-password: Solicita enlace de recuperación de contraseña
POST /auth/reset-password: Restablece contraseña con token de recuperación
8.2 Endpoints de Usuario
GET /users/profile: Obtiene perfil del usuario autenticado
PUT /users/profile: Actualiza información del perfil
GET /users/stats: Obtiene estadísticas del usuario
PUT /users/preferences: Actualiza preferencias de notificaciones
8.3 Endpoints de Meditaciones
GET /meditations: Lista todas las meditaciones disponibles para el usuario
GET /meditations/:id: Obtiene detalles de una meditación específica
GET /meditations/:id/stream: Obtiene URL firmada de S3 para streaming de audio
POST /meditations/:id/complete: Registra sesión de meditación completada
GET /meditations/favorites: Lista meditaciones favoritas del usuario
POST /meditations/:id/favorite: Marca meditación como favorita
DELETE /meditations/:id/favorite: Elimina meditación de favoritos
8.4 Endpoints de Diario Emocional
GET /journal/entries: Lista entradas de diario del usuario
POST /journal/entries: Crea nueva entrada de diario con análisis de IA
GET /journal/entries/:id: Obtiene detalles de una entrada específica
PUT /journal/entries/:id: Actualiza entrada existente (dispara nuevo análisis)
DELETE /journal/entries/:id: Elimina entrada de diario
GET /journal/insights/weekly: Genera insights semanales basados en entradas
8.5 Endpoints de Estado de Ánimo
GET /mood/logs: Obtiene registros de estado de ánimo
POST /mood/logs: Registra estado de ánimo diario
GET /mood/trends: Obtiene análisis de tendencias emocionales
8.6 Endpoints de Suscripción
POST /subscriptions/create-checkout: Crea sesión de checkout de Stripe para suscripción
POST /subscriptions/webhook: Webhook de Stripe para eventos de suscripción
POST /subscriptions/cancel: Cancela suscripción premium
GET /subscriptions/status: Obtiene estado actual de la suscripción
 
9. Configuración de Infraestructura AWS
9.1 Configuración de Instancia EC2
•	Tipo: t3.medium (2 vCPU, 4 GB RAM)
•	Sistema Operativo: Ubuntu Server 22.04 LTS
•	Región: us-east-1 (N. Virginia)
•	Almacenamiento: 30 GB SSD gp3
•	Grupo de Seguridad: Puertos 80, 443, 22 abiertos
9.2 Pasos de Configuración Inicial
Actualizar sistema: 
sudo apt update && sudo apt upgrade -y
Instalar Node.js 18 LTS: 
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
Instalar PM2: 
sudo npm install -g pm2
Instalar Nginx: 
sudo apt install nginx -y
Instalar Certbot: 
sudo apt install certbot python3-certbot-nginx -y
Configurar certificado SSL: 
sudo certbot --nginx -d api.mindflow.com
Clonar repositorio: 
git clone https://github.com/usuario/mindflow-backend.git
cd mindflow-backend
npm install
Configurar variables de entorno: 
Crear archivo .env con todas las credenciales necesarias
Iniciar con PM2: 
pm2 start npm --name "mindflow-backend" -- start
pm2 save
pm2 startup
9.3 Configuración de AWS S3
Crear bucket "mindflow-audio" en us-east-1
Bloquear acceso público y habilitar versionamiento
Configurar encriptación AES-256 (SSE-S3)
Estructura de carpetas: /anxiety/, /stress/, /sleep/, /focus/, /general/
9.4 Configuración de CloudFront CDN
Crear distribución con origen en bucket S3
Configurar comportamiento de cache con TTL de 3600 segundos
Asociar certificado SSL de AWS Certificate Manager
CNAME alternativo: cdn.mindflow.com
 
10. Roadmap de Desarrollo por Sprints
El desarrollo del proyecto se estructura en 4 sprints de 3 semanas cada uno, con enfoque iterativo e incremental. Cada sprint culmina con una versión funcional y desplegable del sistema.
Sprint 1: Fundamentos y Autenticación (Semanas 1-3)
Backend:
•	Configurar proyecto Node.js con Express y estructura de carpetas
•	Implementar conexión a MongoDB Atlas con Mongoose
•	Crear modelos de datos: User, Meditation
•	Implementar sistema de autenticación JWT
•	Desarrollar endpoints de registro y login con email
•	Integrar Google OAuth para autenticación
•	Implementar recuperación de contraseña
•	Configurar middleware de autenticación y validación
Frontend Flutter:
•	Configurar proyecto Flutter con estructura limpia
•	Implementar sistema de navegación con go_router
•	Configurar gestión de estado con Provider/Riverpod
•	Diseñar pantallas de onboarding
•	Crear pantallas de registro y login
•	Integrar Google Sign In
•	Desarrollar pantalla de perfil
•	Crear sistema de temas y diseño visual base
Infraestructura:
•	Configurar instancia EC2 en AWS
•	Instalar Node.js, PM2 y Nginx
•	Configurar certificado SSL
•	Configurar MongoDB Atlas
•	Desplegar primera versión del backend
Sprint 2: Biblioteca de Meditaciones (Semanas 4-6)
•	Configurar bucket S3 y CloudFront
•	Implementar generación de URLs firmadas
•	Crear endpoints de meditaciones
•	Implementar reproductor de audio en Flutter
•	Desarrollar sistema de favoritos
•	Subir contenido inicial de meditaciones
•	Implementar restricciones de contenido premium
Sprint 3: Diario Emocional con IA (Semanas 7-9)
•	Configurar integración con OpenAI API
•	Crear modelo JournalEntry con análisis IA
•	Implementar endpoints CRUD de diario
•	Desarrollar servicio de análisis de sentimientos
•	Crear modelo MoodLog
•	Implementar gráficas de tendencias
•	Desarrollar calendario emocional
•	Crear generador de insights semanales
Sprint 4: Dashboard, Suscripciones y Publicación (Semanas 10-12)
•	Configurar integración con Stripe
•	Implementar endpoints de suscripción
•	Desarrollar dashboard de estadísticas
•	Crear sistema de logros
•	Configurar Firebase Cloud Messaging
•	Implementar notificaciones push
•	Testing exhaustivo de todos los flujos
•	Generar builds de producción
•	Preparar assets para stores
•	Publicar en Google Play Store
•	Publicar en Apple App Store
•	Configurar GitHub Actions para CI/CD
 
11. Conclusiones y Próximos Pasos
Este documento técnico proporciona una hoja de ruta completa para el desarrollo de MindFlow, desde la concepción inicial hasta la publicación en las tiendas de aplicaciones. La arquitectura propuesta permite escalabilidad futura, mientras que el roadmap por sprints garantiza entregas incrementales de valor.
11.1 Consideraciones Técnicas Importantes
Seguridad: Mantener credenciales en variables de entorno. Implementar rate limiting y validación exhaustiva.
Rendimiento: Monitorear tiempos de respuesta del API. Optimizar queries con índices apropiados.
Costos de IA: El uso de OpenAI genera costos variables. Implementar límites razonables en plan gratuito.
Contenido de Meditación: La calidad del audio es crítica. Considerar text-to-speech de alta calidad o narradores profesionales.
Testing: Realizar pruebas exhaustivas en múltiples dispositivos antes de cada despliegue.
11.2 Roadmap Post-Lanzamiento
•	Funcionalidades sociales: grupos de práctica y conexión con amigos
•	Personalización avanzada con machine learning
•	Integración con wearables (Apple Watch, Fitbit)
•	Meditaciones en vivo con instructores certificados
•	Programas estructurados de múltiples semanas
•	Internacionalización a inglés, portugués y otros idiomas
•	Canal B2B para terapeutas
11.3 Métricas de Éxito
Objetivos para el primer mes:
•	500 descargas totales
•	100 usuarios activos diarios
•	2-3% tasa de conversión freemium → premium
•	30% tasa de retención día 7
Objetivos para el primer trimestre:
•	5,000 descargas totales
•	1,000 usuarios activos diarios
•	5-7% tasa de conversión
•	40% tasa de retención día 7
•	25% tasa de retención día 30
11.4 Reflexión Final
MindFlow tiene el potencial de impactar positivamente la salud mental de miles de usuarios al democratizar el acceso a herramientas de bienestar emocional. El mercado está validado, la tecnología es accesible y el modelo de negocio es sostenible. El éxito dependerá de la ejecución consistente del plan de desarrollo, la calidad del contenido de meditación y la capacidad de iterar basándose en feedback de usuarios reales.
 
12. Anexos
12.1 Glosario de Términos Técnicos
API REST: Interfaz de programación de aplicaciones que utiliza peticiones HTTP para operaciones CRUD
JWT: JSON Web Token - estándar para tokens de autenticación seguros y compactos
ODM: Object Document Mapper - capa de abstracción entre código y base de datos NoSQL
CDN: Content Delivery Network - red de servidores distribuidos para entrega rápida de contenido
OAuth: Protocolo estándar de autorización para acceso delegado seguro
SSL/TLS: Protocolos de seguridad para encriptación de comunicaciones en internet
CI/CD: Integración continua y despliegue continuo - prácticas de automatización de desarrollo
Freemium: Modelo de negocio con versión gratuita básica y versión premium de pago
Sprint: Período de tiempo fijo para completar trabajo en metodologías ágiles
Middleware: Software que actúa como puente entre sistema operativo y aplicaciones
Webhook: Método para que aplicación envíe información a otra en tiempo real
Rate Limiting: Técnica para controlar tráfico limitando número de peticiones por período
12.2 Variables de Entorno Requeridas

# Configuración General
NODE_ENV=production
PORT=3000

# Base de Datos
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/mindflow

# Autenticación
JWT_SECRET=clave_secreta_muy_segura
JWT_EXPIRE=7d

# AWS
AWS_ACCESS_KEY_ID=AKIAXXXXXXXXXXXXXXXX
AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxx
AWS_REGION=us-east-1
S3_BUCKET_NAME=mindflow-audio

# OpenAI
OPENAI_API_KEY=sk-xxxxxxxxxxxxxxxx
OPENAI_MODEL=gpt-4

# Stripe
STRIPE_SECRET_KEY=sk_live_xxxxxxxxxxxxxxxx
STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxxxxx

# Google OAuth
GOOGLE_CLIENT_ID=xxxxxxxxxxxx.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=xxxxxxxxxxxxxxxx

# Firebase
FIREBASE_SERVER_KEY=AAAAxxxxxxxx

# Email
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=noreply@mindflow.com
SMTP_PASS=xxxxxxxxxxxxxxxx

# Frontend URL
FRONTEND_URL=https://mindflow.com

12.3 Estructura de Directorios
Backend:

mindflow-backend/
├── src/
│   ├── config/
│   ├── controllers/
│   ├── models/
│   ├── routes/
│   ├── middleware/
│   ├── services/
│   ├── utils/
│   └── app.js
├── tests/
├── .env
├── package.json
└── README.md

Frontend Flutter:

mindflow-mobile/
├── lib/
│   ├── core/
│   ├── data/
│   ├── domain/
│   ├── presentation/
│   │   ├── screens/
│   │   └── widgets/
│   └── main.dart
├── test/
├── android/
├── ios/
├── web/
├── assets/
└── pubspec.yaml

 
Fin del Documento
MindFlow - Especificación Técnica de Requerimientos v1.0
Noviembre 2025
