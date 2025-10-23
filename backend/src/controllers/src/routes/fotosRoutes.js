const express = require('express');
const fotosController = require('../controllers/fotosController');

const router = express.Router();

// POST /api/fotos - Upload de foto
router.post('/', fotosController.uploadMiddleware, fotosController.upload);

// GET /api/fotos/posto/:posto_id - Listar fotos de um posto
router.get('/posto/:posto_id', fotosController.listarPorPosto);

// GET /api/fotos/posto/:posto_id/count - Contar fotos
router.get('/posto/:posto_id/count', fotosController.contarFotos);

// DELETE /api/fotos/:id/usuario/:usuario_id - Deletar foto
router.delete('/:id/usuario/:usuario_id', fotosController.deletar);

module.exports = router;