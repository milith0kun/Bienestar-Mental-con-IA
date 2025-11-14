const jwt = require('jsonwebtoken');
const config = require('../config');

/**
 * Genera un token JWT para un usuario
 */
exports.generateToken = (userId) => {
  return jwt.sign(
    { id: userId },
    config.jwt.secret,
    { expiresIn: config.jwt.expire }
  );
};

/**
 * Genera un refresh token
 */
exports.generateRefreshToken = (userId) => {
  return jwt.sign(
    { id: userId },
    config.jwt.refreshSecret,
    { expiresIn: config.jwt.refreshExpire }
  );
};

/**
 * Verifica un token JWT
 */
exports.verifyToken = (token) => {
  try {
    return jwt.verify(token, config.jwt.secret);
  } catch (error) {
    throw new Error('Token inválido o expirado');
  }
};

/**
 * Verifica un refresh token
 */
exports.verifyRefreshToken = (token) => {
  try {
    return jwt.verify(token, config.jwt.refreshSecret);
  } catch (error) {
    throw new Error('Refresh token inválido o expirado');
  }
};
