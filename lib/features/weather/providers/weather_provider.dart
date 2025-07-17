import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../models/weather_data_model.dart';
import 'package:geolocator/geolocator.dart';

class WeatherProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  WeatherData? _weatherData;
  WeatherData? get weatherData => _weatherData;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchWeather(double lat, double lon) async {
    _isLoading = true;
    notifyListeners();

    try {
      _weatherData = await _apiService.fetchWeather(lat, lon);
      print(
          "Données météo reçues ! Température actuelle : ${_weatherData?.hourly.temperatures.first}°C");
    } catch (e) {
      print("ERREUR DANS WEATHER PROVIDER: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // Dans la classe WeatherProvider

  String _currentCity =
      "Casablanca"; // Pour garder en mémoire la ville actuelle
  String get currentCity => _currentCity;

  Future<void> fetchWeatherByCity(String cityName) async {
    _isLoading = true;
    notifyListeners();
    try {
      // 1. Obtenir les coordonnées de la ville
      final coords = await _apiService.getCoordinates(cityName);
      final lat = coords['latitude']!;
      final lon = coords['longitude']!;

      // 2. Utiliser la méthode existante pour récupérer la météo
      await fetchWeather(lat, lon);
      _currentCity = cityName; // Mettre à jour le nom de la ville
    } catch (e) {
      print("ERREUR fetchWeatherByCity: $e");
      // Optionnel : gérer l'erreur pour l'afficher à l'utilisateur
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchWeatherForCurrentLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Gérer les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permissions de localisation refusées.');
        }
      }

      // 2. Obtenir la position actuelle
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          forceAndroidLocationManager: true // <-- AJOUTEZ CE PARAMÈTRE

          );

      // 3. Récupérer le nom de la ville à partir des coordonnées (optionnel mais mieux)
      // Vous pouvez créer une méthode getCityNameFromCoords dans votre ApiService si vous le souhaitez.
      // Pour l'instant, on récupère juste la météo.
      _currentCity = "Ma Position"; // Nom temporaire

      // 4. Utiliser la méthode existante pour récupérer la météo
      await fetchWeather(position.latitude, position.longitude);
    } catch (e) {
      print("ERREUR de géolocalisation: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
