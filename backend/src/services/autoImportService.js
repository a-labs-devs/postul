const axios = require('axios');
const pool = require('../config/database');

/**
 * 🤖 SERVIÇO DE AUTO-IMPORTAÇÃO DE POSTOS
 * 
 * Importa automaticamente postos da Google Places API quando:
 * - O banco de dados está vazio
 * - Um novo usuário não encontra postos na sua região
 * 
 * USA APENAS DADOS REAIS - SEM MOCK/TESTE
 */

const CONFIG = {
  GOOGLE_API_KEY: process.env.GOOGLE_PLACES_API_KEY || process.env.GOOGLE_API_KEY,
  MIN_POSTOS_REQUIRED: 10, // Mínimo de postos para considerar banco "populado"
  RAIO_BUSCA_METROS: 10000, // 10km
  MAX_RESULTADOS_POR_PONTO: 20,
  
  // Pontos estratégicos para busca inicial (São Paulo + Região Metropolitana)
  PONTOS_INICIAIS: [
    { lat: -23.5505, lng: -46.6333, nome: 'Centro SP' },
    { lat: -23.5629, lng: -46.6544, nome: 'Av Paulista' },
    { lat: -23.5965, lng: -46.6822, nome: 'Pinheiros' },
    { lat: -23.6232, lng: -46.5665, nome: 'Santo Amaro' },
    { lat: -23.5204, lng: -46.4319, nome: 'Guarulhos' },
    { lat: -23.9618, lng: -46.3336, nome: 'Santos' }
  ]
};

class AutoImportService {
  
  /**
   * Verifica se o banco precisa de importação
   */
  async precisaImportar() {
    try {
      const result = await pool.query('SELECT COUNT(*) as total FROM postos');
      const total = parseInt(result.rows[0].total);
      
      console.log(`📊 Total de postos no banco: ${total}`);
      
      return total < CONFIG.MIN_POSTOS_REQUIRED;
    } catch (error) {
      console.error('❌ Erro ao verificar banco:', error.message);
      return true; // Em caso de erro, tenta importar
    }
  }
  
