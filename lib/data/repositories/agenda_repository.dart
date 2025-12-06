import '../datasources/agenda_local_datasource.dart';
import '../../models/appointment.dart';
import '../../core/models/professional.dart';

class AgendaRepository {
  final AgendaLocalDataSource _local;

  AgendaRepository() : _local = AgendaLocalDataSource();

  // 🔹 NUEVO: para usar agendaRepo.init() en main.dart
  Future<void> init() async {
    await _local.init();
  }

  /// Agendar una cita
  Future<Appointment> agendarCita({
    required Professional professional,
    required DateTime fechaHora,
    required Duration duracion,
  }) {
    return _local.agendarCita(
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

  /// Cargar configuración del médico
  Future<Map<String, dynamic>> cargarConfigMedico(String doctorId) {
    return _local.cargarConfigMedico(doctorId);
  }

  /// Guardar configuración del médico
  Future<void> guardarConfigMedico(String doctorId, Map<String, dynamic> config) {
    return _local.guardarConfigMedico(doctorId, config);
  }
}
