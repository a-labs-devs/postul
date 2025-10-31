const express = require('express');
const authController = require('../controllers/authController');

const router = express.Router();

router.post('/cadastrar', authController.cadastrar);
router.post('/login', authController.login);
router.get('/verificar', authController.verificarToken);

// Rotas de recuperação de senha
router.post('/solicitar-recuperacao', authController.solicitarRecuperacao);
router.post('/validar-codigo', authController.validarCodigo);
router.post('/redefinir-senha', authController.redefinirSenha);

module.exports = router;