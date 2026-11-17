import 'package:flutter/material.dart';

import '../data/destinations.dart';
import '../models/destination.dart';
import '../screens/mes_reservations_screen.dart';
import '../services/api_service.dart';
import '../widgets/destination_card.dart';
import '../widgets/erreur_reseau.dart';
import '../widgets/hero_banner.dart';
import '../widgets/home_header.dart';
import '../widgets/search_box.dart';
import '../widgets/section_title.dart';

import 'package:provider/provider.dart';

import '../providers/favoris_model.dart';
import '../screens/favoris_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _categorie = 'Tout';
  int _onglet = 0;

  late Future<List<Destination>> _futurDestinations;

  @override
  void initState() {
    super.initState();
    // TODO 1 : une seule requête, jamais dans build()
    _futurDestinations = ApiService.getDestinations();
  }

  List<Destination> _filtrer(List<Destination> toutes) => _categorie == 'Tout'
      ? toutes
      : toutes.where((d) => d.categorie == _categorie).toList();

  Future<void> _recharger() async {
    final futur = ApiService.getDestinations();
    setState(() {
      _futurDestinations = futur;
    });
    try {
      await futur;
    } catch (_) {}
  }

  Widget _construireExplorer() {
    return FutureBuilder<List<Destination>>(
      future: _futurDestinations,
      builder: (context, snapshot) {
        // TODO 2 : chargement
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          debugPrint('ERREUR API : ${snapshot.error}');
          return ErreurReseau(
            message: 'Impossible de charger les destinations.',
            onReessayer: _recharger,
          );
        }
        // TODO 3 : erreur
        if (snapshot.hasError) {
          return ErreurReseau(
            message: 'Impossible de charger les destinations.',
            onReessayer: _recharger,
          );
        }
        final destinations = snapshot.data!;
        return RefreshIndicator(
          onRefresh: _recharger,
          child: _construireAccueil(destinations),
        );
      },
    );
  }

  Widget _construireAccueil(List<Destination> destinations) {
    final filtrees = _filtrer(destinations);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        const HomeHeader(prenom: 'Oussama'),
        const SizedBox(height: 20),
        const SearchBox(),
        const SizedBox(height: 16),
        if (destinations.isNotEmpty)
          HeroBanner(destination: destinations.first),
        const SizedBox(height: 24),
        const SectionTitle(title: 'Categories'),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final c in categories)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: _categorie == c,
                    onSelected: (_) {
                      setState(() {
                        _categorie = c;
                      });
                    },
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const SectionTitle(title: 'Destinations populaires'),
        const SizedBox(height: 12),
        for (final d in filtrees)
          DestinationCard(
            key: ValueKey(d.id),
            destination: d,
            isFavorite: false,
            onFavoriteToggle: () {},
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget corps;
    final nombre = context.watch<FavorisModel>().nombre;
    switch (_onglet) {
      case 0:
        corps = _construireExplorer();
      case 1:
        corps = const FavorisScreen();
      case 2:
        corps = const MesReservationsScreen();
      default:
        corps = const Center(child: Text('Bientôt disponible'));
    }
    return Scaffold(
      body: SafeArea(child: corps),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _onglet,
        onDestinationSelected: (index) {
          setState(() {
            _onglet = index;
          });
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explorer',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: nombre > 0,
              label: Text('$nombre'),
              child: const Icon(Icons.favorite_border),
            ),
            selectedIcon: const Icon(Icons.favorite),
            label: 'Favoris',
          ),
          const NavigationDestination(
            icon: Icon(Icons.luggage_outlined),
            selectedIcon: Icon(Icons.luggage),
            label: ' Mes Voyages',
          ),
        ],
      ),
    );
  }
}
