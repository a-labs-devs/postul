const express = require('express');
const cors = require('cors');
require('dotenv').config();


const authRoutes = require('./routes/authRoutes');
const postosRoutes = require('./routes/postosRoutes');
const precosRoutes = require('./routes/precosRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api/postos', postosRoutes);
app.use('/api/precos', precosRoutes);
app.get('/', (req, res) => {
  res.json({ mensagem: '🚀 API Postos de Gasolina está rodando!' });
});

app.listen(PORT, () => {
  console.log(`🚀 Servidor rodando na porta ${PORT}`);
  console.log(`📍 http://localhost:${PORT}`);
});