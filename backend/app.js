const express = require('express');
const cors = require('cors');
require('dotenv').config();
const { UPLOADS_DIR, RUTA_PUBLICA } = require('./config/almacenamiento');

const app = express();

app.use(cors());
app.use(express.json());

// Imágenes subidas con POST /api/archivos
app.use(RUTA_PUBLICA, express.static(UPLOADS_DIR, {
    index: false,
    dotfiles: 'deny',
    maxAge: '7d',
    setHeaders: (res) => res.set('X-Content-Type-Options', 'nosniff')
}));

app.use('/api/servicios', require('./routes/servicioRoutes'));
app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api/categorias', require('./routes/categoriaRoutes'));
app.use('/api/trabajadores', require('./routes/trabajadorRoutes'));
app.use('/api/publicaciones', require('./routes/publicacionRoutes'));
app.use('/api/solicitudes', require('./routes/solicitudRoutes'));
app.use('/api/resenas', require('./routes/resenaRoutes'));
app.use('/api/favoritos', require('./routes/favoritoRoutes'));
app.use('/api/reportes', require('./routes/reporteRoutes'));
app.use('/api/bloqueos', require('./routes/bloqueoRoutes'));
app.use('/api/dispositivos', require('./routes/dispositivoRoutes'));
app.use('/api/agenda', require('./routes/agendaRoutes'));
app.use('/api/archivos', require('./routes/archivoRoutes'));
app.use('/api/conversaciones', require('./routes/conversacionRoutes'));
app.use('/api/notificaciones', require('./routes/notificacionRoutes'));

// Rutas inexistentes y errores no controlados también responden { ok, mensaje }
app.use('/api', (req, res) => {
    res.status(404).json({ ok: false, mensaje: 'Ruta no encontrada.' });
});

app.use((err, req, res, next) => {
    if (err.type === 'entity.parse.failed') {
        return res.status(400).json({ ok: false, mensaje: 'El cuerpo de la petición no es JSON válido.' });
    }
    console.error('Error no controlado:', err);
    return res.status(500).json({ ok: false, mensaje: 'Error interno del servidor.' });
});

module.exports = app;
