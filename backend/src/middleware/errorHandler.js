const config = require('../config');

/**
 * Middleware global para manejo de errores
 */
exports.errorHandler = (err, req, res, next) => {
  let error = { ...err };
  error.message = err.message;

  // Log para desarrollo
  if (config.env === 'development') {
    console.error('Error:', err);
  }

  // Error de validación de Mongoose
  if (err.name === 'ValidationError') {
    const message = Object.values(err.errors).map(e => e.message).join(', ');
    error.statusCode = 400;
    error.message = message;
  }

  // Error de duplicado de Mongoose
  if (err.code === 11000) {
    const field = Object.keys(err.keyValue)[0];
    const value = err.keyValue[field];
    error.statusCode = 400;
    error.message = `${field} '${value}' ya está en uso`;
  }

  // Error de CastError de Mongoose (ID inválido)
  if (err.name === 'CastError') {
    error.statusCode = 400;
    error.message = 'ID inválido';
  }

  // Error de JWT
  if (err.name === 'JsonWebTokenError') {
    error.statusCode = 401;
    error.message = 'Token inválido';
  }

  if (err.name === 'TokenExpiredError') {
    error.statusCode = 401;
    error.message = 'Token expirado';
  }

  res.status(error.statusCode || 500).json({
    success: false,
    message: error.message || 'Error del servidor',
    ...(config.env === 'development' && { stack: err.stack }),
  });
};
