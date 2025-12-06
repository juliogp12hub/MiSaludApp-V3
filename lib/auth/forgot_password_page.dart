import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  void _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ingrese su correo")));
      return;
    }

    setState(() => _isLoading = true);

    // Call repo directly or via provider method (if added)
    // Since AuthNotifier doesn't have resetPassword exposed, we can access repo.
    final repo = ref.read(authRepositoryProvider);
    try {
      await repo.resetPassword(email);
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Correo enviado"),
            content: Text("Se han enviado instrucciones a $email"),
            actions: [
              TextButton(onPressed: () {
                Navigator.pop(context); // Dialog
                Navigator.pop(context); // Page
              }, child: const Text("Aceptar"))
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recuperar Contraseña")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text("Ingrese su correo electrónico para recibir instrucciones de restablecimiento."),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Correo", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading ? const CircularProgressIndicator() : const Text("Enviar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
