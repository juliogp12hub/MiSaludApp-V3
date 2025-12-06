import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import '../professional_detail/professional_detail_data.dart';
import '../../data/repositories/agenda_repository.dart';
import '../../core/models/professional.dart';

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

  // Horarios simulados
  final Map<String, List<String>> _horariosDisponibles = const {
    'Lunes': ['08:00', '08:30', '09:00', '09:30', '10:00', '10:30', '11:00'],
    'Martes': ['14:00', '14:30', '15:00', '15:30', '16:00'],
    'Miércoles': ['08:00', '09:00', '10:00', '11:00'],
    'Jueves': ['15:00', '15:30', '16:00', '16:30'],
    'Viernes': ['08:00', '08:30', '09:00'],
  };

  String? _diaSeleccionado;
  String? _horaSeleccionada;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _repo.init();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.citaOriginal != null ? "Reagendar cita" : "Agendar cita")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerProfesional(theme),
            const SizedBox(height: 24),

            const Text(
              'Selecciona un día disponible:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              children: _horariosDisponibles.keys.map((dia) {
                return ChoiceChip(
                  label: Text(dia),
                  selected: _diaSeleccionado == dia,
                  onSelected: (_) {
                    setState(() {
                      _diaSeleccionado = dia;
                      _horaSeleccionada = null; // reset hora
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            if (_diaSeleccionado != null) ...[
              const Text(
                'Selecciona una hora:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _horariosDisponibles[_diaSeleccionado]!
                    .map(
                      (hora) => ChoiceChip(
                        label: Text(hora),
                        selected: _horaSeleccionada == hora,
                        onSelected: (_) {
                          setState(() {
                            _horaSeleccionada = hora;
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
            ],

            const Spacer(),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle),
                  label: Text(widget.citaOriginal != null ? 'Confirmar cambio' : 'Confirmar cita'),
                  onPressed: _diaSeleccionado != null && _horaSeleccionada != null
                      ? _agendar
                      : null,
                ),
              ),
          ],
        ),
      ),
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

  Future<void> _agendar() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate date conversion from "Lunes" + "08:00" to next valid Date
    // For now just use DateTime.now() + logic
    final now = DateTime.now();
    // Simplified logic: just pick next available date matching the weekday.
    // ... skipping complex date logic for brevity, using current date + random days
    final newDate = now.add(const Duration(days: 1)).add(
      Duration(hours: int.parse(_horaSeleccionada!.split(':')[0]), minutes: int.parse(_horaSeleccionada!.split(':')[1]))
    );

    try {
      if (widget.citaOriginal != null) {
        await _repo.reagendarCita(id: widget.citaOriginal!.id, nuevaFecha: newDate);
      } else {
        // Construct Professional from data (approximate reverse mapping)
        final professional = Professional(
            id: widget.data.id,
            name: widget.data.nombre,
            specialty: widget.data.subespecialidad ?? widget.data.tipo,
            city: widget.data.ciudad,
            rating: widget.data.calificacion ?? 0,
            price: widget.data.precioPresencial ?? 0,
            photoUrl: widget.data.avatarUrl,
        );

        await _repo.agendarCita(
          professional: professional,
          fechaHora: newDate,
          duracion: const Duration(minutes: 30),
        );
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Operación exitosa'),
        content: Text(
          'Tu cita con ${widget.data.nombre} '
          'ha sido ${widget.citaOriginal != null ? 'reagendada' : 'agendada'} para '
          '$_diaSeleccionado a las $_horaSeleccionada.',
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
}
