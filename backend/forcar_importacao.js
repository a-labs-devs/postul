/**
 * 🚀 Script para Forçar Importação de Postos
 * 
 * Execute este script DIRETAMENTE NO SERVIDOR:
 * node forcar_importacao.js
 */

require('dotenv').config();
const autoImportService = require('./src/services/autoImportService');

async function main() {
  console.log('\n🚀 ========== FORÇANDO IMPORTAÇÃO DE POSTOS ==========\n');
  
  try {
    const resultado = await autoImportService.executarImportacaoAutomatica();
    
    console.log('\n✅ ========== RESULTADO ==========');
    console.log(JSON.stringify(resultado, null, 2));
    
    if (resultado.executado) {
      console.log(`\n🎉 Sucesso! ${resultado.importados} postos importados!`);
      process.exit(0);
    } else {
      console.log(`\nℹ️  ${resultado.motivo}`);
      process.exit(0);
    }
  } catch (error) {
    console.error('\n❌ ========== ERRO ==========');
    console.error(error);
    process.exit(1);
  }
}

main();
