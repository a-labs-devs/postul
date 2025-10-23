const express = require('express');
const importarPostosController = require('../controllers/importarPostosController');

const router = express.Router();

router.post('/importar-regiao', importarPostosController.importarPorRegiao);

module.exports = router;
