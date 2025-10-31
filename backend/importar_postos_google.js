const axios = require('axios');
const { Pool } = require('pg');

// ========== CONFIGURAÇÃO ==========
const CONFIG = {
  // Sua NOVA chave de API do Google Cloud (atualize aqui!)
  GOOGLE_API_KEY: 'AIzaSyDTIpHb1i5mrduNAwRHFV1zamBhWrhhgXc',
  
  // Conexão com o banco
  DB_CONFIG: {
    host: 'localhost',
    port: 5432,
    user: 'admin',
    password: '7171FIEAvwU0',
    database: 'postos_db'
  },
  
  // Limites
  MAX_POSTOS: 500,
  RAIO_BUSCA_KM: 10,
  
  // Pontos de busca: São Paulo Capital + Litoral Sul
  PONTOS_BUSCA: [
    // São Paulo Capital - Centro expandido
    { lat: -23.5505, lng: -46.6333, nome: 'Centro SP' },
    { lat: -23.5629, lng: -46.6544, nome: 'Paulista' },
    { lat: -23.5475, lng: -46.6361, nome: 'Liberdade' },
    { lat: -23.5340, lng: -46.6256, nome: 'Brás' },
    { lat: -23.5965, lng: -46.6822, nome: 'Pinheiros' },
    { lat: -23.5745, lng: -46.6902, nome: 'Vila Madalena' },
    { lat: -23.6105, lng: -46.6975, nome: 'Butantã' },
    { lat: -23.6204, lng: -46.6978, nome: 'Morumbi' },
    { lat: -23.6528, lng: -46.7167, nome: 'Campo Limpo' },
    { lat: -23.5296, lng: -46.6658, nome: 'Barra Funda' },
    { lat: -23.5268, lng: -46.5706, nome: 'Tatuapé' },
    { lat: -23.5596, lng: -46.5044, nome: 'Vila Prudente' },
    { lat: -23.6232, lng: -46.5665, nome: 'Santo Amaro' },
    { lat: -23.6828, lng: -46.5798, nome: 'Interlagos' },
    { lat: -23.4962, lng: -46.6099, nome: 'Santana' },
    { lat: -23.4697, lng: -46.5404, nome: 'Tucuruvi' },
    
    // Grande São Paulo
    { lat: -23.6821, lng: -46.8754, nome: 'Embu das Artes' },
    { lat: -23.5943, lng: -46.7852, nome: 'Osasco' },
    { lat: -23.5277, lng: -46.7848, nome: 'Barueri' },
    { lat: -23.4618, lng: -46.7903, nome: 'Carapicuíba' },
    { lat: -23.5204, lng: -46.4319, nome: 'Guarulhos Centro' },
    { lat: -23.4543, lng: -46.5330, nome: 'Guarulhos Norte' },
    { lat: -23.6632, lng: -46.5652, nome: 'Diadema' },
    { lat: -23.7364, lng: -46.5439, nome: 'São Bernardo' },
    { lat: -23.8093, lng: -46.5264, nome: 'Santo André' },
    { lat: -23.8779, lng: -46.4559, nome: 'Mauá' },
    
    // Litoral Sul
    { lat: -23.9618, lng: -46.3336, nome: 'Santos Centro' },
    { lat: -23.9935, lng: -46.2698, nome: 'Santos Praia' },
    { lat: -24.0087, lng: -46.4136, nome: 'Cubatão' },
    { lat: -23.9930, lng: -46.2364, nome: 'Guarujá' },
    { lat: -24.0089, lng: -46.4122, nome: 'São Vicente' },
    { lat: -24.0069, lng: -46.4117, nome: 'Praia Grande Norte' },
    { lat: -24.0427, lng: -46.4424, nome: 'Praia Grande Sul' },
    { lat: -24.1894, lng: -46.7889, nome: 'Mongaguá' },
    { lat: -24.3167, lng: -46.9917, nome: 'Itanhaém' },
    { lat: -24.4167, lng: -47.0667, nome: 'Peruíbe' }
  ]
};

// ========== FUNÇÕES ==========

// Conectar ao banco
const pool = new Pool(CONFIG.DB_CONFIG);

// Buscar postos próximos via Google Places API
async function buscarPostosProximos(lat, lng, raioMetros) {
  const url = 'https://places.googleapis.com/v1/places:searchNearby';
  
  try {
    const response = await axios.post(url, {
      includedTypes: ['gas_station'],
      maxResultCount: 20,
      locationRestriction: {
        circle: {
          center: {
            latitude: lat,
            longitude: lng
          },
          radius: raioMetros
        }
      }
    }, {
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': CONFIG.GOOGLE_API_KEY,
        'X-Goog-FieldMask': 'places.id,places.displayName,places.formattedAddress,places.location,places.internationalPhoneNumber,places.regularOpeningHours'
      }
    });
    
    return response.data.places || [];
  } catch (error) {
    console.error(`❌ Erro ao buscar postos em (${lat}, ${lng}):`, error.response?.data || error.message);
    return [];
  }
}

