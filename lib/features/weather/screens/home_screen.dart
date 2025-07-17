import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import '../../auth/providers/auth_provider.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../../history/providers/history_provider.dart';
import '../providers/weather_provider.dart';

// Screens
import '../../auth/screens/splash_screen.dart';
import '../../favorites/screens/favorites_screen.dart';
import '../../history/screens/history_screen.dart';

// Widgets & Utils
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
        Provider.of<WeatherProvider>(context, listen: false)
            .fetchWeatherByCity("Casablanca", userId);
        Provider.of<FavoritesProvider>(context, listen: false)
            .fetchFavorites(userId);
        Provider.of<HistoryProvider>(context, listen: false)
            .fetchHistory(userId);
      }
    });
  }

  void _unfocus() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text(
          "Météo Now",
          style: TextStyle(color: Colors.white),
        ),
        // --- LA SECTION "ACTIONS" EST DE RETOUR ---
        actions: [
          Consumer2<FavoritesProvider, WeatherProvider>(
            builder: (context, favoritesProvider, weatherProvider, child) {
              if (weatherProvider.currentCity.isEmpty) {
                return const SizedBox.shrink();
              }
              final isFavorite =
                  favoritesProvider.isFavorite(weatherProvider.currentCity);
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: Colors.white,
                ),
                tooltip:
                    isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
                onPressed: () {
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
                      hintStyle: TextStyle(color: Colors.white),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: (value) {
                      if (value.isNotEmpty && userId != null) {
                        Provider.of<WeatherProvider>(context, listen: false)
                            .fetchWeatherByCity(value, userId);
                        _unfocus();
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    if (_searchController.text.isNotEmpty && userId != null) {
                      Provider.of<WeatherProvider>(context, listen: false)
                          .fetchWeatherByCity(_searchController.text, userId);
                      _unfocus();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.my_location, color: Colors.white),
                  tooltip: "Météo de ma position",
                  onPressed: () {
                    if (userId != null) {
                      Provider.of<WeatherProvider>(context, listen: false)
                          .fetchWeatherForCurrentLocation(userId);
                      _unfocus();
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              margin: EdgeInsets.only(top: 40),
              decoration: const BoxDecoration(color: Colors.blueGrey),
              child: Text(
                'Météo Now',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.white),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Mes Favoris'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FavoritesScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Mon Historique'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HistoryScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Déconnexion'),
              onTap: () async {
                await Provider.of<AuthProvider>(context, listen: false)
                    .logout();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const SplashScreen()),
                      (route) => false);
                }
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            // On charge l'image depuis les assets
            image: AssetImage("assets/images/bg.jpg"),
            // On s'assure que l'image couvre tout l'écran
            fit: BoxFit.cover,
          ),
        ),
        child: Consumer<WeatherProvider>(
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

            return RefreshIndicator(
              onRefresh: () async {
                if (userId != null) {
                  await Provider.of<WeatherProvider>(context, listen: false)
                      .fetchWeatherByCity(weatherProvider.currentCity, userId);
                }
              },
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 50.0, horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 100,
                        ),
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
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
                                  temperature:
                                      hourlyData.temperatures[itemIndex],
                                  weatherCode:
                                      hourlyData.weatherCodes[itemIndex],
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
      ),
    );
  }
}
