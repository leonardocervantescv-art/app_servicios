const db = require('../config/db');

// Las horas de la agenda son las que eligió el trabajador (hora de pared, sin
// zona horaria). Se devuelven como texto 'YYYY-MM-DD HH:mm:ss' para que no se
// conviertan a UTC y se vean distintas según el servidor o el celular.
const comoTexto = (campo, siguiente) =>
    campo.type === 'DATETIME' ? campo.string() : siguiente();

class AgendaModel {
    static async crear(id_usuario, { titulo, descripcion, fecha_inicio, fecha_fin }) {
        const [results] = await db.query(
            'CALL sp_evento_crear(?, ?, ?, ?, ?)',
            [id_usuario, titulo, descripcion, fecha_inicio, fecha_fin]
        );
        return results[0][0].id_evento;
    }

    static async listar(id_usuario, desde, hasta) {
        const [results] = await db.query({
            sql: 'CALL sp_evento_listar(?, ?, ?)',
            values: [id_usuario, desde, hasta],
            typeCast: comoTexto
        });
        return results[0];
    }

    static async actualizar(id_usuario, id_evento, { titulo, descripcion, fecha_inicio, fecha_fin }) {
        await db.query(
            'CALL sp_evento_actualizar(?, ?, ?, ?, ?, ?)',
            [id_usuario, id_evento, titulo, descripcion, fecha_inicio, fecha_fin]
        );
    }

    static async eliminar(id_usuario, id_evento) {
        await db.query('CALL sp_evento_eliminar(?, ?)', [id_usuario, id_evento]);
    }
}

module.exports = AgendaModel;
