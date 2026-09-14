const db = require('../config/db');

class UsuarioModel {
    // Buscar usuario por correo para validación de login / registro
    static async buscarPorCorreo(correo) {
        const query = `
            SELECT u.id_usuario, u.id_rol, u.nombre, u.apellido, u.correo, u.contrasena, r.nombre_rol
            FROM usuarios u
            JOIN roles r ON u.id_rol = r.id_rol
            WHERE u.correo = ?
        `;
        const [rows] = await db.query(query, [correo]);
        return rows[0];
    }

    // Registrar un nuevo usuario y su perfil si es trabajador
    static async crearUsuario({ id_rol, nombre, apellido, correo, contrasena, telefono }) {
        const connection = await db.getConnection();
        try {
            await connection.beginTransaction();

            // 1. Insertar en la tabla usuarios
            const queryUsuario = `
                INSERT INTO usuarios (id_rol, nombre, apellido, correo, contrasena, telefono)
                VALUES (?, ?, ?, ?, ?, ?)
            `;
            const [resultUsuario] = await connection.query(queryUsuario, [
                id_rol, nombre, apellido, correo, contrasena, telefono || null
            ]);

            const idUsuarioInsertado = resultUsuario.insertId;

            // 2. Si el rol es 'Trabajador', crear automáticamente su registro en perfiles_trabajador
            // (Asumiendo que id_rol 2 es 'Trabajador')
            if (parseInt(id_rol) === 2) {
                const queryPerfil = `
                    INSERT INTO perfiles_trabajador (id_usuario, biografia)
                    VALUES (?, ?)
                `;
                await connection.query(queryPerfil, [idUsuarioInsertado, '']);
            }

            await connection.commit();
            return idUsuarioInsertado;
        } catch (error) {
            await connection.rollback();
            throw error;
        } finally {
            connection.release();
        }
    }

    // Obtener datos del perfil del usuario autenticado
    static async obtenerPorId(id_usuario) {
        const query = `
            SELECT u.id_usuario, u.nombre, u.apellido, u.correo, u.telefono, u.foto_perfil, u.fecha_registro, r.nombre_rol
            FROM usuarios u
            JOIN roles r ON u.id_rol = r.id_rol
            WHERE u.id_usuario = ?
        `;
        const [rows] = await db.query(query, [id_usuario]);
        return rows[0];
    }
}

module.exports = UsuarioModel;