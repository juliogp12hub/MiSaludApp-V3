import 'package:flutter/material.dart';
import '../data/repositories/agenda_repository.dart';
import '../data/datasources/agenda_local_datasource.dart';
import '../core/models/professional.dart';
import '../services/notification_service.dart';
import '../widgets/custom_calendar_widget.dart';

class DoctorAgendaPage extends StatefulWidget {
  final Professional professional;

  const DoctorAgendaPage({required this.professional, super.key});

  @override
  State<DoctorAgendaPage> createState() => _DoctorAgendaPageState();
}

class _DoctorAgendaPageState extends State<DoctorAgendaPage> {
  final AgendaRepository _repo = AgendaRepository();
  final NotificationService _notificationService = NotificationService();

  DateTime _focusedDate = DateTime.now();
  DateTime _fechaSeleccionada = DateTime.now();
  DateTime? _slotSeleccionado;

  bool _isLoadingSlots = false;
  bool _isLoadingCalendar = false;
  List<AgendaSlot> _slotsDisponibles = [];
  Map<DateTime, DayStatus> _monthAvailability = {};

  // To show occupied slots as well? generatingSlots currently returns ONLY available ones.
  // We need to fetch appointments for the day to show "Occupied" or "Blocked" slots too.
  // But for "Manual Blocking", we primarily need empty slots to block them.
  // And maybe see occupied slots to "Unblock" if it was a manual block.

  @override
  void initState() {
    super.initState();
    _repo.init();
    _cargarDisponibilidadMensual(_focusedDate);
    _cargarSlots(_fechaSeleccionada);
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
        _slotSeleccionado = null;
    });

    // For doctor view, we ideally want ALL slots (free + occupied).
    // But generatingSlots filters occupied ones.
    // Ideally we should modify repo to get "All Slots with Status".
    // For now, let's just show available slots to BLOCK.
    // And maybe a list of "Occupied" slots below?

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
      }
    }
  }

  void _onSlotTap(DateTime inicio) {
     showDialog(
       context: context,
       builder: (_) => AlertDialog(
         title: const Text("Gestionar Horario"),
         content: Text("Slot: ${inicio.hour}:${inicio.minute.toString().padLeft(2, '0')}"),
         actions: [
           TextButton(
             child: const Text("Cancelar"),
             onPressed: () => Navigator.pop(context),
           ),
           ElevatedButton(
             style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
             child: const Text("Bloquear Hora"),
             onPressed: () async {
                Navigator.pop(context);
                await _bloquearSlot(inicio);
             },
           ),
           ElevatedButton(
             child: const Text("Invitar Paciente"),
             onPressed: () async {
                Navigator.pop(context);
                await _invitarPaciente(inicio);
             },
           ),
         ],
       )
     );
  }

  Future<void> _bloquearSlot(DateTime inicio) async {
     // Default duration 30 min or from config.
     // We should load config but for now assume 30.
     await _repo.bloquearSlot(
       professional: widget.professional,
       fechaHora: inicio,
       duracion: const Duration(minutes: 30),
     );
     _refresh();
     if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hora bloqueada.")));
  }

  Future<void> _invitarPaciente(DateTime inicio) async {
     // Mock Invitation
     await _repo.agendarCita(
       professional: widget.professional,
       fechaHora: inicio,
       duracion: const Duration(minutes: 30),
       status: "pending_invite",
       patientId: "pending_patient",
     );
     _refresh();
     if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invitación enviada (simulada).")));
  }

  void _refresh() {
     _cargarSlots(_fechaSeleccionada);
     _cargarDisponibilidadMensual(_focusedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mi Agenda (Médico)")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
             CustomCalendarWidget(
                initialDate: _fechaSeleccionada,
                onDateSelected: (d) {
                   setState(() => _fechaSeleccionada = d);
                   _cargarSlots(d);
                },
                onMonthChanged: (m) {
                   setState(() => _focusedDate = m);
                   _cargarDisponibilidadMensual(m);
                },
                availability: _monthAvailability,
                isLoading: _isLoadingCalendar,
             ),
             const Divider(height: 32),
             const Text("Horarios Disponibles para Bloquear/Invitar", style: TextStyle(fontWeight: FontWeight.bold)),
             const SizedBox(height: 10),

             if (_isLoadingSlots)
               const CircularProgressIndicator()
             else if (_slotsDisponibles.isEmpty)
               const Text("No hay horarios libres hoy.")
             else
               Wrap(
                 spacing: 10,
                 runSpacing: 10,
                 children: _slotsDisponibles.map((slot) {
                    final txt = "${slot.inicio.hour.toString().padLeft(2, '0')}:${slot.inicio.minute.toString().padLeft(2, '0')}";
                    return ActionChip(
                      label: Text(txt),
                      onPressed: () => _onSlotTap(slot.inicio),
                    );
                 }).toList(),
               ),

             const SizedBox(height: 20),
             const Text("Nota: Para desbloquear, ve a 'Mis Citas' (simulado) o gestión avanzada.", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
