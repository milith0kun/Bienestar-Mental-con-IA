const mongoose = require('mongoose');
const User = require('../src/models/User.model');
const MoodLog = require('../src/models/MoodLog.model');
const JournalEntry = require('../src/models/JournalEntry.model');

describe('User Model', () => {
  beforeAll(async () => {
    await User.deleteMany({});
  });

  afterAll(async () => {
    await mongoose.connection.close();
  });

  it('debe crear un usuario válido', async () => {
    const userData = {
      email: 'test@example.com',
      password: 'Password123',
      name: 'Test User',
      authProvider: 'email',
    };

    const user = await User.create(userData);

    expect(user.email).toBe(userData.email);
    expect(user.name).toBe(userData.name);
    expect(user.password).not.toBe(userData.password); // Debe estar hasheada
    expect(user.subscription.plan).toBe('free');
    expect(user.subscription.status).toBe('active');
  });

  it('debe hashear la contraseña antes de guardar', async () => {
    const plainPassword = 'Password123';
    const user = new User({
      email: 'hash@example.com',
      password: plainPassword,
      name: 'Hash Test',
    });

    await user.save();

    expect(user.password).not.toBe(plainPassword);
    expect(user.password.length).toBeGreaterThan(plainPassword.length);
  });

  it('debe comparar contraseñas correctamente', async () => {
    const password = 'Password123';
    const user = new User({
      email: 'compare@example.com',
      password,
      name: 'Compare Test',
    });

    await user.save();

    const isMatch = await user.comparePassword(password);
    const isNotMatch = await user.comparePassword('WrongPassword');

    expect(isMatch).toBe(true);
    expect(isNotMatch).toBe(false);
  });

  it('debe verificar si el usuario es premium', async () => {
    const freeUser = await User.create({
      email: 'free@example.com',
      password: 'Password123',
      name: 'Free User',
    });

    const premiumUser = await User.create({
      email: 'premium@example.com',
      password: 'Password123',
      name: 'Premium User',
      subscription: {
        plan: 'premium',
        status: 'active',
      },
    });

    expect(freeUser.isPremium()).toBe(false);
    expect(premiumUser.isPremium()).toBe(true);
  });

  it('debe verificar si puede crear entradas de diario', async () => {
    const user = await User.create({
      email: 'journal@example.com',
      password: 'Password123',
      name: 'Journal User',
    });

    // Usuario nuevo puede crear entradas
    expect(user.canCreateJournalEntry()).toBe(true);

    // Establecer que tiene 10 entradas este mes
    user.stats.journalEntriesThisMonth = 10;
    expect(user.canCreateJournalEntry()).toBe(false);

    // Usuario premium siempre puede crear
    user.subscription.plan = 'premium';
    user.subscription.status = 'active';
    expect(user.canCreateJournalEntry()).toBe(true);
  });

  it('debe resetear contador mensual de entradas', async () => {
    const user = await User.create({
      email: 'reset@example.com',
      password: 'Password123',
      name: 'Reset User',
      stats: {
        journalEntriesThisMonth: 5,
        lastJournalReset: new Date('2023-01-01'),
      },
    });

    user.resetMonthlyJournalCount();
    await user.save();

    expect(user.stats.journalEntriesThisMonth).toBe(0);
    expect(user.stats.lastJournalReset).toBeDefined();
  });

  it('debe rechazar email duplicado', async () => {
    await User.create({
      email: 'duplicate@example.com',
      password: 'Password123',
      name: 'User 1',
    });

    await expect(
      User.create({
        email: 'duplicate@example.com',
        password: 'Password123',
        name: 'User 2',
      })
    ).rejects.toThrow();
  });

  it('debe rechazar email inválido', async () => {
    await expect(
      User.create({
        email: 'invalid-email',
        password: 'Password123',
        name: 'Invalid Email',
      })
    ).rejects.toThrow();
  });
});

