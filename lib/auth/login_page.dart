import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'forgot_password_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // To show simple error dialogs
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("Por favor ingrese correo y contraseña");
      return;
    }

    await ref.read(authProvider.notifier).login(email, password);

    // AuthProvider updates state. RootScaffold watches it and will switch page if success.
    // If error, it stays here and we can check state.error
    final error = ref.read(authProvider).error;
    if (error != null && mounted) {
      _showError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("MiSaludApp Login")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.health_and_safety, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text("Bienvenido", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),

              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Correo Electrónico",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: "Contraseña",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),

              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordPage()));
                  },
                  child: const Text("¿Olvidaste tu contraseña?"),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _login,
                  child: authState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Iniciar Sesión", style: TextStyle(fontSize: 16)),
                ),
              ),

              const SizedBox(height: 24),
              const Text("Cuentas de prueba (Password: 123456):", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _MockUserTile(email: "paciente@test.com", label: "Paciente", controller: _emailController, passController: _passwordController),
              _MockUserTile(email: "doctor@test.com", label: "Doctor", controller: _emailController, passController: _passwordController),
              _MockUserTile(email: "admin@test.com", label: "Admin", controller: _emailController, passController: _passwordController),
            ],
          ),
        ),
      ),
    );
  }
}

class _MockUserTile extends StatelessWidget {
  final String email;
  final String label;
  final TextEditingController controller;
  final TextEditingController passController;

  const _MockUserTile({required this.email, required this.label, required this.controller, required this.passController});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        controller.text = email;
        passController.text = "123456";
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(width: 8),
            Text(email, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
