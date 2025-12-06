import 'package:flutter/foundation.dart';

@immutable
class Patient {
  final String id;
  final String nombre;
  final String email;
  final String telefono;

  /// URL de foto de perfil
  final String? fotoUrl;

  /// Género: "masculino", "femenino", "otro"
  final String? genero;

  /// Fecha de nacimiento (para calcular edad)
  final DateTime? fechaNacimiento;

  /// Datos médicos básicos (opcional)
  final List<String> alergias;
  final List<String> enfermedades;
  final List<String> medicamentos;

  const Patient({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    this.fotoUrl,
    this.genero,
    this.fechaNacimiento,
    this.alergias = const [],
    this.enfermedades = const [],
    this.medicamentos = const [],
  });

  // =====================================================
  // GETTERS ÚTILES
  // =====================================================

  int? get edad {
    if (fechaNacimiento == null) return null;
    final hoy = DateTime.now();
    int years = hoy.year - fechaNacimiento!.year;

    if (hoy.month < fechaNacimiento!.month ||
        (hoy.month == fechaNacimiento!.month &&
            hoy.day < fechaNacimiento!.day)) {
      years--;
    }

    return years;
  }

  String get displayName => nombre;

  // =====================================================
  // JSON (para backend/futuro)
  // =====================================================

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      telefono: json['telefono'] as String,
      fotoUrl: json['fotoUrl'] as String?,
      genero: json['genero'] as String?,
      fechaNacimiento: json['fechaNacimiento'] != null
          ? DateTime.parse(json['fechaNacimiento'])
          : null,
      alergias:
          (json['alergias'] as List?)?.map((e) => e.toString()).toList() ?? [],
      enfermedades:
          (json['enfermedades'] as List?)?.map((e) => e.toString()).toList() ??
          [],
      medicamentos:
          (json['medicamentos'] as List?)?.map((e) => e.toString()).toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'fotoUrl': fotoUrl,
      'genero': genero,
      'fechaNacimiento': fechaNacimiento?.toIso8601String(),
      'alergias': alergias,
      'enfermedades': enfermedades,
      'medicamentos': medicamentos,
    };
  }

  // =====================================================
  // COPY-WITH
  // =====================================================

  Patient copyWith({
    String? nombre,
    String? email,
    String? telefono,
    String? fotoUrl,
    String? genero,
    DateTime? fechaNacimiento,
    List<String>? alergias,
    List<String>? enfermedades,
    List<String>? medicamentos,
  }) {
    return Patient(
      id: id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      genero: genero ?? this.genero,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      alergias: alergias ?? this.alergias,
      enfermedades: enfermedades ?? this.enfermedades,
      medicamentos: medicamentos ?? this.medicamentos,
    );
  }
}
