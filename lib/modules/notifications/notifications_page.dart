import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Notifications List
    final notifications = [
      {
        "title": "Cita Confirmada",
        "body": "Tu cita con Dr. Roberto Médico ha sido confirmada.",
        "time": "Hace 2 horas",
        "icon": Icons.calendar_check,
        "color": Colors.green,
      },
      {
        "title": "Recordatorio",
        "body": "Mañana tienes limpieza dental a las 10:00 AM.",
        "time": "Ayer",
        "icon": Icons.access_alarm,
        "color": Colors.orange,
      },
      {
        "title": "Nueva Promoción",
        "body": "50% de descuento en cardiología esta semana.",
        "time": "Hace 3 días",
        "icon": Icons.local_offer,
        "color": Colors.purple,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Notificaciones")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final n = notifications[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: (n["color"] as Color).withOpacity(0.1),
                child: Icon(n["icon"] as IconData, color: n["color"] as Color),
              ),
              title: Text(n["title"] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n["body"] as String),
                  const SizedBox(height: 4),
                  Text(n["time"] as String, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