describe('MoodLog Model', () => {
  let testUser;

  beforeAll(async () => {
    await MoodLog.deleteMany({});
    await User.deleteMany({});

    testUser = await User.create({
      email: 'mood@example.com',
      password: 'Password123',
      name: 'Mood User',
    });
  });

  afterAll(async () => {
    await MoodLog.deleteMany({});
    await User.deleteMany({});
  });

  it('debe crear un registro de estado de ánimo válido', async () => {
    const moodLog = await MoodLog.create({
      userId: testUser._id,
      date: new Date(),
      mood: 8,
      emotions: ['happy', 'energetic'],
      notes: 'Great day!',
    });

    expect(moodLog.mood).toBe(8);
    expect(moodLog.emotions).toContain('happy');
    expect(moodLog.notes).toBe('Great day!');
  });

  it('debe normalizar la fecha al guardar', async () => {
    const date = new Date('2024-01-15T14:30:00');
    const moodLog = await MoodLog.create({
      userId: testUser._id,
      date,
      mood: 7,
    });

    const savedDate = new Date(moodLog.date);
    expect(savedDate.getHours()).toBe(0);
    expect(savedDate.getMinutes()).toBe(0);
    expect(savedDate.getSeconds()).toBe(0);
  });

  it('debe rechazar valor de mood fuera de rango', async () => {
    await expect(
      MoodLog.create({
        userId: testUser._id,
        date: new Date(),
        mood: 11, // Máximo es 10
      })
    ).rejects.toThrow();

    await expect(
      MoodLog.create({
        userId: testUser._id,
        date: new Date(),
        mood: 0, // Mínimo es 1
      })
    ).rejects.toThrow();
  });

  it('debe calcular promedio de ánimo', async () => {
    // Crear varios registros
    const baseDate = new Date();
    await MoodLog.create({
      userId: testUser._id,
      date: new Date(baseDate.setDate(baseDate.getDate() - 1)),
      mood: 6,
    });
    await MoodLog.create({
      userId: testUser._id,
      date: new Date(baseDate.setDate(baseDate.getDate() - 1)),
      mood: 8,
    });
    await MoodLog.create({
      userId: testUser._id,
      date: new Date(baseDate.setDate(baseDate.getDate() - 1)),
      mood: 7,
    });

    const average = await MoodLog.getAverageMood(testUser._id, 7);
    expect(parseFloat(average)).toBeCloseTo(7, 1);
  });
});

describe('JournalEntry Model', () => {
  let testUser;

  beforeAll(async () => {
    await JournalEntry.deleteMany({});
    await User.deleteMany({});

    testUser = await User.create({
      email: 'journal@example.com',
      password: 'Password123',
      name: 'Journal User',
    });
  });

  afterAll(async () => {
    await JournalEntry.deleteMany({});
    await User.deleteMany({});
  });

  it('debe crear una entrada de diario válida', async () => {
    const entry = await JournalEntry.create({
      userId: testUser._id,
      title: 'My First Entry',
      content: 'Today was a good day. I felt happy and productive.',
      mood: 'good',
    });

    expect(entry.title).toBe('My First Entry');
    expect(entry.mood).toBe('good');
    expect(entry.aiAnalysis.status).toBe('pending');
  });

  it('debe marcar análisis como en proceso', async () => {
    const entry = await JournalEntry.create({
      userId: testUser._id,
      title: 'Test Entry',
      content: 'Test content',
      mood: 'neutral',
    });

    await entry.startProcessing();

    expect(entry.aiAnalysis.status).toBe('processing');
  });

  it('debe guardar resultado de análisis', async () => {
    const entry = await JournalEntry.create({
      userId: testUser._id,
      title: 'Analysis Test',
      content: 'Test content for analysis',
      mood: 'good',
    });

    const analysisResult = {
      sentiment: {
        overall: 'positive',
        score: 0.75,
        emotions: [
          { emotion: 'joy', confidence: 0.8 },
          { emotion: 'contentment', confidence: 0.7 },
        ],
      },
      themes: ['happiness', 'productivity'],
      insights: 'The user is experiencing positive emotions.',
    };

    await entry.saveAnalysis(analysisResult);

    expect(entry.aiAnalysis.status).toBe('completed');
    expect(entry.aiAnalysis.sentiment.overall).toBe('positive');
    expect(entry.aiAnalysis.themes).toContain('happiness');
    expect(entry.aiAnalysis.processedAt).toBeDefined();
  });

  it('debe marcar error en análisis', async () => {
    const entry = await JournalEntry.create({
      userId: testUser._id,
      title: 'Error Test',
      content: 'Test content',
      mood: 'neutral',
    });

    await entry.markAnalysisError('API Error');

    expect(entry.aiAnalysis.status).toBe('error');
    expect(entry.aiAnalysis.error).toBe('API Error');
  });

  it('debe rechazar contenido muy largo', async () => {
    const longContent = 'a'.repeat(5001);

    await expect(
      JournalEntry.create({
        userId: testUser._id,
        title: 'Long Entry',
        content: longContent,
        mood: 'neutral',
      })
    ).rejects.toThrow();
  });
});
