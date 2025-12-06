import 'package:flutter/material.dart';
import 'admin_home_page.dart';
import 'admin_placeholders.dart';

class AdminMainScaffold extends StatefulWidget {
  const AdminMainScaffold({super.key});

  @override
  State<AdminMainScaffold> createState() => _AdminMainScaffoldState();
}

class _AdminMainScaffoldState extends State<AdminMainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const AdminHomePage(),
    const AdminUsersPage(),
    const AdminAppointmentsPage(),
    const AdminContentPage(),
    const AdminProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Usuarios'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Citas'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Contenido'),
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Perfil'),
        ],
      ),
    );
  }
}
