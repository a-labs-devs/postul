const nodemailer = require('nodemailer');

/**
 * 📧 Serviço de Email - Postul
 * Envia notificações de cadastro e outras comunicações
 */
class EmailService {
  constructor() {
    this.transporter = null;
    this.initializeTransporter();
  }

  /**
   * Inicializa o transportador de email
   * Usando Gmail como exemplo, mas pode ser configurado para outros provedores
   */
  initializeTransporter() {
    try {
      this.transporter = nodemailer.createTransport({
        service: 'gmail', // Ou 'hotmail', 'outlook', etc.
        auth: {
          user: process.env.EMAIL_USER, // Email do remetente
          pass: process.env.EMAIL_PASSWORD // Senha de app do Gmail
        }
      });

      console.log('✅ Serviço de email inicializado com sucesso');
    } catch (error) {
      console.error('❌ Erro ao inicializar serviço de email:', error);
    }
  }

  /**
   * Envia email de boas-vindas após cadastro
   * @param {string} nome - Nome do usuário
   * @param {string} email - Email do usuário
   */
  async enviarEmailBoasVindas(nome, email) {
    const mailOptions = {
      from: {
        name: 'Postul - Postos de Gasolina',
        address: process.env.EMAIL_USER
      },
      to: email,
      subject: '🎉 Bem-vindo ao Postul!',
      html: this.templateBoasVindas(nome)
    };

    try {
      const info = await this.transporter.sendMail(mailOptions);
      console.log('✅ Email enviado:', info.messageId);
      return { sucesso: true, messageId: info.messageId };
    } catch (error) {
      console.error('❌ Erro ao enviar email:', error);
      return { sucesso: false, erro: error.message };
    }
  }

