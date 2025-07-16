import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/weather_utils.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/hourly_forecast_item.dart';

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
    // On déclenche la récupération des données dès que l'écran est prêt.
    Future.microtask(() {
      // Coordonnées de Casablanca pour le premier chargement
      Provider.of<WeatherProvider>(context, listen: false)
          .fetchWeatherByCity("Casablanca");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Météo Now"),
        /*actions: [
          // <-- Ajoutez cette section "actions"
          Consumer<FavoritesProvider>(
            // Pour gérer l'état de l'étoile
            builder: (context, favoritesProvider, child) {
              //final isFavorite = favoritesProvider.isFavorite(weatherProvider.currentCity);
              return IconButton(
                icon: Icon(/*isFavorite ? Icons.star :*/ Icons.star_border),
                onPressed: () {
                  // Logique à venir pour ajouter/supprimer
                },
              );
            },
          )
        ],*/
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                )
              ],
            ),
          ),
        ),
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          // Cas 1 : Si les données sont en cours de chargement
          if (weatherProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Cas 2 : Si les données ne sont pas encore chargées
          if (weatherProvider.weatherData == null) {
            return const Center(
              child:
                  Text("Aucune donnée météo disponible. Recherchez une ville."),
            );
          }

          // Cas 3 : Les données sont disponibles, on les affiche !
          final now = DateTime.now();
          final hourlyData = weatherProvider.weatherData!.hourly;

          // Trouver l'index de l'heure actuelle
          int futureIndex =
              hourlyData.time.indexWhere((time) => time.isAfter(now));
          int currentIndex = (futureIndex == -1)
              ? hourlyData.time.length - 1
              : (futureIndex > 0 ? futureIndex - 1 : 0);

          // Utiliser cet index pour obtenir les bonnes données
          final currentTemp = hourlyData.temperatures[currentIndex];
          final currentCode = hourlyData.weatherCodes[currentIndex];

          final weatherDescription =
              WeatherUtils.getWeatherDescription(currentCode);
          final weatherIcon = WeatherUtils.getWeatherIcon(currentCode);

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Section de la météo actuelle
                Column(
                  children: [
                    Text(
                      weatherProvider.currentCity,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 10),
                    Icon(
                      weatherIcon,
                      size: 80,
                      color: Colors.orangeAccent,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${currentTemp.toStringAsFixed(1)}°C",
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      weatherDescription,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),

                // Section des prévisions horaires
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Prévisions horaires",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
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
              ],
            ),
          );
        },
      ),
    );
  }
}
