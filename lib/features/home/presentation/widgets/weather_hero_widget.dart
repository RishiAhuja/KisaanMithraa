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
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: FutureBuilder<WeatherModel?>(
          future: weatherService.getLocalWeather(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreetingWithoutWeather(context),
                  const SizedBox(height: 14),
                  _buildWeatherLoadingState(context),
                ],
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreetingWithoutWeather(context),
                  const SizedBox(height: 14),
                  _buildWeatherErrorState(context),
                ],
              );
            }

            final weather = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreetingWithWeather(context, weather),
                const SizedBox(height: 14),
                _buildWeatherDisplay(context, weather),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGreetingWithWeather(BuildContext context, WeatherModel weather) {
    final greeting = _getLocalizedGreeting(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.waving_hand_rounded,
            color: Colors.amber,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, ${user.name.split(' ')[0]}!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _getWeatherPhrase(weather, context),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 11,
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.waving_hand_rounded,
            color: Colors.amber,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, ${user.name.split(' ')[0]}!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _getContextualMessage(context),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 11,
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
    final localizations = AppLocalizations.of(context)!;
    IconData weatherIcon = _getWeatherIcon(weather.weather.first.main);
    final condition = weather.weather.first.main.toLowerCase();

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: Colors.white.withOpacity(0.9),
                    size: 12,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    weather.name,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    weatherIcon,
                    color: _getWeatherIconColor(condition),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    weather.weatherDescription,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.white.withOpacity(0.1), height: 1),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                            fontSize: 36,
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
                              fontSize: 14,
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
              Container(
                height: 66,
                width: 1,
                color: Colors.white.withOpacity(0.15),
                margin: const EdgeInsets.symmetric(horizontal: 10),
              ),
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
                      context,
                    ),
                    const SizedBox(height: 6),
                    _buildMetricItem(
                      Icons.air_rounded,
                      'Wind',
                      '${(weather.wind.speed * 3.6).round()} ${localizations.weatherWindUnit}',
                      Colors.white,
                      context,
                    ),
                    const SizedBox(height: 6),
                    _buildMetricItem(
                      Icons.compress_rounded,
                      'Pressure',
                      '${weather.main.pressure} ${localizations.weatherPressureUnit}',
                      Colors.amber[100]!,
                      context,
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

  Widget _buildMetricItem(IconData icon, String label, String value,
      Color iconColor, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // Get localized label
    String localizedLabel = '';
    if (label == 'Humidity') {
      localizedLabel = localizations.weatherHumidity;
    } else if (label == 'Wind') {
      localizedLabel = localizations.weatherWind;
    } else if (label == 'Pressure') {
      localizedLabel = localizations.weatherPressure;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 12,
          color: iconColor,
        ),
        const SizedBox(width: 4),
        Text(
          '$localizedLabel:',
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherLoadingState(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              localizations.weatherLoading,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off,
                color: Colors.white.withOpacity(0.9),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                localizations.weatherUnavailable,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            localizations.weatherCheckManually,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

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

  String _getWeatherPhrase(WeatherModel weather, BuildContext context) {
    final condition = weather.weather.first.main.toLowerCase();
    final temp = weather.temperatureCelsius.round();
    final localizations = AppLocalizations.of(context)!;

    if (condition.contains('rain')) {
      return localizations.weatherPhraseRain;
    } else if (condition.contains('cloud')) {
      return localizations.weatherPhraseCloud;
    } else if (condition.contains('clear') && temp > 30) {
      return localizations.weatherPhraseClearHot;
    } else if (condition.contains('clear')) {
      return localizations.weatherPhraseClear;
    } else if (condition.contains('snow')) {
      return localizations.weatherPhraseSnow;
    } else if (temp < 15) {
      return localizations.weatherPhraseCold;
    } else if (temp > 35) {
      return localizations.weatherPhraseHot;
    } else {
      return localizations.weatherPhraseDefault;
    }
  }

  String _getLocalizedGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final localizations = AppLocalizations.of(context)!;

    if (hour < 12) {
      return localizations.goodMorning;
    } else if (hour < 17) {
      return localizations.goodAfternoon;
    } else {
      return localizations.goodEvening;
    }
  }
}
