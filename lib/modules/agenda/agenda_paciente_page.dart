import 'package:flutter/material.dart';
import '../../services/agenda_service_mock.dart';
import '../../core/models/professional.dart';

class AgendaPacientePage extends StatefulWidget {
  final Professional professional;

  const AgendaPacientePage({required this.professional, super.key});

  @override
  State<AgendaPacientePage> createState() => _AgendaPacientePageState();
}

class _AgendaPacientePageState extends State<AgendaPacientePage> {
  final AgendaServiceMock _agenda = AgendaServiceMock();

  DateTime? _fechaSeleccionada;
  String? _modalidadSeleccionada;
  TimeOfDay? _horaSeleccionada;

  bool _isSaving = false;

  // -------------------------------------------------------------
  // GENERACIÓN DE HORARIOS DISPONIBLES AUTOMÁTICOS
  // -------------------------------------------------------------
  List<TimeOfDay> _generarHorarios(Professional d) {
    final List<TimeOfDay> lista = [];

    void agregarRango(int inicio, int fin) {
      for (int h = inicio; h < fin; h++) {
        lista.add(TimeOfDay(hour: h, minute: 0));
        lista.add(TimeOfDay(hour: h, minute: 30));
      }
    }

    if (d.schedules.contains("matutino")) {
      agregarRango(8, 12);
    }
    if (d.schedules.contains("vespertino")) {
      agregarRango(14, 18);
    }
    if (d.schedules.contains("nocturno")) {
      agregarRango(18, 21);
    }

    return lista;
  }

  Future<void> _seleccionarFecha() async {
    final hoy = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: hoy,
      firstDate: hoy,
      lastDate: hoy.add(const Duration(days: 30)),
    );

    if (picked != null) {
      setState(() => _fechaSeleccionada = picked);
    }
  }

  Future<void> _seleccionarHora() async {
    if (_modalidadSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona primero la modalidad.")),
      );
      return;
    }

    if (_fechaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona primero la fecha.")),
      );
      return;
    }

    final professional = widget.professional;
    final horarios = _generarHorarios(professional);

    await showModalBottomSheet(
      context: context,
      builder: (_) {
        return SizedBox(
          height: 350,
          child: ListView.builder(
            itemCount: horarios.length,
            itemBuilder: (_, i) {
              final h = horarios[i];
              return ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(
                  "${h.hour.toString().padLeft(2, '0')}:${h.minute.toString().padLeft(2, '0')}",
                ),
                onTap: () {
                  setState(() => _horaSeleccionada = h);
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _confirmarCita() async {
    if (_modalidadSeleccionada == null ||
        _fechaSeleccionada == null ||
        _horaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos.")),
      );
      return;
    }

    final fecha = DateTime(
      _fechaSeleccionada!.year,
      _fechaSeleccionada!.month,
      _fechaSeleccionada!.day,
      _horaSeleccionada!.hour,
      _horaSeleccionada!.minute,
    );

    setState(() => _isSaving = true);

    await _agenda.agendarCita(
      doctor: widget.professional,
      fechaHora: fecha,
      duration: const Duration(minutes: 30),
    );

    setState(() => _isSaving = false);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Cita agendada con éxito.")));

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.professional;

    final fechaText = _fechaSeleccionada == null
        ? "Selecciona una fecha"
        : "${_fechaSeleccionada!.day.toString().padLeft(2, '0')}/"
              "${_fechaSeleccionada!.month.toString().padLeft(2, '0')}/"
              "${_fechaSeleccionada!.year}";

    final horaText = _horaSeleccionada == null
        ? "Selecciona una hora"
        : "${_horaSeleccionada!.hour.toString().padLeft(2, '0')}:"
              "${_horaSeleccionada!.minute.toString().padLeft(2, '0')}";

    return Scaffold(
      appBar: AppBar(title: const Text("Agendar cita")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              d.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "${d.specialty} • ${d.city}",
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),

            // Modalidad (presencial/virtual)
            const Text(
              "Modalidad",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: d.modalities.map((m) {
                return ChoiceChip(
                  label: Text(
                    m == "presencial"
                        ? "Presencial (Q${d.price.toStringAsFixed(0)})"
                        : "Virtual (Q${d.virtualPrice?.toStringAsFixed(0) ?? "—"})",
                  ),
                  selected: _modalidadSeleccionada == m,
                  onSelected: (_) {
                    setState(() => _modalidadSeleccionada = m);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Fecha
            const Text(
              "Fecha",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(fechaText),
              onTap: _seleccionarFecha,
            ),

            // Hora
            const Text(
              "Hora",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(horaText),
              onTap: _seleccionarHora,
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(_isSaving ? "Guardando..." : "Confirmar cita"),
                onPressed: _isSaving ? null : _confirmarCita,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
