import 'package:flutter/material.dart';
import 'doctor_home_page.dart';
import 'doctor_placeholders.dart';
import '../../patient/patient_profile_page.dart'; // Reuse generic profile or create doctor specific

class DoctorMainScaffold extends StatefulWidget {
  const DoctorMainScaffold({super.key});

  @override
  State<DoctorMainScaffold> createState() => _DoctorMainScaffoldState();
}

class _DoctorMainScaffoldState extends State<DoctorMainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DoctorHomePage(),
    const DoctorAgendaPage(),
    const DoctorPatientsPage(),
    const DoctorStatsPage(),
    const PatientProfilePage(), // Placeholder for Profile
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
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Agenda'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Pacientes'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Estadísticas'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
