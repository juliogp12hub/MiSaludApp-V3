import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../auth/login_page.dart';
import '../../core/models/user.dart';
import 'patient/patient_main_scaffold.dart';
import 'doctor/doctor_main_scaffold.dart';
import 'admin/admin_main_scaffold.dart';

class RootScaffold extends ConsumerWidget {
  const RootScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Initial check or loading
    if (authState.isLoading && !authState.isAuthenticated) {
       return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!authState.isAuthenticated) {
      return const LoginPage();
    }

    final user = authState.user!;
    switch (user.role) {
      case UserRole.patient:
        return const PatientMainScaffold();
      case UserRole.doctor:
        return const DoctorMainScaffold();
      case UserRole.admin:
        return const AdminMainScaffold();
    }
  }
}
