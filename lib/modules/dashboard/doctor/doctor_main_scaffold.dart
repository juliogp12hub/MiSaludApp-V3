import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../../../panel_medico/doctor_agenda_page.dart';
import '../../../core/models/professional.dart'; // For mocking logic if needed
import 'doctor_home_page.dart';
import 'doctor_profile_page.dart';
import 'doctor_placeholders.dart'; // Keep for Stats/Patients if not implemented yet
import '../../newsletter/inicio_noticias_page.dart';

class DoctorMainScaffold extends StatefulWidget {
  const DoctorMainScaffold({super.key});

  @override
  State<DoctorMainScaffold> createState() => _DoctorMainScaffoldState();
}

class _DoctorMainScaffoldState extends State<DoctorMainScaffold> {
  int _currentIndex = 0;

  // We need to pass the professional object to DoctorAgendaPage.
  // Ideally, we fetch it. For now, we construct it from the logged-in user.
  // But DoctorAgendaPage takes a 'Professional'.
  // We'll wrap it in a Consumer to get the user.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(
        builder: (context, ref, _) {
          final user = ref.watch(authProvider).user;
          // Construct mock professional from user
          final professional = Professional(
             id: user?.id ?? "d1",
             name: user?.name ?? "Doctor",
             specialty: "General",
             city: "Guatemala",
             rating: 5.0,
             price: 200,
             isPremium: user?.isPremium ?? false,
          );

          final pages = [
            const DoctorHomePage(),
            DoctorAgendaPage(professional: professional),
            const InicioNoticiasPage(), // Newsletter Module
            const DoctorPatientsPage(), // Placeholder
            const DoctorProfilePage(),
          ];

          return IndexedStack(
            index: _currentIndex,
            children: pages,
          );
        },
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
          BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'Noticias'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Pacientes'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
