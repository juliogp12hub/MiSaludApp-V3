import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/professional.dart';
import '../../providers.dart';
import 'widgets/professional_card.dart';
import '../professional_detail/professional_detail_page.dart';
import '../professional_detail/professional_detail_data.dart';

class BuscadorGenericPage extends ConsumerStatefulWidget {
  final ProfessionalType type;
  final String title;

  const BuscadorGenericPage({super.key, required this.type, required this.title});

  @override
  ConsumerState<BuscadorGenericPage> createState() => _BuscadorGenericPageState();
}

class _BuscadorGenericPageState extends ConsumerState<BuscadorGenericPage> {
  String _search = '';
  String? _ciudadSeleccionada;
  bool _soloTelemedicina = false;

  @override
  Widget build(BuildContext context) {
    final professionalsAsyncValue = ref.watch(professionalsProvider(
      ProfessionalFilter(type: widget.type),
    ));

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          _buildFiltros(),
          const SizedBox(height: 8),
          Expanded(
            child: professionalsAsyncValue.when(
              data: (professionals) {
                final filtrados = _filtrarLista(professionals);
                if (filtrados.isEmpty) {
                  return const Center(
                    child: Text(
                      "No se encontraron profesionales con los filtros actuales.",
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtrados.length,
                  itemBuilder: (context, index) {
                    final p = filtrados[index];
                    return ProfessionalCard(
                      professional: p,
                      onTap: () => _navigateToDetail(context, p),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  List<Professional> _filtrarLista(List<Professional> professionals) {
    return professionals.where((p) {
      final q = _search.trim().toLowerCase();
      final coincideBusqueda =
          q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.specialty.toLowerCase().contains(q);

      final coincideCiudad =
          _ciudadSeleccionada == null || p.city == _ciudadSeleccionada;

      final coincideTelemedicina =
          !_soloTelemedicina || p.isTelemedicine;

      return coincideBusqueda && coincideCiudad && coincideTelemedicina;
    }).toList();
  }

  void _navigateToDetail(BuildContext context, Professional p) {
    final data = ProfessionalDetailData(
      id: p.id,
      nombre: p.name,
      tipo: widget.type.name.toUpperCase(),
      avatarUrl: p.photoUrl ?? 'https://via.placeholder.com/150',
      ciudad: p.city,
      subespecialidad: p.specialty,
      direccion: p.address,
      acercaDe: p.bio,
      calificacion: p.rating,
      precioPresencial: p.price,
      experiencia: '${p.yearsExperience} años',
      idiomas: p.languages,
      hospitales: p.hospitals,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfessionalDetailPage(data: data),
      ),
    );
  }

  Widget _buildFiltros() {
    final professionalsValue = ref.watch(professionalsProvider(
      ProfessionalFilter(type: widget.type),
    ));

    final Set<String> ciudades = {};
    if (professionalsValue.hasValue) {
      for (final p in professionalsValue.value!) {
        ciudades.add(p.city);
      }
    }
    final listaCiudades = ciudades.toList()..sort();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Buscar por nombre o especialidad',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _search = value;
              });
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  decoration: const InputDecoration(
                    labelText: 'Ciudad',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _ciudadSeleccionada,
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text("Todas las ciudades"),
                    ),
                    ...listaCiudades.map(
                      (c) =>
                          DropdownMenuItem<String?>(value: c, child: Text(c)),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _ciudadSeleccionada = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    "Solo telemedicina",
                    style: TextStyle(fontSize: 13),
                  ),
                  value: _soloTelemedicina,
                  onChanged: (value) {
                    setState(() {
                      _soloTelemedicina = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
