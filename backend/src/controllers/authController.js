const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const pool = require('../config/database');
const emailService = require('../services/emailService');

const authController = {
  cadastrar: async (req, res) => {
    const { nome, email, senha } = req.body;

    try {
      if (!nome || !email || !senha) {
        return res.status(400).json({
          sucesso: false,
          mensagem: 'Todos os campos são obrigatórios'
        });
      }

      if (senha.length < 6) {
        return res.status(400).json({
          sucesso: false,
          mensagem: 'Senha deve ter pelo menos 6 caracteres'
        });
      }

      const usuarioExiste = await pool.query(
        'SELECT * FROM usuarios WHERE email = $1',
        [email]
      );

      if (usuarioExiste.rows.length > 0) {
        return res.status(400).json({
          sucesso: false,
          mensagem: 'Email já cadastrado'
        });
      }

      const senhaCriptografada = await bcrypt.hash(senha, 10);

      const novoUsuario = await pool.query(
        'INSERT INTO usuarios (nome, email, senha) VALUES ($1, $2, $3) RETURNING id, nome, email, criado_em',
        [nome, email, senhaCriptografada]
      );

      const usuario = novoUsuario.rows[0];

      const token = jwt.sign(
        { id: usuario.id, email: usuario.email },
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_EXPIRES_IN }
      );

      // 📧 Enviar email de boas-vindas (não bloqueia a resposta)
      emailService.enviarEmailBoasVindas(usuario.nome, usuario.email)
        .then(resultado => {
          if (resultado.sucesso) {
            console.log('✅ Email de boas-vindas enviado para:', usuario.email);
          } else {
            console.log('⚠️ Falha ao enviar email:', resultado.erro);
          }
        })
        .catch(err => console.error('❌ Erro no envio de email:', err));

      res.status(201).json({
        sucesso: true,
        mensagem: 'Usuário cadastrado com sucesso',
        token,
        usuario: {
          id: usuario.id,
          nome: usuario.nome,
          email: usuario.email
        }
      });

    } catch (error) {
      console.error('Erro ao cadastrar:', error);
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao cadastrar usuário'
      });
    }
  },

  login: async (req, res) => {
    const { email, senha } = req.body;

    try {
      if (!email || !senha) {
        return res.status(400).json({
          sucesso: false,
          mensagem: 'Email e senha são obrigatórios'
        });
      }

      const resultado = await pool.query(
        'SELECT * FROM usuarios WHERE email = $1',
        [email]
      );

      if (resultado.rows.length === 0) {
        return res.status(401).json({
          sucesso: false,
          mensagem: 'Email ou senha incorretos'
        });
      }

      const usuario = resultado.rows[0];

      const senhaValida = await bcrypt.compare(senha, usuario.senha);

      if (!senhaValida) {
        return res.status(401).json({
          sucesso: false,
          mensagem: 'Email ou senha incorretos'
        });
      }

      const token = jwt.sign(
        { id: usuario.id, email: usuario.email },
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_EXPIRES_IN }
      );

      res.json({
        sucesso: true,
        mensagem: 'Login realizado com sucesso',
        token,
        usuario: {
          id: usuario.id,
          nome: usuario.nome,
          email: usuario.email
        }
      });

    } catch (error) {
      console.error('Erro ao fazer login:', error);
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao fazer login'
      });
    }
  },

  verificarToken: async (req, res) => {
    const token = req.headers.authorization?.split(' ')[1];

    if (!token) {
      return res.status(401).json({
        sucesso: false,
        mensagem: 'Token não fornecido'
      });
    }

    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      
      const resultado = await pool.query(
        'SELECT id, nome, email FROM usuarios WHERE id = $1',
        [decoded.id]
      );

      if (resultado.rows.length === 0) {
        return res.status(404).json({
          sucesso: false,
          mensagem: 'Usuário não encontrado'
        });
      }

      res.json({
        sucesso: true,
        usuario: resultado.rows[0]
      });

    } catch (error) {
      res.status(401).json({
        sucesso: false,
        mensagem: 'Token inválido'
      });
    }
  },

  // 🔑 Solicitar recuperação de senha
  solicitarRecuperacao: async (req, res) => {
    const { email } = req.body;

    try {
      if (!email) {
        return res.status(400).json({
          sucesso: false,
          mensagem: 'Email é obrigatório'
        });
      }

      // Verificar se usuário existe
      const resultado = await pool.query(
        'SELECT id, nome, email FROM usuarios WHERE email = $1',
        [email]
      );

      if (resultado.rows.length === 0) {
        // Por segurança, retornar sucesso mesmo se email não existe
        return res.json({
          sucesso: true,
          mensagem: 'Se o email existir, você receberá um código de recuperação'
        });
      }

      const usuario = resultado.rows[0];

      // Gerar código de 6 dígitos
      const codigo = Math.floor(100000 + Math.random() * 900000).toString();

      // Salvar código no banco (PostgreSQL calcula expiração com timezone correto)
      await pool.query(
        `INSERT INTO codigos_recuperacao (email, codigo, expira_em) 
         VALUES ($1, $2, NOW() + INTERVAL '30 minutes')`,
        [email, codigo]
      );

      console.log(`🔑 Código gerado para ${email}: ${codigo}`);
      console.log(`⏰ Válido até: ${new Date(Date.now() + 30 * 60 * 1000).toLocaleString('pt-BR')}`);

      // Enviar email com código
      emailService.enviarEmailRecuperacaoSenha(usuario.nome, usuario.email, codigo)
        .then(resultado => {
          if (resultado.sucesso) {
            console.log('✅ Email de recuperação enviado para:', usuario.email);
          } else {
            console.log('⚠️ Falha ao enviar email de recuperação:', resultado.erro);
          }
        })
        .catch(err => console.error('❌ Erro no envio de email de recuperação:', err));

      res.json({
        sucesso: true,
        mensagem: 'Código de recuperação enviado para seu email'
      });

    } catch (error) {
      console.error('Erro ao solicitar recuperação:', error);
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao processar solicitação'
      });
    }
  },

  // 🔑 Validar código de recuperação
  validarCodigo: async (req, res) => {
    const { email, codigo } = req.body;

    console.log('🔍 Validando código:', {
      email,
      codigo,
      tipoCodigo: typeof codigo,
      comprimento: codigo?.length
    });

    try {
      if (!email || !codigo) {
        return res.status(400).json({
          sucesso: false,
          mensagem: 'Email e código são obrigatórios'
        });
      }

      // Buscar código válido
      const resultado = await pool.query(
        `SELECT * FROM codigos_recuperacao 
         WHERE email = $1 
         AND codigo = $2 
         AND usado = false 
         AND expira_em > NOW()
         ORDER BY criado_em DESC
         LIMIT 1`,
        [email, codigo]
      );

      console.log('📊 Resultado da busca:', {
        encontrados: resultado.rows.length,
        todosCodigosEmail: await pool.query(
          'SELECT codigo, usado, expira_em, criado_em FROM codigos_recuperacao WHERE email = $1 ORDER BY criado_em DESC LIMIT 5',
          [email]
        ).then(r => r.rows)
      });

      if (resultado.rows.length === 0) {
        return res.status(400).json({
          sucesso: false,
          mensagem: 'Código inválido ou expirado'
        });
      }

      res.json({
        sucesso: true,
        mensagem: 'Código válido'
      });

    } catch (error) {
      console.error('Erro ao validar código:', error);
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao validar código'
      });
    }
  },

  // 🔑 Redefinir senha
  redefinirSenha: async (req, res) => {
    const { email, codigo, novaSenha } = req.body;

    try {
      if (!email || !codigo || !novaSenha) {
        return res.status(400).json({
          sucesso: false,
          mensagem: 'Todos os campos são obrigatórios'
        });
      }

      if (novaSenha.length < 6) {
        return res.status(400).json({
          sucesso: false,
          mensagem: 'Senha deve ter pelo menos 6 caracteres'
        });
      }

      // Buscar código válido
      const codigoResult = await pool.query(
        `SELECT * FROM codigos_recuperacao 
         WHERE email = $1 
         AND codigo = $2 
         AND usado = false 
         AND expira_em > NOW()
         ORDER BY criado_em DESC
         LIMIT 1`,
        [email, codigo]
      );

      if (codigoResult.rows.length === 0) {
        return res.status(400).json({
          sucesso: false,
          mensagem: 'Código inválido ou expirado'
        });
      }

      // Verificar se usuário existe
      const usuarioResult = await pool.query(
        'SELECT * FROM usuarios WHERE email = $1',
        [email]
      );

      if (usuarioResult.rows.length === 0) {
        return res.status(404).json({
          sucesso: false,
          mensagem: 'Usuário não encontrado'
        });
      }

      // Atualizar senha
      const senhaCriptografada = await bcrypt.hash(novaSenha, 10);
      
      await pool.query(
        'UPDATE usuarios SET senha = $1, atualizado_em = NOW() WHERE email = $2',
        [senhaCriptografada, email]
      );

      // Marcar código como usado
      await pool.query(
        'UPDATE codigos_recuperacao SET usado = true, usado_em = NOW() WHERE id = $1',
        [codigoResult.rows[0].id]
      );

      console.log('✅ Senha redefinida com sucesso para:', email);

      res.json({
        sucesso: true,
        mensagem: 'Senha redefinida com sucesso'
      });

    } catch (error) {
      console.error('Erro ao redefinir senha:', error);
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao redefinir senha'
      });
    }
  }
};


module.exports = authController;