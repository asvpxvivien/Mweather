import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test API Météo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ApiTestScreen(),
    );
  }
}
class ApiTestScreen extends StatefulWidget{
  @override
  _ApiTestScreenState createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State <ApiTestScreen> {
  String _result = "Appuyez sur le bouton pour tester l'API";
  bool _isLoading = false;

  final String _apiKey ="9932911459e9fa56a0e0c68bcca852bc";

  final Dio _dio = Dio();


  Future<void> _testApi() async {
    setState(() {
      _isLoading = true;
      _result = "Chargement...";
    });

 try {
      // Construction de l'URL de l'API
      const String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
      
      // Paramètres de la requête
      final Map<String, dynamic> queryParams = {
        'q': 'Paris',           // Ville à rechercher
        'appid': _apiKey,       // Ta clé API
        'units': 'metric',      // Températures en Celsius
        'lang': 'fr',          // Langue française
      };

      print("🔍 URL complète: $baseUrl");
      print("📝 Paramètres: $queryParams");

      // Envoi de la requête GET
      final Response response = await _dio.get(baseUrl, queryParameters: queryParams);
      
      print("✅ Réponse reçue!");
      print("📊 Status Code: ${response.statusCode}");
      print("📦 Data type: ${response.data.runtimeType}");
      
      // Traitement de la réponse
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        
        // Extraction des données importantes
        final String cityName = data['name'];
        final String country = data['sys']['country'];
        final double temp = data['main']['temp'].toDouble();
        final String description = data['weather'][0]['description'];
        final double humidity = data['main']['humidity'].toDouble();
        
        // Affichage du résultat
        setState(() {
          _result = """
🏙️ Ville: $cityName, $country
🌡️ Température: ${temp.toStringAsFixed(1)}°C
📝 Description: $description
💧 Humidité: ${humidity.toStringAsFixed(0)}%

✅ API fonctionne parfaitement !
""";
        });
        
        print("🎉 Success! Température à Paris: ${temp}°C");
        
      }
    } catch (error) {
      print("❌ Erreur: $error");
      
      setState(() {
        if (error is DioException) {
          if (error.response?.statusCode == 401) {
            _result = """
❌ Erreur 401: Clé API invalide

🔧 Solutions:
1. Vérifiez votre clé API
2. Assurez-vous qu'elle est activée (peut prendre 2h)
3. Remplacez 'TA_CLE_API_ICI' par votre vraie clé
""";
          } else if (error.response?.statusCode == 404) {
            _result = "❌ Ville non trouvée";
          } else {
            _result = "❌ Erreur réseau: ${error.message}";
          }
        } else {
          _result = "❌ Erreur inattendue: $error";
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test API Météo'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "📋 Instructions:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "1. Remplacez 'TA_CLE_API_ICI' par votre vraie clé API\n"
                    "2. Cliquez sur 'Tester l'API'\n"
                    "3. Vérifiez que vous recevez les données météo",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 30),

