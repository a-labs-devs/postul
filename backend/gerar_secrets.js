#!/usr/bin/env node
/**
 * 🔐 Gerador de Secrets para Produção
 * 
 * Este script gera secrets criptograficamente seguros
 * para uso em produção.
 * 
 * Uso: node gerar_secrets.js
 */

const crypto = require('crypto');

console.log('\n🔐 GERADOR DE SECRETS PARA PRODUÇÃO\n');
console.log('=' .repeat(60));

// Gerar JWT_SECRET (64 caracteres hexadecimais)
const jwtSecret = crypto.randomBytes(32).toString('hex');
console.log('\n📝 JWT_SECRET (copie para .env):');
console.log(`JWT_SECRET=${jwtSecret}`);

// Gerar WEBHOOK_SECRET (64 caracteres hexadecimais)
const webhookSecret = crypto.randomBytes(32).toString('hex');
console.log('\n📝 WEBHOOK_SECRET (copie para .env):');
console.log(`WEBHOOK_SECRET=${webhookSecret}`);

// Gerar senha de banco de dados forte
const dbPassword = crypto.randomBytes(16).toString('base64').replace(/[+/=]/g, '');
console.log('\n📝 DB_PASSWORD (copie para .env):');
console.log(`DB_PASSWORD=${dbPassword}`);

// Instruções adicionais
console.log('\n' + '=' .repeat(60));
console.log('\n✅ PRÓXIMOS PASSOS:\n');
console.log('1. Copie os valores acima para seu arquivo .env');
console.log('2. Atualize a senha do PostgreSQL:');
console.log(`   ALTER USER admin WITH PASSWORD '${dbPassword}';`);
console.log('3. Rotacione as API Keys no Google Cloud Console');
console.log('4. Gere nova App Password do Gmail');
console.log('5. NUNCA commite o arquivo .env no Git!');
console.log('6. Configure secrets no GitHub para CI/CD');
console.log('\n⚠️  IMPORTANTE: Guarde esses valores em um local seguro!\n');
