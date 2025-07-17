import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';

class FavoritesProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<String> _favoriteCities = [];
  List<String> get favoriteCities => _favoriteCities;

  bool isFavorite(String cityName) {
    return _favoriteCities.contains(cityName);
  }

  Future<void> fetchFavorites(int userId) async {
    try {
      _favoriteCities = await _apiService.getFavorites(userId);
      notifyListeners();
    } catch (e) {
      print("Erreur fetchFavorites: $e");
    }
  }

  Future<void> toggleFavorite(int userId, String cityName) async {
    final isCurrentlyFavorite = isFavorite(cityName);

    if (isCurrentlyFavorite) {
      // Si c'est déjà un favori, on le supprime
      _favoriteCities.remove(cityName);
      notifyListeners(); // Met à jour l'UI immédiatement pour la réactivité
      try {
        await _apiService.removeFavorite(userId, cityName);
      } catch (e) {
        // En cas d'erreur, on le rajoute à la liste
        _favoriteCities.add(cityName);
        notifyListeners();
        print("Erreur removeFavorite: $e");
      }
    } else {
      // Sinon, on l'ajoute
      _favoriteCities.add(cityName);
      notifyListeners();
      try {
        await _apiService.addFavorite(userId, cityName);
      } catch (e) {
        // En cas d'erreur, on le retire de la liste
        _favoriteCities.remove(cityName);
        notifyListeners();
        print("Erreur addFavorite: $e");
      }
    }
  }
}
