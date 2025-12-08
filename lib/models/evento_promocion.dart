class EventoPromocion {
  final String id;
  final String titulo;
  final String descripcion;
  final String tipo; // evento, promocion, recordatorio, articulo
  final String category; // Salud Mental, Dental, General, etc.
  final DateTime fecha;
  final String autorNombre;
  final String autorTipo;
  final String? professionalId; // Link to professional profile
  final String? imagenUrl;

  EventoPromocion({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    required this.category,
    required this.fecha,
    required this.autorNombre,
    required this.autorTipo,
    this.professionalId,
    this.imagenUrl,
  });

  EventoPromocion copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    String? tipo,
    String? category,
    DateTime? fecha,
    String? autorNombre,
    String? autorTipo,
    String? professionalId,
    String? imagenUrl,
  }) {
    return EventoPromocion(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      tipo: tipo ?? this.tipo,
      category: category ?? this.category,
      fecha: fecha ?? this.fecha,
      autorNombre: autorNombre ?? this.autorNombre,
      autorTipo: autorTipo ?? this.autorTipo,
      professionalId: professionalId ?? this.professionalId,
      imagenUrl: imagenUrl ?? this.imagenUrl,
    );
  }
}
