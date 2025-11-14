const User = require('../models/User.model');

/**
 * @route   GET /api/v1/subscriptions/status
 * @desc    Obtener estado de suscripción del usuario
 * @access  Private
 */
exports.getSubscriptionStatus = async (req, res, next) => {
  try {
    const user = req.user;

    res.status(200).json({
      success: true,
      data: {
        subscription: {
          plan: user.subscription.plan,
          status: user.subscription.status,
          isPremium: user.isPremium(),
          startDate: user.subscription.startDate,
          endDate: user.subscription.endDate,
        },
        features: {
          unlimitedJournalEntries: user.isPremium(),
          premiumMeditations: user.isPremium(),
          aiInsights: user.isPremium(),
          exportData: user.isPremium(),
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   POST /api/v1/subscriptions/upgrade-demo
 * @desc    Actualizar a premium (solo para desarrollo/demostración)
 * @access  Private
 */
exports.upgradeToPremiumDemo = async (req, res, next) => {
  try {
    const userId = req.user._id;

    const user = await User.findById(userId);

    if (user.isPremium()) {
      return res.status(400).json({
        success: false,
        message: 'Ya tienes una suscripción premium activa',
      });
    }

    // Activar premium (modo demo)
    user.subscription.plan = 'premium';
    user.subscription.status = 'active';
    user.subscription.startDate = new Date();

    // Premium por 30 días en demo
    const endDate = new Date();
    endDate.setDate(endDate.getDate() + 30);
    user.subscription.endDate = endDate;

    await user.save();

    res.status(200).json({
      success: true,
      message: 'Suscripción premium activada (modo demo - 30 días)',
      data: {
        subscription: {
          plan: user.subscription.plan,
          status: user.subscription.status,
          startDate: user.subscription.startDate,
          endDate: user.subscription.endDate,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   POST /api/v1/subscriptions/cancel
 * @desc    Cancelar suscripción premium
 * @access  Private
 */
exports.cancelSubscription = async (req, res, next) => {
  try {
    const userId = req.user._id;

    const user = await User.findById(userId);

    if (!user.isPremium()) {
      return res.status(400).json({
        success: false,
        message: 'No tienes una suscripción premium activa',
      });
    }

    // Cancelar suscripción
    user.subscription.plan = 'free';
    user.subscription.status = 'canceled';
    user.subscription.endDate = new Date();

    await user.save();

    res.status(200).json({
      success: true,
      message: 'Suscripción cancelada exitosamente',
      data: {
        subscription: {
          plan: user.subscription.plan,
          status: user.subscription.status,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   GET /api/v1/subscriptions/features
 * @desc    Obtener lista de características premium
 * @access  Public
 */
exports.getPremiumFeatures = async (req, res, next) => {
  try {
    const features = {
      free: {
        name: 'Plan Gratuito',
        price: 0,
        features: [
          'Registro diario de estado de ánimo',
          '10 entradas de diario al mes',
          'Biblioteca básica de meditaciones',
          'Estadísticas básicas',
        ],
      },
      premium: {
        name: 'Plan Premium',
        price: 9.99,
        currency: 'USD',
        period: 'mes',
        features: [
          'Todo lo del plan gratuito',
          'Entradas de diario ilimitadas',
          'Análisis de IA avanzado',
          'Biblioteca completa de meditaciones premium',
          'Estadísticas y tendencias avanzadas',
          'Insights personalizados',
          'Exportación de datos',
          'Soporte prioritario',
        ],
      },
    };

    res.status(200).json({
      success: true,
      data: { plans: features },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   POST /api/v1/subscriptions/create-checkout
 * @desc    Crear sesión de checkout (placeholder para integración con Stripe)
 * @access  Private
 */
exports.createCheckoutSession = async (req, res, next) => {
  try {
    // En producción, aquí se crearía una sesión de Stripe
    // Por ahora, solo retornamos información
    res.status(200).json({
      success: true,
      message: 'Stripe no está configurado. Usa /upgrade-demo para activar premium en modo desarrollo',
      data: {
        isDemoMode: true,
        useEndpoint: '/api/v1/subscriptions/upgrade-demo',
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   POST /api/v1/subscriptions/webhook
 * @desc    Webhook de Stripe (placeholder)
 * @access  Public (validado por Stripe signature)
 */
exports.stripeWebhook = async (req, res, next) => {
  try {
    // En producción, aquí se procesarían los eventos de Stripe
    res.status(200).json({ received: true });
  } catch (error) {
    next(error);
  }
};
