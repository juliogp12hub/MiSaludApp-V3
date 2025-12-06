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

  @override
  void initState() {
    super.initState();
    // Initialize repo to load data (and emit initial stream)
    _repo.init();
  }

  // ------------------ ESTADO REAL ------------------

  String _estadoReal(Appointment cita) {
    final ahora = DateTime.now();

    // Status precedence
    if (cita.status == "cancelada") return "cancelada";
    if (cita.status == "pending_invite") return "pendiente de invitación";
    if (cita.status == "blocked") return "bloqueada"; // Should not appear here ideally but for robustness

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
      case "pendiente de invitación":
        return Colors.orange;
      case "bloqueada":
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  // ------------------ UI ------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis citas'), centerTitle: true),
      body: StreamBuilder<List<Appointment>>(
        stream: _repo.citasStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
             return FutureBuilder<List<Appointment>>(
                future: _repo.obtenerCitasPaciente(),
                builder: (ctx, snap) {
                   if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                   if (snap.data!.isEmpty) return _emptyView();
                   // Filter out blocked slots if user is Patient (unless we are Doctor view, but this is Patient app)
                   final filtered = snap.data!.where((c) => c.status != 'blocked').toList();
                   if (filtered.isEmpty) return _emptyView();
                   return _listView(filtered);
                }
             );
          }

          var citas = snapshot.data!;
          // Filter out blocked slots
          citas = citas.where((c) => c.status != 'blocked').toList();

          if (citas.isEmpty) {
            return _emptyView();
          }

          return _listView(citas);
        },
      ),
    );
  }

  Widget _emptyView() {
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

  Widget _listView(List<Appointment> citas) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: citas.length,
        itemBuilder: (_, i) => _buildCitaCard(citas[i]),
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

            // Invitation UI
            if (estado == "pendiente de invitación") ...[
                const SizedBox(height: 12),
                const Text("Has recibido una invitación para esta cita.", style: TextStyle(fontStyle: FontStyle.italic)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                     TextButton(
                       child: const Text("Rechazar", style: TextStyle(color: Colors.red)),
                       onPressed: () async {
                          await _repo.cancelarCita(cita.id);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invitación rechazada.")));
                       }
                     ),
                     ElevatedButton(
                       child: const Text("Aceptar Cita"),
                       onPressed: () async {
                          // Reagendar acts as update status if we implement "updateCita" or we can hack it
                          // But we don't have "updateStatus" exposed in Repo easily except Reagendar or manual.
                          // Actually "reagendarCita" sets status to confirmed.
                          // So we can call reagendar with same date.
                          await _repo.reagendarCita(id: cita.id, nuevaFecha: cita.dateTime);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cita confirmada.")));
                       }
                     )
                  ],
                )
            ],

            const SizedBox(height: 16),

            // Botones (Solo si confirmada)
            if (estado == "confirmada")
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                  TextButton.icon(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label: const Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () async {
                      await _repo.cancelarCita(cita.id);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Cita cancelada.")),
                      );
                    },
                  ),

                  TextButton.icon(
                    icon: const Icon(Icons.edit_calendar, color: Colors.blue),
                    label: const Text(
                      "Reagendar",
                      style: TextStyle(color: Colors.blue),
                    ),
                    onPressed: () async {
                       final data = ProfessionalDetailData(
                          id: cita.professional.id,
                          nombre: cita.professional.name,
                          tipo: 'Doctor',
                          avatarUrl: cita.professional.photoUrl ?? '',
                          ciudad: cita.professional.city,
                          subespecialidad: cita.professional.specialty,
                       );

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AgendaUniversalPage(
                            data: data,
                            citaOriginal: cita,
                          ),
                        ),
                      );
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
