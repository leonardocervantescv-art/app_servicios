const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const UsuarioModel = require('../models/usuarioModel');
const { ROLES } = require('../config/constantes');
const { esUrlImagen, esUrlHttps } = require('../utils/helpers');
const { verificarGoogle, verificarFacebook, ErrorSocial } = require('../utils/proveedoresSociales');

const firmarToken = (id_usuario, id_rol) =>
    jwt.sign({ id_usuario, id_rol }, process.env.JWT_SECRET, { expiresIn: '30d' });

// Estados de la República (para validar la ubicación elegida a mano).
const ESTADOS_MX = [
    'Aguascalientes', 'Baja California', 'Baja California Sur', 'Campeche', 'Chiapas',
    'Chihuahua', 'Ciudad de México', 'Coahuila', 'Colima', 'Durango', 'Estado de México',
    'Guanajuato', 'Guerrero', 'Hidalgo', 'Jalisco', 'Michoacán', 'Morelos', 'Nayarit',
    'Nuevo León', 'Oaxaca', 'Puebla', 'Querétaro', 'Quintana Roo', 'San Luis Potosí',
    'Sinaloa', 'Sonora', 'Tabasco', 'Tamaulipas', 'Tlaxcala', 'Veracruz', 'Yucatán', 'Zacatecas'
];
const SEXOS = ['Masculino', 'Femenino', 'Otro', 'Prefiero no decir'];

// Registro de Usuario (Cliente o Trabajador)
const registrar = async (req, res) => {
    try {
        const { id_rol, nombre, apellido, correo, contrasena, telefono } = req.body;

        // Validar campos obligatorios
        if (!id_rol || !nombre || !apellido || !correo || !contrasena) {
            return res.status(400).json({
                ok: false,
                mensaje: 'Por favor completa todos los campos obligatorios.'
            });
        }

        // Verificar si el correo ya existe
        const usuarioExistente = await UsuarioModel.buscarPorCorreo(correo);
        if (usuarioExistente) {
            return res.status(400).json({
                ok: false,
                mensaje: 'El correo electrónico ya está registrado.'
            });
        }

        // Encriptar la contraseña
        const salt = await bcrypt.genSalt(10);
        const contrasenaHash = await bcrypt.hash(contrasena, salt);

        // Guardar en BD
        const idUsuario = await UsuarioModel.crearUsuario({
            id_rol,
            nombre,
            apellido,
            correo,
            contrasena: contrasenaHash,
            telefono
        });

        // Generar Token JWT
        const token = jwt.sign(
            { id_usuario: idUsuario, id_rol },
            process.env.JWT_SECRET,
            { expiresIn: '30d' }
        );

        return res.status(201).json({
            ok: true,
            mensaje: 'Usuario registrado exitosamente.',
            token,
            usuario: {
                id_usuario: idUsuario,
                nombre,
                apellido,
                correo,
                id_rol
            }
        });
    } catch (error) {
        console.error('Error en registrar:', error);
        return res.status(500).json({
            ok: false,
            mensaje: 'Error interno del servidor al registrar usuario.'
        });
    }
};

// Login de Usuario
const login = async (req, res) => {
    try {
        const { correo, contrasena } = req.body;

        if (!correo || !contrasena) {
            return res.status(400).json({
                ok: false,
                mensaje: 'Ingresa tu correo y contraseña.'
            });
        }

        // Buscar usuario por correo
        const usuario = await UsuarioModel.buscarPorCorreo(correo);
        if (!usuario) {
            return res.status(401).json({
                ok: false,
                mensaje: 'Credenciales inválidas.'
            });
        }

        // Verificar contraseña
        const contrasenaValida = await bcrypt.compare(contrasena, usuario.contrasena);
        if (!contrasenaValida) {
            return res.status(401).json({
                ok: false,
                mensaje: 'Credenciales inválidas.'
            });
        }

        // Generar Token JWT
        const token = jwt.sign(
            { id_usuario: usuario.id_usuario, id_rol: usuario.id_rol },
            process.env.JWT_SECRET,
            { expiresIn: '30d' }
        );

        return res.status(200).json({
            ok: true,
            mensaje: 'Inicio de sesión exitoso.',
            token,
            usuario: {
                id_usuario: usuario.id_usuario,
                nombre: usuario.nombre,
                apellido: usuario.apellido,
                correo: usuario.correo,
                id_rol: usuario.id_rol,
                rol: usuario.nombre_rol
            }
        });
    } catch (error) {
        console.error('Error en login:', error);
        return res.status(500).json({
            ok: false,
            mensaje: 'Error interno del servidor al iniciar sesión.'
        });
    }
};

// Obtener perfil del usuario autenticado
const obtenerPerfil = async (req, res) => {
    try {
        const id_usuario = req.usuario.id_usuario;
        const usuario = await UsuarioModel.obtenerPorId(id_usuario);

        if (!usuario) {
            return res.status(404).json({
                ok: false,
                mensaje: 'Usuario no encontrado.'
            });
        }

        return res.status(200).json({
            ok: true,
            usuario
        });
    } catch (error) {
        console.error('Error en obtenerPerfil:', error);
        return res.status(500).json({
            ok: false,
            mensaje: 'Error interno del servidor.'
        });
    }
};