  /**
   * Template HTML do email de boas-vindas
   * @param {string} nome - Nome do usuário
   */
  templateBoasVindas(nome) {
    return `
      <!DOCTYPE html>
      <html lang="pt-BR">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Bem-vindo ao Postul</title>
        <style>
          body {
            margin: 0;
            padding: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f5f5f5;
          }
          .container {
            max-width: 600px;
            margin: 40px auto;
            background: white;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
          }
          .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 40px 30px;
            text-align: center;
            color: white;
          }
          .header h1 {
            margin: 0;
            font-size: 32px;
            font-weight: 700;
          }
          .icon {
            font-size: 64px;
            margin-bottom: 10px;
          }
          .content {
            padding: 40px 30px;
            color: #333;
          }
          .content h2 {
            color: #667eea;
            margin-top: 0;
            font-size: 24px;
          }
          .content p {
            line-height: 1.8;
            font-size: 16px;
            color: #555;
          }
          .features {
            background: #f8f9ff;
            border-radius: 8px;
            padding: 20px;
            margin: 20px 0;
          }
          .feature-item {
            display: flex;
            align-items: center;
            margin: 15px 0;
            padding: 10px;
          }
          .feature-icon {
            font-size: 24px;
            margin-right: 15px;
          }
          .feature-text {
            flex: 1;
            font-size: 14px;
            color: #555;
          }
          .cta-button {
            display: inline-block;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px 40px;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 600;
            font-size: 16px;
            margin: 20px 0;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
          }
          .footer {
            background: #f8f9fa;
            padding: 30px;
            text-align: center;
            color: #666;
            font-size: 14px;
            border-top: 1px solid #e0e0e0;
          }
          .social-links {
            margin: 20px 0;
          }
          .social-links a {
            display: inline-block;
            margin: 0 10px;
            color: #667eea;
            text-decoration: none;
            font-size: 24px;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <!-- Header -->
          <div class="header">
            <div class="icon">⛽</div>
            <h1>Postul</h1>
            <p style="margin: 10px 0 0 0; font-size: 16px; opacity: 0.9;">
              Encontre o melhor preço de combustível
            </p>
          </div>

          <!-- Content -->
          <div class="content">
            <h2>Bem-vindo, ${nome}! 🎉</h2>
            <p>
              Ficamos muito felizes em ter você conosco! Sua conta foi criada com sucesso 
              e agora você tem acesso a todos os recursos do Postul.
            </p>

            <div class="features">
              <div class="feature-item">
                <span class="feature-icon">🗺️</span>
                <span class="feature-text">
                  <strong>Postos Próximos:</strong> Encontre os postos mais perto de você em tempo real
                </span>
              </div>
              <div class="feature-item">
                <span class="feature-icon">💰</span>
                <span class="feature-text">
                  <strong>Compare Preços:</strong> Veja os melhores preços de gasolina, etanol e diesel
                </span>
              </div>
              <div class="feature-item">
                <span class="feature-icon">🧭</span>
                <span class="feature-text">
                  <strong>Navegação GPS:</strong> Rotas otimizadas com instruções de voz em português
                </span>
              </div>
              <div class="feature-item">
                <span class="feature-icon">⭐</span>
                <span class="feature-text">
                  <strong>Favoritos:</strong> Salve seus postos preferidos para acesso rápido
                </span>
              </div>
            </div>

            <p>
              Comece agora mesmo a economizar no seu abastecimento! Abra o app e explore 
              todos os postos disponíveis na sua região.
            </p>

            <center>
              <a href="#" class="cta-button">Abrir o Postul</a>
            </center>

            <p style="margin-top: 30px; font-size: 14px; color: #777;">
              Dúvidas ou sugestões? Entre em contato conosco pelo app na seção "Ajuda".
            </p>
          </div>

          <!-- Footer -->
          <div class="footer">
            <p style="margin: 0 0 15px 0;">
              <strong>Postul</strong> - Seu assistente de combustível
            </p>
            
            <div class="social-links">
              <a href="#" title="Facebook">📘</a>
              <a href="#" title="Instagram">📷</a>
              <a href="#" title="Twitter">🐦</a>
            </div>

            <p style="font-size: 12px; color: #999; margin: 15px 0 0 0;">
              Este é um email automático. Por favor, não responda.<br>
              © ${new Date().getFullYear()} Postul. Todos os direitos reservados.
            </p>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  /**
   * Envia email de recuperação de senha
   * @param {string} nome - Nome do usuário
   * @param {string} email - Email do usuário
   * @param {string} codigoRecuperacao - Código para recuperação
   */
  async enviarEmailRecuperacaoSenha(nome, email, codigoRecuperacao) {
    const mailOptions = {
      from: {
        name: 'Postul - Postos de Gasolina',
        address: process.env.EMAIL_USER
      },
      to: email,
      subject: '🔑 Recuperação de Senha - Postul',
      html: this.templateRecuperacaoSenha(nome, codigoRecuperacao)
    };

    try {
      const info = await this.transporter.sendMail(mailOptions);
      console.log('✅ Email de recuperação enviado:', info.messageId);
      return { sucesso: true, messageId: info.messageId };
    } catch (error) {
      console.error('❌ Erro ao enviar email de recuperação:', error);
      return { sucesso: false, erro: error.message };
    }
  }

  /**
   * Template HTML do email de recuperação de senha
   */
  templateRecuperacaoSenha(nome, codigo) {
    return `
      <!DOCTYPE html>
      <html lang="pt-BR">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body {
            margin: 0;
            padding: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f5f5f5;
          }
          .container {
            max-width: 600px;
            margin: 40px auto;
            background: white;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
          }
          .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 40px 30px;
            text-align: center;
            color: white;
          }
          .content {
            padding: 40px 30px;
            color: #333;
          }
          .code-box {
            background: #f8f9ff;
            border: 2px dashed #667eea;
            border-radius: 8px;
            padding: 20px;
            text-align: center;
            margin: 20px 0;
          }
          .code {
            font-size: 32px;
            font-weight: 700;
            color: #667eea;
            letter-spacing: 8px;
            font-family: 'Courier New', monospace;
          }
          .warning {
            background: #fff3cd;
            border-left: 4px solid #ffc107;
            padding: 15px;
            margin: 20px 0;
            border-radius: 4px;
          }
          .footer {
            background: #f8f9fa;
            padding: 30px;
            text-align: center;
            color: #666;
            font-size: 14px;
            border-top: 1px solid #e0e0e0;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1 style="margin: 0; font-size: 32px;">🔑</h1>
            <h2 style="margin: 10px 0 0 0;">Recuperação de Senha</h2>
          </div>

          <div class="content">
            <h2 style="color: #667eea;">Olá, ${nome}!</h2>
            <p>
              Recebemos uma solicitação para recuperar sua senha. Use o código abaixo 
              para criar uma nova senha:
            </p>

            <div class="code-box">
              <p style="margin: 0 0 10px 0; font-size: 14px; color: #666;">
                Seu código de recuperação:
              </p>
              <div class="code">${codigo}</div>
              <p style="margin: 15px 0 0 0; font-size: 12px; color: #999;">
                Válido por 30 minutos
              </p>
            </div>

            <div class="warning">
              <p style="margin: 0; font-size: 14px;">
                ⚠️ <strong>Importante:</strong> Se você não solicitou esta recuperação, 
                ignore este email. Sua senha permanecerá segura.
              </p>
            </div>

            <p style="font-size: 14px; color: #777; margin-top: 30px;">
              Por questões de segurança, nunca compartilhe este código com ninguém.
            </p>
          </div>

          <div class="footer">
            <p style="margin: 0;">
              <strong>Postul</strong> - Seu assistente de combustível
            </p>
            <p style="font-size: 12px; color: #999; margin: 15px 0 0 0;">
              © ${new Date().getFullYear()} Postul. Todos os direitos reservados.
            </p>
          </div>
        </div>
      </body>
      </html>
    `;
  }
}

module.exports = new EmailService();
