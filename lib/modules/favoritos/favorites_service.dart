import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  FavoritesService._internal();
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;

  static const _keyFavoritosDoctores = "favoritos_doctores";
  static const _keyFavoritosPromociones = "favoritos_promociones";

  List<String> _doctorIds = [];
  List<String> _promoIds = [];

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    _doctorIds = prefs.getStringList(_keyFavoritosDoctores) ?? [];
    _promoIds = prefs.getStringList(_keyFavoritosPromociones) ?? [];
  }

  // ---------------------------------------------------------------------------
  // MÉTODOS ESPECÍFICOS PARA DOCTORES
  // ---------------------------------------------------------------------------
  bool esDoctorFavorito(String id) => _doctorIds.contains(id);

  Future<void> toggleDoctorFavorito(String id) async {
    final prefs = await SharedPreferences.getInstance();
    _doctorIds = prefs.getStringList(_keyFavoritosDoctores) ?? [];

    if (_doctorIds.contains(id)) {
      _doctorIds.remove(id);
    } else {
      _doctorIds.add(id);
    }

    await prefs.setStringList(_keyFavoritosDoctores, _doctorIds);
  }

  List<String> obtenerDoctoresFavoritos() => List.unmodifiable(_doctorIds);

  // ---------------------------------------------------------------------------
  // MÉTODOS ESPECÍFICOS PARA PROMOCIONES / NOTICIAS
  // ---------------------------------------------------------------------------
  bool esPromocionFavorita(String id) => _promoIds.contains(id);

  Future<void> togglePromocionFavorita(String id) async {
    final prefs = await SharedPreferences.getInstance();
    _promoIds = prefs.getStringList(_keyFavoritosPromociones) ?? [];

    if (_promoIds.contains(id)) {
      _promoIds.remove(id);
    } else {
      _promoIds.add(id);
    }

    await prefs.setStringList(_keyFavoritosPromociones, _promoIds);
  }

  List<String> obtenerPromocionesFavoritas() => List.unmodifiable(_promoIds);

  // ---------------------------------------------------------------------------
  // API UNIVERSAL (se usa en detalle y en otras pantallas)
  // ---------------------------------------------------------------------------
  Future<bool> esFavorito(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final docs = prefs.getStringList(_keyFavoritosDoctores) ?? [];
    final promos = prefs.getStringList(_keyFavoritosPromociones) ?? [];
    return docs.contains(id) || promos.contains(id);
  }

  Future<void> toggleFavorito({
    required String id,
    required String tipo,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    _doctorIds = prefs.getStringList(_keyFavoritosDoctores) ?? [];
    _promoIds = prefs.getStringList(_keyFavoritosPromociones) ?? [];

    final lower = tipo.toLowerCase();

    // Lo tratamos como promoción / noticia
    if (lower.contains("promo") ||
        lower.contains("evento") ||
        lower.contains("noticia") ||
        lower.contains("artículo") ||
        lower.contains("articulo")) {
      if (_promoIds.contains(id)) {
        _promoIds.remove(id);
      } else {
        _promoIds.add(id);
      }
    } else {
      // Por defecto: profesional de salud
      if (_doctorIds.contains(id)) {
        _doctorIds.remove(id);
      } else {
        _doctorIds.add(id);
      }
    }

    await prefs.setStringList(_keyFavoritosDoctores, _doctorIds);
    await prefs.setStringList(_keyFavoritosPromociones, _promoIds);
  }

  List<String> obtenerTodosFavoritos() =>
      List.unmodifiable({..._doctorIds, ..._promoIds});
}
