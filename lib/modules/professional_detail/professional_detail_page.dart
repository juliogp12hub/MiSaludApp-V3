import 'package:flutter/material.dart';
import 'professional_detail_data.dart';
import '../agenda/agenda_universal_page.dart';

class ProfessionalDetailPage extends StatelessWidget {
  final ProfessionalDetailData data;

  const ProfessionalDetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(data.nombre)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _header(),
          const SizedBox(height: 20),

          if (data.acercaDe != null)
            _section(title: "Acerca de", child: Text(data.acercaDe!)),

          if (data.servicios != null)
            _section(
              title: "Servicios",
              child: Wrap(
                spacing: 6,
                children: data.servicios!
                    .map((s) => Chip(label: Text(s)))
                    .toList(),
              ),
            ),

          if (data.pacientes != null)
            _section(
              title: "Pacientes",
              child: Wrap(
                spacing: 6,
                children: data.pacientes!
                    .map((s) => Chip(label: Text(s)))
                    .toList(),
              ),
            ),

          if (data.hospitales != null)
            _section(
              title: "Centros donde atiende",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: data.hospitales!.map((h) => Text("• $h")).toList(),
              ),
            ),

          if (data.idiomas != null)
            _section(title: "Idiomas", child: Text(data.idiomas!.join(", "))),

          if (data.precioPresencial != null || data.precioVirtual != null)
            _section(
              title: "Precios",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (data.precioPresencial != null)
                    Text(
                      "Consulta presencial: Q${data.precioPresencial!.toStringAsFixed(2)}",
                    ),
                  if (data.precioVirtual != null)
                    Text(
                      "Consulta virtual: Q${data.precioVirtual!.toStringAsFixed(2)}",
                    ),
                ],
              ),
            ),

           // Extra padding for FAB
           const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AgendaUniversalPage(
                    data: data,
                  ),
                ),
              );
            },
            child: const Text("Agendar Cita", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        CircleAvatar(radius: 42, backgroundImage: data.avatarUrl.isNotEmpty ? NetworkImage(data.avatarUrl) : null, child: data.avatarUrl.isEmpty ? Text(data.nombre[0]) : null),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.nombre,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                data.tipo,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              Text(data.ciudad),
              const SizedBox(height: 8),
              if (data.calificacion != null)
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    Text(
                      "${data.calificacion} (${data.numeroOpiniones ?? 0} opiniones)",
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _section({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        child,
        const SizedBox(height: 20),
      ],
    );
  }
}
