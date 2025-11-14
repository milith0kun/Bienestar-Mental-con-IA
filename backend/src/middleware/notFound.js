/**
 * Middleware para manejar rutas no encontradas
 */
exports.notFound = (req, res, next) => {
  res.status(404).json({
    success: false,
    message: `Ruta no encontrada: ${req.originalUrl}`,
  });
};
