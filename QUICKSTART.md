# 🚀 MindFlow - Guía de Inicio Rápido

## ¿Qué es MindFlow?

MindFlow es una aplicación completa de bienestar mental con IA que combina:
- 🧘 Meditaciones guiadas
- 📖 Diario emocional con análisis de IA
- 📊 Seguimiento de estado de ánimo
- 📈 Dashboard de estadísticas personalizadas

**Stack Tecnológico:**
- Frontend: Flutter (iOS, Android, Web)
- Backend: Node.js + Express
- Base de Datos: MongoDB Atlas
- IA: OpenAI API
- Cloud: AWS (S3, EC2)

## ✅ Estado del Proyecto

**Sprint 1 - COMPLETADO** 🎉

- ✅ Backend completo con autenticación
- ✅ Frontend Flutter con navegación
- ✅ Google OAuth integrado
- ✅ Suite completa de tests (70%+ cobertura)
- ✅ Documentación completa

## 📦 Instalación Rápida

### Requisitos Previos

- Node.js 18+ ([Descargar](https://nodejs.org/))
- Flutter 3.16+ ([Descargar](https://flutter.dev/docs/get-started/install))
- MongoDB (local o Atlas) ([MongoDB Atlas gratis](https://www.mongodb.com/cloud/atlas))
- Git

### 1. Clonar el Repositorio

```bash
git clone <repository-url>
cd Bienestar-Mental-con-IA
```

### 2. Configurar Backend

```bash
cd backend
npm install
```

Crear archivo `.env` (copiar de `.env.example`):
```bash
cp .env.example .env
```

Editar `.env` con tus credenciales:
```env
MONGODB_URI=mongodb://localhost:27017/mindflow
JWT_SECRET=tu_clave_secreta_super_segura
# ... otras configuraciones
```

**Opcional:** Poblar base de datos con datos de ejemplo:
```bash
node scripts/seed.js
```

Iniciar servidor:
```bash
npm run dev
```

El backend estará en: `http://localhost:3000`

### 3. Configurar Frontend

```bash
cd ..  # Volver a raíz del proyecto
flutter pub get
```

Crear archivo `.env`:
```bash
cp .env.example .env
```

Editar `.env`:
```env
API_BASE_URL=http://localhost:3000/api/v1
```

Ejecutar aplicación:
```bash
# Android/iOS
flutter run

# Web
flutter run -d chrome

# Elegir dispositivo específico
flutter devices
flutter run -d <device-id>
```

## 🧪 Ejecutar Tests

### Backend Tests

```bash
cd backend
npm test                # Ejecutar todos los tests
npm run test:watch      # Modo watch
```

### Flutter Tests

```bash
flutter test                    # Ejecutar todos los tests
flutter test --coverage         # Con cobertura
```

Ver documentación completa de tests: [TESTING.md](TESTING.md)

## 🔐 Credenciales de Prueba

Después de ejecutar `node scripts/seed.js`:

```
Email: test@mindflow.com
Password: Password123
```

## 📱 Funcionalidades Disponibles

### ✅ Implementado (Sprint 1)

**Backend:**
- Registro con email y contraseña
- Login con email
- Google OAuth 2.0
- Recuperación de contraseña
- Gestión de perfil de usuario
- Estadísticas de usuario
- Preferencias de notificaciones

**Frontend:**
- Splash screen
- Onboarding (3 páginas)
- Login con validación
- Registro con validación
- Recuperación de contraseña
- Perfil de usuario
- Google Sign In
- Navegación con guards de autenticación
- Tema claro y oscuro

### 🚧 Próximos Sprints

**Sprint 2 (Semanas 4-6):**
- Biblioteca de meditaciones
- AWS S3 + CloudFront
- Reproductor de audio
- Sistema de favoritos

**Sprint 3 (Semanas 7-9):**
- Diario emocional
- Análisis de IA con OpenAI
- Registro de estado de ánimo
- Gráficas de tendencias

**Sprint 4 (Semanas 10-12):**
- Suscripciones con Stripe
- Dashboard completo
- Notificaciones push
- Publicación en stores

## 🛠️ Solución de Problemas

### Backend no inicia

**Error: Cannot find module**
```bash
cd backend
rm -rf node_modules package-lock.json
npm install
```

**Error: MongoDB connection**
- Verifica que MongoDB esté corriendo
- O usa MongoDB Atlas (gratis)
- Verifica la URL en `.env`

### Flutter no compila

**Error: pub get failed**
```bash
flutter clean
flutter pub get
```

**Error: Dependencies conflict**
```bash
flutter pub upgrade
```

### Tests fallan

**Backend:**
```bash
cd backend
rm -rf node_modules
npm install
npm test
```

**Flutter:**
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter test
```

## 📚 Documentación

- [README.md](README.md) - Especificaciones técnicas completas
- [IMPLEMENTACION.md](IMPLEMENTACION.md) - Guía de implementación
- [TESTING.md](TESTING.md) - Guía completa de testing
- [backend/README.md](backend/README.md) - Documentación del API

## 🔑 Configuraciones Necesarias

### MongoDB Atlas (Recomendado)

1. Crear cuenta en [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Crear cluster gratuito (M0)
3. Crear usuario de base de datos
4. Obtener connection string
5. Añadir IP a whitelist (0.0.0.0/0 para desarrollo)
6. Copiar connection string a `backend/.env`

### Google OAuth (Opcional)

1. Ir a [Google Cloud Console](https://console.cloud.google.com)
2. Crear nuevo proyecto
3. Habilitar Google+ API
4. Crear credenciales OAuth 2.0
5. Añadir URLs autorizadas
6. Copiar Client ID y Secret a `.env`

### Email SMTP (Gmail)

1. Crear App Password en Gmail:
   - Ir a cuenta de Google
   - Seguridad → Contraseñas de aplicaciones
   - Crear nueva contraseña para "Otra app"
2. Copiar password a `backend/.env` en `SMTP_PASS`

## 📊 Estructura del Proyecto

```
Bienestar-Mental-con-IA/
├── backend/              # Backend Node.js
│   ├── src/
│   │   ├── config/      # Configuraciones
│   │   ├── controllers/ # Controladores
│   │   ├── models/      # Modelos Mongoose
│   │   ├── routes/      # Rutas del API
│   │   ├── middleware/  # Middleware
│   │   ├── services/    # Servicios
│   │   └── utils/       # Utilidades
│   ├── tests/           # Tests del backend
│   └── scripts/         # Scripts útiles
│
├── lib/                 # Frontend Flutter
│   ├── core/           # Configuración y temas
│   ├── data/           # Modelos y repositorios
│   ├── presentation/   # UI y providers
│   └── main.dart
│
├── test/               # Tests de Flutter
├── .env.example        # Ejemplo de variables de entorno
└── README.md          # Especificaciones
```

## 🎯 Próximos Pasos

1. **Configurar MongoDB Atlas** (gratis)
2. **Ejecutar backend** con `npm run dev`
3. **Ejecutar Flutter** con `flutter run`
4. **Poblar datos** con `node scripts/seed.js`
5. **Probar la app** con credenciales de prueba

## 💡 Tips

- Usa `npm run dev` en backend para hot reload
- Usa `flutter run` con hot reload (tecla 'r')
- Los tests usan MongoDB en memoria (no necesitas MongoDB instalado)
- Revisa `TESTING.md` para guía completa de tests
- Los archivos `.env` no se commitean (están en .gitignore)

## 🐛 Reportar Problemas

Si encuentras algún problema:
1. Revisa esta guía
2. Consulta [IMPLEMENTACION.md](IMPLEMENTACION.md)
3. Revisa los logs del backend
4. Ejecuta `flutter doctor` para Flutter
5. Crea un issue en GitHub

## 📞 Soporte

Para preguntas o ayuda:
- Revisa la documentación en `/backend/README.md`
- Consulta las especificaciones en `README.md`
- Lee la guía de testing en `TESTING.md`

---

**¡Feliz desarrollo! 🚀**

MindFlow - Bienestar Mental con IA
