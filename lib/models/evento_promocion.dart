class EventoPromocion {
  final String id;
  final String titulo;
  final String descripcion;
  final String tipo; // evento, promocion, recordatorio, articulo
  final DateTime fecha;
  final String autorNombre;
  final String autorTipo;
  final String? imagenUrl;

  EventoPromocion({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    required this.fecha,
    required this.autorNombre,
    required this.autorTipo,
    this.imagenUrl,
  });
}
