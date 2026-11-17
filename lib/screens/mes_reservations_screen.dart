import 'package:flutter/material.dart';

import '../models/reservation.dart';
import '../services/api_service.dart';
import '../widgets/erreur_reseau.dart';

class MesReservationsScreen extends StatefulWidget {
  const MesReservationsScreen({super.key});

  @override
  State<MesReservationsScreen> createState() => _MesReservationsScreenState();
}

class _MesReservationsScreenState extends State<MesReservationsScreen> {
  late Future<List<Reservation>> _futurReservations;

  @override
  void initState() {
    super.initState();
    // Une seule requête, jamais dans build()
    _futurReservations = ApiService.getReservations();
  }

  Future<void> _recharger() async {
    final futur = ApiService.getReservations();
    setState(() {
      _futurReservations = futur;
    });
    try {
      await futur;
    } catch (_) {}
  }

  String _formaterDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  Widget _construireListe(List<Reservation> reservations) {
    if (reservations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.luggage_outlined, size: 56),
            SizedBox(height: 12),
            Text('Aucune réservation pour le moment'),
          ],
        ),
      );
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [for (final r in reservations) _construireCarte(r)],
    );
  }

  Widget _construireCarte(Reservation r) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                r.destination.image,
                width: 88,
                height: 88,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.destination.nom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 16,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Départ le ${_formaterDate(r.dateDepart)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.group_outlined,
                        size: 16,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${r.voyageurs} voyageur(s) · ${r.formule}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${r.total} DT',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Text(
                'Mes voyages',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Reservation>>(
                future: _futurReservations,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    debugPrint('ERREUR API : ${snapshot.error}');
                    return ErreurReseau(
                      message: 'Impossible de charger vos réservations.',
                      onReessayer: _recharger,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _recharger,
                    child: _construireListe(snapshot.data!),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
