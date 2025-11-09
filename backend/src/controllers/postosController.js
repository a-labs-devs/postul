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

  // 🚀 NOVO: Buscar postos por área (bounding box) - OTIMIZADO COM AUTO-IMPORTAÇÃO
  buscarPorArea: async (req, res) => {
    const { latMin, latMax, lngMin, lngMax, limit } = req.query;

    if (!latMin || !latMax || !lngMin || !lngMax) {
      return res.status(400).json({
        sucesso: false,
        mensagem: 'Coordenadas da área são obrigatórias (latMin, latMax, lngMin, lngMax)'
      });
    }

    const limitePostos = parseInt(limit) || 100; // Máximo 100 postos por requisição

    try {
      // Busca otimizada usando índice de coordenadas
      const resultado = await pool.query(`
        SELECT 
          p.id,
          COALESCE(p.nome, 'Posto sem nome') as nome,
          COALESCE(p.endereco, 'Endereço não informado') as endereco,
          COALESCE(p.latitude::text, '0')::numeric as latitude,
          COALESCE(p.longitude::text, '0')::numeric as longitude,
          COALESCE(p.telefone, '') as telefone,
          COALESCE(p.aberto_24h, false) as aberto_24h,
          COALESCE(
            json_agg(
              json_build_object(
                'tipo', COALESCE(pc.tipo_combustivel, ''),
                'preco', COALESCE(pc.preco, 0)
              )
            ) FILTER (WHERE pc.id IS NOT NULL),
            '[]'::json
          ) as precos
        FROM postos p
        LEFT JOIN precos_combustivel pc ON p.id = pc.posto_id
        WHERE p.latitude BETWEEN $1 AND $2
          AND p.longitude BETWEEN $3 AND $4
          AND p.id IS NOT NULL
        GROUP BY p.id, p.nome, p.endereco, p.latitude, p.longitude, p.telefone, p.aberto_24h
        LIMIT $5
      `, [latMin, latMax, lngMin, lngMax, limitePostos]);

      res.json({
        sucesso: true,
        total: resultado.rows.length,
        postos: resultado.rows
      });
    } catch (error) {
      console.error('Erro ao buscar postos por área:', error);
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao buscar postos por área'
      });
    }
  },

  // Buscar posto por ID (NOVO)
  buscarPorId: async (req, res) => {
    const { id } = req.params;

    try {
      const resultado = await pool.query(
        `SELECT p.*, 
                json_agg(
                  json_build_object(
                    'tipo', pc.tipo_combustivel,
                    'preco', pc.preco,
                    'atualizado_em', pc.data_atualizacao
                  )
                ) FILTER (WHERE pc.id IS NOT NULL) as precos
         FROM postos p
         LEFT JOIN precos_combustivel pc ON p.id = pc.posto_id
         WHERE p.id = $1
         GROUP BY p.id`,
        [id]
      );

      if (resultado.rows.length === 0) {
        return res.status(404).json({
          sucesso: false,
          mensagem: 'Posto não encontrado'
        });
      }

      res.json({
        sucesso: true,
        posto: resultado.rows[0]
      });
    } catch (error) {
      console.error('Erro ao buscar posto:', error);
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao buscar posto'
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
  },

  // Editar posto (NOVO)
  editar: async (req, res) => {
    const { id } = req.params;
    const { nome, endereco, latitude, longitude, telefone, aberto_24h } = req.body;

    try {
      // Verificar se o posto existe
      const postoExiste = await pool.query(
        'SELECT id FROM postos WHERE id = $1',
        [id]
      );

      if (postoExiste.rows.length === 0) {
        return res.status(404).json({
          sucesso: false,
          mensagem: 'Posto não encontrado'
        });
      }

      // Atualizar posto
      const postoAtualizado = await pool.query(
        `UPDATE postos 
         SET nome = $1, 
             endereco = $2, 
             latitude = $3, 
             longitude = $4, 
             telefone = $5, 
             aberto_24h = $6,
             atualizado_em = NOW()
         WHERE id = $7
         RETURNING *`,
        [nome, endereco, latitude, longitude, telefone, aberto_24h, id]
      );

      res.json({
        sucesso: true,
        mensagem: 'Posto atualizado com sucesso',
        posto: postoAtualizado.rows[0]
      });
    } catch (error) {
      console.error('Erro ao editar posto:', error);
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao editar posto'
      });
    }
  },

  // Deletar posto (NOVO)
  deletar: async (req, res) => {
    const { id } = req.params;

    try {
      // Verificar se o posto existe
      const postoExiste = await pool.query(
        'SELECT id FROM postos WHERE id = $1',
        [id]
      );

      if (postoExiste.rows.length === 0) {
        return res.status(404).json({
          sucesso: false,
          mensagem: 'Posto não encontrado'
        });
      }

      // Deletar preços relacionados primeiro (CASCADE)
      await pool.query('DELETE FROM precos_combustivel WHERE posto_id = $1', [id]);

      // Deletar posto
      await pool.query('DELETE FROM postos WHERE id = $1', [id]);

      res.json({
        sucesso: true,
        mensagem: 'Posto deletado com sucesso'
      });
    } catch (error) {
      console.error('Erro ao deletar posto:', error);
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao deletar posto'
      });
    }
  }
};

module.exports = postosController;