const pool = require('../config/database');

const avaliacoesController = {
  // Criar ou atualizar avaliação
  avaliar: async (req, res) => {
    const { posto_id, usuario_id, nota, comentario } = req.body;

    try {
      if (!posto_id || !usuario_id || !nota) {
        return res.status(400).json({
          sucesso: false,
          mensagem: 'Posto, usuário e nota são obrigatórios'
        });
      }

      if (nota < 1 || nota > 5) {
        return res.status(400).json({
          sucesso: false,
          mensagem: 'Nota deve ser entre 1 e 5'
        });
      }

      // Verificar se posto existe
      const postoExiste = await pool.query(
        'SELECT id FROM postos WHERE id = $1',
        [posto_id]
      );

      if (postoExiste.rows.length === 0) {
        return res.status(404).json({
          sucesso: false,
          mensagem: 'Posto não encontrado'
        });
      }

      // Inserir ou atualizar avaliação
      const resultado = await pool.query(
        `INSERT INTO avaliacoes (posto_id, usuario_id, nota, comentario, data_atualizacao)
         VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)
         ON CONFLICT (posto_id, usuario_id) 
         DO UPDATE SET 
           nota = $3,
           comentario = $4,
           data_atualizacao = CURRENT_TIMESTAMP
         RETURNING *`,
        [posto_id, usuario_id, nota, comentario]
      );

      res.json({
        sucesso: true,
        mensagem: 'Avaliação registrada com sucesso',
        avaliacao: resultado.rows[0]
      });

    } catch (error) {
      console.error('Erro ao avaliar posto:', error);
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao avaliar posto'
      });
    }
  },

  // Obter avaliações de um posto
  listarPorPosto: async (req, res) => {
    const { posto_id } = req.params;

    try {
      const resultado = await pool.query(
        `SELECT 
          a.*,
          u.nome as usuario_nome
         FROM avaliacoes a
         JOIN usuarios u ON a.usuario_id = u.id
         WHERE a.posto_id = $1
         ORDER BY a.data_atualizacao DESC`,
        [posto_id]
      );

      res.json({
        sucesso: true,
        avaliacoes: resultado.rows
      });

    } catch (error) {
      console.error('Erro ao listar avaliações:', error);
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao listar avaliações'
      });
    }
  },

  // Obter média e total de avaliações de um posto
  obterMediaPosto: async (req, res) => {
    const { posto_id } = req.params;

    try {
      const resultado = await pool.query(
        `SELECT 
          COALESCE(ROUND(AVG(nota)::numeric, 1), 0) as nota_media,
          COUNT(*) as total_avaliacoes,
          COUNT(CASE WHEN nota = 5 THEN 1 END) as estrelas_5,
          COUNT(CASE WHEN nota = 4 THEN 1 END) as estrelas_4,
          COUNT(CASE WHEN nota = 3 THEN 1 END) as estrelas_3,
          COUNT(CASE WHEN nota = 2 THEN 1 END) as estrelas_2,
          COUNT(CASE WHEN nota = 1 THEN 1 END) as estrelas_1
         FROM avaliacoes
         WHERE posto_id = $1`,
        [posto_id]
      );

      res.json({
        sucesso: true,
        ...resultado.rows[0]
      });

    } catch (error) {
      console.error('Erro ao obter média:', error);
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao obter média'
      });
    }
  },

  // Obter avaliação específica do usuário
  obterAvaliacaoUsuario: async (req, res) => {
    const { posto_id, usuario_id } = req.params;

    try {
      const resultado = await pool.query(
        `SELECT * FROM avaliacoes 
         WHERE posto_id = $1 AND usuario_id = $2`,
        [posto_id, usuario_id]
      );

      if (resultado.rows.length === 0) {
        return res.json({
          sucesso: true,
          avaliacao: null
        });
      }

      res.json({
        sucesso: true,
        avaliacao: resultado.rows[0]
      });

    } catch (error) {
      console.error('Erro ao obter avaliação:', error);
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao obter avaliação'
      });
    }
  },

  // Deletar avaliação
  deletar: async (req, res) => {
    const { posto_id, usuario_id } = req.params;

    try {
      const resultado = await pool.query(
        'DELETE FROM avaliacoes WHERE posto_id = $1 AND usuario_id = $2 RETURNING *',
        [posto_id, usuario_id]
      );

      if (resultado.rows.length === 0) {
        return res.status(404).json({
          sucesso: false,
          mensagem: 'Avaliação não encontrada'
        });
      }

      res.json({
        sucesso: true,
        mensagem: 'Avaliação removida com sucesso'
      });

    } catch (error) {
      console.error('Erro ao deletar avaliação:', error);
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao deletar avaliação'
      });
    }
  }
};

module.exports = avaliacoesController;