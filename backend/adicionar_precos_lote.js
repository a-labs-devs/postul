/**
 * Script para adicionar preços em todos os postos
 * Adiciona preços realistas de combustíveis
 */

require('dotenv').config();
const http = require('http');

const API_URL = 'http://alabsv.ddns.net:3001';

// Preços médios realistas para São Paulo (Nov 2025)
const PRECOS_BASE = {
  'Gasolina Comum': { min: 5.79, max: 6.29 },
  'Gasolina Aditivada': { min: 5.99, max: 6.49 },
  'Etanol': { min: 3.89, max: 4.39 },
  'Diesel': { min: 5.49, max: 5.99 },
  'Diesel S10': { min: 5.69, max: 6.19 },
  'GNV': { min: 4.29, max: 4.79 }
};

function gerarPreco(tipo) {
  const range = PRECOS_BASE[tipo];
  const preco = Math.random() * (range.max - range.min) + range.min;
  return Math.round(preco * 100) / 100;
}

async function buscarPostos() {
  return new Promise((resolve, reject) => {
    http.get(API_URL + '/api/postos/listar', (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const json = JSON.parse(data);
          resolve(json.postos || []);
        } catch(e) {
          reject(e);
        }
      });
    }).on('error', reject);
  });
}

async function adicionarPreco(postoId, tipoCombustivel, preco) {
  return new Promise((resolve) => {
    const postData = JSON.stringify({
      posto_id: postoId,
      tipo_combustivel: tipoCombustivel,
      preco: preco,
      usuario_id: 1
    });

    const options = {
      hostname: 'alabsv.ddns.net',
      port: 3001,
      path: '/api/precos',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData)
      }
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve({ success: res.statusCode === 200 }));
    });

    req.on('error', () => resolve({ success: false }));
    req.write(postData);
    req.end();
  });
}

async function main() {
  console.log('🔄 Iniciando importação de preços...\n');

  try {
    // Buscar todos os postos
    console.log('📥 Buscando postos...');
    const postos = await buscarPostos();
    console.log(✅  postos encontrados\n);

    let total = 0;
    let sucessos = 0;

    // Para cada posto, adicionar preços dos 3 combustíveis principais
    for (let i = 0; i < postos.length; i++) {
      const posto = postos[i];
      console.log([/] );

      // Gasolina Comum (todos os postos têm)
      const precoGasolina = gerarPreco('Gasolina Comum');
      const r1 = await adicionarPreco(posto.id, 'Gasolina Comum', precoGasolina);
      if (r1.success) {
        console.log(   ✅ Gasolina: R$ + precoGasolina.toFixed(2));
        sucessos++;
      }
      total++;

      // Etanol (80% dos postos)
      if (Math.random() > 0.2) {
        const precoEtanol = gerarPreco('Etanol');
        const r2 = await adicionarPreco(posto.id, 'Etanol', precoEtanol);
        if (r2.success) {
          console.log(   ✅ Etanol: R$ + precoEtanol.toFixed(2));
          sucessos++;
        }
        total++;
      }

      // Diesel (50% dos postos)
      if (Math.random() > 0.5) {
        const precoDiesel = gerarPreco('Diesel');
        const r3 = await adicionarPreco(posto.id, 'Diesel', precoDiesel);
        if (r3.success) {
          console.log(   ✅ Diesel: R$ + precoDiesel.toFixed(2));
          sucessos++;
        }
        total++;
      }

      console.log('');
      await new Promise(resolve => setTimeout(resolve, 500));
    }

    console.log('═══════════════════════════════════════════');
    console.log('📊 RESUMO DA IMPORTAÇÃO\n');
    console.log(✅ Preços adicionados: /);
    console.log(📝 Postos processados: );
    console.log('═══════════════════════════════════════════\n');

  } catch (error) {
    console.error('❌ Erro:', error.message);
  }
}

main();
