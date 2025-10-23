const XLSX = require('xlsx');
const fs = require('fs');

console.log('📊 Conversor XLSX → CSV para ANP\n');

const XLSX_FILE = './precos_anp.xlsx';
const CSV_FILE = './precos_anp.csv';

try {
  if (!fs.existsSync(XLSX_FILE)) {
    console.error('❌ Arquivo não encontrado:', XLSX_FILE);
    process.exit(1);
  }

  console.log('📂 Lendo arquivo XLSX...');
  const workbook = XLSX.readFile(XLSX_FILE);
  const sheetName = workbook.SheetNames[0];
  const worksheet = workbook.Sheets[sheetName];
  
  console.log('✅ Planilha encontrada:', sheetName);
  console.log('🔄 Convertendo para CSV...');
  
  const csv = XLSX.utils.sheet_to_csv(worksheet, { FS: ';' });
  fs.writeFileSync(CSV_FILE, csv, 'utf-8');
  
  console.log('✅ Arquivo CSV criado:', CSV_FILE);
  console.log('📊 Tamanho:', (fs.statSync(CSV_FILE).size / 1024 / 1024).toFixed(2), 'MB');
  console.log('\n🚀 Agora execute: node importar_precos_anp.js\n');
  
} catch (error) {
  console.error('❌ Erro:', error.message);
  process.exit(1);
}
