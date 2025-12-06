import 'package:flutter/material.dart';
import '../../core/models/professional.dart';
import '../../data/repositories/agenda_repository.dart';

class ConfigurarAgendaMedicoPage extends StatefulWidget {
  final Professional doctor;

  const ConfigurarAgendaMedicoPage({super.key, required this.doctor});

  @override
  State<ConfigurarAgendaMedicoPage> createState() =>
      _ConfigurarAgendaMedicoPageState();
}

class _ConfigurarAgendaMedicoPageState
    extends State<ConfigurarAgendaMedicoPage> {
  final AgendaRepository _repo = AgendaRepository();

  late TextEditingController _precioPresencialController;
  late TextEditingController _precioVirtualController;

  late bool _atiendeUrgencias;
  late bool _atiendeDomicilio;

  late Set<String> _modalidadesSeleccionadas;

  // Nuevas configuraciones
  List<int> _diasLaborales = [1, 2, 3, 4, 5]; // Lun-Vie
  int _duracionCita = 30; // Minutos
  TimeOfDay _horaInicio = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _horaFin = const TimeOfDay(hour: 17, minute: 0);

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final d = widget.doctor;

    _precioPresencialController = TextEditingController(
      text: d.price.toStringAsFixed(0),
    );
    _precioVirtualController = TextEditingController(
      text: d.virtualPrice?.toStringAsFixed(0) ?? "",
    );

    _atiendeUrgencias = d.acceptsEmergencies;
    _atiendeDomicilio = d.acceptsHomeVisits;

    _modalidadesSeleccionadas = d.modalities.toSet();

    _cargarConfiguracionExtra();
  }

  Future<void> _cargarConfiguracionExtra() async {
    await _repo.init();
    final config = await _repo.cargarConfigMedico(widget.doctor.id);

    if (mounted) {
      setState(() {
        if (config['diasLaborales'] != null) {
          _diasLaborales = List<int>.from(config['diasLaborales']);
        }
        if (config['duracion'] != null) {
          _duracionCita = config['duracion'];
        }
        if (config['inicio'] != null) {
          final parts = (config['inicio'] as String).split(':');
          _horaInicio = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
        if (config['fin'] != null) {
          final parts = (config['fin'] as String).split(':');
          _horaFin = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _precioPresencialController.dispose();
    _precioVirtualController.dispose();
    super.dispose();
  }

  void _guardar() async {
    final d = widget.doctor;

    double precioPresencial = d.price;
    double? precioVirtual = d.virtualPrice;

    final p = double.tryParse(_precioPresencialController.text.trim());
    if (p != null && p > 0) precioPresencial = p;

    final pv = double.tryParse(_precioVirtualController.text.trim());
    if (pv != null && pv > 0) {
      precioVirtual = pv;
    } else {
      precioVirtual = null;
    }

    final modalidades = _modalidadesSeleccionadas.toList();

    // Guardar configuracion avanzada en repositorio
    final configMap = {
      "inicio": "${_horaInicio.hour.toString().padLeft(2, '0')}:${_horaInicio.minute.toString().padLeft(2, '0')}",
      "fin": "${_horaFin.hour.toString().padLeft(2, '0')}:${_horaFin.minute.toString().padLeft(2, '0')}",
      "duracion": _duracionCita,
      "diasLaborales": _diasLaborales,
    };

    await _repo.guardarConfigMedico(d.id, configMap);

    // Retornar Professional actualizado (aunque la agenda real depende de repo ahora)
    final actualizado = d.copyWith(
      price: precioPresencial,
      virtualPrice: precioVirtual,
      acceptsEmergencies: _atiendeUrgencias,
      acceptsHomeVisits: _atiendeDomicilio,
      modalities: modalidades,
      // 'schedules' ya no se usa tanto como antes, pero lo mantenemos por compatibilidad si es necesario
    );

    if (!mounted) return;
    Navigator.pop(context, actualizado);
  }

  Future<void> _seleccionarHora(bool esInicio) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: esInicio ? _horaInicio : _horaFin,
    );
    if (picked != null) {
      setState(() {
        if (esInicio) {
          _horaInicio = picked;
        } else {
          _horaFin = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final d = widget.doctor;

    return Scaffold(
      appBar: AppBar(title: const Text("Configurar agenda")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _headerDoctor(d),
          const SizedBox(height: 20),
          _cardModalidades(),
          const SizedBox(height: 16),
          _cardConfigAgenda(), // Nuevo card de configuración detallada
          const SizedBox(height: 16),
          _cardPrecios(),
          const SizedBox(height: 16),
          _cardExtras(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text(
                "Guardar configuración",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: _guardar,
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerDoctor(Professional d) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blue.shade100,
          backgroundImage: d.photoUrl != null ? NetworkImage(d.photoUrl!) : null,
          child: d.photoUrl == null
              ? const Icon(Icons.person, size: 32, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                d.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                d.specialty,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cardModalidades() {
    return _card(
      title: "Modalidades de atención",
      child: Wrap(
        spacing: 10,
        children: [
          ChoiceChip(
            label: const Text("Presencial"),
            selected: _modalidadesSeleccionadas.contains("presencial"),
            onSelected: (sel) {
              setState(() {
                if (sel) {
                  _modalidadesSeleccionadas.add("presencial");
                } else {
                  _modalidadesSeleccionadas.remove("presencial");
                }
              });
            },
          ),
          ChoiceChip(
            label: const Text("Virtual"),
            selected: _modalidadesSeleccionadas.contains("virtual"),
            onSelected: (sel) {
              setState(() {
                if (sel) {
                  _modalidadesSeleccionadas.add("virtual");
                } else {
                  _modalidadesSeleccionadas.remove("virtual");
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _cardConfigAgenda() {
    // Map de días para mostrar texto
    final mapDias = {1: "Lun", 2: "Mar", 3: "Mié", 4: "Jue", 5: "Vie", 6: "Sáb", 7: "Dom"};

    return _card(
      title: "Configuración de Horario",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Días Laborales
          const Text("Días laborales:", style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: mapDias.entries.map((entry) {
              final dia = entry.key;
              final texto = entry.value;
              final isSelected = _diasLaborales.contains(dia);
              return FilterChip(
                label: Text(texto),
                selected: isSelected,
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _diasLaborales.add(dia);
                    } else {
                      _diasLaborales.remove(dia);
                    }
                    _diasLaborales.sort();
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Hora Inicio y Fin
          Row(
            children: [
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Hora Inicio"),
                  subtitle: Text("${_horaInicio.format(context)}"),
                  onTap: () => _seleccionarHora(true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Hora Fin"),
                  subtitle: Text("${_horaFin.format(context)}"),
                  onTap: () => _seleccionarHora(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Duración Cita
          const Text("Duración de la cita:", style: TextStyle(fontWeight: FontWeight.w600)),
          DropdownButton<int>(
            value: _duracionCita,
            isExpanded: true,
            items: [15, 30, 45, 60, 90, 120].map((min) {
              return DropdownMenuItem(
                value: min,
                child: Text("$min minutos"),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _duracionCita = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _cardPrecios() {
    return _card(
      title: "Precios de consulta",
      child: Column(
        children: [
          TextField(
            controller: _precioPresencialController,
            decoration: const InputDecoration(
              labelText: "Precio Consulta Presencial",
              prefixText: "Q",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _precioVirtualController,
            decoration: const InputDecoration(
              labelText: "Precio Consulta Virtual",
              prefixText: "Q",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _cardExtras() {
    return _card(
      title: "Extras",
      child: Column(
        children: [
          SwitchListTile(
            title: const Text("Atiendo urgencias"),
            value: _atiendeUrgencias,
            onChanged: (v) => setState(() => _atiendeUrgencias = v),
          ),
          SwitchListTile(
            title: const Text("Atiendo a domicilio"),
            value: _atiendeDomicilio,
            onChanged: (v) => setState(() => _atiendeDomicilio = v),
          ),
        ],
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
