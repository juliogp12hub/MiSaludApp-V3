import 'package:flutter/material.dart';
import '../../core/models/professional.dart';
// import 'package:misaludapp_v2/services/doctor/doctor_settings_repository.dart'; // Legacy
// import '../../models/doctor/doctor_settings.dart'; // Legacy

class ConfigurarAgendaMedicoPage extends StatefulWidget {
  final Professional doctor;

  const ConfigurarAgendaMedicoPage({super.key, required this.doctor});

  @override
  State<ConfigurarAgendaMedicoPage> createState() =>
      _ConfigurarAgendaMedicoPageState();
}

class _ConfigurarAgendaMedicoPageState
    extends State<ConfigurarAgendaMedicoPage> {
  late TextEditingController _precioPresencialController;
  late TextEditingController _precioVirtualController;

  late bool _atiendeUrgencias;
  late bool _atiendeDomicilio;

  late bool _matutino;
  late bool _vespertino;
  late bool _nocturno;

  late Set<String> _modalidadesSeleccionadas;

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

    _matutino = d.schedules.contains("matutino");
    _vespertino = d.schedules.contains("vespertino");
    _nocturno = d.schedules.contains("nocturno");

    _modalidadesSeleccionadas = d.modalities.toSet();
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

    final horarios = <String>[];
    if (_matutino) horarios.add("matutino");
    if (_vespertino) horarios.add("vespertino");
    if (_nocturno) horarios.add("nocturno");

    final modalidades = _modalidadesSeleccionadas.toList();

    // Guardar logic would go here, updating repository
    // final settingsRepo = ProfessionalSettingsRepository();
    // await settingsRepo.guardarSettings(settings);

    // Crear un Professional actualizado para retornar
    final actualizado = d.copyWith(
      price: precioPresencial,
      virtualPrice: precioVirtual,
      acceptsEmergencies: _atiendeUrgencias,
      acceptsHomeVisits: _atiendeDomicilio,
      schedules: horarios,
      modalities: modalidades,
    );

    Navigator.pop(context, actualizado);
  }

  @override
  Widget build(BuildContext context) {
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
          _cardHorarios(),
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

  Widget _cardHorarios() {
    return _card(
      title: "Horarios de atención",
      child: Column(
        children: [
          SwitchListTile(
            title: const Text("Matutino (08:00 - 12:00)"),
            value: _matutino,
            onChanged: (v) => setState(() => _matutino = v),
          ),
          SwitchListTile(
            title: const Text("Vespertino (14:00 - 18:00)"),
            value: _vespertino,
            onChanged: (v) => setState(() => _vespertino = v),
          ),
          SwitchListTile(
            title: const Text("Nocturno (18:00 - 21:00)"),
            value: _nocturno,
            onChanged: (v) => setState(() => _nocturno = v),
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
