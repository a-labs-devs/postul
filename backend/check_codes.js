const { Pool } = require('pg');

const pool = new Pool({
  user: 'admin',
  host: 'localhost',
  database: 'postos_db',
  password: '7171FIEAvwU0',
  port: 5432
});

async function checkCodes() {
  try {
    const result = await pool.query(`
      SELECT 
        email, 
        codigo, 
        TO_CHAR(expira_em, 'YYYY-MM-DD HH24:MI:SS') as expira_em,
        TO_CHAR(criado_em, 'YYYY-MM-DD HH24:MI:SS') as criado_em,
        TO_CHAR(NOW(), 'YYYY-MM-DD HH24:MI:SS') as agora,
        usado,
        CASE 
          WHEN expira_em > NOW() THEN 'VÁLIDO'
          ELSE 'EXPIRADO'
        END as status
      FROM codigos_recuperacao 
      WHERE email = 'jeanborgir@gmail.com' 
      ORDER BY criado_em DESC 
      LIMIT 10
    `);
    
    console.log('\n📧 Códigos para jeanborgir@gmail.com:\n');
    
    if (result.rows.length === 0) {
      console.log('❌ Nenhum código encontrado!');
    } else {
      result.rows.forEach((row, index) => {
        console.log(`${index + 1}. Código: ${row.codigo}`);
        console.log(`   Criado em: ${row.criado_em}`);
        console.log(`   Expira em: ${row.expira_em}`);
        console.log(`   Agora: ${row.agora}`);
        console.log(`   Usado: ${row.usado ? 'SIM' : 'NÃO'}`);
        console.log(`   Status: ${row.status}`);
        console.log('');
      });
    }
    
    await pool.end();
    process.exit(0);
  } catch (err) {
    console.error('❌ Erro:', err);
    process.exit(1);
  }
}

checkCodes();
