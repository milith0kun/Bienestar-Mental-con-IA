const { OAuth2Client } = require('google-auth-library');
const User = require('../models/User.model');
const { generateToken, generateRefreshToken } = require('../utils/jwt');
const { generateResetToken, hashToken } = require('../utils/crypto');
const emailService = require('../services/email.service');
const config = require('../config');

const googleClient = new OAuth2Client(config.google.clientId);

/**
 * @route   POST /api/v1/auth/register
 * @desc    Registrar nuevo usuario con email y contraseña
 * @access  Public
 */
exports.register = async (req, res, next) => {
  try {
    const { email, password, name } = req.body;

    // Verificar si el usuario ya existe
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'El correo electrónico ya está registrado',
      });
    }

    // Crear usuario
    const user = await User.create({
      email,
      password,
      name,
      authProvider: 'email',
    });

    // Generar tokens
    const token = generateToken(user._id);
    const refreshToken = generateRefreshToken(user._id);

    // Enviar email de bienvenida (no await para no bloquear respuesta)
    emailService.sendWelcomeEmail(user.email, user.name).catch(err =>
      console.error('Error enviando email de bienvenida:', err)
    );

    res.status(201).json({
      success: true,
      message: 'Usuario registrado exitosamente',
      data: {
        user: {
          id: user._id,
          email: user.email,
          name: user.name,
          profilePicture: user.profilePicture,
          subscription: user.subscription,
        },
        token,
        refreshToken,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   POST /api/v1/auth/login
 * @desc    Iniciar sesión con email y contraseña
 * @access  Public
 */
exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    // Buscar usuario y incluir password
    const user = await User.findOne({ email }).select('+password');

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Credenciales inválidas',
      });
    }

    // Verificar que el usuario se registró con email (no con Google)
    if (user.authProvider !== 'email') {
      return res.status(400).json({
        success: false,
        message: `Esta cuenta fue creada con ${user.authProvider}. Por favor inicia sesión con ${user.authProvider}`,
      });
    }

    // Verificar contraseña
    const isPasswordValid = await user.comparePassword(password);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Credenciales inválidas',
      });
    }

    // Generar tokens
    const token = generateToken(user._id);
    const refreshToken = generateRefreshToken(user._id);

    res.json({
      success: true,
      message: 'Inicio de sesión exitoso',
      data: {
        user: {
          id: user._id,
          email: user.email,
          name: user.name,
          profilePicture: user.profilePicture,
          subscription: user.subscription,
          preferences: user.preferences,
        },
        token,
        refreshToken,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   POST /api/v1/auth/google
 * @desc    Autenticación con Google OAuth
 * @access  Public
 */
exports.googleAuth = async (req, res, next) => {
  try {
    const { idToken } = req.body;

    if (!idToken) {
      return res.status(400).json({
        success: false,
        message: 'ID token de Google es requerido',
      });
    }

    // Verificar token de Google
    const ticket = await googleClient.verifyIdToken({
      idToken,
      audience: config.google.clientId,
    });

    const payload = ticket.getPayload();
    const { sub: googleId, email, name, picture } = payload;

    // Buscar usuario por googleId o email
    let user = await User.findOne({
      $or: [{ googleId }, { email }],
    });

    if (user) {
      // Usuario existe - actualizar googleId si es necesario
      if (!user.googleId) {
        user.googleId = googleId;
        user.authProvider = 'google';
        await user.save();
      }
    } else {
      // Crear nuevo usuario
      user = await User.create({
        email,
        name,
        googleId,
        profilePicture: picture,
        authProvider: 'google',
      });

      // Enviar email de bienvenida
      emailService.sendWelcomeEmail(user.email, user.name).catch(err =>
        console.error('Error enviando email de bienvenida:', err)
      );
    }

    // Generar tokens
    const token = generateToken(user._id);
    const refreshToken = generateRefreshToken(user._id);

    res.json({
      success: true,
      message: 'Autenticación con Google exitosa',
      data: {
        user: {
          id: user._id,
          email: user.email,
          name: user.name,
          profilePicture: user.profilePicture,
          subscription: user.subscription,
          preferences: user.preferences,
        },
        token,
        refreshToken,
      },
    });
  } catch (error) {
    console.error('Error en autenticación de Google:', error);
    res.status(401).json({
      success: false,
      message: 'Error al autenticar con Google',
    });
  }
};

/**
 * @route   POST /api/v1/auth/forgot-password
 * @desc    Solicitar recuperación de contraseña
 * @access  Public
 */
exports.forgotPassword = async (req, res, next) => {
  try {
    const { email } = req.body;

    const user = await User.findOne({ email });

    if (!user) {
      // Por seguridad, siempre retornar éxito aunque no exista el usuario
      return res.json({
        success: true,
        message: 'Si el correo existe, recibirás un enlace de recuperación',
      });
    }

    // Verificar que el usuario se registró con email
    if (user.authProvider !== 'email') {
      return res.status(400).json({
        success: false,
        message: `Esta cuenta fue creada con ${user.authProvider}. No requiere contraseña`,
      });
    }

    // Generar token de reset
    const resetToken = generateResetToken();
    const hashedToken = hashToken(resetToken);

    // Guardar token en la base de datos (expira en 1 hora)
    user.resetPasswordToken = hashedToken;
    user.resetPasswordExpire = Date.now() + 3600000; // 1 hora
    await user.save();

    // Enviar email
    try {
      await emailService.sendPasswordResetEmail(user.email, resetToken);

      res.json({
        success: true,
        message: 'Correo de recuperación enviado',
      });
    } catch (emailError) {
      // Si falla el envío de email, eliminar token
      user.resetPasswordToken = undefined;
      user.resetPasswordExpire = undefined;
      await user.save();

      return res.status(500).json({
        success: false,
        message: 'Error al enviar correo de recuperación',
      });
    }
  } catch (error) {
    next(error);
  }
};

/**
 * @route   POST /api/v1/auth/reset-password
 * @desc    Restablecer contraseña con token
 * @access  Public
 */
exports.resetPassword = async (req, res, next) => {
  try {
    const { token, password } = req.body;

    // Hash el token para comparar
    const hashedToken = hashToken(token);

    // Buscar usuario con token válido y no expirado
    const user = await User.findOne({
      resetPasswordToken: hashedToken,
      resetPasswordExpire: { $gt: Date.now() },
    });

    if (!user) {
      return res.status(400).json({
        success: false,
        message: 'Token inválido o expirado',
      });
    }

    // Actualizar contraseña
    user.password = password;
    user.resetPasswordToken = undefined;
    user.resetPasswordExpire = undefined;
    await user.save();

    // Enviar email de confirmación
    emailService.sendPasswordChangedEmail(user.email, user.name).catch(err =>
      console.error('Error enviando email de confirmación:', err)
    );

    // Generar tokens
    const newToken = generateToken(user._id);
    const refreshToken = generateRefreshToken(user._id);

    res.json({
      success: true,
      message: 'Contraseña restablecida exitosamente',
      data: {
        token: newToken,
        refreshToken,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   POST /api/v1/auth/refresh-token
 * @desc    Renovar access token usando refresh token
 * @access  Public
 */
exports.refreshToken = async (req, res, next) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({
        success: false,
        message: 'Refresh token es requerido',
      });
    }

    // Verificar refresh token
    const { verifyRefreshToken } = require('../utils/jwt');
    const decoded = verifyRefreshToken(refreshToken);

    // Verificar que el usuario existe
    const user = await User.findById(decoded.id);
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Usuario no encontrado',
      });
    }

    // Generar nuevo access token
    const newToken = generateToken(user._id);

    res.json({
      success: true,
      data: {
        token: newToken,
      },
    });
  } catch (error) {
    res.status(401).json({
      success: false,
      message: 'Refresh token inválido o expirado',
    });
  }
};