// Verificar se posto já existe no banco (por coordenadas próximas)
async function postoJaExiste(lat, lng) {
  const query = `
    SELECT id FROM postos 
    WHERE ABS(latitude - $1) < 0.0001 
    AND ABS(longitude - $2) < 0.0001
    LIMIT 1
  `;
  const result = await pool.query(query, [lat, lng]);
  return result.rows.length > 0;
}

// Inserir posto no banco
async function inserirPosto(posto) {
  const nome = posto.displayName?.text || 'Posto sem nome';
  const endereco = posto.formattedAddress || 'Endereço não disponível';
  const latitude = posto.location?.latitude;
  const longitude = posto.location?.longitude;
  const telefone = posto.internationalPhoneNumber || null;
  const aberto24h = posto.regularOpeningHours?.openNow === true && 
                    posto.regularOpeningHours?.periods?.length === 1;
  
  if (!latitude || !longitude) {
    console.log(`⚠️  Posto sem coordenadas: ${nome}`);
    return false;
  }
  
  // Verificar duplicata
  const existe = await postoJaExiste(latitude, longitude);
  if (existe) {
    console.log(`⏭️  Posto já existe: ${nome}`);
    return false;
  }
  
  const query = `
    INSERT INTO postos (nome, endereco, latitude, longitude, telefone, aberto_24h)
    VALUES ($1, $2, $3, $4, $5, $6)
    RETURNING id
  `;
  
  try {
    const result = await pool.query(query, [
      nome,
      endereco,
      latitude,
      longitude,
      telefone,
      aberto24h
    ]);
    
    console.log(`✅ Inserido: ${nome} (ID: ${result.rows[0].id})`);
    return true;
  } catch (error) {
    console.error(`❌ Erro ao inserir posto ${nome}:`, error.message);
    return false;
  }
}

// ========== EXECUÇÃO PRINCIPAL ==========

async function importarPostos() {
  console.log('🚀 Iniciando importação de postos de gasolina...\n');
  console.log(`📍 Área: São Paulo Capital + Litoral Sul`);
  console.log(`🎯 Meta: ${CONFIG.MAX_POSTOS} postos`);
  console.log(`📏 Raio por ponto: ${CONFIG.RAIO_BUSCA_KM}km\n`);
  
  let totalInseridos = 0;
  let totalEncontrados = 0;
  const raioMetros = CONFIG.RAIO_BUSCA_KM * 1000;
  
  try {
    // Testar conexão com o banco
    await pool.query('SELECT NOW()');
    console.log('✅ Conectado ao banco PostgreSQL\n');
    
    // Buscar postos em cada ponto
    for (let i = 0; i < CONFIG.PONTOS_BUSCA.length && totalInseridos < CONFIG.MAX_POSTOS; i++) {
      const ponto = CONFIG.PONTOS_BUSCA[i];
      console.log(`\n🔍 Buscando postos em: ${ponto.nome} (${i + 1}/${CONFIG.PONTOS_BUSCA.length})`);
      
      const postos = await buscarPostosProximos(ponto.lat, ponto.lng, raioMetros);
      totalEncontrados += postos.length;
      
      console.log(`   Encontrados: ${postos.length} postos`);
      
      for (const posto of postos) {
        if (totalInseridos >= CONFIG.MAX_POSTOS) {
          console.log(`\n🎯 Meta de ${CONFIG.MAX_POSTOS} postos atingida!`);
          break;
        }
        
        const inserido = await inserirPosto(posto);
        if (inserido) {
          totalInseridos++;
        }
        
        // Pequeno delay para não sobrecarregar a API
        await new Promise(resolve => setTimeout(resolve, 100));
      }
      
      console.log(`   Progresso: ${totalInseridos}/${CONFIG.MAX_POSTOS} postos inseridos`);
      
      // Delay entre pontos de busca
      if (i < CONFIG.PONTOS_BUSCA.length - 1) {
        await new Promise(resolve => setTimeout(resolve, 500));
      }
    }
    
  } catch (error) {
    console.error('\n❌ Erro fatal:', error.message);
  } finally {
    await pool.end();
    
    console.log('\n' + '='.repeat(50));
    console.log('📊 RESUMO DA IMPORTAÇÃO');
    console.log('='.repeat(50));
    console.log(`✅ Postos inseridos: ${totalInseridos}`);
    console.log(`🔍 Postos encontrados: ${totalEncontrados}`);
    console.log(`📍 Pontos de busca verificados: ${CONFIG.PONTOS_BUSCA.length}`);
    console.log('='.repeat(50));
    console.log('\n✨ Importação concluída!');
  }
}

// Executar
importarPostos();