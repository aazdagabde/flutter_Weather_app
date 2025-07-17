import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../../favorites/screens/favorites_screen.dart';
import '../providers/weather_provider.dart';
import '../widgets/hourly_forecast_item.dart';
import '../../../core/utils/weather_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId != null) {
        // Charger la météo initiale pour Casablanca
        Provider.of<WeatherProvider>(context, listen: false)
            .fetchWeatherByCity("Casablanca");
        // Charger la liste des favoris de l'utilisateur
        Provider.of<FavoritesProvider>(context, listen: false)
            .fetchFavorites(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Météo Now"),
        actions: [
          // Bouton pour voir la liste des favoris
          IconButton(
            icon: const Icon(Icons.folder_special),
            tooltip: "Voir les favoris",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const FavoritesScreen()),
              );
            },
          ),
          // Bouton pour ajouter/supprimer le favori actuel
          Consumer2<FavoritesProvider, WeatherProvider>(
            builder: (context, favoritesProvider, weatherProvider, child) {
              if (weatherProvider.currentCity.isEmpty) {
                return const SizedBox
                    .shrink(); // Ne rien afficher si aucune ville n'est chargée
              }

              final isFavorite =
                  favoritesProvider.isFavorite(weatherProvider.currentCity);

              return IconButton(
                icon: Icon(isFavorite ? Icons.star : Icons.star_border),
                tooltip:
                    isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
                onPressed: () {
                  final userId =
                      Provider.of<AuthProvider>(context, listen: false)
                          .user
                          ?.id;
                  if (userId != null) {
                    favoritesProvider.toggleFavorite(
                        userId, weatherProvider.currentCity);
                  }
                },
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: "Rechercher une ville...",
                      border: InputBorder.none,
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        Provider.of<WeatherProvider>(context, listen: false)
                            .fetchWeatherByCity(value);
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    if (_searchController.text.isNotEmpty) {
                      Provider.of<WeatherProvider>(context, listen: false)
                          .fetchWeatherByCity(_searchController.text);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.my_location),
                  tooltip: "Météo de ma position",
                  onPressed: () {
                    Provider.of<WeatherProvider>(context, listen: false)
                        .fetchWeatherForCurrentLocation();
                  },
                )
              ],
            ),
          ),
        ),
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          if (weatherProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (weatherProvider.weatherData == null) {
            return const Center(
                child: Text("Recherchez une ville pour commencer."));
          }

          final now = DateTime.now();
          final hourlyData = weatherProvider.weatherData!.hourly;

          int futureIndex =
              hourlyData.time.indexWhere((time) => time.isAfter(now));
          int currentIndex = (futureIndex == -1)
              ? hourlyData.time.length - 1
              : (futureIndex > 0 ? futureIndex - 1 : 0);

          final currentTemp = hourlyData.temperatures[currentIndex];
          final currentCode = hourlyData.weatherCodes[currentIndex];
          final weatherDescription =
              WeatherUtils.getWeatherDescription(currentCode);
          final weatherIcon = WeatherUtils.getWeatherIcon(currentCode);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(weatherProvider.currentCity,
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 10),
                      Icon(weatherIcon, size: 80, color: Colors.orangeAccent),
                      const SizedBox(height: 10),
                      Text("${currentTemp.toStringAsFixed(1)}°C",
                          style: Theme.of(context).textTheme.displayLarge),
                      const SizedBox(height: 5),
                      Text(weatherDescription,
                          style: Theme.of(context).textTheme.headlineSmall),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Prévisions horaires",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 24,
                          itemBuilder: (context, index) {
                            final itemIndex = currentIndex + index;
                            if (itemIndex >= hourlyData.time.length)
                              return const SizedBox.shrink();

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: HourlyForecastItem(
                                time: hourlyData.time[itemIndex],
                                temperature: hourlyData.temperatures[itemIndex],
                                weatherCode: hourlyData.weatherCodes[itemIndex],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
