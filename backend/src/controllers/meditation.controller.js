const Meditation = require('../models/Meditation.model');
const User = require('../models/User.model');

/**
 * @route   GET /api/v1/meditations
 * @desc    Obtener lista de meditaciones
 * @access  Public (algunas requieren premium)
 * @query   category, difficulty, search
 */
exports.getMeditations = async (req, res, next) => {
  try {
    const { category, difficulty, search, page = 1, limit = 20 } = req.query;
    const userId = req.user?._id;

    // Construir query
    const query = { isActive: true };

    if (category) {
      query.category = category;
    }

    if (difficulty) {
      query.difficulty = difficulty;
    }

    if (search) {
      query.$text = { $search: search };
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const meditations = await Meditation.find(query)
      .sort({ averageRating: -1, plays: -1 })
      .limit(parseInt(limit))
      .skip(skip);

    const total = await Meditation.countDocuments(query);

    // Si hay usuario autenticado, verificar cuáles puede acceder
    let meditationsWithAccess = meditations;
    if (userId) {
      const user = await User.findById(userId);
      const isPremium = user.isPremium();

      meditationsWithAccess = meditations.map(med => {
        const meditation = med.toJSON();
        meditation.hasAccess = !meditation.isPremium || isPremium;
        meditation.requiresPremium = meditation.isPremium && !isPremium;
        return meditation;
      });
    } else {
      // Usuario no autenticado
      meditationsWithAccess = meditations.map(med => {
        const meditation = med.toJSON();
        meditation.hasAccess = !meditation.isPremium;
        meditation.requiresPremium = meditation.isPremium;
        return meditation;
      });
    }

    res.status(200).json({
      success: true,
      data: {
        meditations: meditationsWithAccess,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / parseInt(limit)),
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   GET /api/v1/meditations/categories
 * @desc    Obtener categorías disponibles con conteo
 * @access  Public
 */
exports.getCategories = async (req, res, next) => {
  try {
    const categories = await Meditation.aggregate([
      { $match: { isActive: true } },
      {
        $group: {
          _id: '$category',
          count: { $sum: 1 },
          avgDuration: { $avg: '$duration' },
        },
      },
      { $sort: { count: -1 } },
    ]);

    const categoryNames = {
      anxiety: 'Ansiedad',
      stress: 'Estrés',
      sleep: 'Sueño',
      focus: 'Enfoque',
      'self-esteem': 'Autoestima',
      gratitude: 'Gratitud',
      general: 'Bienestar General',
    };

    const categoriesWithNames = categories.map(cat => ({
      id: cat._id,
      name: categoryNames[cat._id] || cat._id,
      count: cat.count,
      avgDuration: Math.round(cat.avgDuration),
    }));

    res.status(200).json({
      success: true,
      data: { categories: categoriesWithNames },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   GET /api/v1/meditations/:id
 * @desc    Obtener detalles de una meditación
 * @access  Public
 */
exports.getMeditation = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user?._id;

    const meditation = await Meditation.findOne({ _id: id, isActive: true });

    if (!meditation) {
      return res.status(404).json({
        success: false,
        message: 'Meditación no encontrada',
      });
    }

    const meditationData = meditation.toJSON();

    // Verificar acceso
    if (userId) {
      const user = await User.findById(userId);
      const isPremium = user.isPremium();
      meditationData.hasAccess = !meditation.isPremium || isPremium;
      meditationData.requiresPremium = meditation.isPremium && !isPremium;
    } else {
      meditationData.hasAccess = !meditation.isPremium;
      meditationData.requiresPremium = meditation.isPremium;
    }

    res.status(200).json({
      success: true,
      data: { meditation: meditationData },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   POST /api/v1/meditations/:id/play
 * @desc    Registrar reproducción de meditación
 * @access  Private
 */
exports.playMeditation = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user._id;

    const meditation = await Meditation.findOne({ _id: id, isActive: true });

    if (!meditation) {
      return res.status(404).json({
        success: false,
        message: 'Meditación no encontrada',
      });
    }

    // Verificar si el usuario tiene acceso
    const user = await User.findById(userId);
    if (meditation.isPremium && !user.isPremium()) {
      return res.status(403).json({
        success: false,
        message: 'Esta meditación requiere suscripción Premium',
        error: 'PREMIUM_REQUIRED',
      });
    }

    // Incrementar contador de reproducciones
    await meditation.incrementPlays();

    res.status(200).json({
      success: true,
      message: 'Reproducción registrada',
      data: {
        audioUrl: meditation.audioUrl,
        meditation: meditation.toJSON(),
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   POST /api/v1/meditations/:id/complete
 * @desc    Registrar meditación completada
 * @access  Private
 */
exports.completeMeditation = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { duration } = req.body; // Duración real que completó el usuario
    const userId = req.user._id;

    const meditation = await Meditation.findById(id);

    if (!meditation) {
      return res.status(404).json({
        success: false,
        message: 'Meditación no encontrada',
      });
    }

    // Actualizar estadísticas del usuario
    const user = await User.findById(userId);

    user.stats.totalMeditations += 1;
    user.stats.totalMeditationTime += duration || meditation.duration;

    // Calcular racha de días consecutivos
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const lastMeditation = user.stats.lastMeditationDate;
    if (lastMeditation) {
      const lastDate = new Date(lastMeditation);
      lastDate.setHours(0, 0, 0, 0);

      const daysDiff = Math.floor((today - lastDate) / (1000 * 60 * 60 * 24));

      if (daysDiff === 1) {
        // Día consecutivo
        user.stats.consecutiveDays += 1;
      } else if (daysDiff === 0) {
        // Mismo día, no hacer nada con la racha
      } else {
        // Se rompió la racha
        user.stats.consecutiveDays = 1;
      }
    } else {
      // Primera meditación
      user.stats.consecutiveDays = 1;
    }

    user.stats.lastMeditationDate = new Date();
    await user.save();

    res.status(200).json({
      success: true,
      message: 'Meditación completada',
      data: {
        stats: {
          totalMeditations: user.stats.totalMeditations,
          totalMeditationTime: user.stats.totalMeditationTime,
          consecutiveDays: user.stats.consecutiveDays,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   POST /api/v1/meditations/:id/rate
 * @desc    Calificar una meditación
 * @access  Private
 */
exports.rateMeditation = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { rating } = req.body;

    if (rating < 1 || rating > 5) {
      return res.status(400).json({
        success: false,
        message: 'La calificación debe estar entre 1 y 5',
      });
    }

    const meditation = await Meditation.findById(id);

    if (!meditation) {
      return res.status(404).json({
        success: false,
        message: 'Meditación no encontrada',
      });
    }

    await meditation.updateRating(rating);

    res.status(200).json({
      success: true,
      message: 'Calificación registrada',
      data: {
        averageRating: meditation.averageRating,
        ratingsCount: meditation.ratingsCount,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   GET /api/v1/meditations/featured
 * @desc    Obtener meditaciones destacadas
 * @access  Public
 */
exports.getFeaturedMeditations = async (req, res, next) => {
  try {
    // Obtener las mejores calificadas y más populares
    const featured = await Meditation.find({ isActive: true })
      .sort({ averageRating: -1, plays: -1 })
      .limit(6);

    res.status(200).json({
      success: true,
      data: { meditations: featured },
    });
  } catch (error) {
    next(error);
  }
};
