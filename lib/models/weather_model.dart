class WeatherModel {
  final String cityName;
  final String country;
  final double temperature;
  final String description;
  final String icon;
  final double humidity;
  final double windSpeed;
  final double feelsLike;
  final int pressure;
  final int visibility;
  final DateTime dateTime;
  final double lat;
  final double lon;

  WeatherModel({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.feelsLike,
    required this.pressure,
    required this.visibility,
    required this.dateTime,
    required this.lat,
    required this.lon,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] ?? 'Ville inconnue',
      country: json['sys']['country'] ?? '',
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '01d',
      humidity: (json['main']['humidity'] as num).toDouble(),
      windSpeed: (json['wind']['speed'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      pressure: json['main']['pressure'] ?? 0,
      visibility: json['visibility'] ?? 0,
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        json['dt'] * 1000,
        isUtc: true,
      ).toLocal(),
      lat: (json['coord']['lat'] as num).toDouble(),
      lon: (json['coord']['lon'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'country': country,
      'temperature': temperature,
      'description': description,
      'icon': icon,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'feelsLike': feelsLike,
      'pressure': pressure,
      'visibility': visibility,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'lat': lat,
      'lon': lon,
    };
  }

  String get formattedTemperature => '${temperature.round()}°C';
  String get formattedFeelsLike => '${feelsLike.round()}°C';
  String get formattedHumidity => '${humidity.round()}%';
  String get formattedWindSpeed => '${windSpeed.toStringAsFixed(1)} m/s';
  String get formattedPressure => '${pressure} hPa';
  String get formattedVisibility =>
      '${(visibility / 1000).toStringAsFixed(1)} km';

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';

  String get capitalizedDescription {
    if (description.isEmpty) return '';
    return description[0].toUpperCase() + description.substring(1);
  }

  String get fullLocation => '$cityName, $country';

  @override
  String toString() {
    return 'WeatherModel(city: $cityName, temp: $formattedTemperature, desc: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeatherModel &&
        other.cityName == cityName &&
        other.country == country &&
        other.temperature == temperature;
  }

  @override
  int get hashCode {
    return cityName.hashCode ^ country.hashCode ^ temperature.hashCode;
  }
}
