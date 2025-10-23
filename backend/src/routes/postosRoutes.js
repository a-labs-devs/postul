const express = require('express');
const postosController = require('../controllers/postosController');

const router = express.Router();

// Rotas existentes
router.get('/listar', postosController.listarTodos);
router.get('/proximos', postosController.buscarProximos);
router.post('/cadastrar', postosController.cadastrar);

// NOVAS ROTAS
router.get('/:id', postosController.buscarPorId);
router.put('/editar/:id', postosController.editar);
router.delete('/deletar/:id', postosController.deletar);

module.exports = router;