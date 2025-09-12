import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

enum WeatherStatus {
  initial, // État initial
  loading, // Chargement en cours
  loaded, // Données chargées avec succès
  error, // Erreur
}

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();

  // État actuel
  WeatherStatus _status = WeatherStatus.initial;
  WeatherModel? _currentWeather;
  String _errorMessage = '';

  // Dernière ville recherchée
  String _lastSearchedCity = '';

  // Getters
  WeatherStatus get status => _status;
  WeatherModel? get currentWeather => _currentWeather;
  String get errorMessage => _errorMessage;
  String get lastSearchedCity => _lastSearchedCity;

  // Getters de statut utiles
  bool get isLoading => _status == WeatherStatus.loading;
  bool get hasData =>
      _status == WeatherStatus.loaded && _currentWeather != null;
  bool get hasError => _status == WeatherStatus.error;
  bool get isEmpty => _status == WeatherStatus.initial;

  /// Obtenir la météo par nom de ville
  Future<void> getWeatherByCity(String cityName) async {
    if (cityName.trim().isEmpty) {
      _setError('Veuillez entrer un nom de ville');
      return;
    }

    _setLoading();

    try {
      print('🔍 Provider: Recherche météo pour $cityName');

      final weather = await _weatherService.getCurrentWeatherByCity(cityName);

      _currentWeather = weather;
      _lastSearchedCity = cityName;
      _status = WeatherStatus.loaded;
      _errorMessage = '';

      print('✅ Provider: Météo chargée pour ${weather.cityName}');
      notifyListeners();
    } catch (e) {
      print('❌ Provider: Erreur météo: $e');
      _setError(e.toString().replaceAll('WeatherException: ', ''));
    }
  }

  /// Obtenir la météo par géolocalisation
  Future<void> getWeatherByCurrentLocation() async {
    _setLoading();

    try {
      // Vérifier les permissions de géolocalisation
      print('📍 Provider: Vérification permissions GPS...');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permission de géolocalisation refusée');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Permission de géolocalisation refusée définitivement. Activez-la dans les paramètres.',
        );
      }

      // Vérifier si le service de géolocalisation est activé
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception(
          'Service de géolocalisation désactivé. Activez le GPS.',
        );
      }

      // Obtenir la position actuelle
      print('🌍 Provider: Récupération position GPS...');

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print(
        '📍 Provider: Position trouvée: ${position.latitude}, ${position.longitude}',
      );

      // Obtenir la météo pour cette position
      final weather = await _weatherService.getCurrentWeatherByCoordinates(
        position.latitude,
        position.longitude,
      );

      _currentWeather = weather;
      _lastSearchedCity = weather.cityName;
      _status = WeatherStatus.loaded;
      _errorMessage = '';

      print('✅ Provider: Météo GPS chargée pour ${weather.cityName}');
      notifyListeners();
    } catch (e) {
      print('❌ Provider: Erreur GPS: $e');
      String errorMsg = e.toString();

      // Messages d'erreur plus user-friendly
      if (errorMsg.contains('denied')) {
        errorMsg = 'Permission GPS refusée';
      } else if (errorMsg.contains('disabled')) {
        errorMsg = 'GPS désactivé';
      } else if (errorMsg.contains('timeout')) {
        errorMsg = 'Impossible de localiser votre position';
      }

      _setError(errorMsg);
    }
  }

  /// Rafraîchir la météo actuelle
  Future<void> refreshWeather() async {
    if (_currentWeather != null) {
      // Re-chercher par ville si on a une ville
      if (_lastSearchedCity.isNotEmpty) {
        await getWeatherByCity(_lastSearchedCity);
      } else {
        // Sinon, re-chercher par géolocalisation
        await getWeatherByCurrentLocation();
      }
    }
  }

  /// Rechercher des villes pour l'autocomplétion
  Future<List<String>> searchCities(String query) async {
    try {
      return await _weatherService.searchCities(query);
    } catch (e) {
      print('❌ Provider: Erreur recherche: $e');
      return [];
    }
  }

  /// Effacer les données actuelles
  void clearWeather() {
    _currentWeather = null;
    _lastSearchedCity = '';
    _status = WeatherStatus.initial;
    _errorMessage = '';
    notifyListeners();
  }

  /// Méthodes privées pour gérer l'état
  void _setLoading() {
    _status = WeatherStatus.loading;
    _errorMessage = '';
    notifyListeners();
  }

  void _setError(String message) {
    _status = WeatherStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  /// Debug info
  @override
  String toString() {
    return 'WeatherProvider(status: $_status, city: ${_currentWeather?.cityName ?? 'null'}, error: $_errorMessage)';
  }
}
