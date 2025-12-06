import 'package:flutter/material.dart';
import '../../services/promociones_service_mock.dart';
import '../favoritos/favorites_service.dart';
import '../../models/evento_promocion.dart';

class InicioNoticiasPage extends StatefulWidget {
  const InicioNoticiasPage({super.key});

  @override
  State<InicioNoticiasPage> createState() => _InicioNoticiasPageState();
}

class _InicioNoticiasPageState extends State<InicioNoticiasPage> {
  final _service = PromocionesServiceMock();
  late Future<List<EventoPromocion>> _futureEventos;

  @override
  void initState() {
    super.initState();
    _futureEventos = _service.obtenerEventos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Noticias y Promociones")),
      body: FutureBuilder<List<EventoPromocion>>(
        future: _futureEventos,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final eventos = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: eventos.length,
            itemBuilder: (_, i) => _buildCard(eventos[i]),
          );
        },
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
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: tipoColor[item.tipo] ?? Colors.blueGrey,
          child: const Icon(Icons.campaign, color: Colors.white),
        ),
        title: Text(item.titulo),
        subtitle: Text(item.descripcion),

        /// ⭐ FAVORITOS
        trailing: IconButton(
          icon: Icon(
            FavoritesService().esPromocionFavorita(item.id)
                ? Icons.star
                : Icons.star_border,
            color: Colors.amber,
          ),
          onPressed: () async {
            await FavoritesService().togglePromocionFavorita(item.id);
            setState(() {});
          },
        ),
      ),
    );
  }
}
