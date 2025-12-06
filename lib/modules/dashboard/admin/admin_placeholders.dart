import 'package:flutter/material.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Gestión de Usuarios")));
}

class AdminAppointmentsPage extends StatelessWidget {
  const AdminAppointmentsPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Todas las Citas")));
}

class AdminContentPage extends StatelessWidget {
  const AdminContentPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Gestión de Contenido")));
}

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Perfil Administrador")));
}
