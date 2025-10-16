const pool = require('../config/database');

const postosController = {
  // Listar todos os postos
  listarTodos: async (req, res) => {
    try {
      const resultado = await pool.query(`
        SELECT p.*, 
               json_agg(
                 json_build_object(
                   'tipo', pc.tipo_combustivel,
                   'preco', pc.preco,
                   'atualizado_em', pc.data_atualizacao
                 )
               ) FILTER (WHERE pc.id IS NOT NULL) as precos
        FROM postos p
        LEFT JOIN precos_combustivel pc ON p.id = pc.posto_id
        GROUP BY p.id
        ORDER BY p.nome
      `);

      res.json({
        sucesso: true,
        postos: resultado.rows
      });
    } catch (error) {
      console.error('Erro ao listar postos:', error);
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao listar postos'
      });
    }
  },

  // Buscar postos próximos (por coordenadas)
  buscarProximos: async (req, res) => {
    const { latitude, longitude, raio } = req.query;

    if (!latitude || !longitude) {
      return res.status(400).json({
        sucesso: false,
        mensagem: 'Latitude e longitude são obrigatórias'
      });
    }

    const raioKm = raio || 5;

    try {
      const resultado = await pool.query(`
        SELECT 
          p.*,
          (
            6371 * acos(
              cos(radians($1)) * cos(radians(p.latitude)) *
              cos(radians(p.longitude) - radians($2)) +
              sin(radians($1)) * sin(radians(p.latitude))
            )
          ) AS distancia
        FROM postos p
        WHERE (
          6371 * acos(
            cos(radians($1)) * cos(radians(p.latitude)) *
            cos(radians(p.longitude) - radians($2)) +
            sin(radians($1)) * sin(radians(p.latitude))
          )
        ) <= $3
        ORDER BY distancia
      `, [latitude, longitude, raioKm]);

      const postosComPrecos = await Promise.all(
        resultado.rows.map(async (posto) => {
          const precos = await pool.query(
            `SELECT tipo_combustivel as tipo, preco, data_atualizacao as atualizado_em
             FROM precos_combustivel
             WHERE posto_id = $1`,
            [posto.id]
          );
          
          return {
            ...posto,
            precos: precos.rows.length > 0 ? precos.rows : null
          };
        })
      );

      res.json({
        sucesso: true,
        postos: postosComPrecos
      });
    } catch (error) {
      console.error('Erro ao buscar postos próximos:', error);
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao buscar postos próximos'
      });
    }
  },

  // Cadastrar novo posto
  cadastrar: async (req, res) => {
    const { nome, endereco, latitude, longitude, telefone, aberto_24h } = req.body;

    try {
      if (!nome || !endereco || !latitude || !longitude) {
        return res.status(400).json({
          sucesso: false,
          mensagem: 'Nome, endereço, latitude e longitude são obrigatórios'
        });
      }

      const novoPosto = await pool.query(
        `INSERT INTO postos (nome, endereco, latitude, longitude, telefone, aberto_24h)
         VALUES ($1, $2, $3, $4, $5, $6)
         RETURNING *`,
        [nome, endereco, latitude, longitude, telefone || null, aberto_24h || false]
      );

      res.status(201).json({
        sucesso: true,
        mensagem: 'Posto cadastrado com sucesso',
        posto: novoPosto.rows[0]
      });
    } catch (error) {
      console.error('Erro ao cadastrar posto:', error);
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao cadastrar posto'
      });
    }
  }
};

module.exports = postosController;