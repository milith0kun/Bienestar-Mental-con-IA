const nodemailer = require('nodemailer');
const config = require('../config');

/**
 * Configurar transporter de nodemailer
 */
const transporter = nodemailer.createTransport({
  host: config.email.host,
  port: config.email.port,
  secure: config.email.secure,
  auth: {
    user: config.email.user,
    pass: config.email.pass,
  },
});

/**
 * Enviar email de bienvenida
 */
exports.sendWelcomeEmail = async (email, name) => {
  const mailOptions = {
    from: config.email.from,
    to: email,
    subject: 'Bienvenido a MindFlow',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h1 style="color: #6B4CE6;">¡Bienvenido a MindFlow!</h1>
        <p>Hola ${name},</p>
        <p>Gracias por unirte a MindFlow. Estamos emocionados de acompañarte en tu viaje hacia el bienestar mental.</p>
        <p>Con MindFlow puedes:</p>
        <ul>
          <li>Practicar meditaciones guiadas</li>
          <li>Llevar un diario emocional con análisis de IA</li>
          <li>Hacer seguimiento de tu estado de ánimo</li>
          <li>Obtener insights personalizados</li>
        </ul>
        <p>¡Comienza tu práctica hoy mismo!</p>
        <p>Saludos,<br>El equipo de MindFlow</p>
      </div>
    `,
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log('Email de bienvenida enviado a:', email);
  } catch (error) {
    console.error('Error al enviar email de bienvenida:', error);
  }
};

/**
 * Enviar email de recuperación de contraseña
 */
exports.sendPasswordResetEmail = async (email, resetToken) => {
  const resetUrl = `${config.frontendUrl}/reset-password?token=${resetToken}`;

  const mailOptions = {
    from: config.email.from,
    to: email,
    subject: 'Recuperación de Contraseña - MindFlow',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h1 style="color: #6B4CE6;">Recuperación de Contraseña</h1>
        <p>Has solicitado restablecer tu contraseña en MindFlow.</p>
        <p>Haz clic en el siguiente enlace para crear una nueva contraseña:</p>
        <a href="${resetUrl}" style="display: inline-block; padding: 12px 24px; background-color: #6B4CE6; color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">
          Restablecer Contraseña
        </a>
        <p>Este enlace expirará en 1 hora.</p>
        <p>Si no solicitaste este cambio, puedes ignorar este correo.</p>
        <p>Saludos,<br>El equipo de MindFlow</p>
      </div>
    `,
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log('Email de recuperación enviado a:', email);
  } catch (error) {
    console.error('Error al enviar email de recuperación:', error);
    throw new Error('No se pudo enviar el email de recuperación');
  }
};

/**
 * Enviar confirmación de cambio de contraseña
 */
exports.sendPasswordChangedEmail = async (email, name) => {
  const mailOptions = {
    from: config.email.from,
    to: email,
    subject: 'Contraseña Cambiada - MindFlow',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h1 style="color: #6B4CE6;">Contraseña Cambiada</h1>
        <p>Hola ${name},</p>
        <p>Tu contraseña ha sido cambiada exitosamente.</p>
        <p>Si no realizaste este cambio, por favor contacta a nuestro equipo de soporte inmediatamente.</p>
        <p>Saludos,<br>El equipo de MindFlow</p>
      </div>
    `,
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log('Email de confirmación enviado a:', email);
  } catch (error) {
    console.error('Error al enviar email de confirmación:', error);
  }
};
