import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../../../panel_medico/configurar_agenda_medico_page.dart';
import '../../../core/models/professional.dart';
import '../../perfil/account_settings_page.dart';

class DoctorProfilePage extends ConsumerWidget {
  const DoctorProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    // Construct a Mock Professional object from User for the config page
    final professionalMock = Professional(
      id: user?.id ?? "d1",
      name: user?.name ?? "Doctor",
      specialty: "General",
      city: "Guatemala",
      rating: 5.0,
      price: 200,
      photoUrl: user?.photoUrl,
      type: ProfessionalType.doctor,
      isPremium: user?.isPremium ?? false,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Perfil Profesional"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
                  child: user?.photoUrl == null ? const Icon(Icons.person, size: 50) : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? "Doctor",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                if (user?.isPremium == true)
                  const Chip(
                    label: Text("Premium"),
                    backgroundColor: Colors.amber,
                    avatar: Icon(Icons.star, size: 16),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Menu
          _ProfileMenuItem(
            icon: Icons.manage_accounts,
            text: "Configuración de Cuenta",
            subtitle: "Foto, Contraseña, Notificaciones",
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountSettingsPage()));
            },
          ),

          _ProfileMenuItem(
            icon: Icons.calendar_month,
            text: "Configurar Agenda",
            subtitle: "Horarios, precios y duración",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ConfigurarAgendaMedicoPage(doctor: professionalMock),
                ),
              );
            },
          ),

          const Divider(),

          _ProfileMenuItem(
            icon: Icons.help_outline,
            text: "Ayuda y Soporte",
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? subtitle;
  final VoidCallback onTap;

  const _ProfileMenuItem({required this.icon, required this.text, this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
