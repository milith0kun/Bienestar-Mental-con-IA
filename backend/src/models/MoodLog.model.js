const mongoose = require('mongoose');

const moodLogSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true,
  },
  date: {
    type: Date,
    required: true,
  },
  mood: {
    type: Number,
    required: [true, 'El estado de ánimo es requerido'],
    min: [1, 'El valor mínimo es 1'],
    max: [10, 'El valor máximo es 10'],
  },
  emotions: [{
    type: String,
    enum: [
      'happy',      // Feliz
      'sad',        // Triste
      'anxious',    // Ansioso
      'calm',       // Calmado
      'energetic',  // Energético
      'tired',      // Cansado
      'angry',      // Enojado
      'peaceful',   // En paz
      'stressed',   // Estresado
      'grateful',   // Agradecido
      'hopeful',    // Esperanzado
      'lonely',     // Solo
      'loved',      // Amado
      'motivated',  // Motivado
    ],
  }],
  notes: {
    type: String,
    maxlength: [500, 'Las notas no pueden exceder 500 caracteres'],
    trim: true,
  },
}, {
  timestamps: true,
});

// Índices para búsquedas eficientes y garantizar un registro por día
moodLogSchema.index({ userId: 1, date: 1 }, { unique: true });
moodLogSchema.index({ userId: 1, createdAt: -1 });

// Pre-save hook para normalizar la fecha (solo fecha, sin hora)
moodLogSchema.pre('save', function (next) {
  if (this.isModified('date')) {
    const d = new Date(this.date);
    this.date = new Date(d.getFullYear(), d.getMonth(), d.getDate());
  }
  next();
});

// Static method para obtener registros de un rango de fechas
moodLogSchema.statics.getByDateRange = function (userId, startDate, endDate) {
  const start = new Date(startDate);
  start.setHours(0, 0, 0, 0);

  const end = new Date(endDate);
  end.setHours(23, 59, 59, 999);

  return this.find({
    userId,
    date: {
      $gte: start,
      $lte: end,
    },
  }).sort({ date: 1 });
};

// Static method para calcular promedio de ánimo
moodLogSchema.statics.getAverageMood = async function (userId, days = 7) {
  const startDate = new Date();
  startDate.setDate(startDate.getDate() - days);
  startDate.setHours(0, 0, 0, 0);

  const logs = await this.find({
    userId,
    date: { $gte: startDate },
  });

  if (logs.length === 0) return null;

  const sum = logs.reduce((acc, log) => acc + log.mood, 0);
  return (sum / logs.length).toFixed(2);
};

// Static method para obtener tendencia
moodLogSchema.statics.getTrend = async function (userId, days = 7) {
  const startDate = new Date();
  startDate.setDate(startDate.getDate() - days);
  startDate.setHours(0, 0, 0, 0);

  const logs = await this.find({
    userId,
    date: { $gte: startDate },
  }).sort({ date: 1 });

  if (logs.length < 2) return 'stable';

  // Calcular tendencia simple comparando primera mitad con segunda mitad
  const midPoint = Math.floor(logs.length / 2);
  const firstHalf = logs.slice(0, midPoint);
  const secondHalf = logs.slice(midPoint);

  const firstAvg = firstHalf.reduce((acc, log) => acc + log.mood, 0) / firstHalf.length;
  const secondAvg = secondHalf.reduce((acc, log) => acc + log.mood, 0) / secondHalf.length;

  const difference = secondAvg - firstAvg;

  if (difference > 0.5) return 'improving';
  if (difference < -0.5) return 'declining';
  return 'stable';
};

// Configurar toJSON
moodLogSchema.set('toJSON', {
  versionKey: false,
  transform: function (doc, ret) {
    ret.id = ret._id;
    delete ret._id;
    // Formatear fecha para solo mostrar YYYY-MM-DD
    ret.date = ret.date.toISOString().split('T')[0];
  },
});

module.exports = mongoose.model('MoodLog', moodLogSchema);
