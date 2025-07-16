import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/weather_utils.dart';

class HourlyForecastItem extends StatelessWidget {
  final DateTime time;
  final double temperature;
  final int weatherCode;

  const HourlyForecastItem({
    super.key,
    required this.time,
    required this.temperature,
    required this.weatherCode,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Affiche l'heure (ex: 14:00)
            Text(
              DateFormat.Hm().format(time),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Affiche l'icône météo
            Icon(
              WeatherUtils.getWeatherIcon(weatherCode),
              size: 32,
            ),
            const SizedBox(height: 8),
            // Affiche la température
            Text("${temperature.toStringAsFixed(1)}°C"),
          ],
        ),
      ),
    );
  }
}
