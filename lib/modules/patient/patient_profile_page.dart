import 'package:flutter/material.dart';
import '../../data/repositories/patient_repository.dart';
import '../../models/patient/patient_model.dart';

class PatientProfilePage extends StatefulWidget {
  const PatientProfilePage({super.key});

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  Patient? _paciente;

  @override
  void initState() {
    super.initState();
    _cargarPaciente();
  }

  Future<void> _cargarPaciente() async {
    final p = await patientRepo.obtenerPaciente();
    setState(() => _paciente = p);
  }

  @override
  Widget build(BuildContext context) {
    final p = _paciente;

    return Scaffold(
      appBar: AppBar(title: const Text("Mi Perfil")),
      body: p == null
          ? const Center(child: Text("No hay información del paciente"))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: p.fotoUrl != null
                      ? NetworkImage(p.fotoUrl!)
                      : null,
                  child: p.fotoUrl == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                const SizedBox(height: 20),
                Text(
                  p.nombre ?? "-",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text("Edad: ${p.edad ?? '-'} años"),
                const SizedBox(height: 10),
                const Divider(height: 40),
                ElevatedButton(
                  onPressed: () async {
                    await patientRepo.limpiar();
                    if (!mounted) return;
                    Navigator.pop(context);
                  },
                  child: const Text("Cerrar sesión"),
                ),
              ],
            ),
    );
  }
}
