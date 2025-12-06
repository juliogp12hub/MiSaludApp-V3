import 'package:flutter/material.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 3.3.1 Control del sistema
            const Text("Control del Sistema", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _InfoCard(title: "Pacientes", value: "1,204", color: Colors.blue.shade100)),
                const SizedBox(width: 8),
                Expanded(child: _InfoCard(title: "Doctores", value: "342", color: Colors.green.shade100)),
                const SizedBox(width: 8),
                Expanded(child: _InfoCard(title: "Citas Hoy", value: "89", color: Colors.orange.shade100)),
              ],
            ),
            const SizedBox(height: 24),

            // 3.3.2 Gestión Rápida
            const Text("Gestión Rápida", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.verified_user,
              color: Colors.teal,
              title: "Aprobar Perfiles",
              subtitle: "5 doctores esperando verificación",
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _ActionTile(
              icon: Icons.block,
              color: Colors.red,
              title: "Suspender Cuentas",
              subtitle: "Reportes de usuario recientes",
              onTap: () {},
            ),
             const SizedBox(height: 8),
            _ActionTile(
              icon: Icons.campaign,
              color: Colors.purple,
              title: "Gestionar Promociones",
              subtitle: "Ver activas y pendientes",
              onTap: () {},
            ),

            const SizedBox(height: 24),

            // 3.3.3 Estadísticas Globales
            const Text("Métricas Globales", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              height: 150,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text("Gráfico de afluencia semanal (Placeholder)", style: TextStyle(color: Colors.grey))),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _InfoCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({required this.icon, required this.color, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
