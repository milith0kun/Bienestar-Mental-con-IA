# 🧪 Guía de Prueba Local - MindFlow

Esta guía te ayudará a probar la aplicación MindFlow completa en tu entorno local.

## 📋 Prerrequisitos

### Backend
- ✅ Node.js 18+ instalado
- ✅ MongoDB Atlas configurado (o MongoDB local)
- ✅ npm 9+

### Frontend (Flutter)
- ✅ Flutter SDK instalado (versión 3.x)
- ✅ Android Studio o Xcode (según plataforma)
- ✅ Emulador Android o iOS Simulator configurado

## 🚀 Paso 1: Configurar MongoDB Atlas

### Opción A: MongoDB Atlas (Recomendada)

1. **Activar el clúster:**
   - Inicia sesión en [MongoDB Atlas](https://cloud.mongodb.com/)
   - Ve a tu clúster "Cluster0"
   - Si está pausado, haz clic en "Resume"

2. **Configurar Network Access:**
   - Ve a **Network Access** en el menú lateral
   - Haz clic en **"Add IP Address"**
   - Agrega `0.0.0.0/0` (permite todas las IPs - solo para desarrollo)
   - O agrega tu IP actual

3. **Verificar usuario de base de datos:**
   - Ve a **Database Access**
   - Verifica que existe el usuario `milith0dev_db_user`
   - Debe tener permisos de "Read and write to any database"

### Opción B: MongoDB Local

Si prefieres usar MongoDB local:

```bash
# Instalar MongoDB Community Edition
# macOS
brew tap mongodb/brew
brew install mongodb-community

# Ubuntu
sudo apt-get install mongodb

# Iniciar MongoDB
mongod --dbpath /path/to/data/directory
```

Luego actualiza el `.env` del backend:
```env
MONGODB_URI=mongodb://localhost:27017/mindflow
```

## 🖥️ Paso 2: Iniciar el Backend

### 1. Navegar al directorio del backend
```bash
cd backend
```

### 2. Verificar que las dependencias están instaladas
```bash
npm install
```

### 3. Verificar archivo .env
Asegúrate de que existe `backend/.env` con la configuración correcta:

```env
NODE_ENV=development
PORT=3000
MONGODB_URI=mongodb+srv://milith0dev_db_user:1997281qA@cluster0.cpt00yd.mongodb.net/mindflow?retryWrites=true&w=majority&appName=Cluster0
JWT_SECRET=dev_secret_key_change_in_production_2024
JWT_REFRESH_SECRET=dev_refresh_secret_key_change_in_production_2024
```

### 4. Probar conexión a MongoDB
```bash
npm run test:connection
```

Deberías ver:
```
✅ ¡Conexión exitosa a MongoDB Atlas!
📊 Base de datos: mindflow
🌐 Host: cluster0-shard-00-00.cpt00yd.mongodb.net
```

Si hay errores, consulta `backend/MONGODB_SETUP.md`.

### 5. Poblar la base de datos con datos de prueba
```bash
npm run seed
```

Esto creará:
- ✅ 1 usuario de prueba
- ✅ 8 meditaciones (5 gratuitas + 3 premium)

Credenciales del usuario de prueba:
- **Email:** `test@mindflow.com`
- **Password:** `Password123`

### 6. Iniciar el servidor
```bash
npm run dev
```

Deberías ver:
```
╔═══════════════════════════════════════╗
║   MindFlow Backend API Server         ║
╠═══════════════════════════════════════╣
║   Environment: development            ║
║   Port: 3000                          ║
║   Database: Connected                 ║
╚═══════════════════════════════════════╝
```

### 7. Verificar que el API está funcionando

Abre otro terminal y prueba:

```bash
# Health check
curl http://localhost:3000/health

# Listar meditaciones
curl http://localhost:3000/api/v1/meditations

# Login (obtener token)
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@mindflow.com","password":"Password123"}'
```

## 📱 Paso 3: Iniciar la App Flutter

### 1. Navegar al directorio raíz del proyecto
```bash
cd ..  # Si estás en /backend
```

### 2. Instalar dependencias
```bash
flutter pub get
```

### 3. Verificar dispositivos disponibles
```bash
flutter devices
```

Deberías ver al menos un dispositivo (emulador o simulador).

### 4. Iniciar emulador (si no está corriendo)

**Android:**
```bash
# Listar emuladores
emulator -list-avds

# Iniciar un emulador
emulator -avd <nombre_del_avd>
```

**iOS:**
```bash
open -a Simulator
```

### 5. Ejecutar la app
```bash
flutter run
```

O si tienes múltiples dispositivos:
```bash
flutter run -d <device_id>
```

## 🎯 Paso 4: Probar Funcionalidades

### 1. Autenticación

#### Opción A: Usar credenciales de prueba
1. En la app, ve a "Iniciar Sesión"
2. Email: `test@mindflow.com`
3. Password: `Password123`
4. Haz clic en "Iniciar Sesión"

#### Opción B: Crear nueva cuenta
1. En la app, ve a "Registrarse"
2. Completa el formulario
3. Crea tu cuenta

### 2. Explorar Meditaciones
1. En la pantalla principal, ve a "Meditaciones"
2. Explora las diferentes categorías
3. Las meditaciones marcadas con 🔒 requieren Premium
4. Reproduce una meditación gratuita

### 3. Registro de Estado de Ánimo
1. Ve a "Estado de Ánimo"
2. Selecciona tu estado actual (1-10)
3. Elige emociones
4. Agrega notas (opcional)
5. Guarda el registro
6. Visualiza estadísticas y tendencias

### 4. Diario Emocional
1. Ve a "Diario"
2. Crea una nueva entrada
3. Escribe título y contenido
4. Selecciona tu estado de ánimo
5. Guarda la entrada
6. Visualiza el análisis de IA (si está disponible)

### 5. Probar Premium (Modo Demo)

Para probar funcionalidades premium sin configurar Stripe:

```bash
# Desde tu terminal, con el token de autenticación
curl -X POST http://localhost:3000/api/v1/subscriptions/upgrade-demo \
  -H "Authorization: Bearer <tu_token>" \
  -H "Content-Type: application/json"
```

O usa la app (si implementaste el botón):
1. Ve a "Perfil" > "Suscripción"
2. Toca "Actualizar a Premium (Demo)"
3. Ahora tendrás acceso a todas las funciones premium

## 🔍 Debugging y Logs

### Backend
El servidor mostrará logs de todas las peticiones:
```
REQUEST[GET] => PATH: /api/v1/meditations
RESPONSE[200] => PATH: /api/v1/meditations
```

### Flutter
Los logs aparecerán en tu terminal:
```
flutter: 📝 URI (oculta): http://10.0.2.2:3000/api/v1
flutter: REQUEST[GET] => PATH: /api/v1/meditations
```

## ⚙️ Configuración de Red

### Android Emulator
La app usa `http://10.0.2.2:3000` automáticamente en Android.

`10.0.2.2` es la IP especial que apunta a `localhost` de tu máquina host.

### iOS Simulator
La app usa `http://localhost:3000` en iOS.

### Dispositivo Físico
Si pruebas en un dispositivo físico:

1. Asegúrate de que tu computadora y dispositivo estén en la misma red WiFi
2. Obtén la IP local de tu computadora:
   ```bash
   # macOS/Linux
   ipconfig getifaddr en0

   # Windows
   ipconfig
   ```
3. Actualiza `lib/core/config/api_config.dart`:
   ```dart
   static String get baseUrlDev {
     return 'http://TU_IP_LOCAL:3000/api/v1';
   }
   ```

## 🐛 Problemas Comunes

### Error: "Connection refused" o "Network error"

**Causa:** El backend no está corriendo o la app no puede conectarse.

**Solución:**
1. Verifica que el backend esté corriendo (`npm run dev`)
2. Verifica que esté en el puerto 3000
3. En Android emulator, usa `10.0.2.2` en lugar de `localhost`
4. Verifica el firewall de tu sistema

### Error: "MongoDB connection failed"

**Causa:** No se puede conectar a MongoDB Atlas.

**Solución:**
1. Verifica que el clúster esté activo
2. Verifica Network Access (lista blanca de IPs)
3. Verifica credenciales en `.env`
4. Consulta `backend/MONGODB_SETUP.md`

### Error: "Token inválido" o "No autorizado"

**Causa:** El token de autenticación expiró o es inválido.

**Solución:**
1. Cierra sesión y vuelve a iniciar sesión
2. Limpia los datos de la app
3. Verifica que JWT_SECRET en `.env` no haya cambiado

### La app no actualiza después de cambios en Flutter

**Solución:**
```bash
# Hot restart (r en la consola de flutter)
r

# O reinicia completamente
flutter run
```

### Errores de CORS

Si ves errores de CORS en la consola:

**Solución:** El backend ya tiene CORS configurado. Asegúrate de que el `FRONTEND_URL` en `.env` incluya el origen correcto.

## 📊 Endpoints del API

### Autenticación
- `POST /api/v1/auth/register` - Registrar usuario
- `POST /api/v1/auth/login` - Iniciar sesión
- `POST /api/v1/auth/google` - Google Sign In
- `POST /api/v1/auth/forgot-password` - Recuperar contraseña
- `POST /api/v1/auth/reset-password` - Restablecer contraseña
- `POST /api/v1/auth/refresh-token` - Renovar token

### Usuarios
- `GET /api/v1/users/me` - Obtener perfil
- `PUT /api/v1/users/me` - Actualizar perfil
- `GET /api/v1/users/stats` - Obtener estadísticas

### Meditaciones
- `GET /api/v1/meditations` - Listar meditaciones
- `GET /api/v1/meditations/categories` - Obtener categorías
- `GET /api/v1/meditations/:id` - Obtener detalles
- `POST /api/v1/meditations/:id/play` - Registrar reproducción
- `POST /api/v1/meditations/:id/complete` - Marcar como completada
- `POST /api/v1/meditations/:id/rate` - Calificar meditación

### Estado de Ánimo
- `GET /api/v1/mood/logs` - Obtener registros
- `POST /api/v1/mood/logs` - Crear/actualizar registro
- `GET /api/v1/mood/stats` - Obtener estadísticas
- `GET /api/v1/mood/today` - Obtener registro de hoy
- `DELETE /api/v1/mood/logs/:id` - Eliminar registro

### Diario
- `GET /api/v1/journal/entries` - Listar entradas
- `POST /api/v1/journal/entries` - Crear entrada
- `GET /api/v1/journal/entries/:id` - Obtener entrada
- `PUT /api/v1/journal/entries/:id` - Actualizar entrada
- `DELETE /api/v1/journal/entries/:id` - Eliminar entrada
- `GET /api/v1/journal/stats` - Obtener estadísticas

### Suscripciones
- `GET /api/v1/subscriptions/status` - Estado de suscripción
- `GET /api/v1/subscriptions/features` - Características de planes
- `POST /api/v1/subscriptions/upgrade-demo` - Activar premium (demo)
- `POST /api/v1/subscriptions/cancel` - Cancelar suscripción

## 🎉 ¡Listo!

Si todo está funcionando correctamente, deberías poder:

- ✅ Registrarte e iniciar sesión
- ✅ Ver y reproducir meditaciones
- ✅ Registrar tu estado de ánimo diario
- ✅ Escribir entradas en tu diario
- ✅ Ver estadísticas y tendencias
- ✅ Probar funciones premium (con modo demo)

## 📚 Recursos Adicionales

- **Backend README:** `backend/README.md`
- **Configuración MongoDB:** `backend/MONGODB_SETUP.md`
- **Estado del Proyecto:** `PROJECT_STATUS.md`
- **Guía de Inicio Rápido:** `QUICKSTART.md`

## 🆘 ¿Necesitas ayuda?

Si encuentras problemas:
1. Revisa los logs del backend y Flutter
2. Consulta la sección de "Problemas Comunes"
3. Verifica que todas las dependencias estén instaladas
4. Asegúrate de que MongoDB esté accesible
