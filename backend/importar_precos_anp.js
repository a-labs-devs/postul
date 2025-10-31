const csv = require('csv-parser');
const fs = require('fs');
const { Pool } = require('pg');

// ========== CONFIGURAÇÃO ==========
const CONFIG = {
  DB_CONFIG: {
    host: 'localhost',
    port: 5432,
    user: 'admin',
    password: '7171FIEAvwU0',
    database: 'postos_db'
  },
  
  LOCAL_CSV_PATH: './precos_anp.csv',
  ESTADOS_FILTRO: ['SP'],
  DISTANCIA_MAXIMA: 0.01
};

const pool = new Pool(CONFIG.DB_CONFIG);

// ========== FUNÇÕES ==========

function normalizarCombustivel(produto) {
  const produto_upper = produto.toUpperCase();
  
  if (produto_upper.includes('GASOLINA')) return 'gasolina';
  if (produto_upper.includes('ETANOL') || produto_upper.includes('ALCOOL')) return 'etanol';
  if (produto_upper.includes('DIESEL')) return 'diesel';
  if (produto_upper.includes('GNV')) return 'gnv';
  
  return null;
}

async function encontrarPosto(municipio, bairro, endereco) {
  if (endereco && municipio) {
    const queryEnd = `
      SELECT id, nome, endereco 
      FROM postos 
      WHERE UPPER(endereco) LIKE $1
      AND (
        UPPER(endereco) LIKE $2
        OR UPPER(endereco) LIKE $3
      )
      LIMIT 1
    `;
    
    const enderecoLike = `%${endereco.substring(0, 30).toUpperCase()}%`;
    const municipioLike = `%${municipio.toUpperCase()}%`;
    const bairroLike = bairro ? `%${bairro.toUpperCase()}%` : '%';
    
    const result = await pool.query(queryEnd, [enderecoLike, municipioLike, bairroLike]);
    
    if (result.rows.length > 0) {
      return result.rows[0];
    }
  }
  
  return null;
}

async function inserirPreco(postoId, tipoCombustivel, preco, dataColeta) {
  const query = `
    INSERT INTO precos_combustivel (posto_id, tipo_combustivel, preco, data_atualizacao)
    VALUES ($1, $2, $3, $4)
    RETURNING id
  `;
  
  try {
    const result = await pool.query(query, [postoId, tipoCombustivel, preco, dataColeta]);
    return result.rows[0].id;
  } catch (error) {
    return null;
  }
}

async function processarCSV() {
  console.log('Processando dados da ANP...\n');
  
  let linhasProcessadas = 0;
  let precosInseridos = 0;
  let postosEncontrados = new Set();
  let postosNaoEncontrados = 0;
  
  return new Promise((resolve, reject) => {
    const stream = fs.createReadStream(CONFIG.LOCAL_CSV_PATH)
      .pipe(csv({ separator: ';' }))
      .on('data', async (row) => {
        stream.pause();
        
        try {
          linhasProcessadas++;
          
          if (linhasProcessadas % 1000 === 0) {
            console.log(`Processadas ${linhasProcessadas} linhas...`);
          }
          
          const estado = row['Estado - Sigla'] || row['Estado'];
          if (!estado || !CONFIG.ESTADOS_FILTRO.includes(estado.toUpperCase().trim())) {
            stream.resume();
            return;
          }
          
          const produto = row['Produto'] || '';
          const tipoCombustivel = normalizarCombustivel(produto);
          
          if (!tipoCombustivel) {
            stream.resume();
            return;
          }
          
          const municipio = row['Município'] || row['Municipio'] || '';
          const bairro = row['Bairro'] || '';
          const endereco = row['Endereço'] || row['Endereco'] || '';
          const precoStr = row['Valor de Venda'] || row['Preco Venda'] || '0';
          const preco = parseFloat(precoStr.replace(',', '.'));
          const dataColeta = row['Data da Coleta'] || new Date().toISOString();
          
          if (preco <= 0 || preco > 20) {
            stream.resume();
            return;
          }
          
          const posto = await encontrarPosto(municipio, bairro, endereco);
          
          if (posto) {
            const precoId = await inserirPreco(posto.id, tipoCombustivel, preco, dataColeta);
            if (precoId) {
              precosInseridos++;
              postosEncontrados.add(posto.id);
              
              if (precosInseridos % 10 === 0) {
                console.log(`${precosInseridos} precos inseridos | ${postosEncontrados.size} postos`);
              }
            }
          } else {
            postosNaoEncontrados++;
          }
          
        } catch (error) {
          console.error(`Erro na linha ${linhasProcessadas}:`, error.message);
        }
        
        stream.resume();
      })
      .on('end', () => {
        resolve({
          linhasProcessadas,
          precosInseridos,
          postosEncontrados: postosEncontrados.size,
          postosNaoEncontrados
        });
      })
      .on('error', reject);
  });
}

async function importarDadosANP() {
  console.log('Importador de Precos da ANP\n');
  console.log('==================================================');
  
  try {
    await pool.query('SELECT NOW()');
    console.log('Conectado ao banco PostgreSQL\n');
    
    if (!fs.existsSync(CONFIG.LOCAL_CSV_PATH)) {
      console.error('\nArquivo CSV nao encontrado!');
      console.log('Execute primeiro: node converter_xlsx_csv.js\n');
      process.exit(1);
    }
    
    console.log('Arquivo CSV encontrado!\n');
    
    const resultado = await processarCSV();
    
    console.log('\n==================================================');
    console.log('RESUMO DA IMPORTACAO');
    console.log('==================================================');
    console.log(`Linhas processadas: ${resultado.linhasProcessadas}`);
    console.log(`Precos inseridos: ${resultado.precosInseridos}`);
    console.log(`Postos com precos: ${resultado.postosEncontrados}`);
    console.log(`Postos nao encontrados: ${resultado.postosNaoEncontrados}`);
    console.log('==================================================');
    
    if (resultado.precosInseridos === 0) {
      console.log('\nNenhum preco foi inserido!');
      console.log('Use o sistema colaborativo do app!\n');
    } else {
      console.log('\nImportacao bem-sucedida!');
      console.log('Os precos estao disponiveis no app!\n');
    }
    
  } catch (error) {
    console.error('\nErro fatal:', error.message);
  } finally {
    await pool.end();
  }
}

importarDadosANP();