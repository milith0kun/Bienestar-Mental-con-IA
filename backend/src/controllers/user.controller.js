const User = require('../models/User.model');

/**
 * @route   GET /api/v1/users/profile
 * @desc    Obtener perfil del usuario autenticado
 * @access  Private
 */
exports.getProfile = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Usuario no encontrado',
      });
    }

    res.json({
      success: true,
      data: {
        user: {
          id: user._id,
          email: user.email,
          name: user.name,
          profilePicture: user.profilePicture,
          authProvider: user.authProvider,
          subscription: user.subscription,
          preferences: user.preferences,
          stats: user.stats,
          createdAt: user.createdAt,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   PUT /api/v1/users/profile
 * @desc    Actualizar perfil del usuario
 * @access  Private
 */
exports.updateProfile = async (req, res, next) => {
  try {
    const { name, profilePicture } = req.body;

    const user = await User.findById(req.user._id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Usuario no encontrado',
      });
    }

    // Actualizar campos permitidos
    if (name) user.name = name;
    if (profilePicture !== undefined) user.profilePicture = profilePicture;

    await user.save();

    res.json({
      success: true,
      message: 'Perfil actualizado exitosamente',
      data: {
        user: {
          id: user._id,
          email: user.email,
          name: user.name,
          profilePicture: user.profilePicture,
          subscription: user.subscription,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   GET /api/v1/users/stats
 * @desc    Obtener estadísticas del usuario
 * @access  Private
 */
exports.getStats = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Usuario no encontrado',
      });
    }

    // Resetear contador mensual de entradas de diario si es necesario
    user.resetMonthlyJournalCount();
    await user.save();

    res.json({
      success: true,
      data: {
        stats: {
          totalMeditations: user.stats.totalMeditations,
          totalMeditationTime: user.stats.totalMeditationTime,
          totalMeditationTimeFormatted: formatSeconds(user.stats.totalMeditationTime),
          consecutiveDays: user.stats.consecutiveDays,
          lastMeditationDate: user.stats.lastMeditationDate,
          journalEntries: user.stats.journalEntries,
          journalEntriesThisMonth: user.stats.journalEntriesThisMonth,
          journalEntriesRemaining: user.isPremium() ? 'unlimited' : Math.max(0, 10 - user.stats.journalEntriesThisMonth),
        },
        subscription: {
          plan: user.subscription.plan,
          status: user.subscription.status,
          isPremium: user.isPremium(),
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   PUT /api/v1/users/preferences
 * @desc    Actualizar preferencias del usuario
 * @access  Private
 */
exports.updatePreferences = async (req, res, next) => {
  try {
    const {
      notificationsEnabled,
      meditationReminder,
      moodReminder,
    } = req.body;

    const user = await User.findById(req.user._id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Usuario no encontrado',
      });
    }

    // Actualizar preferencias
    if (notificationsEnabled !== undefined) {
      user.preferences.notificationsEnabled = notificationsEnabled;
    }

    if (meditationReminder) {
      if (meditationReminder.enabled !== undefined) {
        user.preferences.meditationReminder.enabled = meditationReminder.enabled;
      }
      if (meditationReminder.time) {
        user.preferences.meditationReminder.time = meditationReminder.time;
      }
    }

    if (moodReminder) {
      if (moodReminder.enabled !== undefined) {
        user.preferences.moodReminder.enabled = moodReminder.enabled;
      }
      if (moodReminder.time) {
        user.preferences.moodReminder.time = moodReminder.time;
      }
    }

    await user.save();

    res.json({
      success: true,
      message: 'Preferencias actualizadas exitosamente',
      data: {
        preferences: user.preferences,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   POST /api/v1/users/fcm-token
 * @desc    Agregar token FCM para notificaciones push
 * @access  Private
 */
exports.addFcmToken = async (req, res, next) => {
  try {
    const { token } = req.body;

    if (!token) {
      return res.status(400).json({
        success: false,
        message: 'Token FCM es requerido',
      });
    }

    const user = await User.findById(req.user._id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Usuario no encontrado',
      });
    }

    // Agregar token si no existe
    if (!user.fcmTokens.includes(token)) {
      user.fcmTokens.push(token);
      await user.save();
    }

    res.json({
      success: true,
      message: 'Token FCM agregado exitosamente',
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   DELETE /api/v1/users/fcm-token
 * @desc    Eliminar token FCM
 * @access  Private
 */
exports.removeFcmToken = async (req, res, next) => {
  try {
    const { token } = req.body;

    if (!token) {
      return res.status(400).json({
        success: false,
        message: 'Token FCM es requerido',
      });
    }

    const user = await User.findById(req.user._id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Usuario no encontrado',
      });
    }

    // Eliminar token
    user.fcmTokens = user.fcmTokens.filter(t => t !== token);
    await user.save();

    res.json({
      success: true,
      message: 'Token FCM eliminado exitosamente',
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   DELETE /api/v1/users/account
 * @desc    Eliminar cuenta de usuario
 * @access  Private
 */
exports.deleteAccount = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Usuario no encontrado',
      });
    }

    // Eliminar todos los datos asociados
    const JournalEntry = require('../models/JournalEntry.model');
    const MoodLog = require('../models/MoodLog.model');

    await JournalEntry.deleteMany({ userId: user._id });
    await MoodLog.deleteMany({ userId: user._id });
    await user.deleteOne();

    res.json({
      success: true,
      message: 'Cuenta eliminada exitosamente',
    });
  } catch (error) {
    next(error);
  }
};

// Helper function
function formatSeconds(seconds) {
  const hours = Math.floor(seconds / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);

  if (hours > 0) {
    return `${hours}h ${minutes}m`;
  }
  return `${minutes}m`;
}
