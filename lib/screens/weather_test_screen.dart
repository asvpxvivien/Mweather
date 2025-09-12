// lib/screens/weather_test_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../models/weather_model.dart';

class WeatherTestScreen extends StatefulWidget {
  @override
  _WeatherTestScreenState createState() => _WeatherTestScreenState();
}

class _WeatherTestScreenState extends State<WeatherTestScreen> {
  final TextEditingController _cityController = TextEditingController();

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌤️ Test Météo Provider'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Rafraîchir la météo actuelle
              context.read<WeatherProvider>().refreshWeather();
            },
          ),
        ],
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Section de recherche
                _buildSearchSection(weatherProvider),

                const SizedBox(height: 20),

                // Section des résultats
                Expanded(child: _buildResultSection(weatherProvider)),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Section de recherche de ville et GPS
  Widget _buildSearchSection(WeatherProvider provider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔍 Rechercher la météo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // Champ de saisie ville
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'Nom de la ville',
                hintText: 'Ex: Paris, Londres, Tokyo...',
                prefixIcon: const Icon(Icons.location_city),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _cityController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _cityController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() {}),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  provider.getWeatherByCity(value.trim());
                }
              },
            ),

            const SizedBox(height: 15),

            // Boutons d'action
            Row(
              children: [
                // Bouton recherche par ville
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        provider.isLoading ||
                            _cityController.text.trim().isEmpty
                        ? null
                        : () {
                            provider.getWeatherByCity(
                              _cityController.text.trim(),
                            );
                          },
                    icon: const Icon(Icons.search),
                    label: const Text('Rechercher'),
                  ),
                ),

                const SizedBox(width: 10),

                // Bouton GPS
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: provider.isLoading
                        ? null
                        : () {
                            provider.getWeatherByCurrentLocation();
                          },
                    icon: const Icon(Icons.my_location),
                    label: const Text('Ma position'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Section des résultats selon l'état du Provider
  Widget _buildResultSection(WeatherProvider provider) {
    if (provider.isEmpty) {
      return _buildEmptyState();
    }

    if (provider.isLoading) {
      return _buildLoadingState();
    }

    if (provider.hasError) {
      return _buildErrorState(provider.errorMessage, provider);
    }

    if (provider.hasData) {
      return _buildSuccessState(provider.currentWeather!);
    }

    return _buildEmptyState();
  }

  /// État initial (aucune recherche)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wb_sunny, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'Bienvenue !',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Recherchez une ville ou utilisez votre position\npour voir la météo',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  /// État de chargement
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(strokeWidth: 3),
          const SizedBox(height: 20),
          Text(
            'Chargement de la météo...',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 10),
          Text(
            'Veuillez patienter',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  /// État d'erreur
  Widget _buildErrorState(String errorMessage, WeatherProvider provider) {
    return Center(
      child: Card(
        color: Colors.red[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red[400]),
              const SizedBox(height: 15),
              Text(
                '❌ Erreur',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.red[600]),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  provider.clearWeather();
                  _cityController.clear();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// État de succès avec les données météo
  Widget _buildSuccessState(WeatherModel weather) {
    return SingleChildScrollView(
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec ville et température
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weather.fullLocation,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          weather.capitalizedDescription,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        weather.formattedTemperature,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        'Ressenti ${weather.formattedFeelsLike}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 25),
              const Divider(),
              const SizedBox(height: 15),

              // Détails météo
              const Text(
                '📊 Détails',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              _buildDetailRow('💧 Humidité', weather.formattedHumidity),
              _buildDetailRow('💨 Vent', weather.formattedWindSpeed),
              _buildDetailRow('🌡️ Pression', weather.formattedPressure),
              _buildDetailRow('👁️ Visibilité', weather.formattedVisibility),

              const SizedBox(height: 20),

              // Informations techniques (pour débug)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🔧 Infos techniques',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Icône: ${weather.icon}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Coordonnées: ${weather.lat.toStringAsFixed(2)}, ${weather.lon.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Dernière MAJ: ${weather.dateTime.hour}:${weather.dateTime.minute}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget helper pour les lignes de détails
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
