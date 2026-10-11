import 'package:flutter/foundation.dart';
import 'package:manocerca/core/models/usuario.dart';
import 'package:manocerca/services/api_client.dart';
import 'package:manocerca/services/auth_service.dart';

/// Estado de la sesión. El token se guarda solo en memoria (en [ApiClient]);
/// si algún día se decide persistirlo, este es el único lugar que cambia.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._api) : _auth = AuthService(_api) {
    _api.onSesionExpirada = _sesionExpirada;
  }

  final ApiClient _api;
  final AuthService _auth;

  Usuario? _usuario;
  bool _cargando = false;
  String? _error;

  Usuario? get usuario => _usuario;
  bool get autenticado => _usuario != null;
  bool get cargando => _cargando;
  String? get error => _error;

  Future<bool> login({required String correo, required String contrasena}) =>
      _ejecutar(() => _auth.login(correo: correo, contrasena: contrasena));

  Future<bool> registrar({
    required int idRol,
    required String nombre,
    required String apellido,
    required String correo,
    required String contrasena,
    String? telefono,
  }) =>
      _ejecutar(() => _auth.registrar(
            idRol: idRol,
            nombre: nombre,
            apellido: apellido,
            correo: correo,
            contrasena: contrasena,
            telefono: telefono,
          ));

  void cerrarSesion() {
    _api.token = null;
    _usuario = null;
    _error = null;
    notifyListeners();
  }

  void limpiarError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  Future<bool> _ejecutar(Future<Sesion> Function() accion) async {
    if (_cargando) return false;
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      final sesion = await accion();
      _api.token = sesion.token;
      _usuario = sesion.usuario;
      return true;
    } on ApiException catch (e) {
      _error = e.mensaje;
      return false;
    } catch (_) {
      _error = 'Ocurrió un error inesperado. Intenta de nuevo.';
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  void _sesionExpirada() {
    cerrarSesion();
    _error = 'Tu sesión expiró. Inicia sesión de nuevo.';
    notifyListeners();
  }
}
