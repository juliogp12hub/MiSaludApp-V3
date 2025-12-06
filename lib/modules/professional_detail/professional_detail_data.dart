import 'package:flutter/foundation.dart';

@immutable
class ProfessionalDetailData {
  final String id;
  final String nombre;
  final String tipo; // EJ: Médico - Pediatra, Dentista, Psicólogo
  final String avatarUrl;
  final String ciudad;

  // Perfil profesional
  final String? subespecialidad;
  final String? colegiado;
  final String? direccion;
  final String? acercaDe;

  // Reputación
  final double? calificacion;
  final int? numeroOpiniones;
  final int? ranking; // opcional
  final List<String>? categorias;

  // Precios
  final double? precioPresencial;
  final double? precioVirtual;

  // Experiencia
  final String? experiencia;

  // Disponibilidad
  final bool disponibleInmediato;
  final List<String>? horarios;
  final List<String>? hospitales;
  final List<String>? idiomas;

  // UI Secciones
  final List<String>? servicios;
  final List<String>? equipos;
  final List<String>? pacientes;
  final List<String>? modalidades;
  final List<String>? turnos;

  const ProfessionalDetailData({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.avatarUrl,
    required this.ciudad,

    this.subespecialidad,
    this.colegiado,
    this.direccion,
    this.acercaDe,

    this.calificacion,
    this.numeroOpiniones,
    this.ranking,
    this.categorias,

    this.precioPresencial,
    this.precioVirtual,

    this.experiencia,

    this.disponibleInmediato = false,
    this.horarios,
    this.hospitales,
    this.idiomas,

    this.servicios,
    this.equipos,
    this.pacientes,
    this.modalidades,
    this.turnos,
  });
}
