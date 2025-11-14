const mongoose = require('mongoose');

const journalEntrySchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true,
  },
  title: {
    type: String,
    required: [true, 'El título es requerido'],
    trim: true,
    maxlength: [200, 'El título no puede exceder 200 caracteres'],
  },
  content: {
    type: String,
    required: [true, 'El contenido es requerido'],
    maxlength: [5000, 'El contenido no puede exceder 5000 caracteres'],
  },
  mood: {
    type: String,
    enum: ['very-bad', 'bad', 'neutral', 'good', 'very-good'],
    required: [true, 'El estado de ánimo es requerido'],
  },
  aiAnalysis: {
    status: {
      type: String,
      enum: ['pending', 'processing', 'completed', 'error'],
      default: 'pending',
    },
    sentiment: {
      overall: {
        type: String,
        enum: ['negative', 'neutral', 'positive'],
      },
      score: {
        type: Number,
        min: -1,
        max: 1,
      },
      emotions: [{
        emotion: String,
        confidence: Number,
      }],
    },
    themes: [String],
    insights: String,
    processedAt: Date,
    error: String,
  },
}, {
  timestamps: true,
});

// Índices para búsquedas eficientes
journalEntrySchema.index({ userId: 1, createdAt: -1 });
journalEntrySchema.index({ 'aiAnalysis.status': 1 });

// Virtual para obtener fecha formateada
journalEntrySchema.virtual('dateFormatted').get(function () {
  return this.createdAt.toLocaleDateString('es-ES', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  });
});

// Method para marcar análisis como en proceso
journalEntrySchema.methods.startProcessing = async function () {
  this.aiAnalysis.status = 'processing';
  await this.save();
};

// Method para guardar resultado de análisis
journalEntrySchema.methods.saveAnalysis = async function (analysisResult) {
  this.aiAnalysis.status = 'completed';
  this.aiAnalysis.sentiment = analysisResult.sentiment;
  this.aiAnalysis.themes = analysisResult.themes;
  this.aiAnalysis.insights = analysisResult.insights;
  this.aiAnalysis.processedAt = new Date();
  await this.save();
};

// Method para marcar error en análisis
journalEntrySchema.methods.markAnalysisError = async function (errorMessage) {
  this.aiAnalysis.status = 'error';
  this.aiAnalysis.error = errorMessage;
  await this.save();
};

// Configurar toJSON
journalEntrySchema.set('toJSON', {
  virtuals: true,
  versionKey: false,
  transform: function (doc, ret) {
    ret.id = ret._id;
    delete ret._id;
  },
});

module.exports = mongoose.model('JournalEntry', journalEntrySchema);
