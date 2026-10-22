import 'package:manocerca/core/models/usuario.dart';
import 'package:manocerca/services/api_client.dart';

typedef Sesion = ({String token, Usuario usuario});

class AuthService {
  AuthService(this._api);
  final ApiClient _api;

  Future<Sesion> login({required String correo, required String contrasena}) async {
    final r = await _api.post('/auth/login', body: {
      'correo': correo,
      'contrasena': contrasena,
    });
    return _sesion(r);
  }

  Future<Sesion> registrar({
    required int idRol,
    required String nombre,
    required String apellido,
    required String correo,
    required String contrasena,
    String? telefono,
  }) async {
    final r = await _api.post('/auth/registro', body: {
      'id_rol': idRol,
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'contrasena': contrasena,
      if (telefono != null && telefono.isNotEmpty) 'telefono': telefono,
    });
    return _sesion(r);
  }

  /// Perfil completo del usuario de la sesión (ubicación, foto, etc.).
  Future<Usuario> perfil() async {
    final r = await _api.get('/auth/perfil');
    final u = r['usuario'];
    if (u is! Map<String, dynamic>) throw const ApiException('Respuesta inesperada del servidor.');
    return Usuario.fromJson(u);
  }

  /// Solo se mandan los campos presentes. '' borra un dato opcional.
  Future<Usuario> actualizarPerfil(Map<String, Object?> cambios) async {
    final r = await _api.put('/auth/perfil', body: cambios);
    final u = r['usuario'];
    if (u is! Map<String, dynamic>) throw const ApiException('Respuesta inesperada del servidor.');
    return Usuario.fromJson(u);
  }

  Sesion _sesion(Map<String, dynamic> r) {
    final token = r['token'];
    final usuario = r['usuario'];
    if (token is! String || usuario is! Map<String, dynamic>) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    return (token: token, usuario: Usuario.fromJson(usuario));
  }
}
