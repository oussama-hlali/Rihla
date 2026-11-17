import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favoris_model.dart';
import '../widgets/destination_card.dart';

class FavorisScreen extends StatelessWidget {
  const FavorisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoris = context.watch<FavorisModel>();
    final liste = favoris.liste;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Text(
                'Favoris',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: liste.isEmpty
                  ? const Center(child: Text('Aucun favori pour le moment'))
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        for (final d in liste)
                          DestinationCard(
                            key: ValueKey(d.id),
                            destination: d,
                            isFavorite: true,
                            onFavoriteToggle: () {},
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
