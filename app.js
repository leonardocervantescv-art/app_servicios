const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();

app.use(cors());
app.use(express.json());

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

module.exports = app;