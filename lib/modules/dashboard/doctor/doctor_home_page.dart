import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';

class DoctorHomePage extends ConsumerWidget {
  const DoctorHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 3.2.1 Header Profesional
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
                    child: user?.photoUrl == null ? const Icon(Icons.person, size: 32) : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? "Doctor",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        // Status Toggle (Mock)
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            const Text("Online", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // Navigate to Edit Profile
                      // We need to pass a Professional object. Ideally we fetch it or construct it from User.
                      // For now, mock navigation or placeholder.
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Editar perfil en desarrollo")));
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 3.2.3 Estadísticas rápidas (Cards)
              Row(
                children: [
                  Expanded(child: _StatCard(title: "Citas Hoy", value: "8", color: Colors.blue.shade50)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(title: "Nuevos", value: "3", color: Colors.green.shade50)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(title: "Rating", value: "4.9", color: Colors.orange.shade50)),
                ],
              ),

              const SizedBox(height: 24),

              // 3.2.2 Acciones principales
              const Text("Gestión", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.calendar_today, color: Colors.teal),
                title: const Text("Agenda de Hoy"),
                subtitle: const Text("Ver pacientes programados"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const SizedBox(height: 8),
              ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.notifications_active, color: Colors.orange),
                title: const Text("Citas Pendientes"),
                subtitle: const Text("3 solicitudes de cita"),
                trailing: const CircleAvatar(radius: 12, backgroundColor: Colors.red, child: Text("3", style: TextStyle(color: Colors.white, fontSize: 12))),
                onTap: () {},
              ),

              const SizedBox(height: 24),

              // 3.2.4 Promociones pagadas
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.purple.shade700, Colors.purple.shade400]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.rocket_launch, color: Colors.white, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Impulsa tu perfil", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text("Llega a más pacientes hoy", style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.purple),
                      onPressed: () {},
                      child: const Text("Promocionar"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.color});

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
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
