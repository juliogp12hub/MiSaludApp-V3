import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/appointment.dart';
import '../../core/models/professional.dart';

/// Representa un slot disponible (inicio - fin)
class AgendaSlot {
  final DateTime inicio;
  final DateTime fin;

  AgendaSlot({required this.inicio, required this.fin});
}

/// Fuente local que maneja citas + generación de slots
class AgendaLocalDataSource {
  AgendaLocalDataSource._internal();
  static final AgendaLocalDataSource _instance =
      AgendaLocalDataSource._internal();
  factory AgendaLocalDataSource() => _instance;

  static const _keyCitas = "citas_paciente_v2";
  static const _keyConfigMedico = "agenda_config_medico_";

  List<Appointment> _citas = [];

  /// ============================================================
  ///   INIT - Carga las citas desde SharedPreferences
  /// ============================================================
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyCitas);

    if (raw != null) {
      try {
        final decoded = jsonDecode(raw);
        _citas = (decoded as List).map((e) => Appointment.fromJson(e)).toList();
      } catch (e) {
        // Fallback or clear if format changed
        _citas = [];
      }
    }
  }

  /// ============================================================
  ///   GUARDAR CITAS LOCALMENTE
  /// ============================================================
  Future<void> _guardarCitas() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyCitas,
      jsonEncode(_citas.map((e) => e.toJson()).toList()),
    );
  }

  /// ============================================================
  /// CONFIGURACIÓN DEL MÉDICO
  /// ============================================================
  Future<Map<String, dynamic>> cargarConfigMedico(String doctorId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString("$_keyConfigMedico$doctorId");

    if (raw == null) {
      // Config por defecto:
      // 8am-5pm
      // 30 minutos
      // Lunes a Viernes (1-5)
      return {
        "inicio": "08:00",
        "fin": "17:00",
        "duracion": 30,
        "diasLaborales": [1, 2, 3, 4, 5] // 1=Mon, 7=Sun
      };
    }

    return jsonDecode(raw);
  }

  Future<void> guardarConfigMedico(String doctorId, Map<String, dynamic> config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("$_keyConfigMedico$doctorId", jsonEncode(config));
  }

  /// ============================================================
  ///   GENERAR SLOTS DEL DÍA
  /// ============================================================
  Future<List<AgendaSlot>> generarSlots({
    required String doctorId,
    required DateTime fecha,
  }) async {
    final config = await cargarConfigMedico(doctorId);

    // 1. Validar si el día es laboral
    final diasLaborales = (config["diasLaborales"] as List<dynamic>?)
        ?.map((e) => e as int)
        .toList() ?? [1, 2, 3, 4, 5];

    // DateTime.weekday returns 1 for Monday and 7 for Sunday.
    if (!diasLaborales.contains(fecha.weekday)) {
      return []; // No slots if not a working day
    }

    final inicio = _combinar(fecha, config["inicio"]);
    final fin = _combinar(fecha, config["fin"]);
    final duracion = Duration(minutes: config["duracion"] ?? 30);

    List<AgendaSlot> slots = [];

    DateTime cursor = inicio;

    // Asegurarse de que no generamos slots en el pasado si es hoy
    final now = DateTime.now();

    while (cursor.isBefore(fin)) {
      final slotFin = cursor.add(duracion);

      // Si el slot termina después de la hora de fin configurada, no lo agregamos
      if (slotFin.isAfter(fin)) break;

      // Filter past slots if today
      bool isPast = false;
      if (fecha.year == now.year && fecha.month == now.month && fecha.day == now.day) {
        if (cursor.isBefore(now)) {
           isPast = true;
        }
      }

      if (!isPast) {
         // Verificar si está ocupado
        final ocupado = _citas.any(
          (c) =>
              c.professional.id == doctorId &&
              cursor.isBefore(c.dateTime.add(c.duration)) &&
              c.dateTime.isBefore(slotFin) &&
              c.status != 'cancelada',
        );

        if (!ocupado) {
          slots.add(AgendaSlot(inicio: cursor, fin: slotFin));
        }
      }

      cursor = cursor.add(duracion);
    }

    return slots;
  }

  /// Helper para convertir "HH:mm" → DateTime
  DateTime _combinar(DateTime base, String hhmm) {
    final partes = hhmm.split(":");
    return DateTime(
      base.year,
      base.month,
      base.day,
      int.parse(partes[0]),
      int.parse(partes[1]),
    );
  }

  /// ============================================================
  ///   AGENDAR CITA
  /// ============================================================
  Future<Appointment> agendarCita({
    required Professional professional,
    required DateTime fechaHora,
    required Duration duracion,
  }) async {
    final cita = Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      professional: professional,
      dateTime: fechaHora,
      duration: duracion,
      status: "confirmada",
    );

    _citas.add(cita);
    await _guardarCitas();

    return cita;
  }

  /// ============================================================
  ///   OBTENER CITAS DEL PACIENTE
  /// ============================================================
  Future<List<Appointment>> obtenerCitasPaciente() async {
    _citas.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return List.unmodifiable(_citas);
  }

  Future<void> cancelarCita(String id) async {
    final index = _citas.indexWhere((c) => c.id == id);
    if (index == -1) return;

    final cita = _citas[index];

    _citas[index] = cita.copyWith(status: "cancelada");

    await _guardarCitas();
  }

  Future<void> reagendarCita(String id, DateTime nuevaFecha) async {
    final index = _citas.indexWhere((c) => c.id == id);
    if (index == -1) return;

    final cita = _citas[index];

    _citas[index] = cita.copyWith(
      dateTime: nuevaFecha,
      status: "confirmada",
    );

    await _guardarCitas();
  }
}
