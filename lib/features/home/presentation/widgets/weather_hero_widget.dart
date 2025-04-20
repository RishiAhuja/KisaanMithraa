import 'package:cropconnect/core/services/locale/locale_service.dart';
import 'package:cropconnect/features/home/domain/models/weather_model.dart';
import 'package:cropconnect/features/home/services/weather_api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WeatherHeroWidget extends StatelessWidget {
  final dynamic user;

  const WeatherHeroWidget({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weatherService = Get.find<WeatherApiService>();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary
                .withBlue(theme.colorScheme.primary.blue + 40),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: FutureBuilder<WeatherModel?>(
          future: weatherService.getLocalWeather(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreetingWithoutWeather(context),
                  const SizedBox(height: 18),
                  _buildWeatherLoadingState(context),
                ],
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreetingWithoutWeather(context),
                  const SizedBox(height: 18),
                  _buildWeatherErrorState(context),
                ],
              );
            }

            final weather = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreetingWithWeather(context, weather),
                const SizedBox(height: 18),
                _buildWeatherDisplay(context, weather),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGreetingWithWeather(BuildContext context, WeatherModel weather) {
    // Get time-based greeting from shared method
    final greeting = _getLocalizedGreeting(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.waving_hand_rounded,
            color: Colors.amber,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, ${user.name.split(' ')[0]}!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getWeatherPhrase(weather, context),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGreetingWithoutWeather(BuildContext context) {
    final hour = DateTime.now().hour;
    final localizations = AppLocalizations.of(context)!;
    String greeting;

    if (hour < 12) {
      greeting = localizations.goodMorning;
    } else if (hour < 17) {
      greeting = localizations.goodAfternoon;
    } else {
      greeting = localizations.goodEvening;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.waving_hand_rounded,
            color: Colors.amber,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, ${user.name.split(' ')[0]}!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getContextualMessage(context),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getContextualMessage(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final weekday = DateFormat('EEEE').format(now);

    if (weekday == 'Saturday' || weekday == 'Sunday') {
      return localizations.weekendFarmWish;
    }

    final day = now.day;
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);

    if (day <= 10) {
      return localizations.startingMonth;
    } else if (day >= daysInMonth - 5) {
      return localizations.endingMonth;
    } else {
      return localizations.welcomeBack;
    }
  }

  Widget _buildWeatherDisplay(BuildContext context, WeatherModel weather) {
    IconData weatherIcon = _getWeatherIcon(weather.weather.first.main);
    final condition = weather.weather.first.main.toLowerCase();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Location and weather condition in the same row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Location display
              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: Colors.white.withOpacity(0.9),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    weather.name,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Weather condition display
              Row(
                children: [
                  Icon(
                    weatherIcon,
                    color: _getWeatherIconColor(condition),
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    weather.weatherDescription,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: Colors.white.withOpacity(0.1), height: 1),
          const SizedBox(height: 12),

          // Temperature and metrics in separate columns
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Temperature column
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${weather.temperatureCelsius.round()}',
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 0.9,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '°C',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Vertical divider between temperature and metrics
              Container(
                height: 80,
                width: 1,
                color: Colors.white.withOpacity(0.15),
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),

              // Metrics column
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMetricItem(
                      Icons.water_drop_outlined,
                      'Humidity',
                      '${weather.main.humidity}%',
                      Colors.lightBlue[200]!,
                    ),
                    const SizedBox(height: 8),
                    _buildMetricItem(
                      Icons.air_rounded,
                      'Wind',
                      '${(weather.wind.speed * 3.6).round()} km/h',
                      Colors.white,
                    ),
                    const SizedBox(height: 8),
                    _buildMetricItem(
                      Icons.compress_rounded,
                      'Pressure',
                      '${weather.main.pressure} hPa',
                      Colors.amber[100]!,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
      IconData icon, String label, String value, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 14,
          color: iconColor,
        ),
        const SizedBox(width: 6),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  String _getWeatherPhrase(WeatherModel weather, BuildContext context) {
    final condition = weather.weather.first.main.toLowerCase();
    final temp = weather.temperatureCelsius.round();
    final localeService = Get.find<LocaleService>();
    final currentLocale = localeService.currentLocale.value;

    // Cache key combines condition and temperature for specific lookups
    final cacheKey = 'weather_phrase_${condition}_$temp';

    // Try to get from cache first
    final cachedPhrase = localeService.getCachedTranslation(cacheKey);
    if (cachedPhrase != null) {
      return cachedPhrase;
    }

    String phrase;

    if (currentLocale == 'hi') {
      // Hindi weather phrases
      if (condition.contains('rain')) {
        phrase = 'आज घर के अंदर रहना अच्छा होगा';
      } else if (condition.contains('cloud')) {
        phrase = 'खेती के लिए सामान्य दिन';
      } else if (condition.contains('clear') && temp > 30) {
        phrase = 'खेतों में पानी पीते रहें';
      } else if (condition.contains('clear')) {
        phrase = 'खुले में काम करने के लिए अच्छा दिन';
      } else if (condition.contains('snow')) {
        phrase = 'आज अपनी फसलों की रक्षा करें';
      } else if (temp < 15) {
        phrase = 'फसल की वृद्धि के लिए काफी ठंडा';
      } else if (temp > 35) {
        phrase = 'फसलों पर गर्मी तनाव पर नज़र रखें';
      } else {
        phrase = 'खेती के लिए अच्छी स्थिति';
      }
    } else {
      // English weather phrases (unchanged)
      if (condition.contains('rain')) {
        phrase = 'Best to stay indoors today';
      } else if (condition.contains('cloud')) {
        phrase = 'Moderate day for fieldwork';
      } else if (condition.contains('clear') && temp > 30) {
        phrase = 'Stay hydrated in the fields';
      } else if (condition.contains('clear')) {
        phrase = 'Perfect day for outdoor work';
      } else if (condition.contains('snow')) {
        phrase = 'Protect your crops today';
      } else if (temp < 15) {
        phrase = 'Quite cold for crop growth';
      } else if (temp > 35) {
        phrase = 'Watch for heat stress on crops';
      } else {
        phrase = 'Good conditions for farming';
      }
    }

    // Cache the phrase
    localeService.cacheTranslation(cacheKey, phrase);
    return phrase;
  }

  Widget _buildWeatherLoadingState(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              localizations.weatherLoading,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherErrorState(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off,
                color: Colors.white.withOpacity(0.9),
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                localizations.weatherUnavailable,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            localizations.weatherCheckManually,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods remain the same
  IconData _getWeatherIcon(String condition) {
    final lowercaseCondition = condition.toLowerCase();

    if (lowercaseCondition.contains('clear')) {
      return Icons.wb_sunny_rounded;
    } else if (lowercaseCondition.contains('cloud')) {
      return Icons.cloud_rounded;
    } else if (lowercaseCondition.contains('rain') ||
        lowercaseCondition.contains('drizzle')) {
      return Icons.grain_rounded;
    } else if (lowercaseCondition.contains('thunderstorm')) {
      return Icons.flash_on_rounded;
    } else if (lowercaseCondition.contains('snow')) {
      return Icons.ac_unit_rounded;
    } else if (lowercaseCondition.contains('mist') ||
        lowercaseCondition.contains('fog') ||
        lowercaseCondition.contains('haze')) {
      return Icons.cloud_queue_rounded;
    } else {
      return Icons.wb_sunny_rounded;
    }
  }

  Color _getWeatherIconColor(String condition) {
    final lowercaseCondition = condition.toLowerCase();

    if (lowercaseCondition.contains('clear')) {
      return Colors.amber;
    } else if (lowercaseCondition.contains('cloud')) {
      return Colors.white;
    } else if (lowercaseCondition.contains('rain') ||
        lowercaseCondition.contains('drizzle')) {
      return Colors.lightBlue[200]!;
    } else if (lowercaseCondition.contains('thunderstorm')) {
      return Colors.amber;
    } else if (lowercaseCondition.contains('snow')) {
      return Colors.white;
    } else if (lowercaseCondition.contains('mist') ||
        lowercaseCondition.contains('fog') ||
        lowercaseCondition.contains('haze')) {
      return Colors.white.withOpacity(0.8);
    } else {
      return Colors.amber;
    }
  }

  String _getLocalizedGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final localeService = Get.find<LocaleService>();
    final cacheKey = 'greeting_$hour';

    // Try to get from cache first
    final cachedGreeting = localeService.getCachedTranslation(cacheKey);
    if (cachedGreeting != null) {
      return cachedGreeting;
    }

    // Otherwise determine greeting based on time and current locale
    String greeting;
    final currentLocale = localeService.currentLocale.value;

    if (currentLocale == 'hi') {
      if (hour < 12) {
        greeting = 'शुभ प्रभात';
      } else if (hour < 17) {
        greeting = 'शुभ दोपहर';
      } else {
        greeting = 'शुभ संध्या';
      }
    } else {
      if (hour < 12) {
        greeting = 'Good morning';
      } else if (hour < 17) {
        greeting = 'Good afternoon';
      } else {
        greeting = 'Good evening';
      }
    }

    // Cache the greeting
    localeService.cacheTranslation(cacheKey, greeting);
    return greeting;
  }
}
