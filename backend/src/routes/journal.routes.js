const express = require('express');
const Joi = require('joi');
const { protect } = require('../middleware/auth');
const { validate } = require('../middleware/validation');
const journalController = require('../controllers/journal.controller');

const router = express.Router();

// Todas las rutas requieren autenticación
router.use(protect);

// Validation schemas
const createEntrySchema = Joi.object({
  title: Joi.string().min(1).max(200).required().messages({
    'string.min': 'El título no puede estar vacío',
    'string.max': 'El título no puede exceder 200 caracteres',
    'any.required': 'El título es requerido',
  }),
  content: Joi.string().min(1).max(5000).required().messages({
    'string.min': 'El contenido no puede estar vacío',
    'string.max': 'El contenido no puede exceder 5000 caracteres',
    'any.required': 'El contenido es requerido',
  }),
  mood: Joi.string().valid('very-bad', 'bad', 'neutral', 'good', 'very-good').required().messages({
    'any.only': 'Estado de ánimo inválido',
    'any.required': 'El estado de ánimo es requerido',
  }),
});

const updateEntrySchema = Joi.object({
  title: Joi.string().min(1).max(200).messages({
    'string.min': 'El título no puede estar vacío',
    'string.max': 'El título no puede exceder 200 caracteres',
  }),
  content: Joi.string().min(1).max(5000).messages({
    'string.min': 'El contenido no puede estar vacío',
    'string.max': 'El contenido no puede exceder 5000 caracteres',
  }),
  mood: Joi.string().valid('very-bad', 'bad', 'neutral', 'good', 'very-good').messages({
    'any.only': 'Estado de ánimo inválido',
  }),
});

// Routes
router.post('/entries', validate(createEntrySchema), journalController.createEntry);
router.get('/entries', journalController.getEntries);
router.get('/entries/:id', journalController.getEntry);
router.put('/entries/:id', validate(updateEntrySchema), journalController.updateEntry);
router.delete('/entries/:id', journalController.deleteEntry);
router.get('/stats', journalController.getStats);

module.exports = router;