// PUT /api/auth/perfil — datos personales, foto y ubicación.
// Solo se cambian los campos que vienen; '' borra un dato opcional.
const actualizarPerfil = async (req, res) => {
    try {
        const b = req.body ?? {};
        const datos = {};
        const textoOpcional = (campo, max) => {
            if (b[campo] === undefined || b[campo] === null) return null;
            if (typeof b[campo] !== 'string') return `${campo} debe ser texto.`;
            const v = b[campo].trim();
            if (v.length > max) return `${campo} no puede superar los ${max} caracteres.`;
            datos[campo] = v;
            return null;
        };

        const error =
            textoOpcional('nombre', 100) ||
            textoOpcional('apellido', 100) ||
            textoOpcional('telefono', 20) ||
            textoOpcional('municipio', 100) ||
            textoOpcional('colonia', 120) ||
            textoOpcional('estado_mx', 60) ||
            textoOpcional('sexo', 20) ||
            textoOpcional('foto_perfil', 255);
        if (error) return res.status(400).json({ ok: false, mensaje: error });

        if (datos.nombre === '' || datos.apellido === '') {
            return res.status(400).json({ ok: false, mensaje: 'El nombre y el apellido no pueden quedar vacíos.' });
        }
        if (datos.estado_mx && !ESTADOS_MX.includes(datos.estado_mx)) {
            return res.status(400).json({ ok: false, mensaje: 'Elige un estado de la lista.' });
        }
        if (datos.sexo && !SEXOS.includes(datos.sexo)) {
            return res.status(400).json({ ok: false, mensaje: `sexo debe ser: ${SEXOS.join(', ')}.` });
        }
        if (datos.foto_perfil && !esUrlImagen(datos.foto_perfil)) {
            return res.status(400).json({ ok: false, mensaje: 'foto_perfil debe ser una ruta devuelta por POST /api/archivos.' });
        }
        if (b.fecha_nacimiento !== undefined && b.fecha_nacimiento !== null) {
            if (typeof b.fecha_nacimiento !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(b.fecha_nacimiento)) {
                return res.status(400).json({ ok: false, mensaje: 'fecha_nacimiento debe tener el formato AAAA-MM-DD.' });
            }
            datos.fecha_nacimiento = b.fecha_nacimiento;
        }

        const usuario = await UsuarioModel.actualizarPerfil(req.usuario.id_usuario, datos);
        return res.status(200).json({ ok: true, mensaje: 'Perfil actualizado.', usuario });
    } catch (error) {
        if (typeof error.sqlState === 'string' && /^45\d{3}$/.test(error.sqlState)) {
            return res.status(Number(error.sqlState.slice(2))).json({ ok: false, mensaje: error.sqlMessage });
        }
        console.error('Error en actualizarPerfil:', error);
        return res.status(500).json({ ok: false, mensaje: 'Error interno del servidor.' });
    }
};

// Común a Google y Facebook. Si la persona no tiene cuenta y todavía no eligió
// rol, responde { requiere_rol: true } para que la app le pregunte y reintente.
const loginSocial = (proveedor, verificar) => async (req, res) => {
    try {
        const body = req.body ?? {};
        const persona = await verificar(body);

        let usuario = await UsuarioModel.buscarSocial(proveedor, persona.id, persona.correo);
        let creado = false;

        if (usuario && !usuario.activo) {
            return res.status(403).json({ ok: false, mensaje: 'Esta cuenta está desactivada.' });
        }

        if (!usuario) {
            const id_rol = Number(body.id_rol);
            if (id_rol !== ROLES.CLIENTE && id_rol !== ROLES.TRABAJADOR) {
                return res.status(200).json({
                    ok: true,
                    requiere_rol: true,
                    datos: { nombre: persona.nombre, apellido: persona.apellido, correo: persona.correo }
                });
            }

            // Sin contraseña real: se guarda un hash aleatorio que nadie conoce.
            const contrasena = await bcrypt.hash(crypto.randomBytes(32).toString('hex'), 10);
            const correo = persona.correo || `${proveedor}_${persona.id}@sin-correo.hogarix`;
            const nombre = (persona.nombre || 'Usuario').slice(0, 100);
            const apellido = (persona.apellido || '').slice(0, 100);

            const id_usuario = await UsuarioModel.crearUsuario({
                id_rol, nombre, apellido, correo, contrasena, telefono: null
            });
            await UsuarioModel.vincularSocial(id_usuario, proveedor, persona.id);
            if (persona.foto && esUrlHttps(persona.foto)) {
                await UsuarioModel.actualizarPerfil(id_usuario, { foto_perfil: persona.foto }).catch(() => {});
            }
            usuario = { id_usuario, id_rol, nombre, apellido, correo };
            creado = true;
        }

        const token = firmarToken(usuario.id_usuario, usuario.id_rol);
        return res.status(creado ? 201 : 200).json({
            ok: true,
            mensaje: creado ? 'Cuenta creada.' : 'Inicio de sesión exitoso.',
            token,
            usuario: {
                id_usuario: usuario.id_usuario,
                nombre: usuario.nombre,
                apellido: usuario.apellido,
                correo: usuario.correo,
                id_rol: Number(usuario.id_rol)
            }
        });
    } catch (error) {
        if (error instanceof ErrorSocial) {
            return res.status(error.codigo).json({ ok: false, mensaje: error.message });
        }
        console.error(`Error en login con ${proveedor}:`, error);
        return res.status(500).json({ ok: false, mensaje: `No se pudo iniciar sesión con ${proveedor}.` });
    }
};

const loginGoogle = loginSocial('google', verificarGoogle);
const loginFacebook = loginSocial('facebook', verificarFacebook);

module.exports = {
    registrar,
    login,
    obtenerPerfil,
    actualizarPerfil,
    loginGoogle,
    loginFacebook
};