const db = require('../config/db');

class UsuarioModel {
    // Buscar usuario por correo para validación de login / registro
    static async buscarPorCorreo(correo) {
        const [results] = await db.query('CALL sp_usuario_buscar_por_correo(?)', [correo]);
        return results[0][0];
    }

    // Registrar un nuevo usuario (y su perfil de trabajador si aplica) vía procedimiento almacenado
    static async crearUsuario({ id_rol, nombre, apellido, correo, contrasena, telefono }) {
        const connection = await db.getConnection();
        try {
            await connection.query(
                'CALL sp_usuario_crear(?, ?, ?, ?, ?, ?, @id_usuario)',
                [id_rol, nombre, apellido, correo, contrasena, telefono || null]
            );
            const [[fila]] = await connection.query('SELECT @id_usuario AS id_usuario');
            return fila.id_usuario;
        } finally {
            connection.release();
        }
    }

    // Obtener datos del perfil del usuario autenticado
    static async obtenerPorId(id_usuario) {
        const [results] = await db.query('CALL sp_usuario_obtener_por_id(?)', [id_usuario]);
        return results[0][0];
    }
}

module.exports = UsuarioModel;