const express = require('express');
const router = express.Router();
const { registrar, login, obtenerPerfil } = require('../controllers/authController');
const { verificarToken } = require('../middlewares/authMiddleware');

// Rutas Públicas
router.post('/registro', registrar);
router.post('/login', login);

// Rutas Protegidas (requieren token)
router.get('/perfil', verificarToken, obtenerPerfil);

module.exports = router;