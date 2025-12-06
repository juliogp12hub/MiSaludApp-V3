import 'package:shared_preferences/shared_preferences.dart';
import '../../models/patient/patient_model.dart';
import 'dart:convert';

class PatientLocalDatasource {
  static const _key = "patient_data";
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> guardarPaciente(Patient p) async {
    await _prefs?.setString(_key, jsonEncode(p.toJson()));
  }

  Future<Patient?> obtenerPaciente() async {
    final data = _prefs?.getString(_key);
    if (data == null) return null;
    return Patient.fromJson(jsonDecode(data));
  }

  Future<void> actualizarFoto(String url) async {
    final p = await obtenerPaciente();
    if (p == null) return;
    final actualizado = p.copyWith(fotoUrl: url);
    await guardarPaciente(actualizado);
  }

  Future<void> limpiar() async {
    await _prefs?.remove(_key);
  }
}
