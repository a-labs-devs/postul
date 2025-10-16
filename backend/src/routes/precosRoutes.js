const express = require('express');
const precosController = require('../controllers/precosController');

const router = express.Router();

router.post('/atualizar', precosController.atualizarPreco);
router.get('/posto/:posto_id', precosController.listarPorPosto);

module.exports = router;