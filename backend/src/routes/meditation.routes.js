const express = require('express');
const Joi = require('joi');
const { protect, optionalAuth } = require('../middleware/auth');
const { validate } = require('../middleware/validation');
const meditationController = require('../controllers/meditation.controller');

const router = express.Router();

// Validation schemas
const completeMeditationSchema = Joi.object({
  duration: Joi.number().min(0).messages({
    'number.min': 'La duración no puede ser negativa',
  }),
});

const rateMeditationSchema = Joi.object({
  rating: Joi.number().min(1).max(5).required().messages({
    'number.min': 'La calificación mínima es 1',
    'number.max': 'La calificación máxima es 5',
    'any.required': 'La calificación es requerida',
  }),
});

// Public routes (con autenticación opcional)
router.get('/', optionalAuth, meditationController.getMeditations);
router.get('/categories', meditationController.getCategories);
router.get('/featured', meditationController.getFeaturedMeditations);
router.get('/:id', optionalAuth, meditationController.getMeditation);

// Protected routes (requieren autenticación)
router.post('/:id/play', protect, meditationController.playMeditation);
router.post('/:id/complete', protect, validate(completeMeditationSchema), meditationController.completeMeditation);
router.post('/:id/rate', protect, validate(rateMeditationSchema), meditationController.rateMeditation);

module.exports = router;
