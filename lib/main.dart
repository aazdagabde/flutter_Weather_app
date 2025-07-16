import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- Importer vos futurs fichiers ---
// Providers
import 'features/auth/providers/auth_provider.dart';
import 'features/weather/providers/weather_provider.dart';
import 'features/favorites/providers/favorites_provider.dart';
import 'features/history/providers/history_provider.dart';

// Premier écran
import 'features/auth/screens/login_screen.dart';

void main() {
  runApp(
    // On utilise MultiProvider pour déclarer tous nos providers
    // au plus haut niveau de l'application.
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        // ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        //ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Météo Now',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // L'écran de départ de votre application
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
