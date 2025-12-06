import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth/session_service.dart';
import 'modules/dashboard/root_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SessionService.init(); // Legacy session, might remove later
  runApp(const ProviderScope(child: MiSaludApp()));
}

class MiSaludApp extends StatelessWidget {
  const MiSaludApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "MiSaludApp",
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF7F7FB),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent, // Modern look
          titleTextStyle: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.black87),
        ),
      ),
      home: const RootScaffold(),
    );
  }
}
