import 'package:flutter/foundation.dart';

import '../models/destination.dart';

/// Favoris partagés par tous les écrans.

class FavorisModel extends ChangeNotifier {
  // favoris rangés par id : Map<String, Destination>
  final Map<String, Destination> _parId = {};

  // TODO estFavori(Destination d) -> bool
  bool estFavori(Destination d) => _parId.containsKey(d.id);
  // TODO getter liste : les destinations favorites
  List<Destination> get liste => List.unmodifiable(_parId.values);
  // TODO getter nombre
  int get nombre => _parId.length;
  // TODO basculer(Destination d) : ajoute ou retire,
  //      prévient les écouteurs, renvoie true si ajouté
  bool basculer(Destination d) {
    final ajoute = !_parId.containsKey(d.id);
    if (ajoute) {
      _parId[d.id] = d;
    } else {
      _parId.remove(d.id);
    }
    notifyListeners();
    return ajoute;
  }
}
