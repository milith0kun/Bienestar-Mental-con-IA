const express = require('express');
const { protect } = require('../middleware/auth');

const router = express.Router();

// Todas las rutas requieren autenticación
router.use(protect);

// TODO: Implementar endpoints de diario emocional en Sprint 3
// GET /journal/entries - Lista entradas de diario
// POST /journal/entries - Crea nueva entrada con análisis IA
// GET /journal/entries/:id - Obtiene detalles de una entrada
// PUT /journal/entries/:id - Actualiza entrada
// DELETE /journal/entries/:id - Elimina entrada
// GET /journal/insights/weekly - Genera insights semanales

router.get('/entries', (req, res) => {
  res.json({
    success: true,
    message: 'Endpoint de diario emocional - Próximamente en Sprint 3',
    data: { entries: [] },
  });
});

module.exports = router;
