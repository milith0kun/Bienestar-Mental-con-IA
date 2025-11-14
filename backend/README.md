# MindFlow Backend API

API REST para la aplicación MindFlow - Bienestar Mental con IA

## Tecnologías

- **Node.js 18 LTS** - Runtime de JavaScript
- **Express.js 4.18+** - Framework web
- **MongoDB Atlas** - Base de datos NoSQL
- **Mongoose 8.1+** - ODM para MongoDB
- **JWT** - Autenticación con tokens
- **OpenAI API** - Análisis de sentimientos con IA
- **AWS S3** - Almacenamiento de archivos de audio
- **Stripe** - Procesamiento de pagos

## Requisitos Previos

- Node.js 18 o superior
- npm 9 o superior
- Cuenta de MongoDB Atlas
- Cuenta de AWS (para S3)
- API Key de OpenAI
- Cuenta de Stripe (para pagos)

## Instalación

1. Clonar el repositorio:
```bash
git clone <repository-url>
cd backend
```

2. Instalar dependencias:
```bash
npm install
```

3. Configurar variables de entorno:
```bash
cp .env.example .env
# Editar .env con tus credenciales
```

4. Iniciar servidor de desarrollo:
```bash
npm run dev
```

El servidor estará disponible en `http://localhost:3000`

## Variables de Entorno

Consultar `.env.example` para ver todas las variables requeridas.

Variables críticas:
- `MONGODB_URI` - Conexión a MongoDB Atlas
- `JWT_SECRET` - Clave secreta para JWT
- `OPENAI_API_KEY` - API Key de OpenAI
- `AWS_ACCESS_KEY_ID` - Credenciales de AWS
- `STRIPE_SECRET_KEY` - Clave secreta de Stripe

## Estructura del Proyecto

```
backend/
├── src/
│   ├── config/           # Configuraciones
│   │   ├── index.js
│   │   └── database.js
│   ├── controllers/      # Controladores de rutas
│   │   ├── auth.controller.js
│   │   └── user.controller.js
│   ├── models/          # Modelos de Mongoose
│   │   ├── User.model.js
│   │   ├── Meditation.model.js
│   │   ├── JournalEntry.model.js
│   │   └── MoodLog.model.js
│   ├── routes/          # Definición de rutas
│   │   ├── auth.routes.js
│   │   ├── user.routes.js
│   │   ├── meditation.routes.js
│   │   ├── journal.routes.js
│   │   ├── mood.routes.js
│   │   └── subscription.routes.js
│   ├── middleware/      # Middleware personalizado
│   │   ├── auth.js
│   │   ├── validation.js
│   │   ├── errorHandler.js
│   │   └── notFound.js
│   ├── services/        # Lógica de negocio
│   │   └── email.service.js
│   ├── utils/          # Utilidades
│   │   ├── jwt.js
│   │   └── crypto.js
│   ├── app.js          # Configuración de Express
│   └── server.js       # Punto de entrada
├── tests/              # Tests
├── .env.example
├── package.json
└── README.md
```

## API Endpoints

### Base URL
```
http://localhost:3000/api/v1
```

### Autenticación

#### Registrar Usuario
```http
POST /auth/register
Content-Type: application/json

{
  "email": "usuario@example.com",
  "password": "Password123",
  "name": "Juan Pérez"
}
```

**Respuesta exitosa (201):**
```json
{
  "success": true,
  "message": "Usuario registrado exitosamente",
  "data": {
    "user": {
      "id": "user_id",
      "email": "usuario@example.com",
      "name": "Juan Pérez",
      "subscription": {
        "plan": "free",
        "status": "active"
      }
    },
    "token": "jwt_token",
    "refreshToken": "refresh_token"
  }
}
```

#### Iniciar Sesión
```http
POST /auth/login
Content-Type: application/json

{
  "email": "usuario@example.com",
  "password": "Password123"
}
```

#### Autenticación con Google
```http
POST /auth/google
Content-Type: application/json

{
  "idToken": "google_id_token"
}
```

#### Recuperar Contraseña
```http
POST /auth/forgot-password
Content-Type: application/json

{
  "email": "usuario@example.com"
}
```

#### Restablecer Contraseña
```http
POST /auth/reset-password
Content-Type: application/json

{
  "token": "reset_token",
  "password": "NewPassword123"
}
```

