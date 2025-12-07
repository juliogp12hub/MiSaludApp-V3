import 'package:flutter/material.dart';
import '../../data/repositories/agenda_repository.dart';
import '../../data/datasources/agenda_local_datasource.dart';
import '../../core/models/professional.dart';
import '../../services/notification_service.dart';
import '../../widgets/custom_calendar_widget.dart';

class AgendaPacientePage extends StatefulWidget {
  final Professional professional;

  const AgendaPacientePage({required this.professional, super.key});

  @override
  State<AgendaPacientePage> createState() => _AgendaPacientePageState();
}

class _AgendaPacientePageState extends State<AgendaPacientePage> {
  final AgendaRepository _repo = AgendaRepository();
  final NotificationService _notificationService = NotificationService();

  DateTime _focusedDate = DateTime.now();
  DateTime? _fechaSeleccionada;
  String? _modalidadSeleccionada;
  DateTime? _slotSeleccionado;

  bool _isSaving = false;
  bool _isLoadingSlots = false;
  bool _isLoadingCalendar = false;
  List<AgendaSlot> _slotsDisponibles = [];
  Map<DateTime, DayStatus> _monthAvailability = {};
  Map<String, dynamic>? _doctorConfig;

  @override
  void initState() {
    super.initState();
    _repo.init();
    _cargarConfiguracion();
    _cargarDisponibilidadMensual(_focusedDate);
    // Select today initially
    _fechaSeleccionada = DateTime(_focusedDate.year, _focusedDate.month, _focusedDate.day);
    _cargarSlots(_fechaSeleccionada!);
  }

  Future<void> _cargarConfiguracion() async {
    final config = await _repo.cargarConfigMedico(widget.professional.id);
    if (mounted) {
      setState(() {
        _doctorConfig = config;
      });
    }
  }

  Future<void> _cargarDisponibilidadMensual(DateTime month) async {
      setState(() => _isLoadingCalendar = true);
      final availability = await _repo.getAvailabilityForMonth(
          doctorId: widget.professional.id,
          month: month
      );
      if (mounted) {
          setState(() {
              _monthAvailability = availability;
              _isLoadingCalendar = false;
          });
      }
  }

  Future<void> _cargarSlots(DateTime fecha) async {
    setState(() {
        _isLoadingSlots = true;
        _slotSeleccionado = null; // Reset selection
    });

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
        // Sencilla feedback si falla
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

      await _notificationService.sendAppointmentConfirmation(cita);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cita agendada con éxito.")),
      );

      // Update availability since we just booked a slot
      _cargarSlots(_fechaSeleccionada!);
      _cargarDisponibilidadMensual(_focusedDate);

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

            // Calendario
            const Text(
              "Selecciona una fecha",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12)
                ),
                padding: const EdgeInsets.all(8),
                child: CustomCalendarWidget(
                    initialDate: _fechaSeleccionada ?? DateTime.now(),
                    availability: _monthAvailability,
                    isLoading: _isLoadingCalendar,
                    onDateSelected: (date) {
                        setState(() => _fechaSeleccionada = date);
                        _cargarSlots(date);
                    },
                    onMonthChanged: (month) {
                        setState(() => _focusedDate = month);
                        _cargarDisponibilidadMensual(month);
                    },
                ),
            ),

            const SizedBox(height: 24),

            // Horarios (Grid dinámico)
            Row(
              children: [
                const Text(
                  "Horarios Disponibles",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                if (_isLoadingSlots) ...[
                   const SizedBox(width: 12),
                   const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                ]
              ],
            ),
            const SizedBox(height: 8),

            if (_fechaSeleccionada == null)
              const Text("Selecciona un día en el calendario.", style: TextStyle(color: Colors.grey))
            else if (!_isLoadingSlots && _slotsDisponibles.isEmpty)
              Container(
                 padding: const EdgeInsets.all(16),
                 width: double.infinity,
                 decoration: BoxDecoration(
                   color: Colors.grey[100],
                   borderRadius: BorderRadius.circular(8)
                 ),
                 child: const Text("No hay horarios disponibles para esta fecha.", textAlign: TextAlign.center),
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
                onPressed: (_isSaving || _slotSeleccionado == null) ? null : _confirmarCita,
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
