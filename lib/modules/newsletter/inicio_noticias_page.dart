import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/evento_promocion.dart';
import '../../providers/promotions_provider.dart';
import '../../widgets/favorite_toggle.dart';
import 'create_promotion_page.dart';

class InicioNoticiasPage extends ConsumerStatefulWidget {
  const InicioNoticiasPage({super.key});

  @override
  ConsumerState<InicioNoticiasPage> createState() => _InicioNoticiasPageState();
}

class _InicioNoticiasPageState extends ConsumerState<InicioNoticiasPage> {
  String? _selectedCategory;
  String? _selectedType;

  final List<String> _categories = ["General", "Dental", "Salud Mental", "Salud Femenina"];
  final List<String> _types = ["evento", "promocion"];

  @override
  Widget build(BuildContext context) {
    final filter = PromotionFilter(
      category: _selectedCategory,
      type: _selectedType,
    );

    // Watch the provider with the current filter
    final promotions = ref.watch(promotionsProvider(filter));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Noticias y Promociones"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Crear (Solo Profesionales)",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreatePromotionPage())
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: promotions.isEmpty
              ? const Center(child: Text("No hay promociones disponibles."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: promotions.length,
                  itemBuilder: (_, i) => _buildCard(promotions[i]),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Category Filter
          DropdownButton<String>(
            hint: const Text("Categoría"),
            value: _selectedCategory,
            items: [
              const DropdownMenuItem(value: null, child: Text("Todas")),
              ..._categories.map((c) => DropdownMenuItem(value: c, child: Text(c))),
            ],
            onChanged: (val) {
              setState(() => _selectedCategory = val);
              // Trigger reload is handled by watching the new provider family key
            },
          ),
          const SizedBox(width: 16),
          // Type Filter
          Wrap(
            spacing: 8,
            children: _types.map((t) {
              final isSelected = _selectedType == t;
              return FilterChip(
                label: Text(t.toUpperCase()),
                selected: isSelected,
                onSelected: (sel) {
                  setState(() => _selectedType = sel ? t : null);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(EventoPromocion item) {
    final tipoColor = {
      "evento": Colors.blue,
      "promocion": Colors.green,
      "recordatorio": Colors.orange,
      "articulo": Colors.purple,
    };

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: tipoColor[item.tipo] ?? Colors.blueGrey,
                  child: Icon(
                    item.tipo == 'promocion' ? Icons.local_offer : Icons.event,
                    color: Colors.white
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("${item.autorNombre} • ${item.category}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                FavoriteToggle(
                  professionalId: item.id,
                  activeColor: Colors.amber,
                  inactiveColor: Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(item.descripcion),
            if (item.fecha.isAfter(DateTime.now()))
               Padding(
                 padding: const EdgeInsets.only(top: 8.0),
                 child: Row(
                   children: [
                     const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                     const SizedBox(width: 4),
                     Text(
                       "Fecha: ${item.fecha.day}/${item.fecha.month}/${item.fecha.year}",
                       style: const TextStyle(fontSize: 12, color: Colors.grey),
                     ),
                   ],
                 ),
               )
          ],
        ),
      ),
    );
  }
}
