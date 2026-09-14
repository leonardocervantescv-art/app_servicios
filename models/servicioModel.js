const db = require('../config/db');

class ServicioModel {
    static async buscarServicios(id_categoria, tipo_pago) {
        let query = `SELECT st.id_servicio, st.tipo_pago, st.precio_base, st.descripcion_servicio,
                   c.nombre_categoria, u.id_usuario, u.nombre, u.apellido, u.foto_perfil, u.telefono
            FROM servicios_trabajador st
            JOIN categorias c ON st.id_categoria = c.id_categoria
            JOIN perfiles_trabajador pt ON st.id_perfil = pt.id_perfil
            JOIN usuarios u ON pt.id_usuario = u.id_usuario
            WHERE st.id_categoria = ?`;
        const params = [id_categoria];

        if (tipo_pago) {
            query +=  `AND st.tipo_pago = ?`;
            params.push(tipo_pago);
        }

        const [rows] = await db.query(query, params);
        return rows;
    }
}

module.exports = ServicioModel;