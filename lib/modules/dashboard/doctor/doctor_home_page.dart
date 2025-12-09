import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../../../panel_medico/configurar_agenda_medico_page.dart';
import '../../../core/models/professional.dart';
import '../../newsletter/create_promotion_page.dart';

class DoctorHomePage extends ConsumerWidget {
  const DoctorHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    // Construct mock professional
    final professionalMock = Professional(
      id: user?.id ?? "d1",
      name: user?.name ?? "Doctor",
      specialty: "General",
      city: "Guatemala",
      rating: 5.0,
      price: 200,
      isPremium: user?.isPremium ?? false,
    );

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
              const Text("Accesos Rápidos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.edit_calendar,
                      color: Colors.blue,
                      title: "Configurar\nAgenda",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ConfigurarAgendaMedicoPage(doctor: professionalMock),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.campaign,
                      color: Colors.purple,
                      title: "Crear\nNoticia",
                      onTap: () {
                        if (user?.isPremium == true) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CreatePromotionPage()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Función exclusiva para Premium")));
                        }
                      },
                    ),
                  ),
                ],
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

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({required this.icon, required this.title, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
