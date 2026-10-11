const express = require('express');
const router = express.Router();
const { listarEventos, crearEvento, actualizarEvento, eliminarEvento } = require('../controllers/agendaController');
const { verificarToken, verificarRol } = require('../middlewares/authMiddleware');
const { ROLES } = require('../config/constantes');

router.use(verificarToken, verificarRol(ROLES.TRABAJADOR));

router.get('/', listarEventos);
router.post('/', crearEvento);
router.put('/:id_evento', actualizarEvento);
router.delete('/:id_evento', eliminarEvento);

module.exports = router;
