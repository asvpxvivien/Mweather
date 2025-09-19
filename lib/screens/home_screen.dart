// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/weather_provider.dart';
import '../models/weather_model.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _buildGradientBackground(),
        child: SafeArea(
          child: Consumer<WeatherProvider>(
            builder: (context, weatherProvider, child) {
              return Column(
                children: [
                  _buildSearchBar(weatherProvider),

                  Expanded(child: _buildMainContent(weatherProvider)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildGradientBackground() {
    final now = DateTime.now();
    final hour = now.hour;

    List<Color> colors;

    if (hour >= 6 && hour < 12) {
      colors = [
        const Color.fromARGB(255, 61, 54, 208),
        const Color(0xFF98D8E8),
      ];
    } else if (hour >= 12 && hour < 18) {
      colors = [
        const Color(0xFF4A90E2),
        const Color.fromARGB(255, 51, 92, 136),
      ];
    } else if (hour >= 18 && hour < 21) {
      colors = [const Color(0xFFFF7F7F), const Color(0xFFFFB347)];
    } else {
      colors = [const Color(0xFF2C3E50), const Color(0xFF3498DB)];
    }

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
      ),
    );
  }

  Widget _buildSearchBar(WeatherProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .2),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Rechercher une ville...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    provider.getWeatherByCity(value.trim());
                    _searchController.clear();
                  }
                },
              ),
            ),
          ),

          const SizedBox(width: 10),

          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: provider.isLoading
                  ? null
                  : () {
                      provider.getWeatherByCurrentLocation();
                    },
              icon: provider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(WeatherProvider provider) {
    if (provider.isEmpty) {
      return _buildWelcomeState();
    }

    if (provider.isLoading) {
      return _buildLoadingState();
    }

    if (provider.hasError) {
      return _buildErrorState(provider.errorMessage);
    }

    if (provider.hasData) {
      return _buildWeatherContent(provider.currentWeather!);
    }

    return _buildWelcomeState();
  }

  Widget _buildWelcomeState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône météo animée
              TweenAnimationBuilder<double>(
                duration: const Duration(seconds: 2),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.rotate(
                    angle: value * 2 * math.pi * 0.1,
                    child: Icon(
                      Icons.wb_sunny,
                      size: 120,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              Text(
                '🌤️ MWeather',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              Text(
                'Découvrez la météo de votre ville',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withValues(alpha: 0.9),
                  shadows: [
                    Shadow(
                      blurRadius: 5.0,
                      color: Colors.black.withValues(alpha: 0.2),
                      offset: const Offset(1.0, 1.0),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.search,
                    label: 'Rechercher',
                    onPressed: () {
                      FocusScope.of(context).requestFocus();
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.my_location,
                    label: 'Ma position',
                    onPressed: () {
                      context
                          .read<WeatherProvider>()
                          .getWeatherByCurrentLocation();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.blue[700]),
      label: Text(
        label,
        style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        elevation: 8,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),

          const SizedBox(height: 25),

          Text(
            'Chargement...',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Récupération des données météo',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_off,
                    size: 60,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Oups !',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),

                  const SizedBox(height: 25),

                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<WeatherProvider>().clearWeather();
                    },
                    icon: Icon(Icons.refresh, color: Colors.blue[700]),
                    label: Text(
                      'Réessayer',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.9),
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherContent(WeatherModel weather) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildMainWeatherCard(weather),

            const SizedBox(height: 20),

            _buildDetailsCards(weather),
          ],
        ),
      ),
    );
  }

  Widget _buildMainWeatherCard(WeatherModel weather) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            Text(
              weather.fullLocation,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${weather.temperature.round()}',
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                const Text(
                  '°C',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              weather.capitalizedDescription,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Ressenti ${weather.formattedFeelsLike}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCards(WeatherModel weather) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDetailCard(
                icon: Icons.water_drop,
                title: 'Humidité',
                value: weather.formattedHumidity,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildDetailCard(
                icon: Icons.air,
                title: 'Vent',
                value: weather.formattedWindSpeed,
                color: Colors.green,
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        Row(
          children: [
            Expanded(
              child: _buildDetailCard(
                icon: Icons.compress,
                title: 'Pression',
                value: weather.formattedPressure,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildDetailCard(
                icon: Icons.visibility,
                title: 'Visibilité',
                value: weather.formattedVisibility,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color.withValues(alpha: 0.8)),

          const SizedBox(height: 10),

          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
