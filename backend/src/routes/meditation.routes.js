const express = require('express');
const { protect, optionalAuth } = require('../middleware/auth');

const router = express.Router();

// TODO: Implementar endpoints de meditaciones en Sprint 2
// GET /meditations - Lista todas las meditaciones
// GET /meditations/:id - Obtiene detalles de una meditación
// GET /meditations/:id/stream - Obtiene URL firmada de S3
// POST /meditations/:id/complete - Registra sesión completada
// GET /meditations/favorites - Lista favoritas
// POST /meditations/:id/favorite - Marca como favorita
// DELETE /meditations/:id/favorite - Elimina de favoritos

router.get('/', optionalAuth, (req, res) => {
  res.json({
    success: true,
    message: 'Endpoint de meditaciones - Próximamente en Sprint 2',
    data: { meditations: [] },
  });
});

module.exports = router;
