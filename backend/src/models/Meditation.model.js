const mongoose = require('mongoose');

const meditationSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'El título es requerido'],
    trim: true,
  },
  description: {
    type: String,
    required: [true, 'La descripción es requerida'],
    trim: true,
  },
  category: {
    type: String,
    required: [true, 'La categoría es requerida'],
    enum: [
      'anxiety',      // Ansiedad
      'stress',       // Estrés
      'sleep',        // Sueño
      'focus',        // Enfoque
      'self-esteem',  // Autoestima
      'gratitude',    // Gratitud
      'general',      // Bienestar General
    ],
  },
  duration: {
    type: Number,
    required: [true, 'La duración es requerida'],
    min: [60, 'La duración mínima es 60 segundos'],
  },
  difficulty: {
    type: String,
    enum: ['beginner', 'intermediate', 'advanced'],
    default: 'beginner',
  },
  audioUrl: {
    type: String,
    required: [true, 'La URL del audio es requerida'],
  },
  thumbnailUrl: {
    type: String,
    default: null,
  },
  isPremium: {
    type: Boolean,
    default: false,
  },
  tags: [String],
  instructor: {
    type: String,
    default: 'MindFlow',
  },
  plays: {
    type: Number,
    default: 0,
  },
  averageRating: {
    type: Number,
    default: 0,
    min: 0,
    max: 5,
  },
  ratingsCount: {
    type: Number,
    default: 0,
  },
  isActive: {
    type: Boolean,
    default: true,
  },
}, {
  timestamps: true,
});

// Índices para búsquedas eficientes
meditationSchema.index({ category: 1, isActive: 1 });
meditationSchema.index({ isPremium: 1 });
meditationSchema.index({ title: 'text', description: 'text', tags: 'text' });

// Virtual para duración en formato legible
meditationSchema.virtual('durationFormatted').get(function () {
  const minutes = Math.floor(this.duration / 60);
  const seconds = this.duration % 60;
  return `${minutes}:${seconds.toString().padStart(2, '0')}`;
});

// Method para incrementar reproducciones
meditationSchema.methods.incrementPlays = async function () {
  this.plays += 1;
  await this.save();
};

// Method para actualizar rating promedio
meditationSchema.methods.updateRating = async function (newRating) {
  const totalRating = this.averageRating * this.ratingsCount;
  this.ratingsCount += 1;
  this.averageRating = (totalRating + newRating) / this.ratingsCount;
  await this.save();
};

// Configurar toJSON
meditationSchema.set('toJSON', {
  virtuals: true,
  versionKey: false,
  transform: function (doc, ret) {
    ret.id = ret._id;
    delete ret._id;
  },
});

module.exports = mongoose.model('Meditation', meditationSchema);
