import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/api_service.dart';
import '../models/weather_data_model.dart';

class WeatherProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  WeatherData? _weatherData;
  WeatherData? get weatherData => _weatherData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _currentCity = "";
  String get currentCity => _currentCity;

  // Méthode interne qui fait le vrai travail
  Future<void> fetchWeather(double lat, double lon, int userId) async {
    // Cette méthode ne change pas, elle a déjà le paramètre userId
    _weatherData = await _apiService.fetchWeather(lat, lon);

    final currentTemp = _weatherData!.hourly.temperatures.first;
    // On enregistre dans l'historique avec le bon userId
    await _apiService.addHistory(userId, _currentCity, currentTemp);
  }

  // CORRECTION : On ajoute le paramètre userId
  Future<void> fetchWeatherByCity(String cityName, int userId) async {
    _isLoading = true;
    _currentCity = cityName; // Mettre à jour la ville immédiatement
    notifyListeners();
    try {
      final coords = await _apiService.getCoordinates(cityName);
      // On passe le userId à la méthode fetchWeather
      await fetchWeather(coords['latitude']!, coords['longitude']!, userId);
    } catch (e) {
      print("ERREUR fetchWeatherByCity: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  // CORRECTION : On ajoute le paramètre userId
  Future<void> fetchWeatherForCurrentLocation(int userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permissions de localisation refusées.');
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          forceAndroidLocationManager: true);

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      String cityName = "Position Actuelle";
      if (placemarks.isNotEmpty) {
        cityName = placemarks.first.locality ?? "Position Actuelle";
      }
      _currentCity = "$cityName (Ma Position)";

      // On passe le userId à la méthode fetchWeather
      await fetchWeather(position.latitude, position.longitude, userId);
    } catch (e) {
      print("ERREUR de géolocalisation: $e");
    }
    _isLoading = false;
    notifyListeners();
  }
}
