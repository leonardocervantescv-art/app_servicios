class Roles {
  static const int cliente = 1;
  static const int trabajador = 2;
}

class Usuario {
  final int id;
  final String nombre;
  final String apellido;
  final String correo;
  final int idRol;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.idRol,
  });

  bool get esTrabajador => idRol == Roles.trabajador;
  String get nombreCompleto => '$nombre $apellido';
  String get rolTexto => esTrabajador ? 'Trabajador' : 'Cliente';

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: (json['id_usuario'] as num).toInt(),
        nombre: json['nombre'] as String,
        apellido: json['apellido'] as String,
        correo: json['correo'] as String,
        idRol: (json['id_rol'] as num).toInt(),
      );
}
