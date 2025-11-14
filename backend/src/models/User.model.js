const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const config = require('../config');

const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: [true, 'El correo electrónico es requerido'],
    unique: true,
    lowercase: true,
    trim: true,
    match: [/^\S+@\S+\.\S+$/, 'Formato de correo electrónico inválido'],
  },
  password: {
    type: String,
    minlength: [8, 'La contraseña debe tener al menos 8 caracteres'],
    select: false, // No incluir password en queries por defecto
  },
  name: {
    type: String,
    required: [true, 'El nombre es requerido'],
    trim: true,
  },
  profilePicture: {
    type: String,
    default: null,
  },
  authProvider: {
    type: String,
    enum: ['email', 'google'],
    default: 'email',
  },
  googleId: {
    type: String,
    unique: true,
    sparse: true, // Permite valores null sin violar la restricción unique
  },
  subscription: {
    plan: {
      type: String,
      enum: ['free', 'premium'],
      default: 'free',
    },
    status: {
      type: String,
      enum: ['active', 'canceled', 'past_due', 'trialing'],
      default: 'active',
    },
    startDate: Date,
    endDate: Date,
    stripeCustomerId: String,
    stripeSubscriptionId: String,
  },
  preferences: {
    notificationsEnabled: {
      type: Boolean,
      default: true,
    },
    meditationReminder: {
      enabled: {
        type: Boolean,
        default: false,
      },
      time: {
        type: String,
        default: '09:00',
      },
    },
    moodReminder: {
      enabled: {
        type: Boolean,
        default: false,
      },
      time: {
        type: String,
        default: '20:00',
      },
    },
  },
  stats: {
    totalMeditations: {
      type: Number,
      default: 0,
    },
    totalMeditationTime: {
      type: Number,
      default: 0, // En segundos
    },
    consecutiveDays: {
      type: Number,
      default: 0,
    },
    lastMeditationDate: Date,
    journalEntries: {
      type: Number,
      default: 0,
    },
    journalEntriesThisMonth: {
      type: Number,
      default: 0,
    },
    lastJournalReset: Date,
  },
  resetPasswordToken: String,
  resetPasswordExpire: Date,
  fcmTokens: [String], // Firebase Cloud Messaging tokens para notificaciones push
}, {
  timestamps: true,
});

// Index para búsquedas eficientes
userSchema.index({ email: 1 });
userSchema.index({ googleId: 1 });

// Hash password before saving
userSchema.pre('save', async function (next) {
  // Solo hashear si el password fue modificado o es nuevo
  if (!this.isModified('password')) {
    return next();
  }

  // Si authProvider es google, no hashear password
  if (this.authProvider === 'google') {
    return next();
  }

  try {
    const salt = await bcrypt.genSalt(config.bcryptRounds);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

// Method to compare passwords
userSchema.methods.comparePassword = async function (candidatePassword) {
  try {
    return await bcrypt.compare(candidatePassword, this.password);
  } catch (error) {
    throw new Error('Error al comparar contraseñas');
  }
};

// Method to check if user is premium
userSchema.methods.isPremium = function () {
  return this.subscription.plan === 'premium' &&
         this.subscription.status === 'active';
};

// Method to check if user can create journal entry
userSchema.methods.canCreateJournalEntry = function () {
  if (this.isPremium()) {
    return true;
  }

  // Free users: 10 entries per month
  return this.stats.journalEntriesThisMonth < 10;
};

// Method to reset monthly journal count
userSchema.methods.resetMonthlyJournalCount = function () {
  const now = new Date();
  const lastReset = this.stats.lastJournalReset;

  if (!lastReset ||
      lastReset.getMonth() !== now.getMonth() ||
      lastReset.getFullYear() !== now.getFullYear()) {
    this.stats.journalEntriesThisMonth = 0;
    this.stats.lastJournalReset = now;
  }
};

// Remove sensitive data from JSON output
userSchema.methods.toJSON = function () {
  const user = this.toObject();
  delete user.password;
  delete user.resetPasswordToken;
  delete user.resetPasswordExpire;
  delete user.__v;
  return user;
};

module.exports = mongoose.model('User', userSchema);
