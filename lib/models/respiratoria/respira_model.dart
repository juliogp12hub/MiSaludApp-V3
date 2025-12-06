class TerapeutaRespiratorio {
  final String id;
  final String nombre;
  final String ciudad;

  final List<String> servicios; // ej: ["Nebulización", "Oxígeno"]
  final List<String> equipos; // ej: ["Nebulizador", "CPAP"]

  final bool atiendeDomicilio;
  final bool atiendeClinica;

  final bool disponibleInmediato;

  final List<String> turnos; // ["Matutino", "Nocturno"]

  final double precioSesion;

  final List<String> tiposPacientes; // ["Pediátrico", "Adulto"]

  TerapeutaRespiratorio({
    required this.id,
    required this.nombre,
    required this.ciudad,
    required this.servicios,
    required this.equipos,
    required this.atiendeDomicilio,
    required this.atiendeClinica,
    required this.disponibleInmediato,
    required this.turnos,
    required this.precioSesion,
    required this.tiposPacientes,
  });
}
