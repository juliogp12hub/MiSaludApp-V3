import 'package:flutter/material.dart';
import '../../data/repositories/agenda_repository.dart';
import '../../models/appointment.dart';
import '../professional_detail/professional_detail_data.dart';
import '../agenda/agenda_universal_page.dart';

class MisCitasPage extends StatefulWidget {
  const MisCitasPage({super.key});

  @override
  State<MisCitasPage> createState() => _MisCitasPageState();
}

class _MisCitasPageState extends State<MisCitasPage> {
  final AgendaRepository _repo = AgendaRepository();

  late Future<List<Appointment>> _futureCitas;

  @override
  void initState() {
    super.initState();
    // Initialize repo to load data
    _repo.init().then((_) {
      setState(() {
        _futureCitas = _repo.obtenerCitasPaciente();
      });
    });
    _futureCitas = _repo.obtenerCitasPaciente();
  }

  Future<void> _refrescar() async {
    setState(() {
      _futureCitas = _repo.obtenerCitasPaciente();
    });
  }

  // ------------------ ESTADO REAL ------------------

  String _estadoReal(Appointment cita) {
    final ahora = DateTime.now();

    if (cita.status == "cancelada") return "cancelada";

    if (cita.dateTime.isBefore(ahora)) {
      return "completada";
    }

    return "confirmada";
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case "completada":
        return Colors.green;
      case "cancelada":
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  // ------------------ UI ------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis citas'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: _refrescar,
        child: FutureBuilder<List<Appointment>>(
          future: _futureCitas,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final citas = snapshot.data!;
            if (citas.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 80),
                  Center(
                    child: Text(
                      'Aún no tienes citas agendadas.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: citas.length,
              itemBuilder: (_, i) => _buildCitaCard(citas[i]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCitaCard(Appointment cita) {
    final fecha = cita.dateTime;
    final fechaText =
        "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}";
    final horaText =
        "${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";

    final estado = _estadoReal(cita);
    final colorEstado = _estadoColor(estado);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Colors.white,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Professional
            Row(
              children: [
                const Icon(Icons.person_outline, size: 30),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cita.professional.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "${cita.professional.specialty} • ${cita.professional.city}",
              style: const TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 16),

            // Fecha y hora
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                Text(
                  "$fechaText  •  $horaText",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Estado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colorEstado.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorEstado),
              ),
              child: Text(
                estado.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorEstado,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (estado == "confirmada")
                  TextButton.icon(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label: const Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () async {
                      await _repo.cancelarCita(cita.id);
                      _refrescar();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Cita cancelada.")),
                      );
                    },
                  ),

                if (estado == "confirmada")
                  TextButton.icon(
                    icon: const Icon(Icons.edit_calendar, color: Colors.blue),
                    label: const Text(
                      "Reagendar",
                      style: TextStyle(color: Colors.blue),
                    ),
                    onPressed: () async {
                       // Map to ProfessionalDetailData for AgendaUniversalPage if needed,
                       // but AgendaUniversalPage seems to need the doctor data.
                       // We will construct it from Professional.
                       final data = ProfessionalDetailData(
                          id: cita.professional.id,
                          nombre: cita.professional.name,
                          tipo: 'Doctor', // or dynamic
                          avatarUrl: cita.professional.photoUrl ?? '',
                          ciudad: cita.professional.city,
                          subespecialidad: cita.professional.specialty,
                       );

                      final resultado = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AgendaUniversalPage(
                            data: data,
                            citaOriginal: cita,
                          ),
                        ),
                      );

                      if (resultado == true) {
                        _refrescar();
                      }
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
