const SolicitudModel = require('../models/solicitudModel');
const { TIPOS_PAGO, ESTADOS_SOLICITUD } = require('../config/constantes');
const { entero, paginacion, manejarError, solicitudInvalida } = require('../utils/helpers');

const crearSolicitud = async (req, res) => {
    try {
        const body = req.body ?? {};
        const id_trabajador = entero(body.id_trabajador);
        const id_categoria = entero(body.id_categoria);

        if (!id_trabajador || !id_categoria) {
            return solicitudInvalida(res, 'id_trabajador e id_categoria son obligatorios.');
        }
        if (!TIPOS_PAGO.includes(body.tipo_pago_acordado)) {
            return solicitudInvalida(res, `tipo_pago_acordado debe ser uno de: ${TIPOS_PAGO.join(', ')}.`);
        }

        let monto_estimado = null;
        if (body.monto_estimado !== undefined && body.monto_estimado !== null) {
            if (typeof body.monto_estimado !== 'number' || !Number.isFinite(body.monto_estimado)
                || body.monto_estimado < 0 || body.monto_estimado > 99999999.99) {
                return solicitudInvalida(res, 'monto_estimado debe ser un número mayor o igual a 0.');
            }
            monto_estimado = body.monto_estimado;
        }

        const id_solicitud = await SolicitudModel.crear(req.usuario.id_usuario, {
            id_trabajador,
            id_categoria,
            tipo_pago_acordado: body.tipo_pago_acordado,
            monto_estimado
        });
        return res.status(201).json({ ok: true, mensaje: 'Solicitud enviada.', id_solicitud });
    } catch (error) {
        return manejarError(res, error, 'crearSolicitud');
    }
};

const listarSolicitudes = async (req, res) => {
    try {
        let estado = null;
        if (req.query.estado !== undefined) {
            if (!ESTADOS_SOLICITUD.includes(req.query.estado)) {
                return solicitudInvalida(res, `estado debe ser uno de: ${ESTADOS_SOLICITUD.join(', ')}.`);
            }
            estado = req.query.estado;
        }

        const { limite, offset } = paginacion(req.query);
        const solicitudes = await SolicitudModel.listar({
            id_usuario: req.usuario.id_usuario,
            estado,
            limite,
            offset
        });
        return res.status(200).json({ ok: true, total: solicitudes.length, data: solicitudes });
    } catch (error) {
        return manejarError(res, error, 'listarSolicitudes');
    }
};

const obtenerSolicitud = async (req, res) => {
    try {
        const id_solicitud = entero(req.params.id_solicitud);
        if (!id_solicitud) return solicitudInvalida(res, 'id_solicitud no es válido.');

        const [solicitud] = await SolicitudModel.listar({
            id_usuario: req.usuario.id_usuario,
            id_solicitud,
            limite: 1,
            offset: 0
        });
        if (!solicitud) {
            return res.status(404).json({ ok: false, mensaje: 'Solicitud no encontrada.' });
        }
        return res.status(200).json({ ok: true, data: solicitud });
    } catch (error) {
        return manejarError(res, error, 'obtenerSolicitud');
    }
};

const cambiarEstadoSolicitud = async (req, res) => {
    try {
        const id_solicitud = entero(req.params.id_solicitud);
        if (!id_solicitud) return solicitudInvalida(res, 'id_solicitud no es válido.');

        const { estado } = req.body ?? {};
        if (!ESTADOS_SOLICITUD.includes(estado)) {
            return solicitudInvalida(res, `estado debe ser uno de: ${ESTADOS_SOLICITUD.join(', ')}.`);
        }

        const resultado = await SolicitudModel.cambiarEstado(req.usuario.id_usuario, id_solicitud, estado);
        return res.status(200).json({ ok: true, mensaje: `Solicitud ${estado.toLowerCase()}.`, data: resultado });
    } catch (error) {
        return manejarError(res, error, 'cambiarEstadoSolicitud');
    }
};

module.exports = {
    crearSolicitud,
    listarSolicitudes,
    obtenerSolicitud,
    cambiarEstadoSolicitud
};
