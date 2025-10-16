const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

const createTables = async () => {
  // Tabela de usuários
  const createUsersTable = `
    CREATE TABLE IF NOT EXISTS usuarios (
      id SERIAL PRIMARY KEY,
      nome VARCHAR(255) NOT NULL,
      email VARCHAR(255) UNIQUE NOT NULL,
      senha VARCHAR(255) NOT NULL,
      criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  `;

  // Tabela de postos
  const createPostosTable = `
    CREATE TABLE IF NOT EXISTS postos (
      id SERIAL PRIMARY KEY,
      nome VARCHAR(255) NOT NULL,
      endereco TEXT NOT NULL,
      latitude DECIMAL(10, 8) NOT NULL,
      longitude DECIMAL(11, 8) NOT NULL,
      telefone VARCHAR(20),
      aberto_24h BOOLEAN DEFAULT false,
      criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  `;

  // Tabela de preços de combustíveis
  const createPrecosTable = `
    CREATE TABLE IF NOT EXISTS precos_combustivel (
      id SERIAL PRIMARY KEY,
      posto_id INTEGER REFERENCES postos(id) ON DELETE CASCADE,
      tipo_combustivel VARCHAR(50) NOT NULL,
      preco DECIMAL(5, 3) NOT NULL,
      data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      usuario_id INTEGER REFERENCES usuarios(id),
      UNIQUE(posto_id, tipo_combustivel)
    );
  `;

  try {
    await pool.query(createUsersTable);
    await pool.query(createPostosTable);
    await pool.query(createPrecosTable);
    console.log('✅ Tabelas criadas com sucesso!');
  } catch (error) {
    console.error('❌ Erro ao criar tabelas:', error);
  }
};

createTables();

module.exports = pool;