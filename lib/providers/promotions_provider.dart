import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/evento_promocion.dart';

class PromotionFilter {
  final String? category;
  final String? type; // evento, promocion
  final bool? onlyProfessional;

  const PromotionFilter({this.category, this.type, this.onlyProfessional});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromotionFilter &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          type == other.type &&
          onlyProfessional == other.onlyProfessional;

  @override
  int get hashCode => category.hashCode ^ type.hashCode ^ onlyProfessional.hashCode;
}

// Mock Repository
class PromotionRepository {
  final List<EventoPromocion> _items = [
    EventoPromocion(
      id: 'promo_1',
      titulo: 'Jornada de presión arterial',
      descripcion: 'Evaluación cardiovascular gratuita este sábado.',
      tipo: 'evento',
      category: 'General',
      fecha: DateTime.now().add(const Duration(days: 2)),
      autorNombre: 'Clínica Vida Sana',
      autorTipo: 'clinica',
    ),
    EventoPromocion(
      id: 'promo_2',
      titulo: '50% descuento en chequeo mujer',
      descripcion: 'Consulta ginecológica y papanicolaou.',
      tipo: 'promocion',
      category: 'Salud Femenina',
      fecha: DateTime.now(),
      autorNombre: 'Hospital Los Pinos',
      autorTipo: 'hospital',
    ),
    EventoPromocion(
      id: 'promo_3',
      titulo: 'Limpieza Dental 2x1',
      descripcion: 'Válido todo el mes de octubre.',
      tipo: 'promocion',
      category: 'Dental',
      fecha: DateTime.now(),
      autorNombre: 'Dra. Ana López',
      autorTipo: 'doctor',
      professionalId: '2', // Matches mock doctor ID
    ),
    EventoPromocion(
      id: 'promo_4',
      titulo: 'Charla: Manejo del Estrés',
      descripcion: 'Webinar gratuito por Zoom.',
      tipo: 'evento',
      category: 'Salud Mental',
      fecha: DateTime.now().add(const Duration(days: 5)),
      autorNombre: 'Lic. Carlos Ruiz',
      autorTipo: 'doctor',
      professionalId: '3',
    ),
  ];

  Future<List<EventoPromocion>> getPromotions({PromotionFilter? filter}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (filter == null) return _items;

    return _items.where((p) {
      if (filter.category != null && p.category != filter.category) return false;
      if (filter.type != null && p.tipo != filter.type) return false;
      if (filter.onlyProfessional == true && p.professionalId == null) return false;
      return true;
    }).toList();
  }

  Future<void> addPromotion(EventoPromocion promo) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _items.insert(0, promo);
  }
}

// Provider
final promotionRepositoryProvider = Provider((ref) => PromotionRepository());

// StateNotifier for the Page
class PromotionsNotifier extends StateNotifier<List<EventoPromocion>> {
  final PromotionRepository _repo;

  PromotionsNotifier(this._repo) : super([]) {
    load();
  }

  Future<void> load({PromotionFilter? filter}) async {
    state = await _repo.getPromotions(filter: filter);
  }

  Future<void> add(EventoPromocion promo) async {
    await _repo.addPromotion(promo);
    await load(); // Reload all
  }
}

final promotionsProvider = StateNotifierProvider.family<PromotionsNotifier, List<EventoPromocion>, PromotionFilter?>((ref, filter) {
  return PromotionsNotifier(ref.watch(promotionRepositoryProvider));
});
