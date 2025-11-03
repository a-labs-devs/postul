const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

async function checkPostos() {
  try {
    console.log('🔍 Conectando ao banco de dados...');
    const client = await pool.connect();
    
    // Verificar quantidade de postos
    const result = await client.query('SELECT COUNT(*) FROM postos');
    const count = result.rows[0].count;
    console.log(`📊 Total de postos no banco: ${count}`);
    
    // Mostrar alguns postos
    if (count > 0) {
      const postos = await client.query('SELECT id, nome, latitude, longitude FROM postos LIMIT 5');
      console.log('\n📍 Primeiros 5 postos:');
      postos.rows.forEach(posto => {
        console.log(`  - ID: ${posto.id}, Nome: ${posto.nome}, Lat: ${posto.latitude}, Lng: ${posto.longitude}`);
      });
    } else {
      console.log('\n⚠️ Nenhum posto encontrado no banco!');
      console.log('Execute: node importar_postos_google.js');
    }
    
    client.release();
    await pool.end();
  } catch (error) {
    console.error('❌ Erro:', error.message);
    process.exit(1);
  }
}

checkPostos();
