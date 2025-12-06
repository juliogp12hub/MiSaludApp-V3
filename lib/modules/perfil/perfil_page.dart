import 'package:flutter/material.dart';
import '../../services/usuario_service.dart';
import 'editar_perfil_page.dart';
import 'registro_profesional_page.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  late UsuarioService _usuario;

  @override
  void initState() {
    super.initState();
    _usuario = UsuarioService();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    await _usuario.cargar();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        title: const Text("Mi Perfil"),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHeaderCard(),
        const SizedBox(height: 20),
        _buildDatosCard(),
        const SizedBox(height: 20),
        _buildProfesionalSection(),
      ],
    );
  }

  // HEADER ----------------------------------------------------
  Widget _buildHeaderCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: Colors.blue.shade100,
            child: const Icon(Icons.person, size: 48, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              _usuario.nombre.isEmpty ? "Usuario invitado" : _usuario.nombre,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // DATOS PERSONALES ------------------------------------------
  Widget _buildDatosCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Datos del usuario",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildDato("Nombre", _usuario.nombre),
          _buildDato(
            "Teléfono",
            _usuario.telefono.isEmpty ? "No registrado" : _usuario.telefono,
          ),
          _buildDato(
            "Sexo",
            _usuario.sexo == null || _usuario.sexo!.isEmpty
                ? "No especificado"
                : _usuario.sexo!,
          ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final r = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditarPerfilPage()),
                );
                if (r == true) _cargarUsuario();
              },
              child: const Text("Editar perfil"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDato(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            "$titulo: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }

  // PROFESIONAL -----------------------------------------------
  Widget _buildProfesionalSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Perfil profesional",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildEstadoProfesional(),
        ],
      ),
    );
  }

  Widget _buildEstadoProfesional() {
    if (!_usuario.esProfesional &&
        !_usuario.profesionalPendiente &&
        !_usuario.profesionalRechazado &&
        !_usuario.profesionalVerificado) {
      return _buildBotonRegistro("Registrarme como profesional");
    }

    if (_usuario.profesionalPendiente) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _estado("En revisión", Colors.orange),
          const SizedBox(height: 10),
          const Text(
            "Tu solicitud está en revisión por el equipo de MiSaludApp.",
          ),
        ],
      );
    }

    if (_usuario.profesionalRechazado) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _estado("Rechazado", Colors.red),
          const SizedBox(height: 10),
          const Text(
            "No se pudo verificar tu número de colegiado o documento.",
          ),
          const SizedBox(height: 16),
          _buildBotonRegistro("Volver a enviar documentos"),
        ],
      );
    }

    if (_usuario.profesionalVerificado) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _estado("Verificado", Colors.green),
          const SizedBox(height: 10),
          Text("Tipo: ${_usuario.tipoProfesional.toUpperCase()}"),
          Text("Número de colegiado: ${_usuario.numeroColegiado}"),
        ],
      );
    }

    return const SizedBox();
  }

  Widget _estado(String texto, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        texto,
        style: TextStyle(fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildBotonRegistro(String texto) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () async {
          final r = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RegistroProfesionalPage()),
          );
          if (r == true) _cargarUsuario();
        },
        child: Text(texto),
      ),
    );
  }
}
