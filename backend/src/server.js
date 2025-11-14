const app = require('./app');
const config = require('./config');
const connectDB = require('./config/database');

// Connect to database
connectDB();

// Start server
const server = app.listen(config.port, () => {
  console.log(`
    ╔═══════════════════════════════════════╗
    ║   MindFlow Backend API Server         ║
    ╠═══════════════════════════════════════╣
    ║   Environment: ${config.env.padEnd(23)} ║
    ║   Port: ${String(config.port).padEnd(30)} ║
    ║   Database: Connected                 ║
    ╚═══════════════════════════════════════╝
  `);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (err) => {
  console.error('Unhandled Promise Rejection:', err);
  // Close server & exit process
  server.close(() => process.exit(1));
});

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err);
  process.exit(1);
});
