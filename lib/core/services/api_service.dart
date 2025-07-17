import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../features/history/models/history_entry_model.dart';
import '../models/user_model.dart';
import '../../features/weather/models/weather_data_model.dart';

class ApiService {
  final String _baseUrl = "http://10.0.2.2/backend_weather_app";

  Future<User> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/login.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      // On décode le message d'erreur de l'API et on le lance
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Échec de la connexion.');
    }
  }

  // CORRECTION : Le type de retour est maintenant Future<void>
  Future<void> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/register.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    // CORRECTION : On vérifie le code 201 Created pour un succès
    if (response.statusCode == 201) {
      // L'inscription a réussi, on n'a rien besoin de retourner.
      return;
    } else {
      // Si ça échoue, on récupère le message d'erreur de l'API.
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Échec de l\'inscription.');
    }
  }

  //obtenir les donnees de l api de open-meteo (api open source)
  Future<WeatherData> fetchWeather(double laltitude, double longitude) async {
    final String weatherUrl =
        "https://api.open-meteo.com/v1/forecast?latitude=$laltitude&longitude=$longitude&hourly=temperature_2m,weathercode";
    final response = await http.get(Uri.parse(weatherUrl));
    if (response.statusCode == 200) {
      return WeatherData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Impossible de charger les donnéés météo');
    }
  }

  // Cette méthode récupère les coordonnées d'une ville (api open source)
  Future<Map<String, double>> getCoordinates(String cityName) async {
    final String geocodingUrl =
        "https://geocoding-api.open-meteo.com/v1/search?name=$cityName&count=1";
    final response = await http.get(Uri.parse(geocodingUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        final location = data['results'][0];
        return {
          'latitude': location['latitude'],
          'longitude': location['longitude'],
        };
      } else {
        throw Exception('Ville non trouvée.');
      }
    } else {
      throw Exception('Erreur de géocodage.');
    }
  }

  Future<List<String>> getFavorites(int userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/favorites/get.php?user_id=$userId'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      // On transforme la liste de maps en liste de strings
      return data.map((item) => item['city_name'].toString()).toList();
    } else {
      throw Exception('Impossible de charger les favoris.');
    }
  }

  Future<void> addFavorite(int userId, String cityName) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/favorites/add.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'city_name': cityName}),
    );

    if (response.statusCode != 201) {
      throw Exception('Impossible d\'ajouter le favori.');
    }
  }

  Future<void> removeFavorite(int userId, String cityName) async {
    final response = await http.post(
      // ou http.delete si vous avez configuré le serveur pour
      Uri.parse('$_baseUrl/api/favorites/remove.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'city_name': cityName}),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Impossible de supprimer le favori.');
    }
  }

  Future<void> addHistory(
      int userId, String cityName, double temperature) async {
    final response = await http.post(Uri.parse('$_baseUrl/api/history/add.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'city_name': cityName,
          'temperature': temperature,
        }));

    if (response.statusCode != 201) {
      throw Exception('Impossible d\' ajouter à l\'historique.');
    }
  }

  Future<List<HistoryEntry>> getHistory(int userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/history/get.php?user_id=$userId'),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => HistoryEntry.fromJson(item)).toList();
    } else {
      throw Exception('Impossible de charger l\'historique .');
    }
  }
}
