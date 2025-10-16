const express = require('express');
const postosController = require('../controllers/postosController');

const router = express.Router();

router.get('/listar', postosController.listarTodos);
router.get('/proximos', postosController.buscarProximos);
router.post('/cadastrar', postosController.cadastrar);

module.exports = router;