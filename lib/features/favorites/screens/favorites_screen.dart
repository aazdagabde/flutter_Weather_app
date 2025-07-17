import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                  // Au clic, on cherche la météo de cette ville et on revient à l'accueil
                  Provider.of<WeatherProvider>(context, listen: false)
                      .fetchWeatherByCity(city);
                  Navigator.of(context).pop();
                },
              );
            },
          );
        },
      ),
    );
  }
}
