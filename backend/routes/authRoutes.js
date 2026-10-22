const express = require('express');
const router = express.Router();
const {
    registrar,
    login,
    obtenerPerfil,
    actualizarPerfil,
    loginGoogle,
    loginFacebook
} = require('../controllers/authController');
const { verificarToken } = require('../middlewares/authMiddleware');

// Rutas Públicas
router.post('/registro', registrar);
router.post('/login', login);
router.post('/google', loginGoogle);
router.post('/facebook', loginFacebook);

// Rutas Protegidas (requieren token)
router.get('/perfil', verificarToken, obtenerPerfil);
router.put('/perfil', verificarToken, actualizarPerfil);

module.exports = router;
