class WeatherData {
  final HourlyData hourly;

  WeatherData({required this.hourly});

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      hourly: HourlyData.fromJson(json['hourly']),
    );
  }
}

class HourlyData {
  final List<DateTime> time;
  final List<double> temperatures;
  final List<int> weatherCodes;

  HourlyData({
    required this.time,
    required this.temperatures,
    required this.weatherCodes,
  });

  factory HourlyData.fromJson(Map<String, dynamic> json) {
    return HourlyData(
      time: List<String>.from(json['time'])
          .map((e) => DateTime.parse(e))
          .toList(),
      temperatures:
          List<double>.from(json['temperature_2m'].map((e) => e.toDouble())),
      weatherCodes: List<int>.from(json['weathercode']),
    );
  }
}
