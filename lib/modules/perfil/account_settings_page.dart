import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../notifications/notifications_page.dart';

class AccountSettingsPage extends ConsumerStatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  ConsumerState<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends ConsumerState<AccountSettingsPage> {
  // Mock image picker
  Future<void> _pickImage() async {
    // In real app, utilize image_picker
    await Future.delayed(const Duration(seconds: 1));
    // Simulate upload result
    final newUrl = "https://i.pravatar.cc/300?u=${DateTime.now().millisecondsSinceEpoch}";

    final notifier = ref.read(authProvider.notifier);
    final user = ref.read(authProvider).user;
    if (user != null) {
       // We need a method in notifier to update photo.
       // Currently notifier exposes repository indirectly via login/logout.
       // We should add update methods to AuthNotifier or call Repo directly and refresh state.
       // Let's call Repo and refresh.
       // BUT AuthNotifier state is local. If we update Repo, we should reload AuthNotifier state.
       // Actually `checkSession` reloads it.
       final repo = ref.read(authRepositoryProvider);
       await repo.updateProfilePhoto(user.id, newUrl);
       await notifier.checkSession();

       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Foto de perfil actualizada.")));
       }
    }
  }

  void _showChangePasswordDialog() {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final repo = ref.read(authRepositoryProvider);
    final user = ref.read(authProvider).user;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cambiar Contraseña"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldController,
              decoration: const InputDecoration(labelText: "Contraseña Actual"),
              obscureText: true,
            ),
            TextField(
              controller: newController,
              decoration: const InputDecoration(labelText: "Nueva Contraseña"),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              try {
                await repo.changePassword(user!.id, oldController.text, newController.text);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Contraseña cambiada exitosamente.")));
                }
              } catch (e) {
                // Show error (AppError message)
                // Assuming we cast e to string or apperror
                if (mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              }
            },
            child: const Text("Guardar")
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text("Configuración de Cuenta")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Photo
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                  child: user.photoUrl == null ? const Icon(Icons.person, size: 50) : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: Colors.blue,
                    radius: 18,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      onPressed: _pickImage,
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 32),

          const Text("Seguridad", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Cambiar Contraseña"),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showChangePasswordDialog,
          ),

          const SizedBox(height: 24),
          const Text("Notificaciones", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SwitchListTile(
            value: true,
            onChanged: (v) {}, // Mock
            title: const Text("Notificaciones Push"),
            secondary: const Icon(Icons.notifications_active),
          ),
          SwitchListTile(
            value: false,
            onChanged: (v) {}, // Mock
            title: const Text("SMS"),
            secondary: const Icon(Icons.sms),
          ),
          SwitchListTile(
            value: true,
            onChanged: (v) {}, // Mock
            title: const Text("Correo Electrónico"),
            secondary: const Icon(Icons.email),
          ),

          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("Historial de Notificaciones"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage()));
            },
          ),
        ],
      ),
    );
  }
}
