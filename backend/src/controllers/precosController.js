const pool = require('../config/database');

const precosController = {
  // Atualizar ou criar preço de combustível
  atualizarPreco: async (req, res) => {
    const { posto_id, tipo_combustivel, preco, usuario_id } = req.body;

    try {
      if (!posto_id || !tipo_combustivel || !preco) {
        return res.status(400).json({
          sucesso: false,
          mensagem: 'Posto, tipo de combustível e preço são obrigatórios'
        });
      }

      // Verificar se o posto existe
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

      // Inserir ou atualizar preço
      const resultado = await pool.query(
        `INSERT INTO precos_combustivel (posto_id, tipo_combustivel, preco, usuario_id, data_atualizacao)
         VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)
         ON CONFLICT (posto_id, tipo_combustivel) 
         DO UPDATE SET 
           preco = $3,
           usuario_id = $4,
           data_atualizacao = CURRENT_TIMESTAMP
         RETURNING *`,
        [posto_id, tipo_combustivel, preco, usuario_id]
      );

      res.json({
        sucesso: true,
        mensagem: 'Preço atualizado com sucesso',
        preco: resultado.rows[0]
      });

    } catch (error) {
      console.error('Erro ao atualizar preço:', error);
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao atualizar preço'
      });
    }
  },

  // Atualizar preço via navegação (sem autenticação obrigatória)
  atualizarPrecoNavegacao: async (req, res) => {
    const { posto_id, nome_posto, preco, produto, data_atualizacao } = req.body;

    try {
      if (!posto_id || !preco) {
        return res.status(400).json({
          sucesso: false,
          mensagem: 'Posto ID e preço são obrigatórios'
        });
      }

      // Verificar se o posto existe
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

      // Normalizar tipo de combustível
      const tipoCombustivel = produto || 'Gasolina';

      // Inserir ou atualizar preço (sem usuario_id pois vem da navegação)
      const resultado = await pool.query(
        `INSERT INTO precos_combustivel (posto_id, tipo_combustivel, preco, data_atualizacao)
         VALUES ($1, $2, $3, COALESCE($4::timestamp, CURRENT_TIMESTAMP))
         ON CONFLICT (posto_id, tipo_combustivel) 
         DO UPDATE SET 
           preco = $3,
           data_atualizacao = COALESCE($4::timestamp, CURRENT_TIMESTAMP)
         RETURNING *`,
        [posto_id, tipoCombustivel, preco, data_atualizacao || null]
      );

      console.log(`✅ Preço atualizado via navegação: Posto ${posto_id} (${nome_posto}) - ${tipoCombustivel}: R$ ${preco}`);

      res.json({
        sucesso: true,
        mensagem: 'Preço atualizado com sucesso via navegação',
        preco: resultado.rows[0]
      });

    } catch (error) {
      console.error('❌ Erro ao atualizar preço via navegação:', error);
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao atualizar preço via navegação',
        erro: error.message
      });
    }
  },

  // Listar preços de um posto específico
  listarPorPosto: async (req, res) => {
    const { posto_id } = req.params;

    try {
      const resultado = await pool.query(
        `SELECT pc.*, u.nome as usuario_nome
         FROM precos_combustivel pc
         LEFT JOIN usuarios u ON pc.usuario_id = u.id
         WHERE pc.posto_id = $1
         ORDER BY pc.tipo_combustivel`,
        [posto_id]
      );

      res.json({
        sucesso: true,
        precos: resultado.rows
      });

    } catch (error) {
      console.error('Erro ao listar preços:', error);
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao listar preços'
      });
    }
  }
};

module.exports = precosController;