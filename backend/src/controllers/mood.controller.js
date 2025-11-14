const MoodLog = require('../models/MoodLog.model');

/**
 * @route   POST /api/v1/mood/logs
 * @desc    Crear o actualizar registro de estado de ánimo del día
 * @access  Private
 */
exports.createMoodLog = async (req, res, next) => {
  try {
    const { mood, emotions, notes, date } = req.body;
    const userId = req.user._id;

    // Normalizar fecha a solo día (sin hora)
    const logDate = date ? new Date(date) : new Date();
    logDate.setHours(0, 0, 0, 0);

    // Verificar si ya existe un registro para este día
    let moodLog = await MoodLog.findOne({
      userId,
      date: logDate,
    });

    if (moodLog) {
      // Actualizar registro existente
      moodLog.mood = mood;
      moodLog.emotions = emotions || [];
      moodLog.notes = notes || '';
      await moodLog.save();

      return res.status(200).json({
        success: true,
        message: 'Registro de estado de ánimo actualizado',
        data: { moodLog },
      });
    }

    // Crear nuevo registro
    moodLog = await MoodLog.create({
      userId,
      date: logDate,
      mood,
      emotions: emotions || [],
      notes: notes || '',
    });

    res.status(201).json({
      success: true,
      message: 'Estado de ánimo registrado exitosamente',
      data: { moodLog },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   GET /api/v1/mood/logs
 * @desc    Obtener registros de estado de ánimo
 * @access  Private
 * @query   startDate, endDate (opcional)
 */
exports.getMoodLogs = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const { startDate, endDate } = req.query;

    let logs;

    if (startDate && endDate) {
      // Obtener logs en rango de fechas
      logs = await MoodLog.getByDateRange(userId, startDate, endDate);
    } else {
      // Obtener últimos 30 días por defecto
      const end = new Date();
      const start = new Date();
      start.setDate(start.getDate() - 30);
      logs = await MoodLog.getByDateRange(userId, start, end);
    }

    res.status(200).json({
      success: true,
      data: {
        logs,
        count: logs.length,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   GET /api/v1/mood/stats
 * @desc    Obtener estadísticas y tendencias de estado de ánimo
 * @access  Private
 * @query   days (opcional, default: 7)
 */
exports.getMoodStats = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const days = parseInt(req.query.days) || 7;

    // Obtener promedio
    const averageMood = await MoodLog.getAverageMood(userId, days);

    // Obtener tendencia
    const trend = await MoodLog.getTrend(userId, days);

    // Obtener logs para análisis adicional
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);
    startDate.setHours(0, 0, 0, 0);

    const logs = await MoodLog.find({
      userId,
      date: { $gte: startDate },
    }).sort({ date: 1 });

    // Calcular emociones más frecuentes
    const emotionCount = {};
    logs.forEach(log => {
      log.emotions.forEach(emotion => {
        emotionCount[emotion] = (emotionCount[emotion] || 0) + 1;
      });
    });

    const topEmotions = Object.entries(emotionCount)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5)
      .map(([emotion, count]) => ({ emotion, count }));

    res.status(200).json({
      success: true,
      data: {
        period: {
          days,
          startDate,
          endDate: new Date(),
        },
        stats: {
          averageMood: averageMood ? parseFloat(averageMood) : null,
          trend,
          totalLogs: logs.length,
          topEmotions,
        },
        logs,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   GET /api/v1/mood/today
 * @desc    Obtener registro de hoy
 * @access  Private
 */
exports.getTodayMood = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const moodLog = await MoodLog.findOne({
      userId,
      date: today,
    });

    res.status(200).json({
      success: true,
      data: {
        moodLog,
        hasLoggedToday: !!moodLog,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   DELETE /api/v1/mood/logs/:id
 * @desc    Eliminar registro de estado de ánimo
 * @access  Private
 */
exports.deleteMoodLog = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const { id } = req.params;

    const moodLog = await MoodLog.findOne({ _id: id, userId });

    if (!moodLog) {
      return res.status(404).json({
        success: false,
        message: 'Registro no encontrado',
      });
    }

    await moodLog.deleteOne();

    res.status(200).json({
      success: true,
      message: 'Registro eliminado exitosamente',
    });
  } catch (error) {
    next(error);
  }
};
