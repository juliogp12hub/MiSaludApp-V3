import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../../agenda/mis_citas_page.dart';
import '../../buscador/dashboard_buscar_page.dart';
import '../../favoritos/favoritos_page.dart';
// Reusing news component for now

class PatientHomePage extends ConsumerWidget {
  const PatientHomePage({super.key});

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
              // 3.1.1 Header Personal
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
                    child: user?.photoUrl == null ? const Icon(Icons.person) : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hola, ${user?.name ?? 'Paciente'} 👋",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          "¿Qué necesitas hoy?",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 3.1.4 Promociones y Noticias (Top section as requested)
              const Text(
                "Para ti",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // Simplified Carousel using a PageView or just a Card for now
              SizedBox(
                height: 180,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _PromoCard(color: Colors.blue.shade100, title: "Chequeo General", subtitle: "20% de descuento"),
                    const SizedBox(width: 12),
                    _PromoCard(color: Colors.green.shade100, title: "Salud Mental", subtitle: "Primera sesión gratis"),
                    const SizedBox(width: 12),
                    _PromoCard(color: Colors.orange.shade100, title: "Dental", subtitle: "Limpieza profunda"),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3.1.2 Acciones Rápidas
              const Text(
                "Acciones Rápidas",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _ActionCard(
                    icon: Icons.search,
                    title: "Buscar Médico",
                    color: Colors.purple.shade50,
                    iconColor: Colors.purple,
                    onTap: () => _navigate(context, const DashboardBuscarPage()),
                  ),
                  _ActionCard(
                    icon: Icons.calendar_month,
                    title: "Mis Citas",
                    color: Colors.blue.shade50,
                    iconColor: Colors.blue,
                    onTap: () => _navigate(context, const MisCitasPage()),
                  ),
                  _ActionCard( // Redundant with MisCitas but requested "Agenda"
                    icon: Icons.book_online,
                    title: "Agenda",
                    color: Colors.orange.shade50,
                    iconColor: Colors.orange,
                    onTap: () => _navigate(context, const MisCitasPage()), // Mapping to MisCitas for now
                  ),
                  _ActionCard(
                    icon: Icons.favorite,
                    title: "Favoritos",
                    color: Colors.red.shade50,
                    iconColor: Colors.red,
                    onTap: () => _navigate(context, const FavoritosPage()),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 3.1.3 Próximas Citas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Próximas Citas",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => _navigate(context, const MisCitasPage()),
                    child: const Text("Ver todas"),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Horizontal List of Appointments (Mock for now, or fetch from provider)
              // Ideally use AppointmentProvider here.
              SizedBox(
                height: 140,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    _AppointmentCardMock(
                      doctorName: "Dr. Juan Pérez",
                      specialty: "Cardiología",
                      date: "Mañana, 10:00 AM",
                    ),
                    SizedBox(width: 12),
                    _AppointmentCardMock(
                      doctorName: "Dra. Ana López",
                      specialty: "Dentista",
                      date: "Jueves, 4:30 PM",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}

class _PromoCard extends StatelessWidget {
  final Color color;
  final String title;
  final String subtitle;

  const _PromoCard({required this.color, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: const Text("PROMO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.6))),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: iconColor),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _AppointmentCardMock extends StatelessWidget {
  final String doctorName;
  final String specialty;
  final String date;

  const _AppointmentCardMock({required this.doctorName, required this.specialty, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(doctorName, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(specialty, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.blue),
                const SizedBox(width: 4),
                Text(date, style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
