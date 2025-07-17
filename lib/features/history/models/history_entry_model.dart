class HistoryEntry {
  final String cityName;
  final double temperature;
  final DateTime consultationDate;

  HistoryEntry({
    required this.cityName,
    required this.temperature,
    required this.consultationDate,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      cityName: json['city_name'],
      temperature: double.parse(json['temperature']),
      consultationDate: DateTime.parse(json['consultation_date']),
    );
  }
}
