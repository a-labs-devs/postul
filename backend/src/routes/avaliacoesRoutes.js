const express = require('express');
const avaliacoesController = require('../controllers/avaliacoesController');

const router = express.Router();

// POST /api/avaliacoes - Criar/atualizar avaliação
router.post('/', avaliacoesController.avaliar);

// GET /api/avaliacoes/posto/:posto_id - Listar avaliações de um posto
router.get('/posto/:posto_id', avaliacoesController.listarPorPosto);

// GET /api/avaliacoes/posto/:posto_id/media - Obter média de um posto
router.get('/posto/:posto_id/media', avaliacoesController.obterMediaPosto);

// GET /api/avaliacoes/posto/:posto_id/usuario/:usuario_id - Obter avaliação específica
router.get('/posto/:posto_id/usuario/:usuario_id', avaliacoesController.obterAvaliacaoUsuario);

// DELETE /api/avaliacoes/posto/:posto_id/usuario/:usuario_id - Deletar avaliação
router.delete('/posto/:posto_id/usuario/:usuario_id', avaliacoesController.deletar);

module.exports = router;