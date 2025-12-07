import 'dart:async';
import '../datasources/agenda_local_datasource.dart';
import '../../models/appointment.dart';
import '../../core/models/professional.dart';

class AgendaRepository {
  final AgendaLocalDataSource _local;

  // Use the singleton stream from local source
  Stream<List<Appointment>> get citasStream => _local.citasStream;

  AgendaRepository() : _local = AgendaLocalDataSource();

  // 🔹 NUEVO: para usar agendaRepo.init() en main.dart
  Future<void> init() async {
    await _local.init();
  }

  /// Agendar una cita (o invitación)
  Future<Appointment> agendarCita({
    required Professional professional,
    required DateTime fechaHora,
    required Duration duracion,
    String status = "confirmada",
    String? patientId,
  }) async {
    return _local.agendarCita(
      professional: professional,
      fechaHora: fechaHora,
      duracion: duracion,
      status: status,
      patientId: patientId,
    );
  }

  Future<void> bloquearSlot({
     required Professional professional,
     required DateTime fechaHora,
     required Duration duracion,
  }) async {
    await _local.bloquearSlot(
      professional: professional,
      fechaHora: fechaHora,
      duracion: duracion,
    );
  }

  /// Citas del paciente
  Future<List<Appointment>> obtenerCitasPaciente() {
    return _local.obtenerCitasPaciente();
  }

  Future<void> cancelarCita(String id) async {
    await _local.cancelarCita(id);
  }

  Future<void> reagendarCita({
    required String id,
    required DateTime nuevaFecha,
  }) async {
    await _local.reagendarCita(id, nuevaFecha);
  }

  /// Generar slots disponibles
  Future<List<AgendaSlot>> generarSlots({
    required String doctorId,
    required DateTime fecha,
  }) {
    return _local.generarSlots(doctorId: doctorId, fecha: fecha);
  }

  /// Obtener disponibilidad mensual
  Future<Map<DateTime, DayStatus>> getAvailabilityForMonth({
    required String doctorId,
    required DateTime month
  }) {
    return _local.getAvailabilityForMonth(doctorId: doctorId, month: month);
  }

  /// Cargar configuración del médico
  Future<Map<String, dynamic>> cargarConfigMedico(String doctorId) {
    return _local.cargarConfigMedico(doctorId);
  }

  /// Guardar configuración del médico
  Future<void> guardarConfigMedico(String doctorId, Map<String, dynamic> config) {
    return _local.guardarConfigMedico(doctorId, config);
  }
}
