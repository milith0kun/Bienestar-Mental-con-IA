const jwt = require('jsonwebtoken');
const config = require('../config');
const User = require('../models/User.model');

/**
 * Middleware para proteger rutas que requieren autenticación
 */
exports.protect = async (req, res, next) => {
  try {
    let token;

    // Verificar si el token está en el header Authorization
    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
      token = req.headers.authorization.split(' ')[1];
    }

    // Verificar que el token existe
    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'No autorizado. Token no proporcionado',
      });
    }

    // Verificar el token
    const decoded = jwt.verify(token, config.jwt.secret);

    // Buscar el usuario en la base de datos
    const user = await User.findById(decoded.id);

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Usuario no encontrado',
      });
    }

    // Agregar usuario al request
    req.user = user;
    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        success: false,
        message: 'Token inválido',
      });
    }

    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Token expirado',
      });
    }

    return res.status(500).json({
      success: false,
      message: 'Error al verificar autenticación',
    });
  }
};

/**
 * Middleware para verificar que el usuario tiene suscripción premium
 */
exports.requirePremium = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({
      success: false,
      message: 'No autorizado',
    });
  }

  if (!req.user.isPremium()) {
    return res.status(403).json({
      success: false,
      message: 'Esta función requiere suscripción premium',
      upgrade: true,
    });
  }

  next();
};

/**
 * Middleware opcional de autenticación (no falla si no hay token)
 */
exports.optionalAuth = async (req, res, next) => {
  try {
    let token;

    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
      token = req.headers.authorization.split(' ')[1];
    }

    if (token) {
      const decoded = jwt.verify(token, config.jwt.secret);
      const user = await User.findById(decoded.id);
      if (user) {
        req.user = user;
      }
    }

    next();
  } catch (error) {
    // Si hay error, simplemente continuar sin usuario autenticado
    next();
  }
};
