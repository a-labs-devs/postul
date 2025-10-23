const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

const createTables = async () => {
  // Tabela de usuários
  const createUsersTable = `
    CREATE TABLE IF NOT EXISTS usuarios (
      id SERIAL PRIMARY KEY,
      nome VARCHAR(255) NOT NULL,
      email VARCHAR(255) UNIQUE NOT NULL,
      senha VARCHAR(255) NOT NULL,
      criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  `;

  // Tabela de postos
  const createPostosTable = `
    CREATE TABLE IF NOT EXISTS postos (
      id SERIAL PRIMARY KEY,
      nome VARCHAR(255) NOT NULL,
      endereco TEXT NOT NULL,
      latitude DECIMAL(10, 8) NOT NULL,
      longitude DECIMAL(11, 8) NOT NULL,
      telefone VARCHAR(20),
      aberto_24h BOOLEAN DEFAULT false,
      criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  `;

  // Tabela de preços de combustíveis
  const createPrecosTable = `
    CREATE TABLE IF NOT EXISTS precos_combustivel (
      id SERIAL PRIMARY KEY,
      posto_id INTEGER REFERENCES postos(id) ON DELETE CASCADE,
      tipo_combustivel VARCHAR(50) NOT NULL,
      preco DECIMAL(5, 3) NOT NULL,
      data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      usuario_id INTEGER REFERENCES usuarios(id),
      UNIQUE(posto_id, tipo_combustivel)
    );
  `;

  // NOVA: Tabela de favoritos
  const createFavoritosTable = `
    CREATE TABLE IF NOT EXISTS favoritos (
      id SERIAL PRIMARY KEY,
      usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
      posto_id INTEGER NOT NULL REFERENCES postos(id) ON DELETE CASCADE,
      combustivel_preferido VARCHAR(50) DEFAULT 'Gasolina Comum',
      preco_alvo DECIMAL(10, 2),
      notificar_sempre BOOLEAN DEFAULT true,
      criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      UNIQUE(usuario_id, posto_id)
    );
  `;

  // NOVA: Tabela de histórico de preços
  const createHistoricoTable = `
    CREATE TABLE IF NOT EXISTS historico_precos (
      id SERIAL PRIMARY KEY,
      posto_id INTEGER NOT NULL REFERENCES postos(id) ON DELETE CASCADE,
      tipo_combustivel VARCHAR(50) NOT NULL,
      preco DECIMAL(10, 2) NOT NULL,
      preco_anterior DECIMAL(10, 2),
      variacao DECIMAL(10, 2),
      variacao_percentual DECIMAL(5, 2),
      usuario_id INTEGER REFERENCES usuarios(id) ON DELETE SET NULL,
      registrado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  `;

  // Índices para melhor performance
  const createIndexes = `
    CREATE INDEX IF NOT EXISTS idx_favoritos_usuario ON favoritos(usuario_id);
    CREATE INDEX IF NOT EXISTS idx_favoritos_posto ON favoritos(posto_id);
    CREATE INDEX IF NOT EXISTS idx_historico_posto_combustivel ON historico_precos(posto_id, tipo_combustivel);
    CREATE INDEX IF NOT EXISTS idx_historico_data ON historico_precos(registrado_em DESC);
  `;

  // Função para registrar histórico automaticamente
  const createTriggerFunction = `
    CREATE OR REPLACE FUNCTION registrar_historico_preco()
    RETURNS TRIGGER AS $$
    BEGIN
      -- Se é INSERT ou o preço mudou
      IF (TG_OP = 'INSERT') OR (OLD.preco != NEW.preco) THEN
        INSERT INTO historico_precos (
          posto_id, 
          tipo_combustivel, 
          preco, 
          preco_anterior,
          variacao,
          variacao_percentual,
          usuario_id
        ) VALUES (
          NEW.posto_id,
          NEW.tipo_combustivel,
          NEW.preco,
          CASE WHEN TG_OP = 'UPDATE' THEN OLD.preco ELSE NULL END,
          CASE WHEN TG_OP = 'UPDATE' THEN (NEW.preco - OLD.preco) ELSE NULL END,
          CASE WHEN TG_OP = 'UPDATE' AND OLD.preco > 0 
               THEN ((NEW.preco - OLD.preco) / OLD.preco * 100) 
               ELSE NULL END,
          NEW.usuario_id
        );
      END IF;
      
      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;
  `;

  // Trigger para executar a função
  const createTrigger = `
    DROP TRIGGER IF EXISTS trigger_historico_preco ON precos_combustivel;
    CREATE TRIGGER trigger_historico_preco
    AFTER INSERT OR UPDATE ON precos_combustivel
    FOR EACH ROW
    EXECUTE FUNCTION registrar_historico_preco();
  `;

  try {
    console.log('📦 Criando tabelas...');
    
    // Tabelas principais
    await pool.query(createUsersTable);
    console.log('  ✅ Tabela usuarios');
    
    await pool.query(createPostosTable);
    console.log('  ✅ Tabela postos');
    
    await pool.query(createPrecosTable);
    console.log('  ✅ Tabela precos_combustivel');
    
    // Novas tabelas
    await pool.query(createFavoritosTable);
    console.log('  ✅ Tabela favoritos');
    
    await pool.query(createHistoricoTable);
    console.log('  ✅ Tabela historico_precos');
    
    // Índices
    await pool.query(createIndexes);
    console.log('  ✅ Índices criados');
    
    // Trigger
    await pool.query(createTriggerFunction);
    console.log('  ✅ Função de trigger criada');
    
    await pool.query(createTrigger);
    console.log('  ✅ Trigger configurado');
    
    console.log('\n🎉 Todas as tabelas criadas com sucesso!');
    console.log('\n📊 Estrutura do banco:');
    console.log('  • usuarios');
    console.log('  • postos');
    console.log('  • precos_combustivel');
    console.log('  • favoritos (NOVO)');
    console.log('  • historico_precos (NOVO)');
    
  } catch (error) {
    console.error('❌ Erro ao criar tabelas:', error);
  }
};

createTables();

module.exports = pool;