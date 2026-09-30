// Devuelve un entero positivo o null si el valor no lo es.
const entero = (valor) => {
    if (typeof valor !== 'number' && typeof valor !== 'string') return null;
    const n = Number(valor);
    return Number.isInteger(n) && n > 0 ? n : null;
};

const texto = (valor) => (typeof valor === 'string' ? valor.trim() : '');

const paginacion = (query, limiteMax = 50, limiteDefecto = 20) => {
    const pagina = entero(query.pagina) || 1;
    const limite = Math.min(entero(query.limite) || limiteDefecto, limiteMax);
    return { limite, offset: (pagina - 1) * limite };
};

const esUrlHttps = (valor) => typeof valor === 'string' && valor.length <= 255 && valor.startsWith('https://');

// Acepta 'YYYY-MM-DD HH:mm:ss' o cualquier formato ISO 8601 que Date entienda.
const fechaValida = (valor) => {
    if (typeof valor !== 'string' || !valor.trim()) return null;
    const fecha = new Date(valor.replace(' ', 'T'));
    return Number.isNaN(fecha.getTime()) ? null : valor;
};

// Los procedimientos almacenados lanzan SQLSTATE '45XXX' para errores de negocio,
// donde XXX es el código HTTP (400, 403, 404, 409). Cualquier otro error es un 500.
const manejarError = (res, error, contexto) => {
    if (typeof error.sqlState === 'string' && /^45\d{3}$/.test(error.sqlState)) {
        const codigo = parseInt(error.sqlState.slice(2), 10);
        return res.status(codigo >= 400 && codigo <= 599 ? codigo : 400).json({
            ok: false,
            mensaje: error.sqlMessage
        });
    }
    console.error(`Error en ${contexto}:`, error);
    return res.status(500).json({
        ok: false,
        mensaje: 'Error interno del servidor.'
    });
};

const solicitudInvalida = (res, mensaje) => res.status(400).json({ ok: false, mensaje });

module.exports = { entero, texto, paginacion, esUrlHttps, fechaValida, manejarError, solicitudInvalida };
