const { Pool } = require('pg');

const CONFIG = {
  DB_CONFIG: {
    host: 'localhost',
    port: 5432,
    user: 'admin',
    password: '7171FIEAvwU0',
    database: 'postos_db'
  }
};

const pool = new Pool(CONFIG.DB_CONFIG);

// Preços base realistas para SP (outubro 2024)
const PRECOS_BASE = {
  gasolina: { min: 5.39, max: 6.49 },
  etanol: { min: 3.79, max: 4.89 },
  diesel: { min: 5.89, max: 6.79 },
  gnv: { min: 4.49, max: 5.39 }
};

function gerarPreco(tipo) {
  const base = PRECOS_BASE[tipo];
  const preco = base.min + Math.random() * (base.max - base.min);
  return parseFloat(preco.toFixed(2));
}

async function gerarPrecos() {
  console.log('Gerador de Precos de Teste\n');
  console.log('==================================================');
  
  try {
    await pool.query('SELECT NOW()');
    console.log('Conectado ao banco PostgreSQL\n');
    
    // Buscar todos os postos
    const postos = await pool.query('SELECT id, nome FROM postos ORDER BY id');
    console.log(`Encontrados ${postos.rows.length} postos\n`);
    
    let precosInseridos = 0;
    
    for (const posto of postos.rows) {
      // Gerar preços para cada tipo de combustível
      const tipos = ['gasolina', 'etanol', 'diesel', 'gnv'];
      
      for (const tipo of tipos) {
        // 80% chance de ter cada tipo de combustível
        if (Math.random() > 0.2) {
          const preco = gerarPreco(tipo);
          
          await pool.query(
            `INSERT INTO precos_combustivel (posto_id, tipo_combustivel, preco, data_atualizacao)
             VALUES ($1, $2, $3, NOW())`,
            [posto.id, tipo, preco]
          );
          
          precosInseridos++;
        }
      }
      
      if (posto.id % 10 === 0) {
        console.log(`Processados ${posto.id} postos... (${precosInseridos} precos)`);
      }
    }
    
    console.log('\n==================================================');
    console.log('RESUMO');
    console.log('==================================================');
    console.log(`Postos processados: ${postos.rows.length}`);
    console.log(`Precos inseridos: ${precosInseridos}`);
    console.log('==================================================');
    console.log('\nPrecos gerados com sucesso!');
    console.log('Abra o app para visualizar!\n');
    
  } catch (error) {
    console.error('Erro:', error.message);
  } finally {
    await pool.end();
  }
}

gerarPrecos();