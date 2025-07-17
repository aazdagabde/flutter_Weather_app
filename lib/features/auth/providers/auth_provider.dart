import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _user;
  User? get user => _user;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null; // Réinitialiser l'erreur

    notifyListeners();

    try {
      _user = await _apiService.login(username, password);

// --- AJOUT : Sauvegarder la session ---
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt('userId', _user!.id);
      prefs.setString('username', _user!.username);
// --- FIN DE L'AJOUT ---
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;

      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.register(username, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("ERREUR DANS REGISTER PROVIDER: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Nouvelle méthode pour tenter une connexion automatique
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userId')) {
      return false;
    }

    final userId = prefs.getInt('userId');
    final username = prefs.getString('username');
    _user = User(id: userId!, username: username!);
    notifyListeners();
    return true;
  }

// Nouvelle méthode pour la déconnexion
  Future<void> logout() async {
    _user = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear(); // Supprime toutes les données sauvegardées
  }
}
