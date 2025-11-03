/**
 * 🏁 Script para Adicionar Posto Manualmente
 * Adiciona: Rede 7 - Taipas
 */

require('dotenv').config();
const { Pool } = require('pg');

const CONFIG = {
  DB_CONFIG: {
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    user: process.env.DB_USER || 'admin',
    password: process.env.DB_PASSWORD || 'admin123',
    database: process.env.DB_NAME || 'postos_db'
  }
};

const pool = new Pool(CONFIG.DB_CONFIG);

async function adicionarPosto() {
  console.log('🏁 Adicionando Posto: Rede 7 - Taipas\n');
  
  try {
    // Dados do posto
    const nome = 'Rede 7 - Taipas';
    const endereco = 'Taipas, São Paulo - SP';
    const latitude = -23.431174682262377;
    const longitude = -46.72647292735973;
    const telefone = null;
    const aberto24h = false;
    
    // Verificar se já existe
    const existeQuery = `
      SELECT id, nome FROM postos 
      WHERE ABS(latitude - $1) < 0.0001 
      AND ABS(longitude - $2) < 0.0001
      LIMIT 1
    `;
    
    const existe = await pool.query(existeQuery, [latitude, longitude]);
    
    if (existe.rows.length > 0) {
      console.log(`⚠️  Posto já existe no banco:`);
      console.log(`   ID: ${existe.rows[0].id}`);
      console.log(`   Nome: ${existe.rows[0].nome}`);
      console.log('\n✅ Nenhuma ação necessária.');
      await pool.end();
      return;
    }
    
    // Inserir posto
    const insertQuery = `
      INSERT INTO postos (nome, endereco, latitude, longitude, telefone, aberto_24h)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING id, nome
    `;
    
    const result = await pool.query(insertQuery, [
      nome,
      endereco,
      latitude,
      longitude,
      telefone,
      aberto24h
    ]);
    
    console.log('✅ Posto adicionado com sucesso!');
    console.log(`   ID: ${result.rows[0].id}`);
    console.log(`   Nome: ${result.rows[0].nome}`);
    console.log(`   Coordenadas: ${latitude}, ${longitude}`);
    
    // Verificar total de postos
    const totalQuery = 'SELECT COUNT(*) as total FROM postos';
    const total = await pool.query(totalQuery);
    
    console.log(`\n📊 Total de postos no banco: ${total.rows[0].total}`);
    
  } catch (error) {
    console.error('\n❌ Erro ao adicionar posto:');
    console.error(error);
  } finally {
    await pool.end();
  }
}

// Executar
adicionarPosto();
