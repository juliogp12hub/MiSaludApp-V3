import 'package:flutter/material.dart';
import '../../core/models/professional.dart';
import 'buscador_generic_page.dart';

class DashboardBuscarPage extends StatelessWidget {
  const DashboardBuscarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_DashboardItem>[
      _DashboardItem(
        title: "Doctores",
        icon: Icons.medical_information,
        color: Colors.blue,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const BuscadorGenericPage(
                type: ProfessionalType.doctor,
                title: 'Buscar Doctores',
              ),
            ),
          );
        },
      ),
      _DashboardItem(
        title: "Dentistas",
        icon: Icons.health_and_safety,
        color: Colors.teal,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const BuscadorGenericPage(
                type: ProfessionalType.dentist,
                title: 'Buscar Dentistas',
              ),
            ),
          );
        },
      ),
      _DashboardItem(
        title: "Psicólogos",
        icon: Icons.psychology,
        color: Colors.deepPurple,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const BuscadorGenericPage(
                type: ProfessionalType.psychologist,
                title: 'Buscar Psicólogos',
              ),
            ),
          );
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Buscar servicios de salud")),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 4 / 3,
        ),
        itemBuilder: (context, index) {
          return _DashboardCard(item: items[index]);
        },
      ),
    );
  }
}

class _DashboardItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _DashboardItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _DashboardCard extends StatelessWidget {
  final _DashboardItem item;

  const _DashboardCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: item.onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, size: 48, color: item.color),
              const SizedBox(height: 12),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
