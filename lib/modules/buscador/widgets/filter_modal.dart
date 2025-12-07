import 'package:flutter/material.dart';
import '../../../providers.dart';

class FilterModal extends StatefulWidget {
  final ProfessionalFilter currentFilter;
  final Function(ProfessionalFilter) onApply;

  const FilterModal({
    super.key,
    required this.currentFilter,
    required this.onApply,
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  late RangeValues _priceRange;
  late double _minRating;
  late int _minExperience;
  late List<String> _selectedCities;
  late List<String> _selectedInsurances;
  late String _sortBy;

  // Mock available data (In real app, fetch from repo)
  final List<String> _allCities = ['Ciudad de Guatemala', 'Antigua Guatemala', 'Xela', 'Escuintla', 'Cobán'];
  final List<String> _allInsurances = ['Seguros G&T', 'Roble', 'Universales', 'Mapfre', 'Seguros El Roble'];

  @override
  void initState() {
    super.initState();
    _priceRange = RangeValues(
      widget.currentFilter.minPrice ?? 0,
      widget.currentFilter.maxPrice ?? 1000,
    );
    _minRating = widget.currentFilter.minRating ?? 0;
    _minExperience = widget.currentFilter.minExperience ?? 0;
    _selectedCities = List.from(widget.currentFilter.cities ?? []);
    _selectedInsurances = List.from(widget.currentFilter.insurances ?? []);
    _sortBy = widget.currentFilter.sortBy;
  }

  void _apply() {
    final filter = widget.currentFilter.copyWith(
      minPrice: _priceRange.start > 0 ? _priceRange.start : null,
      maxPrice: _priceRange.end < 1000 ? _priceRange.end : null,
      minRating: _minRating > 0 ? _minRating : null,
      minExperience: _minExperience > 0 ? _minExperience : null,
      cities: _selectedCities.isNotEmpty ? _selectedCities : null,
      insurances: _selectedInsurances.isNotEmpty ? _selectedInsurances : null,
      sortBy: _sortBy,
    );
    widget.onApply(filter);
    Navigator.pop(context);
  }

  void _reset() {
    setState(() {
      _priceRange = const RangeValues(0, 1000);
      _minRating = 0;
      _minExperience = 0;
      _selectedCities = [];
      _selectedInsurances = [];
      _sortBy = 'relevance';
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (_, controller) {
        return Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(onPressed: _reset, child: const Text("Limpiar")),
                  const Text("Filtros", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: _apply, child: const Text("Aplicar")),
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(16),
                children: [
                  _sectionTitle("Ordenar por"),
                  Wrap(
                    spacing: 8,
                    children: [
                       _sortChip('Relevancia', 'relevance'),
                       _sortChip('Menor Precio', 'price_asc'),
                       _sortChip('Mayor Precio', 'price_desc'),
                       _sortChip('Mayor Calificación', 'rating_desc'),
                       _sortChip('Más Experiencia', 'experience_desc'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _sectionTitle("Rango de Precio (Q)"),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 1000,
                    divisions: 20,
                    labels: RangeLabels(
                      "Q${_priceRange.start.round()}",
                      "Q${_priceRange.end.round()}",
                    ),
                    onChanged: (val) => setState(() => _priceRange = val),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Q${_priceRange.start.round()}"),
                      Text("Q${_priceRange.end.round()} +"),
                    ],
                  ),

                  const SizedBox(height: 24),
                  _sectionTitle("Calificación Mínima"),
                  Slider(
                    value: _minRating,
                    min: 0,
                    max: 5,
                    divisions: 5,
                    label: "$_minRating estrellas",
                    onChanged: (val) => setState(() => _minRating = val),
                  ),
                  Text(_minRating == 0 ? "Cualquiera" : "$_minRating+ Estrellas"),

                  const SizedBox(height: 24),
                  _sectionTitle("Años de Experiencia"),
                  Slider(
                    value: _minExperience.toDouble(),
                    min: 0,
                    max: 30,
                    divisions: 6,
                    label: "$_minExperience años",
                    onChanged: (val) => setState(() => _minExperience = val.toInt()),
                  ),
                  Text(_minExperience == 0 ? "Cualquiera" : "$_minExperience+ años"),

                  const SizedBox(height: 24),
                  _sectionTitle("Ciudad"),
                  Wrap(
                    spacing: 8,
                    children: _allCities.map((city) {
                      final isSelected = _selectedCities.contains(city);
                      return FilterChip(
                        label: Text(city),
                        selected: isSelected,
                        onSelected: (sel) {
                           setState(() {
                             if (sel) {
                               _selectedCities.add(city);
                             } else {
                               _selectedCities.remove(city);
                             }
                           });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),
                  _sectionTitle("Aseguradora"),
                  Wrap(
                    spacing: 8,
                    children: _allInsurances.map((ins) {
                      final isSelected = _selectedInsurances.contains(ins);
                      return FilterChip(
                        label: Text(ins),
                        selected: isSelected,
                        onSelected: (sel) {
                           setState(() {
                             if (sel) {
                               _selectedInsurances.add(ins);
                             } else {
                               _selectedInsurances.remove(ins);
                             }
                           });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }

  Widget _sortChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _sortBy == value,
      onSelected: (sel) {
        if (sel) setState(() => _sortBy = value);
      },
    );
  }
}
