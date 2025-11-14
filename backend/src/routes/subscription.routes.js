const express = require('express');
const { protect } = require('../middleware/auth');

const router = express.Router();

// TODO: Implementar endpoints de suscripción en Sprint 4
// POST /subscriptions/create-checkout - Crea sesión de checkout Stripe
// POST /subscriptions/webhook - Webhook de Stripe
// POST /subscriptions/cancel - Cancela suscripción
// GET /subscriptions/status - Obtiene estado de suscripción

router.get('/status', protect, (req, res) => {
  res.json({
    success: true,
    message: 'Endpoint de suscripciones - Próximamente en Sprint 4',
    data: {
      plan: req.user.subscription.plan,
      status: req.user.subscription.status,
    },
  });
});

module.exports = router;
