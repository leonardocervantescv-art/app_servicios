import 'package:manocerca/core/utils/precio.dart';

class Pro {
  /// `id_usuario` del trabajador. Es null solo en los datos de ejemplo.
  final int? id;
  final String name;

  /// null mientras el trabajador no tenga reseñas (o el backend no las envíe).
  final double? rating;
  final int reviews;

  /// Sin geolocalización por ahora: siempre null con datos reales.
  final String? distance;
  final String? availability;

  final String? categoria;
  final String? tipoPago;
  final double? precioBase;
  final String? descripcion;

  const Pro({
    this.id,
    required this.name,
    this.rating,
    this.reviews = 0,
    this.distance,
    this.availability,
    this.categoria,
    this.tipoPago,
    this.precioBase,
    this.descripcion,
  });

  /// MySQL entrega los DECIMAL (precios, promedios) como texto: "150.00".
  static double? _numero(Object? valor) =>
      valor == null ? null : double.tryParse('$valor');

  /// Una fila de `GET /api/servicios/buscar`.
  factory Pro.fromServicioJson(Map<String, dynamic> json) {
    final disponible = json['disponible'];
    return Pro(
      id: (json['id_usuario'] as num).toInt(),
      name: '${json['nombre']} ${json['apellido']}'.trim(),
      rating: _numero(json['calificacion_promedio']),
      reviews: _numero(json['total_resenas'])?.toInt() ?? 0,
      availability: disponible == null
          ? null
          : ((disponible == true || disponible == 1) ? 'Disponible' : 'No disponible'),
      categoria: json['nombre_categoria'] as String?,
      tipoPago: json['tipo_pago'] as String?,
      precioBase: _numero(json['precio_base']),
      descripcion: json['descripcion_servicio'] as String?,
    );
  }

  String get precioTexto => textoPrecio(precioBase, tipoPago);
}
