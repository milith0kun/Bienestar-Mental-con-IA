const express = require('express');
const Joi = require('joi');
const { validate } = require('../middleware/validation');
const { protect } = require('../middleware/auth');
const userController = require('../controllers/user.controller');

const router = express.Router();

// Todas las rutas requieren autenticación
router.use(protect);

// Validation schemas
const updateProfileSchema = Joi.object({
  name: Joi.string().min(2).max(100).messages({
    'string.min': 'El nombre debe tener al menos 2 caracteres',
    'string.max': 'El nombre es demasiado largo',
  }),
  profilePicture: Joi.string().uri().allow(null, '').messages({
    'string.uri': 'Debe ser una URL válida',
  }),
});

const updatePreferencesSchema = Joi.object({
  notificationsEnabled: Joi.boolean(),
  meditationReminder: Joi.object({
    enabled: Joi.boolean(),
    time: Joi.string().pattern(/^([01]\d|2[0-3]):([0-5]\d)$/).messages({
      'string.pattern.base': 'La hora debe estar en formato HH:MM',
    }),
  }),
  moodReminder: Joi.object({
    enabled: Joi.boolean(),
    time: Joi.string().pattern(/^([01]\d|2[0-3]):([0-5]\d)$/).messages({
      'string.pattern.base': 'La hora debe estar en formato HH:MM',
    }),
  }),
});

const fcmTokenSchema = Joi.object({
  token: Joi.string().required().messages({
    'any.required': 'El token FCM es requerido',
  }),
});

// Routes
router.get('/profile', userController.getProfile);
router.put('/profile', validate(updateProfileSchema), userController.updateProfile);
router.get('/stats', userController.getStats);
router.put('/preferences', validate(updatePreferencesSchema), userController.updatePreferences);
router.post('/fcm-token', validate(fcmTokenSchema), userController.addFcmToken);
router.delete('/fcm-token', validate(fcmTokenSchema), userController.removeFcmToken);
router.delete('/account', userController.deleteAccount);

module.exports = router;
