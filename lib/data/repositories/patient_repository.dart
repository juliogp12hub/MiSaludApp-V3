import '../datasources/patient_local_datasource.dart';
import '../../models/patient/patient_model.dart';

class PatientRepository {
  final PatientLocalDatasource _local;

  PatientRepository(this._local);

  Future<void> init() async => await _local.init();

  Future<Patient?> obtenerPaciente() => _local.obtenerPaciente();

  Future<void> guardarPaciente(Patient p) => _local.guardarPaciente(p);

  Future<void> actualizarFoto(String url) => _local.actualizarFoto(url);

  Future<void> limpiar() => _local.limpiar();
}

/// instancia global
final patientRepo = PatientRepository(PatientLocalDatasource());
