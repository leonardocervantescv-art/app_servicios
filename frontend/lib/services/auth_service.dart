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

  Sesion _sesion(Map<String, dynamic> r) => (
        token: r['token'] as String,
        usuario: Usuario.fromJson(r['usuario'] as Map<String, dynamic>),
      );
}
