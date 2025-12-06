import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/usuario_service.dart';

class RegistroProfesionalPage extends StatefulWidget {
  const RegistroProfesionalPage({super.key});

  @override
  State<RegistroProfesionalPage> createState() =>
      _RegistroProfesionalPageState();
}

class _RegistroProfesionalPageState extends State<RegistroProfesionalPage> {
  final _formKey = GlobalKey<FormState>();
  final _colegiadoCtrl = TextEditingController();

  String? _tipoProfesional;
  PlatformFile? _archivoSeleccionado;
  bool _enviando = false;

  final List<String> _tipos = [
    "medico",
    "enfermeria",
    "fisioterapia",
    "terapia respiratoria",
  ];

  // -------------------------------------------------------------
  // Seleccionar archivo
  // -------------------------------------------------------------
  Future<void> _seleccionarArchivo() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (res == null) return;

    setState(() => _archivoSeleccionado = res.files.single);
  }

  // -------------------------------------------------------------
  // Enviar solicitud
  // -------------------------------------------------------------
  Future<void> _enviarSolicitud() async {
    if (!_formKey.currentState!.validate()) return;

    if (_archivoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debes adjuntar un documento.")),
      );
      return;
    }

    setState(() => _enviando = true);

    final usuario = UsuarioService();
    await usuario.cargar();

    // Convertir el archivo a base64
    // Como en la selección pusimos withData: true, siempre habrá bytes
    final bytes = _archivoSeleccionado!.bytes!;
    final archivoBase64 = base64Encode(bytes);

    await usuario.setDatosProfesional(
      tipo: _tipoProfesional!,
      colegiado: _colegiadoCtrl.text.trim(),
      archivoBase64: archivoBase64,
      archivoPath: _archivoSeleccionado!.path!,
    );

    setState(() => _enviando = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Solicitud enviada con éxito.")),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro Profesional")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Tipo de profesional",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Dropdown
              DropdownButtonFormField<String>(
                initialValue: _tipoProfesional,
                hint: const Text("Selecciona una opción"),
                items: _tipos
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _tipoProfesional = v),
                validator: (v) =>
                    v == null ? "Debes seleccionar un tipo profesional" : null,
              ),

              const SizedBox(height: 20),

              // Número de colegiado
              TextFormField(
                controller: _colegiadoCtrl,
                decoration: const InputDecoration(
                  labelText: "Número de colegiado",
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Campo obligatorio" : null,
              ),

              const SizedBox(height: 20),

              // Adjuntar archivo
              OutlinedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: Text(
                  _archivoSeleccionado == null
                      ? "Adjuntar documento"
                      : "Archivo seleccionado",
                ),
                onPressed: _seleccionarArchivo,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _enviando ? null : _enviarSolicitud,
                  child: _enviando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Enviar solicitud"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
