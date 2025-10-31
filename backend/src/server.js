const express = require('express');
const cors = require('cors');
const compression = require('compression');
require('dotenv').config();

const authRoutes = require('./routes/authRoutes');
const postosRoutes = require('./routes/postosRoutes');
const precosRoutes = require('./routes/precosRoutes');
const notificacoesRoutes = require('./routes/notificacoesRoutes');
const importarPostosRoutes = require('./routes/importarPostosRoutes');
const favoritosRoutes = require('./routes/favoritosRoutes');
const avaliacoesRoutes = require('./routes/avaliacoesRoutes');
const fotosRoutes = require('./routes/fotosRoutes');

const app = express();
const PORT = 3001;

// Middleware de compressão GZIP (deve vir antes das rotas)
app.use(compression());
app.use(cors());
app.use(express.json());

// Servir arquivos estáticos (fotos)
app.use('/uploads', express.static('uploads'));

// Rotas da API
app.use('/api/auth', authRoutes);
app.use('/api/postos', postosRoutes);
app.use('/api/precos', precosRoutes);
app.use('/api/notificacoes', notificacoesRoutes);
app.use('/api/importar', importarPostosRoutes);
app.use('/api/favoritos', favoritosRoutes);
app.use('/api/avaliacoes', avaliacoesRoutes);
app.use('/api/fotos', fotosRoutes);

// Rota principal
app.get('/', (req, res) => {
  res.json({ 
    mensagem: '🚀 API Postos de Gasolina está rodando!',
    endpoints: {
      auth: '/api/auth',
      postos: '/api/postos',
      precos: '/api/precos',
      notificacoes: '/api/notificacoes',
      importar: '/api/importar',
      favoritos: '/api/favoritos',
      avaliacoes: '/api/avaliacoes',
      fotos: '/api/fotos'
    }
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Servidor rodando na porta ${PORT}`);
  console.log(`📍 http://localhost:${PORT}`);
  console.log(`\n✅ Endpoints disponíveis:`);
  console.log(`  • /api/auth - Autenticação`);
  console.log(`  • /api/postos - Postos de gasolina`);
  console.log(`  • /api/precos - Preços dos combustíveis`);
  console.log(`  • /api/notificacoes - Notificações`);
  console.log(`  • /api/importar - Importar postos`);
  console.log(`  • /api/favoritos - Favoritos do usuário`);
  console.log(`  • /api/avaliacoes - Avaliações dos postos`);
  console.log(`  • /api/fotos - Upload e fotos dos postos`);
});

module.exports = app;