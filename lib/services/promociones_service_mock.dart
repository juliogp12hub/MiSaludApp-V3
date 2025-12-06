import '../models/evento_promocion.dart';

class PromocionesServiceMock {
  final List<EventoPromocion> _items = [
    EventoPromocion(
      id: '1',
      titulo: 'Jornada de presión arterial',
      descripcion:
          'Este sábado tendremos toma de presión, consejería nutricional y evaluación cardiovascular gratuita.',
      tipo: 'evento',
      fecha: DateTime.now().add(const Duration(days: 2)),
      autorNombre: 'Clínica Vida Sana',
      autorTipo: 'clinica',
    ),
    EventoPromocion(
      id: '2',
      titulo: '50% descuento en chequeo anual de mujer',
      descripcion:
          'Incluye consulta ginecológica, papanicolaou y ultrasonido pélvico.',
      tipo: 'promocion',
      fecha: DateTime.now(),
      autorNombre: 'Hospital Los Pinos',
      autorTipo: 'hospital',
    ),
    EventoPromocion(
      id: '3',
      titulo: 'Recordatorio: tu mamografía anual',
      descripcion: 'Si tienes +40 años, realiza una mamografía cada 1–2 años.',
      tipo: 'recordatorio',
      fecha: DateTime.now(),
      autorNombre: 'MiSaludApp',
      autorTipo: 'app',
    ),
  ];

  Future<List<EventoPromocion>> obtenerEventos({String? tipo}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (tipo == null) return _items;
    return _items.where((e) => e.tipo == tipo).toList();
  }
}
