import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/evento_promocion.dart';
import '../../providers/promotions_provider.dart';

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

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final promo = EventoPromocion(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        titulo: _titulo,
        descripcion: _descripcion,
        tipo: _tipo,
        category: _categoria,
        fecha: DateTime.now().add(const Duration(days: 7)),
        autorNombre: "Dr. Mock (Tú)", // Mocked Logged In Doctor
        autorTipo: "doctor",
        professionalId: "1", // Mocked ID
      );

      // We use ref.read on the generic provider to add.
      // Note: Since family providers are distinct, we should ideally have a method in repo exposed.
      // But here we can read a specific one (e.g. null filter) to get the notifier and add.
      // The notifier.add calls repo.add which updates the source list.
      // Then when other providers read, they should fetch fresh data if they re-read.
      // However, `promotionsProvider` fetches in constructor.
      // To fix this: `PromotionsNotifier` should probably listen to a stream from Repo or we force refresh.
      // For this mock, `notifier.add` calls `load()` which updates state for THAT notifier.
      // If `InicioNoticiasPage` is watching `promotionsProvider(currentFilter)`, it is a DIFFERENT notifier instance if we read `promotionsProvider(null)`.
      // Solution: The Repo is a singleton Provider. The Notifiers read from it.
      // We need to invalidate the providers so they re-read from Repo.

      ref.read(promotionRepositoryProvider).addPromotion(promo).then((_) {
         ref.invalidate(promotionsProvider); // Invalidate all families
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
