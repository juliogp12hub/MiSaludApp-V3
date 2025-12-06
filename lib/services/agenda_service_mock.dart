import 'dart:async';
import '../models/appointment.dart';
import '../core/models/professional.dart';

class AgendaServiceMock {
  AgendaServiceMock._internal();
  static final AgendaServiceMock _instance = AgendaServiceMock._internal();
  factory AgendaServiceMock() => _instance;

  final List<Appointment> _citas = [];

  int _autoIncrementId = 1;

  Future<List<Appointment>> obtenerCitasPaciente() async {
    await Future.delayed(const Duration(milliseconds: 200));
    // En el futuro aquí filtraremos por paciente.
    _citas.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return List.unmodifiable(_citas);
  }

  Future<Appointment> agendarCita({
    required Professional doctor,
    required DateTime fechaHora,
    Duration duration = const Duration(minutes: 30),
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final cita = Appointment(
      id: _autoIncrementId.toString(),
      professional: doctor,
      dateTime: fechaHora,
      duration: duration,
      status: "confirmada",
    );
    _autoIncrementId++;
    _citas.add(cita);
    return cita;
  }

  Future<void> cancelarCita(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _citas.removeWhere((c) => c.id == id);
  }
}
