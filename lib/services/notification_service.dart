import 'package:flutter/foundation.dart';
import '../models/appointment.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  // Mock methods for SMS (Twilio) and Push (Firebase FCM)

  Future<void> sendAppointmentConfirmation(Appointment appointment) async {
    // In a real app, this would call your backend or cloud function
    // which then triggers Twilio/FCM.

    // 1. SMS
    _logSMS(
      to: "Patient-Phone",
      body: "Hola, tu cita con ${appointment.professional.name} ha sido confirmada para el ${appointment.dateTime}."
    );

    // 2. Push
    _logPush(
      title: "Cita Confirmada",
      body: "Tu cita está lista. Fecha: ${appointment.dateTime}"
    );
  }

  Future<void> sendAppointmentCancellation(Appointment appointment) async {
    _logSMS(
      to: "Patient-Phone",
      body: "Tu cita con ${appointment.professional.name} ha sido cancelada."
    );

    _logPush(
      title: "Cita Cancelada",
      body: "La cita del ${appointment.dateTime} ha sido cancelada."
    );
  }

  Future<void> sendAppointmentReschedule(Appointment oldAppointment, Appointment newAppointment) async {
     _logSMS(
      to: "Patient-Phone",
      body: "Tu cita ha sido reagendada para el ${newAppointment.dateTime}."
    );

    _logPush(
      title: "Cita Reagendada",
      body: "Nueva fecha: ${newAppointment.dateTime}"
    );
  }

  // TODO: Implement scheduled notifications (24h and 1h before)
  // This would likely involve a background worker or server-side scheduler.
  Future<void> scheduleReminders(Appointment appointment) async {
    debugPrint("[NotificationService] Scheduling reminders for appointment ${appointment.id}...");
    debugPrint("   -> Reminder set for ${appointment.dateTime.subtract(const Duration(hours: 24))} (24h before)");
    debugPrint("   -> Reminder set for ${appointment.dateTime.subtract(const Duration(hours: 1))} (1h before)");
  }

  void _logSMS({required String to, required String body}) {
    debugPrint("📱 [SMS Mock - Twilio] To: $to | Body: $body");
  }

  void _logPush({required String title, required String body}) {
    debugPrint("🔔 [Push Mock - FCM] Title: $title | Body: $body");
  }
}
