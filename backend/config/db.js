const mysql = require('mysql2/promise');
require('dotenv').config();

// Bases en la nube (p. ej. Aiven) exigen conexión cifrada: pega su certificado CA en DB_SSL_CA.
const ssl = process.env.DB_SSL_CA
    ? { ca: process.env.DB_SSL_CA.replace(/\\n/g, '\n'), rejectUnauthorized: true }
    : undefined;

const pool = mysql.createPool({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT ? Number(process.env.DB_PORT) : 3306,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    ssl,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    // Evita errores por conexiones inactivas que la base en la nube ya cerró.
    enableKeepAlive: true,
    keepAliveInitialDelay: 10000
});

module.exports = pool;
