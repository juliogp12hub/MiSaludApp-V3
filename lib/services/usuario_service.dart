import 'package:shared_preferences/shared_preferences.dart';

class UsuarioService {
  UsuarioService._internal();
  static final UsuarioService _instance = UsuarioService._internal();
  factory UsuarioService() => _instance;

  // ---------------------------------------------------------
  // Claves de almacenamiento
  // ---------------------------------------------------------
  static const _keyNombre = "usuario_nombre";
  static const _keyTelefono = "usuario_telefono";
  static const _keyEdad = "usuario_edad";
  static const _keySexo = "usuario_sexo";

  // Estado general del usuario
  static const _keyTipo = "usuario_tipo"; // paciente / profesional
  static const _keyEstadoVerificacion = "usuario_verificacion_estado";
  // Valores aceptados: "none", "pending", "verified", "rejected"

  // Datos del profesional
  static const _keyProfTipo = "usuario_prof_tipo";
  static const _keyProfColegiado = "usuario_prof_colegiado";
  static const _keyProfArchivoBase64 = "usuario_prof_archivo_base64";
  static const _keyProfArchivoPath = "usuario_prof_archivo_path";

  // ---------------------------------------------------------
  // Campos en memoria
  // ---------------------------------------------------------
  String? _nombre;
  String? _telefono;
  int? _edad;
  String? _sexo;

  String _tipo = "paciente";
  String _estadoVerificacion = "none";

  String? _tipoProfesional;
  String? _numeroColegiado;
  String? _archivoBase64;
  String? _archivoPath;

  // ---------------------------------------------------------
  // Getters públicos
  // ---------------------------------------------------------
  String get nombre => _nombre ?? "";
  String get telefono => _telefono ?? "";
  int? get edad => _edad;
  String? get sexo => _sexo;

  bool get tieneTelefono => telefono.trim().isNotEmpty;

  String get tipo => _tipo; // paciente / profesional
  bool get esProfesional => _tipo == "profesional";

  bool get profesionalPendiente =>
      esProfesional && _estadoVerificacion == "pending";
  bool get profesionalVerificado =>
      esProfesional && _estadoVerificacion == "verified";
  bool get profesionalRechazado =>
      esProfesional && _estadoVerificacion == "rejected";

  String get estadoVerificacion => _estadoVerificacion;

  String get tipoProfesional => _tipoProfesional ?? "";
  String get numeroColegiado => _numeroColegiado ?? "";
  String get archivoBase64 => _archivoBase64 ?? "";
  String get archivoPath => _archivoPath ?? "";

  // ---------------------------------------------------------
  // CARGAR USUARIO
  // ---------------------------------------------------------
  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();

    _nombre = prefs.getString(_keyNombre);
    _telefono = prefs.getString(_keyTelefono);
    _edad = prefs.getInt(_keyEdad);
    _sexo = prefs.getString(_keySexo);

    _tipo = prefs.getString(_keyTipo) ?? "paciente";
    _estadoVerificacion = prefs.getString(_keyEstadoVerificacion) ?? "none";

    _tipoProfesional = prefs.getString(_keyProfTipo);
    _numeroColegiado = prefs.getString(_keyProfColegiado);
    _archivoBase64 = prefs.getString(_keyProfArchivoBase64);
    _archivoPath = prefs.getString(_keyProfArchivoPath);
  }

  // ---------------------------------------------------------
  // GUARDAR DATOS BÁSICOS (perfil paciente)
  // ---------------------------------------------------------
  Future<void> guardarDatos({
    required String nombre,
    required String telefono,
    int? edad,
    String? sexo,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    _nombre = nombre.trim();
    _telefono = telefono.trim();
    _edad = edad;
    _sexo = sexo;

    await prefs.setString(_keyNombre, _nombre!);
    await prefs.setString(_keyTelefono, _telefono!);

    if (_edad != null) {
      await prefs.setInt(_keyEdad, _edad!);
    } else {
      await prefs.remove(_keyEdad);
    }

    if (_sexo != null && _sexo!.trim().isNotEmpty) {
      await prefs.setString(_keySexo, _sexo!);
    } else {
      await prefs.remove(_keySexo);
    }
  }

  // ---------------------------------------------------------
  // REGISTRO PROFESIONAL (NUEVO SISTEMA ÚNICO)
  // ---------------------------------------------------------
  Future<void> setDatosProfesional({
    required String tipo,
    required String colegiado,
    required String archivoBase64,
    required String archivoPath,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    _tipo = "profesional";
    _tipoProfesional = tipo;
    _numeroColegiado = colegiado.trim();
    _archivoBase64 = archivoBase64;
    _archivoPath = archivoPath;

    // Siempre inicia como pendiente
    _estadoVerificacion = "pending";

    await prefs.setString(_keyTipo, _tipo);
    await prefs.setString(_keyProfTipo, _tipoProfesional!);
    await prefs.setString(_keyProfColegiado, _numeroColegiado!);
    await prefs.setString(_keyProfArchivoBase64, _archivoBase64!);
    await prefs.setString(_keyProfArchivoPath, _archivoPath!);
    await prefs.setString(_keyEstadoVerificacion, _estadoVerificacion);
  }

  // ---------------------------------------------------------
  // Actualizar estado profesional (para ADMINS)
  // ---------------------------------------------------------
  Future<void> marcarVerificado() async {
    final prefs = await SharedPreferences.getInstance();
    _estadoVerificacion = "verified";
    await prefs.setString(_keyEstadoVerificacion, "verified");
  }

  Future<void> marcarRechazado() async {
    final prefs = await SharedPreferences.getInstance();
    _estadoVerificacion = "rejected";
    await prefs.setString(_keyEstadoVerificacion, "rejected");
  }
}
