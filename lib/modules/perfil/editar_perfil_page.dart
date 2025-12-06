import 'package:flutter/material.dart';
import '../../services/usuario_service.dart';

class EditarPerfilPage extends StatefulWidget {
  const EditarPerfilPage({super.key});

  @override
  State<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  final UsuarioService _usuario = UsuarioService();

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreCtrl;
  late TextEditingController _telefonoCtrl;
  late TextEditingController _edadCtrl;
  String? _sexo;

  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: _usuario.nombre ?? "");
    _telefonoCtrl = TextEditingController(text: _usuario.telefono ?? "");
    _edadCtrl = TextEditingController(
      text: _usuario.edad != null ? _usuario.edad.toString() : "",
    );
    _sexo = _usuario.sexo;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _edadCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final nombre = _nombreCtrl.text.trim();
    final telefono = _telefonoCtrl.text.trim();
    final edadText = _edadCtrl.text.trim();
    final edad = edadText.isNotEmpty ? int.tryParse(edadText) : null;

    setState(() => _guardando = true);

    await _usuario.guardarDatos(
      nombre: nombre,
      telefono: telefono,
      edad: edad,
      sexo: _sexo,
    );

    setState(() => _guardando = false);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar perfil")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 8),
              const Text(
                "Datos personales",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: "Nombre completo",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Ingresa tu nombre.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonoCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Número de teléfono",
                  hintText: "Ej. 5555-5555",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final texto = value?.trim() ?? "";
                  if (texto.isEmpty) {
                    return "El teléfono es obligatorio.";
                  }
                  if (texto.length < 8) {
                    return "El teléfono parece demasiado corto.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _edadCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Edad (opcional)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _sexo,
                decoration: const InputDecoration(
                  labelText: "Sexo (opcional)",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "Masculino",
                    child: Text("Masculino"),
                  ),
                  DropdownMenuItem(value: "Femenino", child: Text("Femenino")),
                  DropdownMenuItem(value: "Otro", child: Text("Otro")),
                  DropdownMenuItem(
                    value: "Prefiero no decir",
                    child: Text("Prefiero no decir"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _sexo = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _guardando ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _guardando
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Guardar cambios",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
