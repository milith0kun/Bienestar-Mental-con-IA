const express = require('express');
const Joi = require('joi');
const { protect } = require('../middleware/auth');
const { validate } = require('../middleware/validation');
const moodController = require('../controllers/mood.controller');

const router = express.Router();

// Todas las rutas requieren autenticación
router.use(protect);

// Validation schemas
const createMoodSchema = Joi.object({
  mood: Joi.number().min(1).max(10).required().messages({
    'number.min': 'El valor mínimo es 1',
    'number.max': 'El valor máximo es 10',
    'any.required': 'El estado de ánimo es requerido',
  }),
  emotions: Joi.array().items(
    Joi.string().valid(
      'happy', 'sad', 'anxious', 'calm', 'energetic', 'tired',
      'angry', 'peaceful', 'stressed', 'grateful', 'hopeful',
      'lonely', 'loved', 'motivated'
    )
  ).messages({
    'any.only': 'Emoción no válida',
  }),
  notes: Joi.string().max(500).allow('').messages({
    'string.max': 'Las notas no pueden exceder 500 caracteres',
  }),
  date: Joi.date().messages({
    'date.base': 'Fecha inválida',
  }),
});

// Routes
router.post('/logs', validate(createMoodSchema), moodController.createMoodLog);
router.get('/logs', moodController.getMoodLogs);
router.get('/stats', moodController.getMoodStats);
router.get('/today', moodController.getTodayMood);
router.delete('/logs/:id', moodController.deleteMoodLog);

module.exports = router;
