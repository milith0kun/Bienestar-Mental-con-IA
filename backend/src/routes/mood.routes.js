const express = require('express');
const { protect } = require('../middleware/auth');

const router = express.Router();

// Todas las rutas requieren autenticación
router.use(protect);

// TODO: Implementar endpoints de estado de ánimo en Sprint 3
// GET /mood/logs - Obtiene registros de estado de ánimo
// POST /mood/logs - Registra estado de ánimo diario
// GET /mood/trends - Obtiene análisis de tendencias emocionales

router.get('/logs', (req, res) => {
  res.json({
    success: true,
    message: 'Endpoint de estado de ánimo - Próximamente en Sprint 3',
    data: { logs: [] },
  });
});

module.exports = router;
