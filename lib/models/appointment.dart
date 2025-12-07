import 'package:flutter/foundation.dart';
import '../core/models/professional.dart';

@immutable
class Appointment {
  final String id;
  final Professional professional;
  final DateTime dateTime;
  final Duration duration;

  /// "confirmada", "cancelada", "completada", "blocked", "pending_invite"
  final String status;

  /// Optional: ID of the patient invited (if status == pending_invite)
  /// or if it's a real backend, the patientId.
  final String? patientId;

  const Appointment({
    required this.id,
    required this.professional,
    required this.dateTime,
    required this.duration,
    required this.status,
    this.patientId,
  });

  Appointment copyWith({
    String? id,
    Professional? professional,
    DateTime? dateTime,
    Duration? duration,
    String? status,
    String? patientId,
  }) {
    return Appointment(
      id: id ?? this.id,
      professional: professional ?? this.professional,
      dateTime: dateTime ?? this.dateTime,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      patientId: patientId ?? this.patientId,
    );
  }

  // ========= JSON =========

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      professional: Professional.fromJson(json['professional'] as Map<String, dynamic>),
      dateTime: DateTime.parse(json['dateTime'] as String),
      duration: Duration(minutes: (json['durationMinutes'] as int?) ?? 30),
      status: (json['status'] as String?) ?? 'confirmada',
      patientId: json['patientId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'professional': professional.toJson(),
      'dateTime': dateTime.toIso8601String(),
      'durationMinutes': duration.inMinutes,
      'status': status,
      'patientId': patientId,
    };
  }
}
