import 'package:flutter/material.dart';

// Módulos existentes en tu estructura
import '../modules/buscador/dashboard_buscar_page.dart';
import '../modules/agenda/mis_citas_page.dart';
import '../modules/patient/patient_profile_page.dart';

// Si luego agregas tu página de noticias, solo la importas aquí
// import '../modules/noticias/inicio_noticias_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _index = 0;

  // Lista de pantallas reales
  final _pages = const [
    DashboardBuscarPage(),
    MisCitasPage(),
    PatientProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),

        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Buscar"),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Mis citas",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }
}
