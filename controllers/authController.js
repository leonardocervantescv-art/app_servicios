const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const UsuarioModel = require('../models/usuarioModel');

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
            process.env.JWT_SECRET || 'clave_secreta_servicios_app',
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
            process.env.JWT_SECRET || 'clave_secreta_servicios_app',
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

module.exports = {
    registrar,
    login,
    obtenerPerfil
};