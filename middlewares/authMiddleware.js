const jwt = require('jsonwebtoken');

const verificarToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Formato: "Bearer TOKEN"

    if (!token) {
        return res.status(401).json({
            ok: false,
            mensaje: 'Acceso denegado. No se proporcionó un token de autenticación.'
        });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'clave_secreta_servicios_app');
        req.usuario = decoded; // Adjunta id_usuario y id_rol a la petición
        next();
    } catch (error) {
        return res.status(403).json({
            ok: false,
            mensaje: 'Token inválido o expirado.'
        });
    }
};

module.exports = {
    verificarToken
};