#### Renovar Token
```http
POST /auth/refresh-token
Content-Type: application/json

{
  "refreshToken": "refresh_token"
}
```

### Usuario (Requiere Autenticación)

Todas las rutas de usuario requieren el header:
```
Authorization: Bearer <token>
```

#### Obtener Perfil
```http
GET /users/profile
```

#### Actualizar Perfil
```http
PUT /users/profile
Content-Type: application/json

{
  "name": "Nuevo Nombre",
  "profilePicture": "https://example.com/image.jpg"
}
```

#### Obtener Estadísticas
```http
GET /users/stats
```

**Respuesta:**
```json
{
  "success": true,
  "data": {
    "stats": {
      "totalMeditations": 15,
      "totalMeditationTime": 3600,
      "totalMeditationTimeFormatted": "1h 0m",
      "consecutiveDays": 5,
      "journalEntries": 8,
      "journalEntriesThisMonth": 3,
      "journalEntriesRemaining": 7
    },
    "subscription": {
      "plan": "free",
      "status": "active",
      "isPremium": false
    }
  }
}
```

#### Actualizar Preferencias
```http
PUT /users/preferences
Content-Type: application/json

{
  "notificationsEnabled": true,
  "meditationReminder": {
    "enabled": true,
    "time": "09:00"
  },
  "moodReminder": {
    "enabled": true,
    "time": "20:00"
  }
}
```

#### Agregar Token FCM
```http
POST /users/fcm-token
Content-Type: application/json

{
  "token": "fcm_device_token"
}
```

#### Eliminar Cuenta
```http
DELETE /users/account
```

### Health Check

```http
GET /health
```

**Respuesta:**
```json
{
  "success": true,
  "message": "MindFlow API is running",
  "timestamp": "2024-11-14T00:00:00.000Z",
  "environment": "development"
}
```

## Formato de Respuestas

### Respuesta Exitosa
```json
{
  "success": true,
  "message": "Mensaje descriptivo",
  "data": {
    // Datos de la respuesta
  }
}
```

### Respuesta de Error
```json
{
  "success": false,
  "message": "Descripción del error",
  "errors": [
    {
      "field": "email",
      "message": "El correo electrónico es requerido"
    }
  ]
}
```

## Códigos de Estado HTTP

- `200` - OK
- `201` - Created
- `400` - Bad Request (validación fallida)
- `401` - Unauthorized (no autenticado)
- `403` - Forbidden (no autorizado)
- `404` - Not Found
- `500` - Internal Server Error

## Validaciones

### Contraseña
- Mínimo 8 caracteres
- Al menos una mayúscula
- Al menos una minúscula
- Al menos un número

### Email
- Formato válido de email
- Único en el sistema

## Seguridad

- Todas las contraseñas se hashean con bcrypt (10 rounds)
- Tokens JWT con expiración de 7 días
- Rate limiting: 100 peticiones por minuto por IP
- CORS configurado para dominios específicos
- Helmet.js para headers de seguridad
- Validación de entrada con Joi

## Testing

```bash
# Ejecutar tests
npm test

# Tests con coverage
npm test -- --coverage

# Tests en modo watch
npm run test:watch
```

## Despliegue

### AWS EC2

1. Conectar a instancia EC2
2. Clonar repositorio
3. Instalar dependencias
4. Configurar variables de entorno
5. Iniciar con PM2:

```bash
pm2 start src/server.js --name mindflow-backend
pm2 save
pm2 startup
```

### Nginx (Proxy Reverso)

```nginx
server {
    listen 80;
    server_name api.mindflow.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## Roadmap de Desarrollo

### Sprint 1 (Actual) ✅
- [x] Autenticación JWT
- [x] Google OAuth
- [x] Gestión de usuarios
- [x] Recuperación de contraseña

### Sprint 2 (Próximo)
- [ ] Biblioteca de meditaciones
- [ ] AWS S3 integration
- [ ] Sistema de favoritos
- [ ] Restricciones premium

### Sprint 3
- [ ] Diario emocional
- [ ] Integración OpenAI
- [ ] Registro de estado de ánimo
- [ ] Análisis de tendencias

### Sprint 4
- [ ] Integración Stripe
- [ ] Suscripciones premium
- [ ] Notificaciones push
- [ ] Dashboard de estadísticas

## Contacto

Para preguntas o soporte, contactar al equipo de desarrollo.

## Licencia

Privado - Todos los derechos reservados
