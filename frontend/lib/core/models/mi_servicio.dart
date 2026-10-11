import 'package:manocerca/core/utils/precio.dart';

/// Un servicio que ofrece el trabajador autenticado.
class MiServicio {
  final int id;
  final int idCategoria;
  final String categoria;
  final String tipoPago;
  final double? precioBase;
  final String? descripcion;

  const MiServicio({
    required this.id,
    required this.idCategoria,
    required this.categoria,
    required this.tipoPago,
    this.precioBase,
    this.descripcion,
  });

  String get precioTexto => textoPrecio(precioBase, tipoPago);

  factory MiServicio.fromJson(Map<String, dynamic> json) => MiServicio(
        id: (json['id_servicio'] as num).toInt(),
        idCategoria: (json['id_categoria'] as num).toInt(),
        categoria: json['nombre_categoria'] as String,
        tipoPago: json['tipo_pago'] as String,
        // MySQL entrega DECIMAL como texto ("150.00").
        precioBase: json['precio_base'] == null
            ? null
            : double.tryParse('${json['precio_base']}'),
        descripcion: json['descripcion_servicio'] as String?,
      );
}

/// Lo que necesita la pantalla "Mis servicios".
class PerfilTrabajador {
  final bool disponible;
  final List<MiServicio> servicios;

  const PerfilTrabajador({required this.disponible, required this.servicios});

  factory PerfilTrabajador.fromJson(Map<String, dynamic> json) => PerfilTrabajador(
        disponible: json['disponible'] == true || json['disponible'] == 1,
        servicios: ((json['servicios'] as List?) ?? const [])
            .map((e) => MiServicio.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
