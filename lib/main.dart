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

}