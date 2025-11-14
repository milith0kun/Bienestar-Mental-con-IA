# Configuración de MongoDB Atlas

## ⚠️ Problema de Conexión Detectado

El backend está configurado para conectarse a MongoDB Atlas, pero actualmente no puede establecer la conexión.

**Error:** `querySrv ECONNREFUSED _mongodb._tcp.cluster0.cpt00yd.mongodb.net`

## 📋 Pasos para Resolver

### 1. Verificar que el Clúster está Activo

1. Inicia sesión en [MongoDB Atlas](https://cloud.mongodb.com/)
2. Ve a tu clúster "Cluster0"
3. Verifica que el estado sea "Active" (no "Paused")
4. Si está pausado, haz clic en "Resume" para activarlo

### 2. Configurar Lista Blanca de IPs (Network Access)

MongoDB Atlas requiere que agregues las IPs desde las que te conectarás:

1. En MongoDB Atlas, ve a **Network Access** (en el menú lateral)
2. Haz clic en **"Add IP Address"**
3. Para desarrollo, puedes usar:
   - **Opción 1 (Recomendada para desarrollo):** Agregar `0.0.0.0/0` para permitir todas las IPs
   - **Opción 2 (Más segura):** Agregar solo tu IP actual
4. Haz clic en **"Confirm"**

### 3. Verificar Credenciales de Usuario

1. En MongoDB Atlas, ve a **Database Access**
2. Verifica que el usuario `milith0dev_db_user` existe
3. Si no existe, créalo con:
   - Username: `milith0dev_db_user`
   - Password: `1997281qA`
   - Database User Privileges: "Atlas admin" o "Read and write to any database"

### 4. Verificar la URI de Conexión

La URI actual en `.env` es:
```
mongodb+srv://milith0dev_db_user:1997281qA@cluster0.cpt00yd.mongodb.net/mindflow?retryWrites=true&w=majority&appName=Cluster0
```

Verifica que:
- El nombre del clúster sea correcto: `cluster0.cpt00yd.mongodb.net`
- El nombre de la base de datos sea: `mindflow`
- Las credenciales sean correctas

### 5. Probar la Conexión

Después de realizar los cambios anteriores, ejecuta:

```bash
cd backend
npm run test:connection
```

## 🧪 Script de Prueba Manual

También puedes probar manualmente:

```bash
node scripts/test-connection.js
```

## 📝 Configuración Actual

- **Base de datos:** mindflow
- **Usuario:** milith0dev_db_user
- **Clúster:** cluster0.cpt00yd.mongodb.net
- **Modelos configurados:**
  - User (Usuarios)
  - MoodLog (Registro de estados de ánimo)
  - JournalEntry (Entradas de diario)
  - Meditation (Meditaciones)

## 🔍 Verificación de Estado

Una vez que la conexión funcione, verás:
```
✅ ¡Conexión exitosa a MongoDB Atlas!
📊 Base de datos: mindflow
🌐 Host: cluster0-shard-00-00.cpt00yd.mongodb.net
```

## 🆘 Soporte

Si el problema persiste:
1. Verifica tu conexión a internet
2. Revisa los logs de MongoDB Atlas
3. Considera usar un túnel o VPN si estás detrás de un firewall corporativo