  /**
   * Busca postos na Google Places API (DADOS REAIS)
   */
  async buscarPostosGoogle(lat, lng, raioMetros = CONFIG.RAIO_BUSCA_METROS) {
    if (!CONFIG.GOOGLE_API_KEY) {
      console.error('❌ GOOGLE_API_KEY não configurada no .env');
      return [];
    }
    
    const url = 'https://places.googleapis.com/v1/places:searchNearby';
    
    try {
      const response = await axios.post(url, {
        includedTypes: ['gas_station'],
        maxResultCount: CONFIG.MAX_RESULTADOS_POR_PONTO,
        locationRestriction: {
          circle: {
            center: { latitude: lat, longitude: lng },
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
      console.error(`❌ Erro ao buscar no Google Places (${lat}, ${lng}):`, 
        error.response?.data?.error?.message || error.message);
      return [];
    }
  }
  
  /**
   * Verifica se posto já existe (por coordenadas próximas)
   */
  async postoJaExiste(lat, lng) {
    try {
      const query = `
        SELECT id FROM postos 
        WHERE ABS(latitude - $1) < 0.0001 
        AND ABS(longitude - $2) < 0.0001
        LIMIT 1
      `;
      const result = await pool.query(query, [lat, lng]);
      return result.rows.length > 0;
    } catch (error) {
      return false;
    }
  }
  
  /**
   * Insere posto no banco
   */
  async inserirPosto(posto) {
    const nome = posto.displayName?.text || 'Posto sem nome';
    const endereco = posto.formattedAddress || 'Endereço não disponível';
    const latitude = posto.location?.latitude;
    const longitude = posto.location?.longitude;
    const telefone = posto.internationalPhoneNumber || null;
    const aberto24h = posto.regularOpeningHours?.openNow === true && 
                      posto.regularOpeningHours?.periods?.length === 1;
    
    if (!latitude || !longitude) {
      return { sucesso: false, motivo: 'sem_coordenadas' };
    }
    
    // Verificar duplicata
    const existe = await this.postoJaExiste(latitude, longitude);
    if (existe) {
      return { sucesso: false, motivo: 'duplicado' };
    }
    
    const query = `
      INSERT INTO postos (nome, endereco, latitude, longitude, telefone, aberto_24h)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING id
    `;
    
    try {
      const result = await pool.query(query, [
        nome, endereco, latitude, longitude, telefone, aberto24h
      ]);
      
      return { 
        sucesso: true, 
        id: result.rows[0].id,
        nome: nome
      };
    } catch (error) {
      console.error(`❌ Erro ao inserir posto "${nome}":`, error.message);
      return { sucesso: false, motivo: 'erro_db' };
    }
  }
  
  /**
   * Importa postos de um ponto específico
   */
  async importarPonto(ponto) {
    console.log(`\n🔍 Buscando postos em ${ponto.nome}...`);
    
    const postos = await this.buscarPostosGoogle(ponto.lat, ponto.lng);
    
    if (postos.length === 0) {
      console.log(`⚠️  Nenhum posto encontrado em ${ponto.nome}`);
      return { importados: 0, duplicados: 0, erros: 0 };
    }
    
    let importados = 0;
    let duplicados = 0;
    let erros = 0;
    
    for (const posto of postos) {
      const resultado = await this.inserirPosto(posto);
      
      if (resultado.sucesso) {
        importados++;
        console.log(`✅ ${importados}. ${resultado.nome}`);
      } else if (resultado.motivo === 'duplicado') {
        duplicados++;
      } else {
        erros++;
      }
    }
    
    console.log(`📍 ${ponto.nome}: ${importados} importados, ${duplicados} duplicados, ${erros} erros`);
    
    return { importados, duplicados, erros };
  }
  
  /**
   * FUNÇÃO PRINCIPAL: Executa importação automática completa
   */
  async executarImportacaoAutomatica() {
    console.log('\n🤖 ========== AUTO-IMPORTAÇÃO DE POSTOS ==========');
    console.log('⏱️  Iniciando...', new Date().toLocaleString('pt-BR'));
    
    const precisa = await this.precisaImportar();
    
    if (!precisa) {
      console.log('✅ Banco já possui postos suficientes. Importação não necessária.');
      return {
        executado: false,
        motivo: 'banco_ja_populado'
      };
    }
    
    console.log('🚀 Banco vazio ou com poucos postos. Iniciando importação...\n');
    
    let totalImportados = 0;
    let totalDuplicados = 0;
    let totalErros = 0;
    
    for (const ponto of CONFIG.PONTOS_INICIAIS) {
      const stats = await this.importarPonto(ponto);
      totalImportados += stats.importados;
      totalDuplicados += stats.duplicados;
      totalErros += stats.erros;
      
      // Delay para não sobrecarregar a API
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
    
    console.log('\n✅ ========== IMPORTAÇÃO CONCLUÍDA ==========');
    console.log(`📊 Total importados: ${totalImportados}`);
    console.log(`⏭️  Total duplicados: ${totalDuplicados}`);
    console.log(`❌ Total erros: ${totalErros}`);
    console.log('⏱️  Finalizado:', new Date().toLocaleString('pt-BR'));
    
    return {
      executado: true,
      importados: totalImportados,
      duplicados: totalDuplicados,
      erros: totalErros
    };
  }
  
  /**
   * Importa postos para uma região específica (quando usuário não encontra postos)
   */
  async importarRegiao(latitude, longitude, raio = 10000) {
    console.log(`\n🎯 Importando postos próximos a (${latitude}, ${longitude})...`);
    
    const postos = await this.buscarPostosGoogle(latitude, longitude, raio);
    
    if (postos.length === 0) {
      return {
        sucesso: false,
        mensagem: 'Nenhum posto encontrado nesta região'
      };
    }
    
    let importados = 0;
    let duplicados = 0;
    
    for (const posto of postos) {
      const resultado = await this.inserirPosto(posto);
      
      if (resultado.sucesso) {
        importados++;
      } else if (resultado.motivo === 'duplicado') {
        duplicados++;
      }
    }
    
    console.log(`✅ Região importada: ${importados} novos postos, ${duplicados} duplicados`);
    
    return {
      sucesso: true,
      importados,
      duplicados,
      total: postos.length
    };
  }
}

// Singleton
const autoImportService = new AutoImportService();

module.exports = autoImportService;
