import 'package:flutter/material.dart';

class DoctorAgendaPage extends StatelessWidget {
  const DoctorAgendaPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Agenda del Doctor")));
}

class DoctorPatientsPage extends StatelessWidget {
  const DoctorPatientsPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Lista de Pacientes")));
}

class DoctorStatsPage extends StatelessWidget {
  const DoctorStatsPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Estadísticas")));
}
