const express = require('express');
const precosController = require('../controllers/precosController');

const router = express.Router();

// POST /api/precos - Atualizar preço
router.post('/', precosController.atualizarPreco);

// POST /api/precos/atualizar - Atualizar preço via app (navegação)
router.post('/atualizar', precosController.atualizarPrecoNavegacao);

// GET /api/precos/posto/:posto_id - Listar preços de um posto
router.get('/posto/:posto_id', precosController.listarPorPosto);

module.exports = router;