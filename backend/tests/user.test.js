const request = require('supertest');
const mongoose = require('mongoose');
const app = require('../src/app');
const User = require('../src/models/User.model');

describe('User Endpoints', () => {
  let authToken;
  let userId;

  beforeAll(async () => {
    // Limpiar base de datos
    await User.deleteMany({});

    // Crear usuario de prueba y obtener token
    const response = await request(app).post('/api/v1/auth/register').send({
      name: 'Test User',
      email: 'test@example.com',
      password: 'Password123',
    });

    authToken = response.body.data.token;
    userId = response.body.data.user.id;
  });

  afterAll(async () => {
    await User.deleteMany({});
    await mongoose.connection.close();
  });

  describe('GET /api/v1/users/profile', () => {
    it('debe obtener perfil del usuario autenticado', async () => {
      const response = await request(app)
        .get('/api/v1/users/profile')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.user.email).toBe('test@example.com');
      expect(response.body.data.user.name).toBe('Test User');
      expect(response.body.data.user.subscription).toBeDefined();
      expect(response.body.data.user.stats).toBeDefined();
    });

    it('debe rechazar petición sin token', async () => {
      const response = await request(app)
        .get('/api/v1/users/profile')
        .expect(401);

      expect(response.body.success).toBe(false);
    });

    it('debe rechazar petición con token inválido', async () => {
      const response = await request(app)
        .get('/api/v1/users/profile')
        .set('Authorization', 'Bearer invalid_token')
        .expect(401);

      expect(response.body.success).toBe(false);
    });
  });

  describe('PUT /api/v1/users/profile', () => {
    it('debe actualizar nombre del usuario', async () => {
      const response = await request(app)
        .put('/api/v1/users/profile')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          name: 'Updated Name',
        })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.user.name).toBe('Updated Name');

      // Verificar en la base de datos
      const user = await User.findById(userId);
      expect(user.name).toBe('Updated Name');
    });

    it('debe actualizar foto de perfil', async () => {
      const profilePicture = 'https://example.com/photo.jpg';

      const response = await request(app)
        .put('/api/v1/users/profile')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          profilePicture,
        })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.user.profilePicture).toBe(profilePicture);
    });
  });

  describe('GET /api/v1/users/stats', () => {
    it('debe obtener estadísticas del usuario', async () => {
      const response = await request(app)
        .get('/api/v1/users/stats')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.stats).toBeDefined();
      expect(response.body.data.stats.totalMeditations).toBeDefined();
      expect(response.body.data.stats.totalMeditationTime).toBeDefined();
      expect(response.body.data.stats.journalEntries).toBeDefined();
      expect(response.body.data.subscription).toBeDefined();
    });
  });

  describe('PUT /api/v1/users/preferences', () => {
    it('debe actualizar preferencias de notificaciones', async () => {
      const response = await request(app)
        .put('/api/v1/users/preferences')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          notificationsEnabled: false,
          meditationReminder: {
            enabled: true,
            time: '08:00',
          },
        })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.preferences.notificationsEnabled).toBe(false);
      expect(response.body.data.preferences.meditationReminder.enabled).toBe(
        true
      );
      expect(response.body.data.preferences.meditationReminder.time).toBe(
        '08:00'
      );
    });
  });

  describe('POST /api/v1/users/fcm-token', () => {
    it('debe agregar token FCM', async () => {
      const fcmToken = 'test_fcm_token_123';

      const response = await request(app)
        .post('/api/v1/users/fcm-token')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ token: fcmToken })
        .expect(200);

      expect(response.body.success).toBe(true);

      // Verificar en la base de datos
      const user = await User.findById(userId);
      expect(user.fcmTokens).toContain(fcmToken);
    });
  });

  describe('DELETE /api/v1/users/fcm-token', () => {
    it('debe eliminar token FCM', async () => {
      const fcmToken = 'test_fcm_token_to_delete';

      // Primero agregar el token
      await request(app)
        .post('/api/v1/users/fcm-token')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ token: fcmToken });

      // Ahora eliminarlo
      const response = await request(app)
        .delete('/api/v1/users/fcm-token')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ token: fcmToken })
        .expect(200);

      expect(response.body.success).toBe(true);

      // Verificar en la base de datos
      const user = await User.findById(userId);
      expect(user.fcmTokens).not.toContain(fcmToken);
    });
  });
});
