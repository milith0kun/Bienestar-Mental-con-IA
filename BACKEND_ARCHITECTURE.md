# 🏗️ MindFlow - Arquitectura Completa del Backend

**Documento de Referencia Técnica**
**Versión:** 2.0
**Fecha:** Noviembre 2024
**Estado:** Guía de Implementación para Sprints 2-4

---

## 📋 Tabla de Contenidos

1. [Estado Actual del Backend](#estado-actual-del-backend)
2. [Arquitectura General](#arquitectura-general)
3. [Estructura de Directorios Completa](#estructura-de-directorios-completa)
4. [Capas de la Arquitectura](#capas-de-la-arquitectura)
5. [Modelos de Datos](#modelos-de-datos)
6. [Controladores](#controladores)
7. [Servicios](#servicios)
8. [Middleware](#middleware)
9. [Rutas y Endpoints](#rutas-y-endpoints)
10. [Integración con Servicios Externos](#integración-con-servicios-externos)
11. [Manejo de Errores](#manejo-de-errores)
12. [Seguridad](#seguridad)
13. [Testing](#testing)
14. [Roadmap de Implementación](#roadmap-de-implementación)

---

## 📊 Estado Actual del Backend

### ✅ Completado (Sprint 1)

**Modelos:**
- ✅ User.model.js - Completo con autenticación, subscripción, preferencias
- ✅ Meditation.model.js - Preparado para Sprint 2
- ✅ JournalEntry.model.js - Preparado para Sprint 3
- ✅ MoodLog.model.js - Preparado para Sprint 3

**Controladores:**
- ✅ auth.controller.js - 6 endpoints (register, login, google, forgot, reset, refresh)
- ✅ user.controller.js - 7 endpoints (profile, stats, preferences, fcm, delete)

**Middleware:**
- ✅ auth.js - protect, requirePremium, optionalAuth
- ✅ errorHandler.js - Manejo centralizado de errores
- ✅ validation.js - Validación con Joi
- ✅ notFound.js - Manejo de rutas 404

**Servicios:**
- ✅ email.service.js - Welcome, password reset, password changed

**Utilidades:**
- ✅ jwt.js - generateToken, generateRefreshToken, verify
- ✅ crypto.js - generateResetToken, hashResetToken

**Configuración:**
- ✅ config/index.js - Configuración centralizada
- ✅ config/database.js - Conexión MongoDB

**Infraestructura:**
- ✅ app.js - Aplicación Express configurada
- ✅ server.js - Servidor HTTP
- ✅ Tests completos (40 tests, 75% cobertura)

### 🚧 Pendiente

**Sprint 2 - Meditaciones:**
- ❌ meditation.controller.js
- ❌ s3.service.js
- ❌ meditation.service.js

**Sprint 3 - IA y Emociones:**
- ❌ journal.controller.js
- ❌ mood.controller.js
- ❌ openai.service.js
- ❌ analysis.service.js

**Sprint 4 - Suscripciones:**
- ❌ subscription.controller.js
- ❌ stripe.service.js
- ❌ notification.service.js
- ❌ fcm.service.js

---

## 🏛️ Arquitectura General

### Patrón de Arquitectura: MVC en Capas

```
┌─────────────────────────────────────────────────────────┐
│                    FLUTTER CLIENT                        │
│                  (iOS, Android, Web)                     │
└─────────────────────────────────────────────────────────┘
                            │
                            │ HTTPS / JWT
                            ▼
┌─────────────────────────────────────────────────────────┐
│                    NGINX (Proxy)                         │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                  EXPRESS.JS BACKEND                      │
│ ┌─────────────────────────────────────────────────────┐ │
│ │  MIDDLEWARE LAYER                                   │ │
│ │  • Authentication (JWT)                             │ │
│ │  • Validation (Joi)                                 │ │
│ │  • Rate Limiting                                    │ │
│ │  • Error Handling                                   │ │
│ └─────────────────────────────────────────────────────┘ │
│                            │                             │
│ ┌─────────────────────────────────────────────────────┐ │
│ │  ROUTES LAYER                                       │ │
│ │  /auth  /users  /meditations  /journal  /mood       │ │
│ └─────────────────────────────────────────────────────┘ │
│                            │                             │
│ ┌─────────────────────────────────────────────────────┐ │
│ │  CONTROLLERS LAYER                                  │ │
│ │  • Request validation                               │ │
│ │  • Call services                                    │ │
│ │  • Format responses                                 │ │
│ └─────────────────────────────────────────────────────┘ │
│                            │                             │
│ ┌─────────────────────────────────────────────────────┐ │
│ │  SERVICES LAYER                                     │ │
│ │  • Business logic                                   │ │
│ │  • External API calls                               │ │
│ │  • Data processing                                  │ │
│ └─────────────────────────────────────────────────────┘ │
│                            │                             │
│ ┌─────────────────────────────────────────────────────┐ │
│ │  MODELS LAYER (Mongoose)                            │ │
│ │  • Schema definitions                               │ │
│ │  • Validation rules                                 │ │
│ │  • Instance methods                                 │ │
│ └─────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        ▼                   ▼                   ▼
┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│  MongoDB     │   │   AWS S3     │   │  OpenAI API  │
│   Atlas      │   │  CloudFront  │   │   Stripe     │
└──────────────┘   └──────────────┘   └──────────────┘
```

### Principios de Diseño

1. **Separación de Responsabilidades**: Cada capa tiene un propósito único
2. **Inyección de Dependencias**: Servicios configurables y testables
3. **Stateless**: Sin sesiones en memoria, todo en JWT
4. **API REST**: Endpoints RESTful siguiendo convenciones
5. **Error Handling**: Manejo centralizado con códigos HTTP apropiados
6. **Validación**: Validación exhaustiva en middleware antes de controladores
7. **Seguridad**: JWT, bcrypt, helmet, rate limiting
8. **Escalabilidad**: Diseño preparado para múltiples instancias

---

## 📁 Estructura de Directorios Completa

```
backend/
├── src/
│   ├── config/                      # Configuración
│   │   ├── index.js                 # ✅ Config centralizada
│   │   └── database.js              # ✅ Conexión MongoDB
│   │
│   ├── models/                      # Modelos Mongoose
│   │   ├── User.model.js            # ✅ Usuario
│   │   ├── Meditation.model.js      # ✅ Meditación
│   │   ├── JournalEntry.model.js    # ✅ Entrada de diario
│   │   ├── MoodLog.model.js         # ✅ Registro de ánimo
│   │   └── Subscription.model.js    # 🔜 Suscripción (opcional)
│   │
│   ├── controllers/                 # Controladores
│   │   ├── auth.controller.js       # ✅ Autenticación
│   │   ├── user.controller.js       # ✅ Usuarios
│   │   ├── meditation.controller.js # ❌ Sprint 2
│   │   ├── journal.controller.js    # ❌ Sprint 3
│   │   ├── mood.controller.js       # ❌ Sprint 3
│   │   └── subscription.controller.js # ❌ Sprint 4
│   │
│   ├── services/                    # Servicios
│   │   ├── email.service.js         # ✅ Email
│   │   ├── s3.service.js            # ❌ Sprint 2 - AWS S3
│   │   ├── meditation.service.js    # ❌ Sprint 2 - Lógica meditaciones
│   │   ├── openai.service.js        # ❌ Sprint 3 - OpenAI API
│   │   ├── analysis.service.js      # ❌ Sprint 3 - Análisis IA
│   │   ├── stripe.service.js        # ❌ Sprint 4 - Stripe
│   │   └── notification.service.js  # ❌ Sprint 4 - Push notifications
│   │
│   ├── middleware/                  # Middleware
│   │   ├── auth.js                  # ✅ Autenticación JWT
│   │   ├── validation.js            # ✅ Validación Joi
│   │   ├── errorHandler.js          # ✅ Manejo de errores
│   │   ├── notFound.js              # ✅ Rutas 404
│   │   └── upload.js                # ❌ Sprint 2 - Multer upload
│   │
│   ├── routes/                      # Rutas
│   │   ├── auth.routes.js           # ✅ /auth
│   │   ├── user.routes.js           # ✅ /users
│   │   ├── meditation.routes.js     # 🚧 /meditations (placeholder)
│   │   ├── journal.routes.js        # 🚧 /journal (placeholder)
│   │   ├── mood.routes.js           # 🚧 /mood (placeholder)
│   │   └── subscription.routes.js   # 🚧 /subscriptions (placeholder)
│   │
│   ├── utils/                       # Utilidades
│   │   ├── jwt.js                   # ✅ JWT helpers
│   │   ├── crypto.js                # ✅ Crypto helpers
│   │   └── logger.js                # ❌ Winston logger
│   │
│   ├── validators/                  # Esquemas de validación
│   │   ├── auth.validator.js        # ✅ Validación auth
│   │   ├── user.validator.js        # ✅ Validación user
│   │   ├── meditation.validator.js  # ❌ Sprint 2
│   │   ├── journal.validator.js     # ❌ Sprint 3
│   │   └── mood.validator.js        # ❌ Sprint 3
│   │
│   ├── app.js                       # ✅ Express app
│   └── server.js                    # ✅ HTTP server
│
├── tests/                           # Tests
│   ├── setup.js                     # ✅ Setup global
│   ├── auth.test.js                 # ✅ Tests auth
│   ├── user.test.js                 # ✅ Tests user
│   ├── models.test.js               # ✅ Tests models
│   ├── meditation.test.js           # ❌ Sprint 2
│   ├── journal.test.js              # ❌ Sprint 3
│   ├── mood.test.js                 # ❌ Sprint 3
│   └── integration/                 # ❌ Tests integración
│
├── scripts/                         # Scripts utilidad
│   ├── seed.js                      # ✅ Seed database
│   └── migrate.js                   # ❌ Migraciones
│
├── .env                             # ✅ Variables de entorno
├── .env.example                     # ✅ Template
├── .gitignore                       # ✅ Git ignore
├── package.json                     # ✅ Dependencies
├── jest.config.js                   # ✅ Jest config
└── README.md                        # ✅ API docs
```

---

## 🧱 Capas de la Arquitectura

### 1. Capa de Rutas (Routes Layer)

**Responsabilidad**: Mapear URLs a controladores

```javascript
// Estructura de un archivo de rutas
const express = require('express');
const router = express.Router();
const controller = require('../controllers/ejemplo.controller');
const { protect, requirePremium } = require('../middleware/auth');
const { validate } = require('../middleware/validation');
const validators = require('../validators/ejemplo.validator');

// Rutas públicas
router.post('/public', validate(validators.create), controller.publicAction);

// Rutas protegidas
router.use(protect); // Todas las rutas después requieren auth

router.get('/', controller.list);
router.get('/:id', controller.getById);
router.post('/', validate(validators.create), controller.create);
router.put('/:id', validate(validators.update), controller.update);
router.delete('/:id', controller.delete);

// Rutas premium
router.get('/premium-only', requirePremium, controller.premiumAction);

module.exports = router;
```

### 2. Capa de Controladores (Controllers Layer)

**Responsabilidad**: Procesar peticiones, delegar a servicios, formatear respuestas

**Patrón estándar de controlador:**

```javascript
const Service = require('../services/ejemplo.service');

// Listar recursos
exports.list = async (req, res, next) => {
  try {
    // 1. Extraer parámetros
    const { page = 1, limit = 10, category } = req.query;
    const userId = req.user.id;

    // 2. Llamar servicio
    const result = await Service.list({
      userId,
      page: parseInt(page),
      limit: parseInt(limit),
      category,
    });

    // 3. Formatear respuesta
    res.status(200).json({
      success: true,
      data: result.items,
      pagination: {
        page: result.page,
        limit: result.limit,
        total: result.total,
        pages: result.pages,
      },
    });
  } catch (error) {
    next(error); // Delegar al errorHandler
  }
};

// Obtener por ID
exports.getById = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const item = await Service.getById(id, userId);

    if (!item) {
      return res.status(404).json({
        success: false,
        message: 'Recurso no encontrado',
      });
    }

    res.status(200).json({
      success: true,
      data: { item },
    });
  } catch (error) {
    next(error);
  }
};

// Crear
exports.create = async (req, res, next) => {
  try {
    const data = req.body;
    const userId = req.user.id;

    const item = await Service.create({ ...data, userId });

    res.status(201).json({
      success: true,
      message: 'Recurso creado exitosamente',
      data: { item },
    });
  } catch (error) {
    next(error);
  }
};

// Actualizar
exports.update = async (req, res, next) => {
  try {
    const { id } = req.params;
    const data = req.body;
    const userId = req.user.id;

    const item = await Service.update(id, userId, data);

    res.status(200).json({
      success: true,
      message: 'Recurso actualizado exitosamente',
      data: { item },
    });
  } catch (error) {
    next(error);
  }
};

// Eliminar
exports.delete = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    await Service.delete(id, userId);

    res.status(200).json({
      success: true,
      message: 'Recurso eliminado exitosamente',
    });
  } catch (error) {
    next(error);
  }
};
```

### 3. Capa de Servicios (Services Layer)

**Responsabilidad**: Lógica de negocio, interacción con modelos, llamadas a APIs externas

**Patrón estándar de servicio:**

```javascript
const Model = require('../models/Ejemplo.model');

class ExampleService {
  async list({ userId, page, limit, category }) {
    const skip = (page - 1) * limit;

    const query = { userId };
    if (category) {
      query.category = category;
    }

    const [items, total] = await Promise.all([
      Model.find(query)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .lean(),
      Model.countDocuments(query),
    ]);

    return {
      items,
      page,
      limit,
      total,
      pages: Math.ceil(total / limit),
    };
  }

  async getById(id, userId) {
    const item = await Model.findOne({ _id: id, userId });
    return item;
  }

  async create(data) {
    const item = await Model.create(data);
    return item;
  }

  async update(id, userId, data) {
    const item = await Model.findOneAndUpdate(
      { _id: id, userId },
      data,
      { new: true, runValidators: true }
    );

    if (!item) {
      throw new Error('Recurso no encontrado');
    }

    return item;
  }

  async delete(id, userId) {
    const item = await Model.findOneAndDelete({ _id: id, userId });

    if (!item) {
      throw new Error('Recurso no encontrado');
    }

    return item;
  }
}

module.exports = new ExampleService();
```

### 4. Capa de Modelos (Models Layer)

**Responsabilidad**: Esquemas, validaciones, métodos de instancia

**Estructura estándar de modelo:**

```javascript
const mongoose = require('mongoose');

const exampleSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    title: {
      type: String,
      required: [true, 'El título es requerido'],
      trim: true,
      maxlength: [100, 'El título no puede exceder 100 caracteres'],
    },
    status: {
      type: String,
      enum: ['active', 'inactive', 'archived'],
      default: 'active',
    },
    metadata: {
      type: Map,
      of: String,
    },
  },
  {
    timestamps: true, // createdAt, updatedAt
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Índices compuestos
exampleSchema.index({ userId: 1, createdAt: -1 });

// Índice de texto para búsqueda
exampleSchema.index({ title: 'text', description: 'text' });

// Virtual property
exampleSchema.virtual('isActive').get(function () {
  return this.status === 'active';
});

// Métodos de instancia
exampleSchema.methods.archive = function () {
  this.status = 'archived';
  return this.save();
};

// Métodos estáticos
exampleSchema.statics.findActive = function () {
  return this.find({ status: 'active' });
};

// Hooks
exampleSchema.pre('save', function (next) {
  // Lógica antes de guardar
  next();
});

exampleSchema.post('save', function (doc, next) {
  // Lógica después de guardar
  next();
});

module.exports = mongoose.model('Example', exampleSchema);
```

---

## 📦 Modelos de Datos

### User Model (✅ Implementado)

**Archivo**: `src/models/User.model.js`

**Campos principales:**
- email, password, name, profilePicture
- authProvider, googleId
- subscription: { plan, status, startDate, endDate, stripeCustomerId }
- preferences: { notificationsEnabled, meditationReminder, moodReminder }
- stats: { totalMeditations, totalMeditationTime, consecutiveDays, journalEntries }
- fcmTokens: [String]

**Métodos:**
- `comparePassword(candidatePassword)`: Verifica contraseña
- `isPremium()`: Retorna true si usuario es premium
- `canCreateJournalEntry()`: Verifica límite de plan gratuito
- `resetMonthlyJournalCount()`: Reset mensual de entradas

### Meditation Model (✅ Preparado)

**Archivo**: `src/models/Meditation.model.js`

**Campos:**
- title, description, category, duration
- difficulty, audioUrl, thumbnailUrl
- isPremium, tags, instructor
- plays, averageRating, isActive

**Métodos:**
- `incrementPlays()`: Incrementa contador de reproducciones
- `updateRating(newRating)`: Actualiza rating promedio

### JournalEntry Model (✅ Preparado)

**Archivo**: `src/models/JournalEntry.model.js`

**Campos:**
- userId (ref User)
- title, content, mood
- aiAnalysis: { status, sentiment, themes, insights, processedAt }

**Métodos:**
- `startProcessing()`: Marca como "processing"
- `saveAnalysis(analysisData)`: Guarda resultados de IA
- `markAnalysisError(error)`: Marca error en análisis

### MoodLog Model (✅ Preparado)

**Archivo**: `src/models/MoodLog.model.js`

**Campos:**
- userId (ref User)
- date (solo fecha, sin hora)
- mood (1-10)
- emotions: [String]
- notes

**Índices:**
- Compound unique: (userId, date) - Solo 1 registro por día

**Métodos estáticos:**
- `getByDateRange(userId, startDate, endDate)`: Obtiene logs de rango
- `getAverageMood(userId, days)`: Promedio de últimos N días
- `getTrend(userId, days)`: Analiza tendencia (subiendo/bajando/estable)

---

## 🎮 Controladores

### ✅ auth.controller.js (Implementado)

**Endpoints:**
- `register(req, res)`: Registro con email/password
- `login(req, res)`: Login con credenciales
- `googleAuth(req, res)`: Login con Google OAuth
- `forgotPassword(req, res)`: Solicita reset de password
- `resetPassword(req, res)`: Reset con token
- `refreshToken(req, res)`: Renueva access token

### ✅ user.controller.js (Implementado)

**Endpoints:**
- `getProfile(req, res)`: Obtiene perfil
- `updateProfile(req, res)`: Actualiza nombre/foto
- `getStats(req, res)`: Estadísticas del usuario
- `updatePreferences(req, res)`: Actualiza preferencias
- `addFcmToken(req, res)`: Agrega token FCM
- `removeFcmToken(req, res)`: Elimina token FCM
- `deleteAccount(req, res)`: Elimina cuenta

### ❌ meditation.controller.js (Sprint 2)

**Debe implementar:**

```javascript
// GET /meditations
exports.list = async (req, res, next) => {
  // Lista meditaciones disponibles para el usuario
  // Filtros: category, difficulty, isPremium
  // Si user es free, solo muestra 5 meditaciones específicas
};

// GET /meditations/:id
exports.getById = async (req, res, next) => {
  // Obtiene detalles de meditación
  // Verifica si usuario tiene acceso (premium o free)
};

// GET /meditations/:id/stream
exports.getStreamUrl = async (req, res, next) => {
  // Genera URL firmada de S3 con expiración de 1 hora
  // Verifica acceso del usuario
  // Retorna URL y duración
};

// POST /meditations/:id/complete
exports.completeMeditation = async (req, res, next) => {
  // Registra sesión completada
  // Actualiza stats del usuario (totalMeditations, totalMeditationTime)
  // Actualiza consecutiveDays si aplica
  // Incrementa plays de la meditación
};

// GET /meditations/favorites
exports.getFavorites = async (req, res, next) => {
  // Lista meditaciones favoritas del usuario
  // Populado completo de datos
};

// POST /meditations/:id/favorite
exports.addToFavorites = async (req, res, next) => {
  // Agrega meditación a favoritos del usuario
  // Puede usar un array en User o colección separada
};

// DELETE /meditations/:id/favorite
exports.removeFromFavorites = async (req, res, next) => {
  // Elimina de favoritos
};

// GET /meditations/search (opcional)
exports.search = async (req, res, next) => {
  // Búsqueda por texto usando índice de texto
  // Retorna resultados ordenados por relevancia
};
```

### ❌ journal.controller.js (Sprint 3)

**Debe implementar:**

```javascript
// GET /journal/entries
exports.list = async (req, res, next) => {
  // Lista entradas de diario del usuario
  // Paginación, orden cronológico inverso
  // Incluye resultado de análisis IA
};

// POST /journal/entries
exports.create = async (req, res, next) => {
  // 1. Verifica límite de plan (free: 10/mes)
  // 2. Crea entrada con status 'pending'
  // 3. Dispara análisis de IA en background
  // 4. Retorna entrada creada
  // 5. Incrementa stats.journalEntries del usuario
};

// GET /journal/entries/:id
exports.getById = async (req, res, next) => {
  // Obtiene entrada específica
  // Verifica ownership (userId)
};

// PUT /journal/entries/:id
exports.update = async (req, res, next) => {
  // Actualiza título/contenido/mood
  // Dispara nuevo análisis de IA
  // Marca aiAnalysis.status como 'pending'
};

// DELETE /journal/entries/:id
exports.delete = async (req, res, next) => {
  // Elimina entrada
  // Decrementa stats.journalEntries
};

// GET /journal/insights/weekly
exports.getWeeklyInsights = async (req, res, next) => {
  // 1. Obtiene entradas de últimos 7 días
  // 2. Envía a OpenAI para generar insights
  // 3. Retorna análisis de tendencias, patrones, recomendaciones
};
```

### ❌ mood.controller.js (Sprint 3)

**Debe implementar:**

```javascript
// GET /mood/logs
exports.list = async (req, res, next) => {
  // Lista registros de ánimo del usuario
  // Query params: startDate, endDate (default: últimos 30 días)
  // Ordenado por fecha descendente
};

// POST /mood/logs
exports.create = async (req, res, next) => {
  // Registra estado de ánimo del día
  // Validación: solo 1 registro por día
  // Si ya existe, retorna error
  // Campos: mood (1-10), emotions[], notes
};

// GET /mood/trends
exports.getTrends = async (req, res, next) => {
  // Calcula tendencias emocionales
  // Query param: period (7, 30, 90 días)
  // Retorna:
  //   - Promedio de mood
  //   - Tendencia (subiendo/bajando/estable)
  //   - Emociones más frecuentes
  //   - Distribución por rangos de mood
  //   - Días con mejor/peor ánimo
};

// GET /mood/calendar
exports.getCalendar = async (req, res, next) => {
  // Retorna datos para calendario emocional
  // Query params: year, month
  // Formato: { "2024-11-01": { mood: 8, emotions: [...] } }
};
```

### ❌ subscription.controller.js (Sprint 4)

**Debe implementar:**

```javascript
// POST /subscriptions/create-checkout
exports.createCheckout = async (req, res, next) => {
  // 1. Crea sesión de checkout en Stripe
  // 2. Asocia con usuario actual
  // 3. Retorna URL de checkout
};

// POST /subscriptions/webhook
exports.webhook = async (req, res, next) => {
  // Webhook de Stripe para eventos:
  // - checkout.session.completed: Activar suscripción
  // - invoice.payment_succeeded: Renovación exitosa
  // - invoice.payment_failed: Pago fallido
  // - customer.subscription.deleted: Cancelación
  // IMPORTANTE: Verificar firma de Stripe
};

// POST /subscriptions/cancel
exports.cancel = async (req, res, next) => {
  // Cancela suscripción en Stripe
  // Actualiza estado en User
  // Suscripción permanece activa hasta fin de período
};

// GET /subscriptions/status
exports.getStatus = async (req, res, next) => {
  // Retorna estado actual de suscripción
  // Incluye: plan, status, fechas, próximo cobro
};

// POST /subscriptions/portal (opcional)
exports.getPortalUrl = async (req, res, next) => {
  // Genera URL del portal de cliente de Stripe
  // Permite al usuario gestionar su suscripción
};
```

---

## ⚙️ Servicios

### ✅ email.service.js (Implementado)

**Métodos:**
- `sendWelcomeEmail(email, name)`
- `sendPasswordResetEmail(email, resetUrl)`
- `sendPasswordChangedEmail(email)`

### ❌ s3.service.js (Sprint 2)

**Debe implementar:**

```javascript
const AWS = require('aws-sdk');
const config = require('../config');

const s3 = new AWS.S3({
  accessKeyId: config.aws.accessKeyId,
  secretAccessKey: config.aws.secretAccessKey,
  region: config.aws.region,
});

class S3Service {
  /**
   * Genera URL firmada para streaming de audio
   * @param {String} key - S3 object key (ej: 'anxiety/calma-ansiedad.mp3')
   * @param {Number} expiresIn - Expiración en segundos (default: 3600)
   * @returns {String} URL firmada
   */
  async getSignedUrl(key, expiresIn = 3600) {
    const params = {
      Bucket: config.aws.s3BucketName,
      Key: key,
      Expires: expiresIn,
    };

    return s3.getSignedUrlPromise('getObject', params);
  }

  /**
   * Sube archivo a S3
   * @param {Buffer} fileBuffer - Buffer del archivo
   * @param {String} key - Clave en S3
   * @param {String} contentType - MIME type
   * @returns {Object} Resultado del upload
   */
  async uploadFile(fileBuffer, key, contentType) {
    const params = {
      Bucket: config.aws.s3BucketName,
      Key: key,
      Body: fileBuffer,
      ContentType: contentType,
      ServerSideEncryption: 'AES256',
    };

    return s3.upload(params).promise();
  }

  /**
   * Elimina archivo de S3
   * @param {String} key - Clave del objeto
   */
  async deleteFile(key) {
    const params = {
      Bucket: config.aws.s3BucketName,
      Key: key,
    };

    return s3.deleteObject(params).promise();
  }

  /**
   * Obtiene metadata de archivo
   * @param {String} key - Clave del objeto
   * @returns {Object} Metadata
   */
  async getFileMetadata(key) {
    const params = {
      Bucket: config.aws.s3BucketName,
      Key: key,
    };

    return s3.headObject(params).promise();
  }
}

module.exports = new S3Service();
```

### ❌ meditation.service.js (Sprint 2)

**Debe implementar:**

```javascript
const Meditation = require('../models/Meditation.model');
const User = require('../models/User.model');
const s3Service = require('./s3.service');

class MeditationService {
  /**
   * Lista meditaciones con filtros y acceso según plan
   */
  async list(userId, filters) {
    const user = await User.findById(userId);
    const isPremium = user.isPremium();

    let query = { isActive: true };

    // Filtros
    if (filters.category) query.category = filters.category;
    if (filters.difficulty) query.difficulty = filters.difficulty;

    // Si es free, solo meditaciones gratuitas
    if (!isPremium) {
      query.isPremium = false;
    }

    const meditations = await Meditation.find(query)
      .sort({ plays: -1, createdAt: -1 })
      .select('-__v');

    return meditations;
  }

  /**
   * Obtiene URL de streaming con validación de acceso
   */
  async getStreamUrl(meditationId, userId) {
    const meditation = await Meditation.findById(meditationId);
    if (!meditation) {
      throw new Error('Meditación no encontrada');
    }

    const user = await User.findById(userId);

    // Verificar acceso
    if (meditation.isPremium && !user.isPremium()) {
      throw new Error('Esta meditación requiere suscripción premium');
    }

    // Generar URL firmada
    const streamUrl = await s3Service.getSignedUrl(
      meditation.audioUrl,
      3600
    );

    return {
      streamUrl,
      duration: meditation.duration,
      expiresIn: 3600,
    };
  }

  /**
   * Registra sesión completada y actualiza estadísticas
   */
  async completeMeditation(meditationId, userId, duration) {
    const meditation = await Meditation.findById(meditationId);
    if (!meditation) {
      throw new Error('Meditación no encontrada');
    }

    // Actualizar stats de usuario
    const user = await User.findById(userId);
    user.stats.totalMeditations += 1;
    user.stats.totalMeditationTime += duration;

    // Actualizar racha de días consecutivos
    // TODO: Implementar lógica de racha

    await user.save();

    // Incrementar plays de meditación
    await meditation.incrementPlays();

    return {
      totalMeditations: user.stats.totalMeditations,
      totalMeditationTime: user.stats.totalMeditationTime,
    };
  }

  /**
   * Gestiona favoritos
   */
  async toggleFavorite(meditationId, userId) {
    const user = await User.findById(userId);

    // Agregar array de favoritos al modelo User si no existe
    if (!user.favoriteMeditations) {
      user.favoriteMeditations = [];
    }

    const index = user.favoriteMeditations.indexOf(meditationId);

    if (index === -1) {
      user.favoriteMeditations.push(meditationId);
    } else {
      user.favoriteMeditations.splice(index, 1);
    }

    await user.save();

    return {
      isFavorite: index === -1,
      favoriteMeditations: user.favoriteMeditations,
    };
  }
}

module.exports = new MeditationService();
```

### ❌ openai.service.js (Sprint 3)

**Debe implementar:**

```javascript
const { Configuration, OpenAIApi } = require('openai');
const config = require('../config');

const configuration = new Configuration({
  apiKey: config.openai.apiKey,
});

const openai = new OpenAIApi(configuration);

class OpenAIService {
  /**
   * Analiza sentimiento de entrada de diario
   * @param {String} content - Texto de la entrada
   * @returns {Object} Análisis de sentimiento
   */
  async analyzeSentiment(content) {
    const prompt = `Analiza el siguiente texto de un diario emocional y proporciona:
1. Sentimiento general (positivo, neutral, negativo)
2. Puntuación de sentimiento de -1 a 1
3. Emociones principales detectadas (máximo 5)
4. Temas principales (máximo 3)

Texto: "${content}"

Responde en formato JSON válido con esta estructura:
{
  "sentiment": {
    "overall": "positive|neutral|negative",
    "score": 0.5,
    "emotions": [
      { "emotion": "alegría", "confidence": 0.8 },
      { "emotion": "esperanza", "confidence": 0.6 }
    ]
  },
  "themes": ["trabajo", "relaciones"]
}`;

    try {
      const response = await openai.createChatCompletion({
        model: config.openai.model,
        messages: [
          {
            role: 'system',
            content: 'Eres un asistente especializado en análisis emocional.',
          },
          { role: 'user', content: prompt },
        ],
        max_tokens: config.openai.maxTokens,
        temperature: 0.3,
      });

      const result = JSON.parse(response.data.choices[0].message.content);
      return result;
    } catch (error) {
      console.error('Error al analizar sentimiento:', error);
      throw new Error('Error al procesar análisis de IA');
    }
  }

  /**
   * Genera insights semanales basados en entradas
   * @param {Array} entries - Array de entradas de la semana
   * @returns {String} Insights generados
   */
  async generateWeeklyInsights(entries) {
    const entriesText = entries
      .map((e) => `Día ${e.createdAt.toLocaleDateString()}: ${e.content}`)
      .join('\n\n');

    const prompt = `Basándote en las siguientes entradas de diario de la última semana, genera insights personalizados:

${entriesText}

Proporciona:
1. Patrones emocionales detectados
2. Eventos o situaciones recurrentes
3. Recomendaciones de bienestar
4. Prácticas de mindfulness sugeridas

Responde en español, en tono empático y profesional (máximo 300 palabras).`;

    try {
      const response = await openai.createChatCompletion({
        model: config.openai.model,
        messages: [
          {
            role: 'system',
            content:
              'Eres un psicólogo especializado en bienestar mental y mindfulness.',
          },
          { role: 'user', content: prompt },
        ],
        max_tokens: 500,
        temperature: 0.7,
      });

      return response.data.choices[0].message.content;
    } catch (error) {
      console.error('Error al generar insights:', error);
      throw new Error('Error al generar insights');
    }
  }
}

module.exports = new OpenAIService();
```

### ❌ analysis.service.js (Sprint 3)

**Debe implementar:**

```javascript
const JournalEntry = require('../models/JournalEntry.model');
const openaiService = require('./openai.service');

class AnalysisService {
  /**
   * Procesa análisis de IA para entrada de diario
   * Esta función se ejecuta en background
   */
  async processJournalEntry(entryId) {
    try {
      const entry = await JournalEntry.findById(entryId);

      if (!entry) {
        throw new Error('Entrada no encontrada');
      }

      // Marcar como procesando
      await entry.startProcessing();

      // Llamar a OpenAI
      const analysis = await openaiService.analyzeSentiment(entry.content);

      // Guardar resultados
      await entry.saveAnalysis(analysis);

      console.log(`Análisis completado para entrada ${entryId}`);
    } catch (error) {
      console.error(`Error al procesar entrada ${entryId}:`, error);

      // Marcar error
      const entry = await JournalEntry.findById(entryId);
      if (entry) {
        await entry.markAnalysisError(error.message);
      }
    }
  }

  /**
   * Procesa múltiples entradas en batch
   */
  async processBatch(entryIds) {
    const promises = entryIds.map((id) => this.processJournalEntry(id));
    return Promise.allSettled(promises);
  }
}

module.exports = new AnalysisService();
```

### ❌ stripe.service.js (Sprint 4)

**Debe implementar:**

```javascript
const stripe = require('stripe')(require('../config').stripe.secretKey);
const User = require('../models/User.model');
const config = require('../config');

class StripeService {
  /**
   * Crea sesión de checkout para suscripción
   */
  async createCheckoutSession(userId) {
    const user = await User.findById(userId);

    // Crear o recuperar customer de Stripe
    let customerId = user.subscription.stripeCustomerId;

    if (!customerId) {
      const customer = await stripe.customers.create({
        email: user.email,
        metadata: { userId: user._id.toString() },
      });
      customerId = customer.id;

      user.subscription.stripeCustomerId = customerId;
      await user.save();
    }

    // Crear sesión de checkout
    const session = await stripe.checkout.sessions.create({
      customer: customerId,
      payment_method_types: ['card'],
      line_items: [
        {
          price: config.stripe.premiumPriceId,
          quantity: 1,
        },
      ],
      mode: 'subscription',
      success_url: `${config.frontendUrl}/subscription/success?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${config.frontendUrl}/subscription/cancel`,
      metadata: {
        userId: user._id.toString(),
      },
    });

    return {
      sessionId: session.id,
      url: session.url,
    };
  }

  /**
   * Maneja evento de checkout completado
   */
  async handleCheckoutCompleted(session) {
    const userId = session.metadata.userId;
    const user = await User.findById(userId);

    if (!user) {
      throw new Error('Usuario no encontrado');
    }

    user.subscription.plan = 'premium';
    user.subscription.status = 'active';
    user.subscription.startDate = new Date();
    user.subscription.stripeCustomerId = session.customer;

    await user.save();

    console.log(`Suscripción activada para usuario ${userId}`);
  }

  /**
   * Maneja renovación de suscripción
   */
  async handleInvoicePaymentSucceeded(invoice) {
    const customerId = invoice.customer;
    const user = await User.findOne({
      'subscription.stripeCustomerId': customerId,
    });

    if (!user) return;

    user.subscription.status = 'active';
    await user.save();

    console.log(`Suscripción renovada para usuario ${user._id}`);
  }

  /**
   * Maneja pago fallido
   */
  async handleInvoicePaymentFailed(invoice) {
    const customerId = invoice.customer;
    const user = await User.findOne({
      'subscription.stripeCustomerId': customerId,
    });

    if (!user) return;

    user.subscription.status = 'past_due';
    await user.save();

    // TODO: Enviar email de notificación
  }

  /**
   * Maneja cancelación de suscripción
   */
  async handleSubscriptionDeleted(subscription) {
    const customerId = subscription.customer;
    const user = await User.findOne({
      'subscription.stripeCustomerId': customerId,
    });

    if (!user) return;

    user.subscription.plan = 'free';
    user.subscription.status = 'canceled';
    user.subscription.endDate = new Date(subscription.current_period_end * 1000);

    await user.save();

    console.log(`Suscripción cancelada para usuario ${user._id}`);
  }

  /**
   * Cancela suscripción
   */
  async cancelSubscription(userId) {
    const user = await User.findById(userId);

    if (!user.subscription.stripeCustomerId) {
      throw new Error('No hay suscripción activa');
    }

    // Obtener suscripciones del customer
    const subscriptions = await stripe.subscriptions.list({
      customer: user.subscription.stripeCustomerId,
      status: 'active',
      limit: 1,
    });

    if (subscriptions.data.length === 0) {
      throw new Error('No hay suscripción activa');
    }

    // Cancelar al final del período
    await stripe.subscriptions.update(subscriptions.data[0].id, {
      cancel_at_period_end: true,
    });

    return {
      message: 'Suscripción cancelada. Permanecerá activa hasta el final del período.',
      endDate: new Date(subscriptions.data[0].current_period_end * 1000),
    };
  }

  /**
   * Genera URL del portal de cliente
   */
  async createPortalSession(userId) {
    const user = await User.findById(userId);

    if (!user.subscription.stripeCustomerId) {
      throw new Error('No hay suscripción');
    }

    const session = await stripe.billingPortal.sessions.create({
      customer: user.subscription.stripeCustomerId,
      return_url: `${config.frontendUrl}/profile`,
    });

    return { url: session.url };
  }
}

module.exports = new StripeService();
```

### ❌ notification.service.js (Sprint 4)

**Debe implementar:**

```javascript
const admin = require('firebase-admin');
const User = require('../models/User.model');

// Inicializar Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert({
    // Credenciales de Firebase
  }),
});

class NotificationService {
  /**
   * Envía notificación push a usuario
   */
  async sendToUser(userId, notification) {
    const user = await User.findById(userId);

    if (!user.preferences.notificationsEnabled) {
      return { message: 'Notificaciones deshabilitadas' };
    }

    if (!user.fcmTokens || user.fcmTokens.length === 0) {
      return { message: 'No hay tokens FCM registrados' };
    }

    const message = {
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: notification.data || {},
      tokens: user.fcmTokens,
    };

    try {
      const response = await admin.messaging().sendMulticast(message);

      // Limpiar tokens inválidos
      if (response.failureCount > 0) {
        await this.cleanInvalidTokens(user, response.responses);
      }

      return response;
    } catch (error) {
      console.error('Error al enviar notificación:', error);
      throw error;
    }
  }

  /**
   * Envía recordatorio de meditación
   */
  async sendMeditationReminder(userId) {
    return this.sendToUser(userId, {
      title: '🧘 Hora de meditar',
      body: 'Tómate unos minutos para tu práctica de mindfulness',
      data: {
        type: 'meditation_reminder',
        action: 'open_meditations',
      },
    });
  }

  /**
   * Envía recordatorio de registro de ánimo
   */
  async sendMoodReminder(userId) {
    return this.sendToUser(userId, {
      title: '😊 ¿Cómo te sientes hoy?',
      body: 'Registra tu estado de ánimo del día',
      data: {
        type: 'mood_reminder',
        action: 'open_mood_log',
      },
    });
  }

  /**
   * Limpia tokens FCM inválidos
   */
  async cleanInvalidTokens(user, responses) {
    const invalidTokens = [];

    responses.forEach((resp, idx) => {
      if (!resp.success) {
        invalidTokens.push(user.fcmTokens[idx]);
      }
    });

    if (invalidTokens.length > 0) {
      user.fcmTokens = user.fcmTokens.filter(
        (token) => !invalidTokens.includes(token)
      );
      await user.save();
    }
  }

  /**
   * Programa recordatorios diarios
   */
  async scheduleReminders() {
    // Esta función se llamaría desde un cron job
    const users = await User.find({
      'preferences.notificationsEnabled': true,
    });

    for (const user of users) {
      // Verificar hora de recordatorio de meditación
      if (user.preferences.meditationReminder.enabled) {
        // TODO: Verificar hora y enviar si corresponde
      }

      // Verificar hora de recordatorio de mood
      if (user.preferences.moodReminder.enabled) {
        // TODO: Verificar hora y enviar si corresponde
      }
    }
  }
}

module.exports = new NotificationService();
```

---

## 🛡️ Middleware

### ✅ auth.js (Implementado)

**Funciones:**
- `protect`: Autenticación JWT requerida
- `requirePremium`: Verificación de suscripción premium
- `optionalAuth`: Autenticación opcional

### ✅ validation.js (Implementado)

**Funciones:**
- `validate(schema)`: Validación de body con Joi
- `validateQuery(schema)`: Validación de query params
- `validateParams(schema)`: Validación de URL params

### ✅ errorHandler.js (Implementado)

Maneja todos los errores de forma centralizada

### ❌ upload.js (Sprint 2)

**Debe implementar:**

```javascript
const multer = require('multer');
const path = require('path');

// Configuración de almacenamiento en memoria
const storage = multer.memoryStorage();

// Filtro de archivos de audio
const audioFilter = (req, file, cb) => {
  const allowedTypes = /mp3|wav|m4a|aac/;
  const extname = allowedTypes.test(
    path.extname(file.originalname).toLowerCase()
  );
  const mimetype = allowedTypes.test(file.mimetype);

  if (extname && mimetype) {
    cb(null, true);
  } else {
    cb(new Error('Solo se permiten archivos de audio'));
  }
};

// Límite de tamaño: 50MB
const upload = multer({
  storage,
  fileFilter: audioFilter,
  limits: {
    fileSize: 50 * 1024 * 1024, // 50MB
  },
});

module.exports = {
  uploadSingle: upload.single('audio'),
  uploadMultiple: upload.array('audios', 10),
};
```

---

## 🛣️ Rutas y Endpoints

### Convenciones de API REST

**Métodos HTTP:**
- `GET`: Obtener recursos
- `POST`: Crear recursos
- `PUT`: Actualizar recursos completos
- `PATCH`: Actualizar recursos parcialmente
- `DELETE`: Eliminar recursos

**Códigos de respuesta:**
- `200`: OK - Operación exitosa
- `201`: Created - Recurso creado
- `204`: No Content - Operación exitosa sin contenido
- `400`: Bad Request - Error en validación
- `401`: Unauthorized - No autenticado
- `403`: Forbidden - No autorizado
- `404`: Not Found - Recurso no encontrado
- `409`: Conflict - Conflicto (ej: email duplicado)
- `422`: Unprocessable Entity - Error de validación de negocio
- `429`: Too Many Requests - Rate limit excedido
- `500`: Internal Server Error - Error del servidor

**Formato de respuesta estándar:**

```javascript
// Éxito
{
  "success": true,
  "data": {
    "user": { ... },
    "token": "..."
  },
  "message": "Operación exitosa" // Opcional
}

// Éxito con paginación
{
  "success": true,
  "data": {
    "items": [...],
  },
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 45,
    "pages": 5
  }
}

// Error
{
  "success": false,
  "message": "Descripción del error",
  "errors": [  // Opcional para validación
    {
      "field": "email",
      "message": "Email inválido"
    }
  ]
}
```

### Mapa Completo de Endpoints

```
API Base URL: https://api.mindflow.com/api/v1

AUTENTICACIÓN (Público)
├── POST   /auth/register              ✅ Registro con email
├── POST   /auth/login                 ✅ Login
├── POST   /auth/google                ✅ Google OAuth
├── POST   /auth/forgot-password       ✅ Solicitar reset
├── POST   /auth/reset-password        ✅ Reset con token
└── POST   /auth/refresh-token         ✅ Renovar token

USUARIOS (Protegido)
├── GET    /users/profile              ✅ Obtener perfil
├── PUT    /users/profile              ✅ Actualizar perfil
├── GET    /users/stats                ✅ Estadísticas
├── PUT    /users/preferences          ✅ Preferencias
├── POST   /users/fcm-token            ✅ Agregar token FCM
├── DELETE /users/fcm-token            ✅ Eliminar token FCM
└── DELETE /users/account              ✅ Eliminar cuenta

MEDITACIONES
├── GET    /meditations                ❌ Sprint 2 - Listar
├── GET    /meditations/search         ❌ Sprint 2 - Buscar
├── GET    /meditations/:id            ❌ Sprint 2 - Detalles
├── GET    /meditations/:id/stream     ❌ Sprint 2 - URL streaming
├── POST   /meditations/:id/complete   ❌ Sprint 2 - Completar sesión
├── GET    /meditations/favorites      ❌ Sprint 2 - Listar favoritas
├── POST   /meditations/:id/favorite   ❌ Sprint 2 - Agregar favorita
└── DELETE /meditations/:id/favorite   ❌ Sprint 2 - Quitar favorita

DIARIO EMOCIONAL
├── GET    /journal/entries            ❌ Sprint 3 - Listar
├── POST   /journal/entries            ❌ Sprint 3 - Crear
├── GET    /journal/entries/:id        ❌ Sprint 3 - Detalles
├── PUT    /journal/entries/:id        ❌ Sprint 3 - Actualizar
├── DELETE /journal/entries/:id        ❌ Sprint 3 - Eliminar
└── GET    /journal/insights/weekly    ❌ Sprint 3 - Insights semanales

ESTADO DE ÁNIMO
├── GET    /mood/logs                  ❌ Sprint 3 - Listar
├── POST   /mood/logs                  ❌ Sprint 3 - Registrar
├── GET    /mood/trends                ❌ Sprint 3 - Tendencias
└── GET    /mood/calendar              ❌ Sprint 3 - Vista calendario

SUSCRIPCIONES
├── GET    /subscriptions/status       ❌ Sprint 4 - Estado actual
├── POST   /subscriptions/create-checkout ❌ Sprint 4 - Crear checkout
├── POST   /subscriptions/webhook      ❌ Sprint 4 - Webhook Stripe
├── POST   /subscriptions/cancel       ❌ Sprint 4 - Cancelar
└── POST   /subscriptions/portal       ❌ Sprint 4 - Portal de cliente
```

---

## 🔌 Integración con Servicios Externos

### AWS S3 + CloudFront

**Configuración necesaria:**

1. **Crear bucket S3:**
```bash
aws s3 mb s3://mindflow-audio --region us-east-1
```

2. **Configurar bucket policy (privado):**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::mindflow-audio/*"
    }
  ]
}
```

3. **Estructura de carpetas:**
```
mindflow-audio/
├── anxiety/
├── stress/
├── sleep/
├── focus/
├── self-esteem/
├── gratitude/
└── general/
```

4. **CloudFront Distribution:**
- Origin: S3 bucket
- Restricted Bucket Access: Yes
- Origin Access Identity: Create new
- Viewer Protocol: Redirect HTTP to HTTPS
- Cache TTL: 3600 segundos

### OpenAI API

**Configuración:**

```javascript
// config/index.js
module.exports = {
  openai: {
    apiKey: process.env.OPENAI_API_KEY,
    model: process.env.OPENAI_MODEL || 'gpt-4',
    maxTokens: parseInt(process.env.OPENAI_MAX_TOKENS) || 1000,
  },
};
```

**Costos estimados:**
- GPT-4: $0.03 por 1K tokens (input) + $0.06 por 1K tokens (output)
- Análisis de entrada de diario (~500 palabras): ~$0.05 por análisis
- Insights semanales: ~$0.10 por generación

**Límites recomendados:**
- Free tier: 10 análisis de diario por mes
- Premium: Ilimitado

### Stripe

**Configuración:**

1. **Crear producto en Stripe:**
```javascript
const product = await stripe.products.create({
  name: 'MindFlow Premium',
  description: 'Suscripción mensual premium',
});

const price = await stripe.prices.create({
  product: product.id,
  unit_amount: 999, // $9.99
  currency: 'usd',
  recurring: {
    interval: 'month',
  },
});
```

2. **Configurar webhook:**
- URL: `https://api.mindflow.com/api/v1/subscriptions/webhook`
- Eventos:
  - `checkout.session.completed`
  - `invoice.payment_succeeded`
  - `invoice.payment_failed`
  - `customer.subscription.deleted`

3. **Verificar webhook signature:**
```javascript
const sig = req.headers['stripe-signature'];
const event = stripe.webhooks.constructEvent(
  req.body,
  sig,
  config.stripe.webhookSecret
);
```

### Firebase Cloud Messaging

**Configuración:**

1. **Crear proyecto en Firebase**
2. **Descargar service account key**
3. **Inicializar en backend:**

```javascript
const admin = require('firebase-admin');
const serviceAccount = require('./firebase-adminsdk.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});
```

4. **En Flutter:**
```dart
final messaging = FirebaseMessaging.instance;
final token = await messaging.getToken();
// Enviar token al backend
```

---

## 🚨 Manejo de Errores

### Clases de Error Personalizadas

```javascript
// utils/errors.js

class AppError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = true;
    Error.captureStackTrace(this, this.constructor);
  }
}

class ValidationError extends AppError {
  constructor(message) {
    super(message, 400);
  }
}

class UnauthorizedError extends AppError {
  constructor(message = 'No autorizado') {
    super(message, 401);
  }
}

class ForbiddenError extends AppError {
  constructor(message = 'Acceso prohibido') {
    super(message, 403);
  }
}

class NotFoundError extends AppError {
  constructor(message = 'Recurso no encontrado') {
    super(message, 404);
  }
}

class ConflictError extends AppError {
  constructor(message = 'Conflicto') {
    super(message, 409);
  }
}

module.exports = {
  AppError,
  ValidationError,
  UnauthorizedError,
  ForbiddenError,
  NotFoundError,
  ConflictError,
};
```

### Uso en Controladores

```javascript
const { NotFoundError, ForbiddenError } = require('../utils/errors');

exports.getById = async (req, res, next) => {
  try {
    const item = await Service.getById(req.params.id);

    if (!item) {
      throw new NotFoundError('Recurso no encontrado');
    }

    if (item.userId.toString() !== req.user.id) {
      throw new ForbiddenError('No tienes permiso para acceder a este recurso');
    }

    res.json({ success: true, data: { item } });
  } catch (error) {
    next(error);
  }
};
```

---

## 🔒 Seguridad

### Checklist de Seguridad

- [x] Contraseñas hasheadas con bcrypt (10 rounds)
- [x] JWT con expiración (7 días access, 30 días refresh)
- [x] HTTPS en producción
- [x] Helmet.js para headers de seguridad
- [x] CORS configurado
- [x] Rate limiting (100 req/min)
- [x] Validación exhaustiva de entrada (Joi)
- [x] Mongoose sanitization
- [ ] Logs con Winston
- [ ] Monitoreo con Sentry
- [ ] Auditoría de dependencias (npm audit)
- [ ] Variables de entorno seguras
- [ ] Verificación de webhook signatures (Stripe)

### Mejores Prácticas

1. **Nunca exponer información sensible en errores**
```javascript
// ❌ MAL
res.status(500).json({ error: error.stack });

// ✅ BIEN
res.status(500).json({
  success: false,
  message: 'Error interno del servidor'
});
```

2. **Validar ownership de recursos**
```javascript
const item = await Model.findOne({ _id: id, userId: req.user.id });
if (!item) {
  throw new NotFoundError();
}
```

3. **Límites en plan gratuito**
```javascript
if (!user.isPremium() && user.stats.journalEntries >= 10) {
  throw new ForbiddenError('Límite de plan gratuito alcanzado');
}
```

4. **Sanitizar input de usuario**
```javascript
const sanitized = DOMPurify.sanitize(userInput);
```

---

## 🧪 Testing

### Estructura de Tests

```javascript
// tests/meditation.test.js

const request = require('supertest');
const app = require('../src/app');
const Meditation = require('../src/models/Meditation.model');
const User = require('../src/models/User.model');

describe('Meditation Endpoints', () => {
  let authToken;
  let premiumToken;
  let freeUserId;
  let premiumUserId;

  beforeAll(async () => {
    // Setup: Crear usuarios de prueba
    const freeUser = await User.create({
      email: 'free@test.com',
      password: 'Password123',
      name: 'Free User',
      authProvider: 'email',
    });
    freeUserId = freeUser._id;

    const premiumUser = await User.create({
      email: 'premium@test.com',
      password: 'Password123',
      name: 'Premium User',
      authProvider: 'email',
      subscription: {
        plan: 'premium',
        status: 'active',
      },
    });
    premiumUserId = premiumUser._id;

    // Obtener tokens
    const freeRes = await request(app)
      .post('/api/v1/auth/login')
      .send({ email: 'free@test.com', password: 'Password123' });
    authToken = freeRes.body.data.token;

    const premiumRes = await request(app)
      .post('/api/v1/auth/login')
      .send({ email: 'premium@test.com', password: 'Password123' });
    premiumToken = premiumRes.body.data.token;

    // Crear meditaciones de prueba
    await Meditation.create([
      {
        title: 'Meditación Gratuita',
        category: 'general',
        duration: 300,
        audioUrl: 'general/free.mp3',
        isPremium: false,
      },
      {
        title: 'Meditación Premium',
        category: 'anxiety',
        duration: 600,
        audioUrl: 'anxiety/premium.mp3',
        isPremium: true,
      },
    ]);
  });

  afterAll(async () => {
    // Cleanup
    await User.deleteMany({});
    await Meditation.deleteMany({});
  });

  describe('GET /meditations', () => {
    it('debe listar meditaciones para usuario free', async () => {
      const res = await request(app)
        .get('/api/v1/meditations')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(res.body.success).toBe(true);
      expect(res.body.data.meditations).toHaveLength(1); // Solo gratuitas
      expect(res.body.data.meditations[0].isPremium).toBe(false);
    });

    it('debe listar todas las meditaciones para usuario premium', async () => {
      const res = await request(app)
        .get('/api/v1/meditations')
        .set('Authorization', `Bearer ${premiumToken}`)
        .expect(200);

      expect(res.body.success).toBe(true);
      expect(res.body.data.meditations.length).toBeGreaterThan(0);
    });

    it('debe filtrar por categoría', async () => {
      const res = await request(app)
        .get('/api/v1/meditations?category=general')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(res.body.success).toBe(true);
      res.body.data.meditations.forEach(m => {
        expect(m.category).toBe('general');
      });
    });
  });

  describe('GET /meditations/:id/stream', () => {
    it('debe rechazar acceso a meditación premium para usuario free', async () => {
      const meditation = await Meditation.findOne({ isPremium: true });

      const res = await request(app)
        .get(`/api/v1/meditations/${meditation._id}/stream`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(403);

      expect(res.body.success).toBe(false);
      expect(res.body.message).toContain('premium');
    });

    it('debe generar URL de streaming para usuario premium', async () => {
      const meditation = await Meditation.findOne({ isPremium: true });

      const res = await request(app)
        .get(`/api/v1/meditations/${meditation._id}/stream`)
        .set('Authorization', `Bearer ${premiumToken}`)
        .expect(200);

      expect(res.body.success).toBe(true);
      expect(res.body.data.streamUrl).toBeDefined();
      expect(res.body.data.duration).toBe(meditation.duration);
    });
  });

  describe('POST /meditations/:id/complete', () => {
    it('debe registrar sesión completada y actualizar stats', async () => {
      const meditation = await Meditation.findOne({ isPremium: false });

      const res = await request(app)
        .post(`/api/v1/meditations/${meditation._id}/complete`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({ duration: 300 })
        .expect(200);

      expect(res.body.success).toBe(true);

      // Verificar que stats se actualizaron
      const user = await User.findById(freeUserId);
      expect(user.stats.totalMeditations).toBe(1);
      expect(user.stats.totalMeditationTime).toBe(300);
    });
  });
});
```

---

## 📅 Roadmap de Implementación

### Sprint 2 - Meditaciones (Semanas 4-6)

**Semana 4: Configuración AWS y Backend**
- [ ] Crear bucket S3 y configurar permisos
- [ ] Configurar CloudFront CDN
- [ ] Implementar `s3.service.js`
- [ ] Implementar `meditation.service.js`
- [ ] Implementar `meditation.controller.js`
- [ ] Crear validadores de meditaciones
- [ ] Implementar rutas completas
- [ ] Subir 8 meditaciones de prueba a S3

**Semana 5: Tests y Refinamiento**
- [ ] Escribir tests de `meditation.controller`
- [ ] Escribir tests de `s3.service`
- [ ] Test de URLs firmadas
- [ ] Test de restricciones premium/free
- [ ] Optimizar queries de meditaciones

**Semana 6: Integración Flutter**
- [ ] (Flutter) Reproductor de audio con just_audio
- [ ] (Flutter) Pantalla de lista de meditaciones
- [ ] (Flutter) Pantalla de detalle
- [ ] (Flutter) Sistema de favoritos
- [ ] Testing end-to-end

### Sprint 3 - IA y Emociones (Semanas 7-9)

**Semana 7: OpenAI y Diario**
- [ ] Configurar cuenta de OpenAI
- [ ] Implementar `openai.service.js`
- [ ] Implementar `analysis.service.js`
- [ ] Implementar `journal.controller.js`
- [ ] Crear validadores de journal
- [ ] Implementar procesamiento async de IA

**Semana 8: Estado de Ánimo**
- [ ] Implementar `mood.controller.js`
- [ ] Implementar cálculos de tendencias
- [ ] Crear endpoint de calendario
- [ ] Tests de journal y mood
- [ ] Optimizar costos de OpenAI

**Semana 9: Integración Flutter**
- [ ] (Flutter) Pantalla de diario con editor
- [ ] (Flutter) Visualización de análisis IA
- [ ] (Flutter) Pantalla de mood logs
- [ ] (Flutter) Gráficas con fl_chart
- [ ] (Flutter) Calendario emocional

### Sprint 4 - Suscripciones y Publicación (Semanas 10-12)

**Semana 10: Stripe y Notificaciones**
- [ ] Configurar cuenta de Stripe
- [ ] Implementar `stripe.service.js`
- [ ] Implementar `subscription.controller.js`
- [ ] Configurar webhooks de Stripe
- [ ] Implementar `notification.service.js`
- [ ] Configurar Firebase Cloud Messaging

**Semana 11: Dashboard y Testing**
- [ ] (Flutter) Pantalla de suscripción
- [ ] (Flutter) Integración con Stripe Checkout
- [ ] (Flutter) Dashboard completo
- [ ] Testing exhaustivo de todos los flujos
- [ ] Fix de bugs encontrados

**Semana 12: Publicación**
- [ ] Generar builds de producción (Android/iOS)
- [ ] Crear assets para stores (screenshots, iconos)
- [ ] Escribir descripción de app
- [ ] Subir a Google Play Store
- [ ] Subir a Apple App Store
- [ ] Configurar CI/CD con GitHub Actions
- [ ] Documentación final

---

## 📝 Notas Finales

### Principios de Código Limpio

1. **DRY (Don't Repeat Yourself)**: No duplicar lógica
2. **SOLID**: Principios de diseño orientado a objetos
3. **KISS (Keep It Simple)**: Mantener simplicidad
4. **YAGNI (You Aren't Gonna Need It)**: No sobreingeniería
5. **Code Review**: Revisar todo código antes de merge

### Convenciones de Código

- **Nombres de archivos**: `lowercase-with-dashes.js`
- **Nombres de clases**: `PascalCase`
- **Nombres de funciones**: `camelCase`
- **Nombres de constantes**: `UPPER_SNAKE_CASE`
- **Indentación**: 2 espacios
- **Comillas**: Simples `'` para strings
- **Punto y coma**: Siempre usar `;`

### Estructura de Commits

```
tipo(scope): descripción corta

Descripción más detallada si es necesario

Tipos: feat, fix, docs, style, refactor, test, chore
```

Ejemplos:
```
feat(meditation): implementar endpoint de streaming
fix(auth): corregir validación de token expirado
docs(api): actualizar documentación de endpoints
test(journal): agregar tests de análisis IA
```

---

## 🎯 Conclusión

Este documento proporciona una guía completa y detallada de cómo debe estructurarse el backend de MindFlow. La arquitectura en capas, los patrones de diseño y las mejores prácticas aquí descritas garantizan:

- **Escalabilidad**: Preparado para crecer
- **Mantenibilidad**: Código limpio y organizado
- **Testabilidad**: Fácil de testear
- **Seguridad**: Implementación robusta
- **Performance**: Optimizado desde el inicio

Cada componente tiene un propósito claro y una responsabilidad específica. Los próximos sprints deben seguir esta estructura para mantener la consistencia y calidad del código.

---

**MindFlow Backend Architecture v2.0**
Noviembre 2024
