import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../../weather/providers/weather_provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Villes Favorites"),
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
          if (favoritesProvider.favoriteCities.isEmpty) {
            return const Center(child: Text("Vous n'avez aucun favori."));
          }

          return ListView.builder(
            itemCount: favoritesProvider.favoriteCities.length,
            itemBuilder: (context, index) {
              final city = favoritesProvider.favoriteCities[index];
              return ListTile(
                title: Text(city),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // 1. Récupérer l'ID de l'utilisateur connecté
                  final userId =
                      Provider.of<AuthProvider>(context, listen: false)
                          .user
                          ?.id;

                  // 2. Vérifier que l'utilisateur est bien connecté
                  if (userId != null) {
                    // 3. Appeler la fonction avec les DEUX arguments
                    Provider.of<WeatherProvider>(context, listen: false)
                        .fetchWeatherByCity(city, userId);

                    // 4. Revenir à l'écran d'accueil
                    Navigator.of(context).pop();
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
