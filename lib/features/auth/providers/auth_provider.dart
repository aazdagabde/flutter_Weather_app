import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _user;
  User? get user => _user;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _apiService.login(username, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("ERREUR ATTRAPÉE DANS AUTHPROVIDER: $e");
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
      return true;
    } catch (e) {
      print("ERREUR DANS REGISTER PROVIDER: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
