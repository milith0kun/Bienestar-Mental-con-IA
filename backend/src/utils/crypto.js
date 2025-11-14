const crypto = require('crypto');

/**
 * Genera un token aleatorio para recuperación de contraseña
 */
exports.generateResetToken = () => {
  return crypto.randomBytes(32).toString('hex');
};

/**
 * Hashea el token de reset para almacenamiento seguro
 */
exports.hashToken = (token) => {
  return crypto.createHash('sha256').update(token).digest('hex');
};
