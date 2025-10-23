const express = require('express');
const favoritosController = require('../controllers/favoritosController');

const router = express.Router();

// Listar favoritos do usuário
router.get('/listar', favoritosController.listar);

// Adicionar favorito
router.post('/adicionar', favoritosController.adicionar);

// Remover favorito
router.delete('/remover/:id', favoritosController.remover);

// Atualizar favorito
router.put('/atualizar/:id', favoritosController.atualizar);

// Verificar se é favorito
router.get('/verificar', favoritosController.verificar);

// Histórico de preços
router.get('/historico', favoritosController.historico);

// Verificar quedas de preço (para notificações)
router.get('/verificar-quedas', favoritosController.verificarQuedasPreco);

module.exports = router;