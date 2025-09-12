import 'package:dio/dio.dart';
import '../models/weather_model.dart';

class WeatherService {
  final Dio _dio = Dio();

  // 🔑 REMPLACE PAR TA VRAIE CLÉ API !
  static const String _apiKey = '9932911459e9fa56a0e0c68bcca852bc';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  // Configuration par défaut
  static const Map<String, dynamic> _defaultParams = {
    'appid': _apiKey,
    'units': 'metric', // Celsius
    'lang': 'fr', // Français
  };

  WeatherService() {
    // Configuration de Dio avec timeout
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    // Intercepteur pour logger les requêtes (utile pour débugger)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (obj) => print('🌐 API Call: $obj'),
      ),
    );
  }

  /// Obtenir la météo actuelle par nom de ville
  Future<WeatherModel> getCurrentWeatherByCity(String cityName) async {
    try {
      print('🔍 Recherche météo pour: $cityName');

      final response = await _dio.get(
        '$_baseUrl/weather',
        queryParameters: {..._defaultParams, 'q': cityName},
      );

      print('✅ Météo reçue pour: ${response.data['name']}');
      return WeatherModel.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Erreur API: ${e.message}');
      throw _handleDioException(e);
    } catch (e) {
      print('❌ Erreur inattendue: $e');
      throw WeatherException('Erreur inattendue: $e');
    }
  }

  /// Obtenir la météo actuelle par coordonnées GPS
  Future<WeatherModel> getCurrentWeatherByCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      print('🌍 Météo par coordonnées: $latitude, $longitude');

      final response = await _dio.get(
        '$_baseUrl/weather',
        queryParameters: {..._defaultParams, 'lat': latitude, 'lon': longitude},
      );

      print('✅ Météo reçue pour: ${response.data['name']}');
      return WeatherModel.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Erreur API: ${e.message}');
      throw _handleDioException(e);
    } catch (e) {
      print('❌ Erreur inattendue: $e');
      throw WeatherException('Erreur inattendue: $e');
    }
  }

  /// Rechercher plusieurs villes par nom (pour l'autocomplétion)
  Future<List<String>> searchCities(String query) async {
    if (query.length < 2) return [];

    try {
      // OpenWeatherMap n'a pas d'endpoint de recherche direct
      // On peut utiliser l'API Geocoding pour ça
      final response = await _dio.get(
        'https://api.openweathermap.org/geo/1.0/direct',
        queryParameters: {'q': query, 'limit': 5, 'appid': _apiKey},
      );

      final List<dynamic> cities = response.data;
      return cities.map<String>((city) {
        final name = city['name'] ?? '';
        final country = city['country'] ?? '';
        final state = city['state'] ?? '';

        if (state.isNotEmpty) {
          return '$name, $state, $country';
        } else {
          return '$name, $country';
        }
      }).toList();
    } catch (e) {
      print('❌ Erreur recherche villes: $e');
      return [];
    }
  }

  /// Gestion des erreurs Dio
  WeatherException _handleDioException(DioException e) {
    switch (e.response?.statusCode) {
      case 400:
        return WeatherException('Requête invalide');
      case 401:
        return WeatherException('Clé API invalide ou expirée');
      case 404:
        return WeatherException('Ville non trouvée');
      case 429:
        return WeatherException('Limite d\'appels API dépassée');
      case 500:
        return WeatherException('Erreur serveur météo');
      default:
        if (e.type == DioExceptionType.connectionTimeout) {
          return WeatherException('Connexion lente, réessayez');
        } else if (e.type == DioExceptionType.receiveTimeout) {
          return WeatherException('Serveur trop lent, réessayez');
        } else {
          return WeatherException('Erreur réseau: ${e.message}');
        }
    }
  }
}

/// Exception personnalisée pour les erreurs météo
class WeatherException implements Exception {
  final String message;

  WeatherException(this.message);

  @override
  String toString() => 'WeatherException: $message';
}
