const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();

app.use(cors());
app.use(express.json());

app.use('/api/servicios', require('./routes/servicioRoutes'));
app.use('/api/auth', require('./routes/authRoutes'));

module.exports = app;