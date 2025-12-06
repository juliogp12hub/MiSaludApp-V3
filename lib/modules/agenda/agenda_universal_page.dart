import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import '../professional_detail/professional_detail_data.dart';
import '../../data/repositories/agenda_repository.dart';
import '../../data/datasources/agenda_local_datasource.dart';
import '../../core/models/professional.dart';
import '../../services/notification_service.dart';

class AgendaUniversalPage extends StatefulWidget {
  final ProfessionalDetailData data;
  final Appointment? citaOriginal;

  const AgendaUniversalPage({
    super.key,
    required this.data,
    this.citaOriginal,
  });

  @override
  State<AgendaUniversalPage> createState() => _AgendaUniversalPageState();
}

class _AgendaUniversalPageState extends State<AgendaUniversalPage> {
  final AgendaRepository _repo = AgendaRepository();
  final NotificationService _notificationService = NotificationService();

  DateTime? _fechaSeleccionada;
  DateTime? _slotSeleccionado;

  bool _isLoading = false;
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
    final config = await _repo.cargarConfigMedico(widget.data.id);
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
        _slotSeleccionado = null;
        _isLoadingSlots = true;
      });
      _cargarSlots(picked);
    }
  }

  Future<void> _cargarSlots(DateTime fecha) async {
    try {
      final slots = await _repo.generarSlots(
        doctorId: widget.data.id,
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _agendar() async {
    if (_fechaSeleccionada == null || _slotSeleccionado == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final duracion = Duration(minutes: _doctorConfig?['duracion'] ?? 30);
      final nuevaFecha = _slotSeleccionado!;

      if (widget.citaOriginal != null) {
        // Reagendar
        await _repo.reagendarCita(id: widget.citaOriginal!.id, nuevaFecha: nuevaFecha);

        // Notificar reagendamiento
        final nuevaCita = widget.citaOriginal!.copyWith(dateTime: nuevaFecha);
        await _notificationService.sendAppointmentReschedule(widget.citaOriginal!, nuevaCita);
      } else {
        // Nueva cita
        final professional = Professional(
          id: widget.data.id,
          name: widget.data.nombre,
          specialty: widget.data.subespecialidad ?? widget.data.tipo,
          city: widget.data.ciudad,
          rating: widget.data.calificacion ?? 0,
          price: widget.data.precioPresencial ?? 0,
          photoUrl: widget.data.avatarUrl,
        );

        final cita = await _repo.agendarCita(
          professional: professional,
          fechaHora: nuevaFecha,
          duracion: duracion,
        );

        // Notificar confirmacion
        await _notificationService.sendAppointmentConfirmation(cita);
      }

      if (mounted) {
        _mostrarDialogoConfirmacion();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _mostrarDialogoConfirmacion() {
    final horaStr = _slotSeleccionado != null
        ? "${_slotSeleccionado!.hour.toString().padLeft(2, '0')}:${_slotSeleccionado!.minute.toString().padLeft(2, '0')}"
        : "";

    final fechaStr = _fechaSeleccionada != null
        ? "${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}"
        : "";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Operación exitosa'),
        content: Text(
          'Tu cita con ${widget.data.nombre} '
          'ha sido ${widget.citaOriginal != null ? 'reagendada' : 'agendada'} para '
          'el $fechaStr a las $horaStr.',
        ),
        actions: [
          TextButton(
            child: const Text('Aceptar'),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, true); // Return to previous screen with success
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fechaText = _fechaSeleccionada == null
        ? "Selecciona una fecha"
        : "${_fechaSeleccionada!.day.toString().padLeft(2, '0')}/"
              "${_fechaSeleccionada!.month.toString().padLeft(2, '0')}/"
              "${_fechaSeleccionada!.year}";

    return Scaffold(
      appBar: AppBar(title: Text(widget.citaOriginal != null ? "Reagendar cita" : "Agendar cita")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerProfesional(theme),
            const SizedBox(height: 24),

            // Selector Fecha
            const Text(
              'Selecciona un día:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today, color: Colors.blue),
              title: Text(fechaText),
              onTap: _seleccionarFecha,
            ),
            const SizedBox(height: 24),

            // Selector Hora (Slots)
            const Text(
              'Horarios disponibles:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

            // Botón
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.check_circle),
                  label: Text(
                    widget.citaOriginal != null ? 'Confirmar cambio' : 'Confirmar cita',
                    style: const TextStyle(fontSize: 18),
                  ),
                  onPressed: _fechaSeleccionada != null && _slotSeleccionado != null
                      ? _agendar
                      : null,
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

  Widget _headerProfesional(ThemeData theme) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundImage: widget.data.avatarUrl.isNotEmpty ? NetworkImage(widget.data.avatarUrl) : null,
          child: widget.data.avatarUrl.isEmpty ? Text(widget.data.nombre[0]) : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.data.nombre,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.data.tipo,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
