import 'package:flutter/material.dart';
import '../../data/repositories/agenda_repository.dart';
import '../../data/datasources/agenda_local_datasource.dart';
import '../../core/models/professional.dart';
import '../../services/notification_service.dart';

class AgendaPacientePage extends StatefulWidget {
  final Professional professional;

  const AgendaPacientePage({required this.professional, super.key});

  @override
  State<AgendaPacientePage> createState() => _AgendaPacientePageState();
}

class _AgendaPacientePageState extends State<AgendaPacientePage> {
  final AgendaRepository _repo = AgendaRepository();
  final NotificationService _notificationService = NotificationService();

  DateTime? _fechaSeleccionada;
  String? _modalidadSeleccionada;
  DateTime? _slotSeleccionado; // Inicio del slot seleccionado

  bool _isSaving = false;
  bool _isLoadingSlots = false;
  List<AgendaSlot> _slotsDisponibles = [];
  Map<String, dynamic>? _doctorConfig;

  @override
  void initState() {
    super.initState();
    _repo.init();
    _cargarConfiguracion();
  }

  Future<void> _cargarConfiguracion() async {
    final config = await _repo.cargarConfigMedico(widget.professional.id);
    if (mounted) {
      setState(() {
        _doctorConfig = config;
      });
    }
  }

  Future<void> _seleccionarFecha() async {
    final hoy = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? hoy,
      firstDate: hoy,
      lastDate: hoy.add(const Duration(days: 30)),
    );

    if (picked != null) {
      setState(() {
        _fechaSeleccionada = picked;
        _slotSeleccionado = null; // Reset slot al cambiar fecha
        _isLoadingSlots = true;
      });
      _cargarSlots(picked);
    }
  }

  Future<void> _cargarSlots(DateTime fecha) async {
    try {
      final slots = await _repo.generarSlots(
        doctorId: widget.professional.id,
        fecha: fecha,
      );
      if (mounted) {
        setState(() {
          _slotsDisponibles = slots;
          _isLoadingSlots = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _slotsDisponibles = [];
          _isLoadingSlots = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error cargando horarios: $e")),
        );
      }
    }
  }

  Future<void> _confirmarCita() async {
    if (_modalidadSeleccionada == null ||
        _fechaSeleccionada == null ||
        _slotSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos.")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final duracion = Duration(minutes: _doctorConfig?['duracion'] ?? 30);

      final cita = await _repo.agendarCita(
        professional: widget.professional,
        fechaHora: _slotSeleccionado!,
        duracion: duracion,
      );

      // Enviar notificaciones (Mock)
      await _notificationService.sendAppointmentConfirmation(cita);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cita agendada con éxito.")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al agendar: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.professional;

    final fechaText = _fechaSeleccionada == null
        ? "Selecciona una fecha"
        : "${_fechaSeleccionada!.day.toString().padLeft(2, '0')}/"
              "${_fechaSeleccionada!.month.toString().padLeft(2, '0')}/"
              "${_fechaSeleccionada!.year}";

    return Scaffold(
      appBar: AppBar(title: const Text("Agendar cita")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del profesional
            Text(
              d.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "${d.specialty} • ${d.city}",
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),

            // Modalidad
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
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today, color: Colors.blue),
              title: Text(fechaText),
              onTap: _seleccionarFecha,
            ),

            const SizedBox(height: 24),

            // Horarios (Grid dinámico)
            const Text(
              "Horarios Disponibles",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (_fechaSeleccionada == null)
              const Text("Por favor selecciona una fecha primero.", style: TextStyle(color: Colors.grey))
            else if (_isLoadingSlots)
              const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ))
            else if (_slotsDisponibles.isEmpty)
              Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: Colors.grey[100],
                   borderRadius: BorderRadius.circular(8)
                 ),
                 child: const Text("No hay horarios disponibles para esta fecha. Intenta otro día."),
              )
            else
              _buildSlotsGrid(),

            const SizedBox(height: 40),

            // Botón Confirmar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
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
                label: Text(
                  _isSaving ? "Guardando..." : "Confirmar cita",
                  style: const TextStyle(fontSize: 18),
                ),
                onPressed: _isSaving ? null : _confirmarCita,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotsGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _slotsDisponibles.map((slot) {
        final isSelected = _slotSeleccionado == slot.inicio;

        // Formato HH:mm
        final hourStr = "${slot.inicio.hour.toString().padLeft(2, '0')}:${slot.inicio.minute.toString().padLeft(2, '0')}";

        return ChoiceChip(
          label: Text(hourStr),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _slotSeleccionado = selected ? slot.inicio : null;
            });
          },
          selectedColor: Colors.blue,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
}
