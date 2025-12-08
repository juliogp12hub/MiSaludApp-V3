import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/evento_promocion.dart';
import '../../providers/promotions_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/models/user.dart';

class CreatePromotionPage extends ConsumerStatefulWidget {
  const CreatePromotionPage({super.key});

  @override
  ConsumerState<CreatePromotionPage> createState() => _CreatePromotionPageState();
}

class _CreatePromotionPageState extends ConsumerState<CreatePromotionPage> {
  final _formKey = GlobalKey<FormState>();

  String _titulo = '';
  String _descripcion = '';
  String _tipo = 'promocion';
  String _categoria = 'General';

  final List<String> _categories = ["General", "Dental", "Salud Mental", "Salud Femenina"];

  @override
  void initState() {
    super.initState();
    // Safety check: Redirect if not allowed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      final canCreate = user != null && (
          user.role == UserRole.admin ||
          (user.role == UserRole.doctor && user.isPremium)
      );

      if (!canCreate) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Acceso denegado. Se requiere cuenta Premium.")));
        Navigator.pop(context);
      }
    });
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final user = ref.read(authProvider).user;

      final promo = EventoPromocion(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        titulo: _titulo,
        descripcion: _descripcion,
        tipo: _tipo,
        category: _categoria,
        fecha: DateTime.now().add(const Duration(days: 7)),
        autorNombre: user?.name ?? "Dr. Desconocido",
        autorTipo: user?.role == UserRole.admin ? "admin" : "doctor",
        professionalId: user?.id,
      );

      ref.read(promotionRepositoryProvider).addPromotion(promo).then((_) {
         ref.invalidate(promotionsProvider);
         Navigator.pop(context);
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Promoción creada exitosamente.")));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear Promoción")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Título"),
                validator: (v) => v!.isEmpty ? "Requerido" : null,
                onSaved: (v) => _titulo = v!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: "Descripción"),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? "Requerido" : null,
                onSaved: (v) => _descripcion = v!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _tipo,
                decoration: const InputDecoration(labelText: "Tipo"),
                items: const [
                  DropdownMenuItem(value: "promocion", child: Text("Promoción")),
                  DropdownMenuItem(value: "evento", child: Text("Evento")),
                ],
                onChanged: (v) => setState(() => _tipo = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _categoria,
                decoration: const InputDecoration(labelText: "Categoría"),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _categoria = v!),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _guardar,
                child: const Text("Publicar"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
