const JournalEntry = require('../models/JournalEntry.model');
const User = require('../models/User.model');

/**
 * @route   POST /api/v1/journal/entries
 * @desc    Crear nueva entrada de diario
 * @access  Private
 */
exports.createEntry = async (req, res, next) => {
  try {
    const { title, content, mood } = req.body;
    const userId = req.user._id;

    // Verificar si el usuario puede crear entrada
    const user = await User.findById(userId);
    user.resetMonthlyJournalCount();

    if (!user.canCreateJournalEntry()) {
      return res.status(403).json({
        success: false,
        message: 'Has alcanzado el límite de 10 entradas mensuales. Actualiza a Premium para entradas ilimitadas',
        error: 'JOURNAL_LIMIT_REACHED',
      });
    }

    // Crear entrada
    const entry = await JournalEntry.create({
      userId,
      title,
      content,
      mood,
    });

    // Actualizar contadores del usuario
    user.stats.journalEntries += 1;
    user.stats.journalEntriesThisMonth += 1;
    if (!user.stats.lastJournalReset) {
      user.stats.lastJournalReset = new Date();
    }
    await user.save();

    // Iniciar análisis de IA en background (si OpenAI está configurado)
    processJournalAnalysis(entry._id).catch(err =>
      console.error('Error en análisis de IA:', err)
    );

    res.status(201).json({
      success: true,
      message: 'Entrada de diario creada exitosamente',
      data: { entry },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   GET /api/v1/journal/entries
 * @desc    Obtener todas las entradas del usuario
 * @access  Private
 */
exports.getEntries = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const { page = 1, limit = 10, sortBy = 'createdAt', order = 'desc' } = req.query;

    const skip = (parseInt(page) - 1) * parseInt(limit);
    const sortOrder = order === 'asc' ? 1 : -1;

    const entries = await JournalEntry.find({ userId })
      .sort({ [sortBy]: sortOrder })
      .limit(parseInt(limit))
      .skip(skip);

    const total = await JournalEntry.countDocuments({ userId });

    res.status(200).json({
      success: true,
      data: {
        entries,
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
 * @route   GET /api/v1/journal/entries/:id
 * @desc    Obtener una entrada específica
 * @access  Private
 */
exports.getEntry = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const { id } = req.params;

    const entry = await JournalEntry.findOne({ _id: id, userId });

    if (!entry) {
      return res.status(404).json({
        success: false,
        message: 'Entrada no encontrada',
      });
    }

    res.status(200).json({
      success: true,
      data: { entry },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   PUT /api/v1/journal/entries/:id
 * @desc    Actualizar entrada de diario
 * @access  Private
 */
exports.updateEntry = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const { id } = req.params;
    const { title, content, mood } = req.body;

    const entry = await JournalEntry.findOne({ _id: id, userId });

    if (!entry) {
      return res.status(404).json({
        success: false,
        message: 'Entrada no encontrada',
      });
    }

    // Actualizar campos
    if (title !== undefined) entry.title = title;
    if (content !== undefined) entry.content = content;
    if (mood !== undefined) entry.mood = mood;

    await entry.save();

    // Si el contenido cambió, re-analizar con IA
    if (content !== undefined) {
      entry.aiAnalysis.status = 'pending';
      await entry.save();
      processJournalAnalysis(entry._id).catch(err =>
        console.error('Error en análisis de IA:', err)
      );
    }

    res.status(200).json({
      success: true,
      message: 'Entrada actualizada exitosamente',
      data: { entry },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   DELETE /api/v1/journal/entries/:id
 * @desc    Eliminar entrada de diario
 * @access  Private
 */
exports.deleteEntry = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const { id } = req.params;

    const entry = await JournalEntry.findOne({ _id: id, userId });

    if (!entry) {
      return res.status(404).json({
        success: false,
        message: 'Entrada no encontrada',
      });
    }

    await entry.deleteOne();

    // Actualizar contador del usuario
    const user = await User.findById(userId);
    if (user.stats.journalEntries > 0) {
      user.stats.journalEntries -= 1;
    }
    await user.save();

    res.status(200).json({
      success: true,
      message: 'Entrada eliminada exitosamente',
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   GET /api/v1/journal/stats
 * @desc    Obtener estadísticas de diario
 * @access  Private
 */
exports.getStats = async (req, res, next) => {
  try {
    const userId = req.user._id;

    // Contar total de entradas
    const totalEntries = await JournalEntry.countDocuments({ userId });

    // Entradas este mes
    const startOfMonth = new Date();
    startOfMonth.setDate(1);
    startOfMonth.setHours(0, 0, 0, 0);

    const entriesThisMonth = await JournalEntry.countDocuments({
      userId,
      createdAt: { $gte: startOfMonth },
    });

    // Distribución de mood
    const moodDistribution = await JournalEntry.aggregate([
      { $match: { userId } },
      { $group: { _id: '$mood', count: { $sum: 1 } } },
      { $sort: { count: -1 } },
    ]);

    // Temas más frecuentes (de análisis IA)
    const themesAnalysis = await JournalEntry.aggregate([
      { $match: { userId, 'aiAnalysis.themes': { $exists: true, $ne: [] } } },
      { $unwind: '$aiAnalysis.themes' },
      { $group: { _id: '$aiAnalysis.themes', count: { $sum: 1 } } },
      { $sort: { count: -1 } },
      { $limit: 10 },
    ]);

    // Verificar si puede crear más entradas
    const user = await User.findById(userId);
    user.resetMonthlyJournalCount();
    const canCreate = user.canCreateJournalEntry();
    const remaining = user.isPremium() ? 'unlimited' : 10 - user.stats.journalEntriesThisMonth;

    res.status(200).json({
      success: true,
      data: {
        stats: {
          totalEntries,
          entriesThisMonth,
          canCreateMore: canCreate,
          remaining,
          isPremium: user.isPremium(),
        },
        moodDistribution,
        topThemes: themesAnalysis.map(t => ({
          theme: t._id,
          count: t.count,
        })),
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Función auxiliar para procesar análisis de IA
 * Esta es una versión simplificada - en producción usaría OpenAI API
 */
async function processJournalAnalysis(entryId) {
  try {
    const entry = await JournalEntry.findById(entryId);
    if (!entry) return;

    await entry.startProcessing();

    // Simulación de análisis (en producción usar OpenAI)
    // Por ahora, solo marcamos como completado con datos de ejemplo
    const mockAnalysis = {
      sentiment: {
        overall: entry.mood === 'very-good' || entry.mood === 'good' ? 'positive' :
                 entry.mood === 'very-bad' || entry.mood === 'bad' ? 'negative' : 'neutral',
        score: entry.mood === 'very-good' ? 0.8 :
               entry.mood === 'good' ? 0.4 :
               entry.mood === 'bad' ? -0.4 :
               entry.mood === 'very-bad' ? -0.8 : 0,
        emotions: [],
      },
      themes: extractThemes(entry.content),
      insights: generateInsights(entry.mood, entry.content),
    };

    await entry.saveAnalysis(mockAnalysis);
  } catch (error) {
    const entry = await JournalEntry.findById(entryId);
    if (entry) {
      await entry.markAnalysisError(error.message);
    }
  }
}

/**
 * Extraer temas del contenido (versión simple)
 */
function extractThemes(content) {
  const themes = [];
  const lowerContent = content.toLowerCase();

  const themeKeywords = {
    'trabajo': ['trabajo', 'laboral', 'oficina', 'jefe', 'compañeros'],
    'familia': ['familia', 'papá', 'mamá', 'hermano', 'hermana', 'hijo', 'hija'],
    'pareja': ['pareja', 'novio', 'novia', 'esposo', 'esposa', 'amor'],
    'amigos': ['amigo', 'amiga', 'amistad'],
    'salud': ['salud', 'médico', 'enfermedad', 'dolor', 'ejercicio'],
    'dinero': ['dinero', 'financiero', 'pago', 'deuda', 'ahorro'],
    'estudios': ['estudio', 'universidad', 'examen', 'clase', 'profesor'],
    'personal': ['yo', 'me', 'mi', 'conmigo'],
  };

  for (const [theme, keywords] of Object.entries(themeKeywords)) {
    if (keywords.some(keyword => lowerContent.includes(keyword))) {
      themes.push(theme);
    }
  }

  return themes.length > 0 ? themes : ['reflexión personal'];
}

/**
 * Generar insights basados en mood y contenido
 */
function generateInsights(mood, content) {
  const insights = [];

  if (mood === 'very-good' || mood === 'good') {
    insights.push('Estás experimentando emociones positivas. Es un buen momento para reflexionar sobre qué factores contribuyen a tu bienestar.');
  } else if (mood === 'very-bad' || mood === 'bad') {
    insights.push('Parece que estás pasando por un momento difícil. Recuerda que es normal tener días así y que pedir ayuda es una señal de fortaleza.');
  }

  if (content.length > 1000) {
    insights.push('Has escrito una entrada detallada. La escritura reflexiva puede ser muy terapéutica.');
  }

  return insights.join(' ');
}
