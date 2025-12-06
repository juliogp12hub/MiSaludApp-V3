import 'package:flutter/material.dart';
import '../../agenda/mis_citas_page.dart';
import '../../buscador/dashboard_buscar_page.dart';
import '../../favoritos/favoritos_page.dart';
import '../../patient/patient_profile_page.dart'; // Ensure this exists or use a new one
import 'patient_home_page.dart';

class PatientMainScaffold extends StatefulWidget {
  const PatientMainScaffold({super.key});

  @override
  State<PatientMainScaffold> createState() => _PatientMainScaffoldState();
}

class _PatientMainScaffoldState extends State<PatientMainScaffold> {
  int _currentIndex = 0;

  // We use a list of pages. Note: MisCitasPage etc are assumed to be ready.
  final List<Widget> _pages = [
    const PatientHomePage(),
    const DashboardBuscarPage(),
    const MisCitasPage(),
    const FavoritosPage(),
    const PatientProfilePage(),
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
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
