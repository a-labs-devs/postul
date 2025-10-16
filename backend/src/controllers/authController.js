const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const pool = require('../config/database');

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
  }
};

module.exports = authController;