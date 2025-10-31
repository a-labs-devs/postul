/**
 * 🧪 Script de Teste - Envio de Email
 * 
 * Use este script para testar se o sistema de email está funcionando
 * antes de testar pelo app.
 * 
 * Como usar:
 * 1. Configure EMAIL_USER e EMAIL_PASSWORD no .env
 * 2. Execute: node test-email.js
 * 3. Verifique sua caixa de entrada
 */

require('dotenv').config();
const emailService = require('./src/services/emailService');

console.log('\n📧 ========== TESTE DE EMAIL ==========\n');

// Configurações do teste
const TESTE = {
  nome: 'Jean erick',
  email: 'jbiersack87@gmail.com'
};

console.log(`📤 Enviando email de teste para: ${TESTE.email}`);
console.log(`👤 Nome do destinatário: ${TESTE.nome}\n`);

// Enviar email
emailService.enviarEmailBoasVindas(TESTE.nome, TESTE.email)
  .then(resultado => {
    console.log('\n✅ ========== RESULTADO ==========\n');
    
    if (resultado.sucesso) {
      console.log('✅ EMAIL ENVIADO COM SUCESSO!');
      console.log(`📬 Message ID: ${resultado.messageId}`);
      console.log('\n📋 Próximos passos:');
      console.log('   1. Verifique a caixa de entrada do email');
      console.log('   2. Se não encontrar, verifique a pasta de spam');
      console.log('   3. Se funcionou, o sistema está pronto! 🎉\n');
    } else {
      console.log('❌ FALHA AO ENVIAR EMAIL');
      console.log(`⚠️ Erro: ${resultado.erro}`);
      console.log('\n📋 Possíveis causas:');
      console.log('   1. EMAIL_USER ou EMAIL_PASSWORD não configurados no .env');
      console.log('   2. Senha de app do Gmail incorreta');
      console.log('   3. Verificação em 2 etapas não ativada');
      console.log('   4. Problemas de conexão com o servidor SMTP\n');
      console.log('💡 Solução: Consulte o arquivo EMAIL_SETUP.md\n');
    }
  })
  .catch(erro => {
    console.log('\n❌ ========== ERRO CRÍTICO ==========\n');
    console.error('❌ Erro:', erro.message);
    console.log('\n📋 Verifique:');
    console.log('   1. O arquivo .env existe na raiz do backend');
    console.log('   2. As variáveis EMAIL_USER e EMAIL_PASSWORD estão definidas');
    console.log('   3. O serviço emailService foi inicializado corretamente\n');
  });
