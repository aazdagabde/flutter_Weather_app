import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../models/history_entry_model.dart';

class HistoryProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<HistoryEntry> _historyEntries = [];
  List<HistoryEntry> get historyEntries => _historyEntries;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchHistory(int userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _historyEntries = await _apiService.getHistory(userId);
    } catch (e) {
      print("Erreur fetchHistory: $e");
      _historyEntries = []; // En cas d'erreur, on vide la liste
    }
    _isLoading = false;
    notifyListeners();
  }
}
