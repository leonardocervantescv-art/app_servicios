const app = require('./app');
require('dotenv').config();

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
    console.log(`\n Servidor corriendo en el puerto ${PORT}`);
    console.log(`servidor en http://localhost:${PORT}\n`);
});