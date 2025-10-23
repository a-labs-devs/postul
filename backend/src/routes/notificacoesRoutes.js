const express = require('express');
const notificacoesController = require('../controllers/notificacoesController');

const router = express.Router();

router.post('/enviar-teste', notificacoesController.enviarTeste);

module.exports = router;