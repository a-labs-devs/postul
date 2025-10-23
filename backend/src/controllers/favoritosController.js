const pool = require('../config/database');

const favoritosController = {
  // Listar favoritos do usuário
  listar: async (req, res) => {
    const { usuario_id } = req.query;

    if (!usuario_id) {
      return res.status(400).json({
        sucesso: false,
        mensagem: 'ID do usuário é obrigatório'
      });
    }

    try {
      const resultado = await pool.query(`
        SELECT 
          f.*,
          p.nome as posto_nome,
          p.endereco as posto_endereco,
          p.latitude,
          p.longitude,
          p.telefone,
          p.aberto_24h,
          (
            SELECT json_agg(
              json_build_object(
                'tipo', pc.tipo_combustivel,
                'preco', pc.preco,
                'atualizado_em', pc.data_atualizacao
              )
            )
            FROM precos_combustivel pc
            WHERE pc.posto_id = p.id
          ) as precos
        FROM favoritos f
        INNER JOIN postos p ON f.posto_id = p.id
        WHERE f.usuario_id = $1
        ORDER BY f.criado_em DESC
      `, [usuario_id]);

      res.json({
        sucesso: true,
        favoritos: resultado.rows
      });
    } catch (error) {
      console.error('Erro ao listar favoritos:', error);
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao listar favoritos'
      });
    }
  },

  // Adicionar favorito
  adicionar: async (req, res) => {
    const { usuario_id, posto_id, combustivel_preferido, preco_alvo, notificar_sempre } = req.body;

    if (!usuario_id || !posto_id) {
      return res.status(400).json({
        sucesso: false,
        mensagem: 'ID do usuário e do posto são obrigatórios'
      });
    }

    try {
      // Verificar se já existe
      const existe = await pool.query(
        'SELECT id FROM favoritos WHERE usuario_id = $1 AND posto_id = $2',
        [usuario_id, posto_id]
      );

      if (existe.rows.length > 0) {
        return res.status(400).json({
          sucesso: false,
          mensagem: 'Posto já está nos favoritos'
        });
      }

      // Adicionar favorito
      const novoFavorito = await pool.query(`
        INSERT INTO favoritos (
          usuario_id, 
          posto_id, 
          combustivel_preferido, 
          preco_alvo, 
          notificar_sempre
        ) VALUES ($1, $2, $3, $4, $5)
        RETURNING *
      `, [
        usuario_id, 
        posto_id, 
        combustivel_preferido || 'Gasolina Comum', 
        preco_alvo || null,
        notificar_sempre !== false
      ]);

      res.status(201).json({
        sucesso: true,
        mensagem: 'Posto adicionado aos favoritos',
        favorito: novoFavorito.rows[0]
      });
    } catch (error) {
      console.error('Erro ao adicionar favorito:', error);
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao adicionar favorito'
      });
    }
  },

  // Remover favorito
  remover: async (req, res) => {
    const { id } = req.params;

    try {
      const resultado = await pool.query(
        'DELETE FROM favoritos WHERE id = $1 RETURNING *',
        [id]
      );

      if (resultado.rows.length === 0) {
        return res.status(404).json({
          sucesso: false,
          mensagem: 'Favorito não encontrado'
        });
      }

      res.json({
        sucesso: true,
        mensagem: 'Favorito removido'
      });
    } catch (error) {
      console.error('Erro ao remover favorito:', error);
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao remover favorito'
      });
    }
  },

  // Atualizar configurações do favorito
  atualizar: async (req, res) => {
    const { id } = req.params;
    const { combustivel_preferido, preco_alvo, notificar_sempre } = req.body;

    try {
      const resultado = await pool.query(`
        UPDATE favoritos
        SET 
          combustivel_preferido = COALESCE($1, combustivel_preferido),
          preco_alvo = $2,
          notificar_sempre = COALESCE($3, notificar_sempre)
        WHERE id = $4
        RETURNING *
      `, [combustivel_preferido, preco_alvo, notificar_sempre, id]);

      if (resultado.rows.length === 0) {
        return res.status(404).json({
          sucesso: false,
          mensagem: 'Favorito não encontrado'
        });
      }

      res.json({
        sucesso: true,
        mensagem: 'Favorito atualizado',
        favorito: resultado.rows[0]
      });
    } catch (error) {
      console.error('Erro ao atualizar favorito:', error);
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao atualizar favorito'
      });
    }
  },

  // Verificar se posto é favorito
  verificar: async (req, res) => {
    const { usuario_id, posto_id } = req.query;

    if (!usuario_id || !posto_id) {
      return res.status(400).json({
        sucesso: false,
        mensagem: 'ID do usuário e do posto são obrigatórios'
      });
    }

    try {
      const resultado = await pool.query(
        'SELECT * FROM favoritos WHERE usuario_id = $1 AND posto_id = $2',
        [usuario_id, posto_id]
      );

      res.json({
        sucesso: true,
        favorito: resultado.rows.length > 0,
        dados: resultado.rows[0] || null
      });
    } catch (error) {
      console.error('Erro ao verificar favorito:', error);
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao verificar favorito'
      });
    }
  },

  // Obter histórico de preços
  historico: async (req, res) => {
    const { posto_id, tipo_combustivel, dias } = req.query;

    if (!posto_id || !tipo_combustivel) {
      return res.status(400).json({
        sucesso: false,
        mensagem: 'ID do posto e tipo de combustível são obrigatórios'
      });
    }

    const diasHistorico = dias || 30;

    try {
      const resultado = await pool.query(`
        SELECT *
        FROM historico_precos
        WHERE posto_id = $1 
          AND tipo_combustivel = $2
          AND registrado_em >= NOW() - INTERVAL '${diasHistorico} days'
        ORDER BY registrado_em DESC
      `, [posto_id, tipo_combustivel]);

      res.json({
        sucesso: true,
        historico: resultado.rows
      });
    } catch (error) {
      console.error('Erro ao buscar histórico:', error);
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao buscar histórico'
      });
    }
  },

  // Verificar quedas de preço nos favoritos
  verificarQuedasPreco: async (req, res) => {
    try {
      const resultado = await pool.query(`
        SELECT 
          f.id as favorito_id,
          f.usuario_id,
          f.posto_id,
          f.combustivel_preferido,
          f.preco_alvo,
          f.notificar_sempre,
          p.nome as posto_nome,
          pc.preco as preco_atual,
          (
            SELECT preco 
            FROM historico_precos 
            WHERE posto_id = f.posto_id 
              AND tipo_combustivel = f.combustivel_preferido
            ORDER BY registrado_em DESC 
            OFFSET 1 LIMIT 1
          ) as preco_anterior
        FROM favoritos f
        INNER JOIN postos p ON f.posto_id = p.id
        INNER JOIN precos_combustivel pc ON p.id = pc.posto_id 
          AND pc.tipo_combustivel = f.combustivel_preferido
        WHERE f.notificar_sempre = true
      `);

      const notificacoes = [];

      for (const fav of resultado.rows) {
        if (fav.preco_anterior && fav.preco_atual < fav.preco_anterior) {
          const variacao = fav.preco_anterior - fav.preco_atual;
          
          // Verificar se deve notificar
          const deveNotificar = 
            fav.notificar_sempre || 
            (fav.preco_alvo && fav.preco_atual <= fav.preco_alvo);

          if (deveNotificar) {
            notificacoes.push({
              usuario_id: fav.usuario_id,
              posto_id: fav.posto_id,
              posto_nome: fav.posto_nome,
              combustivel: fav.combustivel_preferido,
              preco_anterior: fav.preco_anterior,
              preco_atual: fav.preco_atual,
              economia: variacao
            });
          }
        }
      }

      res.json({
        sucesso: true,
        notificacoes,
        total: notificacoes.length
      });
    } catch (error) {
      console.error('Erro ao verificar quedas de preço:', error);
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao verificar quedas de preço'
      });
    }
  }
};

module.exports = favoritosController;