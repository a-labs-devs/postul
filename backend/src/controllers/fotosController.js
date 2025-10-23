const pool = require('../config/database');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Configurar storage do Multer
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const dir = './uploads/fotos-postos';
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    cb(null, dir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'posto-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter: function (req, file, cb) {
    const filetypes = /jpeg|jpg|png|webp/;
    const mimetype = filetypes.test(file.mimetype);
    const extname = filetypes.test(path.extname(file.originalname).toLowerCase());

    if (mimetype && extname) {
      return cb(null, true);
    }
    cb(new Error('Apenas imagens são permitidas (jpeg, jpg, png, webp)'));
  }
});

const fotosController = {
  // Middleware de upload
  uploadMiddleware: upload.single('foto'),

  // Upload de foto
  upload: async (req, res) => {
    const { posto_id, usuario_id, descricao } = req.body;

    try {
      if (!req.file) {
        return res.status(400).json({
          sucesso: false,
          mensagem: 'Nenhuma foto foi enviada'
        });
      }

      if (!posto_id || !usuario_id) {
        // Deletar arquivo enviado
        fs.unlinkSync(req.file.path);
        return res.status(400).json({
          sucesso: false,
          mensagem: 'Posto e usuário são obrigatórios'
        });
      }

      // Verificar se posto existe
      const postoExiste = await pool.query(
        'SELECT id FROM postos WHERE id = $1',
        [posto_id]
      );

      if (postoExiste.rows.length === 0) {
        fs.unlinkSync(req.file.path);
        return res.status(404).json({
          sucesso: false,
          mensagem: 'Posto não encontrado'
        });
      }

      // Salvar no banco
      const urlFoto = `/uploads/fotos-postos/${req.file.filename}`;
      
      const resultado = await pool.query(
        `INSERT INTO fotos_postos (posto_id, usuario_id, url_foto, descricao)
         VALUES ($1, $2, $3, $4)
         RETURNING *`,
        [posto_id, usuario_id, urlFoto, descricao]
      );

      res.json({
        sucesso: true,
        mensagem: 'Foto enviada com sucesso',
        foto: resultado.rows[0]
      });

    } catch (error) {
      console.error('Erro ao fazer upload:', error);
      // Deletar arquivo em caso de erro
      if (req.file) {
        fs.unlinkSync(req.file.path);
      }
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao fazer upload da foto'
      });
    }
  },

  // Listar fotos de um posto
  listarPorPosto: async (req, res) => {
    const { posto_id } = req.params;

    try {
      const resultado = await pool.query(
        `SELECT 
          f.*,
          u.nome as usuario_nome
         FROM fotos_postos f
         JOIN usuarios u ON f.usuario_id = u.id
         WHERE f.posto_id = $1 AND f.ativo = true
         ORDER BY f.data_upload DESC`,
        [posto_id]
      );

      res.json({
        sucesso: true,
        fotos: resultado.rows
      });

    } catch (error) {
      console.error('Erro ao listar fotos:', error);
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao listar fotos'
      });
    }
  },

  // Deletar foto
  deletar: async (req, res) => {
    const { id, usuario_id } = req.params;

    try {
      // Buscar foto
      const foto = await pool.query(
        'SELECT * FROM fotos_postos WHERE id = $1 AND usuario_id = $2',
        [id, usuario_id]
      );

      if (foto.rows.length === 0) {
        return res.status(404).json({
          sucesso: false,
          mensagem: 'Foto não encontrada ou você não tem permissão'
        });
      }

      // Marcar como inativa
      await pool.query(
        'UPDATE fotos_postos SET ativo = false WHERE id = $1',
        [id]
      );

      // Deletar arquivo físico
      const caminhoArquivo = `.${foto.rows[0].url_foto}`;
      if (fs.existsSync(caminhoArquivo)) {
        fs.unlinkSync(caminhoArquivo);
      }

      res.json({
        sucesso: true,
        mensagem: 'Foto removida com sucesso'
      });

    } catch (error) {
      console.error('Erro ao deletar foto:', error);
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao deletar foto'
      });
    }
  },

  // Contar fotos de um posto
  contarFotos: async (req, res) => {
    const { posto_id } = req.params;

    try {
      const resultado = await pool.query(
        'SELECT COUNT(*) as total FROM fotos_postos WHERE posto_id = $1 AND ativo = true',
        [posto_id]
      );

      res.json({
        sucesso: true,
        total: parseInt(resultado.rows[0].total)
      });

    } catch (error) {
      console.error('Erro ao contar fotos:', error);
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao contar fotos'
      });
    }
  }
};

module.exports = fotosController;