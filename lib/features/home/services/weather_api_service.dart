import 'dart:convert';
import 'package:cropconnect/core/services/hive/hive_storage_service.dart';
import 'package:cropconnect/features/home/domain/models/weather_model.dart';
import 'package:cropconnect/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cropconnect/features/profile/controller/profile_controller.dart';

class WeatherApiService extends GetxService {
  final ProfileController _profileController = Get.find<ProfileController>();

  final _cache = <String, dynamic>{}.obs;
  final _cacheTimestamps = <String, int>{}.obs;
  final _cacheDuration = const Duration(hours: 1);

  String get _apiKey => dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  double? get userLatitude => _profileController.user.value?.latitude;
  double? get userLongitude => _profileController.user.value?.longitude;

  bool get hasLocation => userLatitude != null && userLongitude != null;

  Future<WeatherModel?> getLocalWeather() async {
    try {
      if (!hasLocation) {
        final position = await _profileController.getCurrentLocation();
        if (position == null) {
          return await _getWeatherByUserLocation();
        }
      }

      if (userLatitude == null || userLongitude == null) {
        AppLogger.warning(
            'Still missing coordinates, falling back to location-based weather');
        return await _getWeatherByUserLocation();
      }

      final cacheKey =
          'weather_${userLatitude?.toStringAsFixed(2)}_${userLongitude?.toStringAsFixed(2)}';

      if (_isCacheValid(cacheKey)) {
        return WeatherModel.fromJson(_cache[cacheKey]);
      }

      try {
        final url = Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather?lat=$userLatitude&lon=$userLongitude&appid=$_apiKey&units=metric');

        if (kDebugMode) {
          AppLogger.info(
              'Fetching weather data from: ${url.toString().replaceAll(_apiKey, 'API_KEY')}');
        }

        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          _cache[cacheKey] = data;
          _cacheTimestamps[cacheKey] = DateTime.now().millisecondsSinceEpoch;
          return WeatherModel.fromJson(data);
        } else {
          AppLogger.error(
              'Failed to load weather data. Status code: ${response.statusCode}');
          AppLogger.error('Response body: ${response.body}');

          if (response.body.contains("Nothing to geocode")) {
            AppLogger.info(
                'Geocoding error detected, falling back to location-based weather');
            return await _getWeatherByUserLocation();
          }

          if (_cache.containsKey(cacheKey)) {
            return WeatherModel.fromJson(_cache[cacheKey]);
          }

          return null;
        }
      } catch (e) {
        AppLogger.error('Error fetching weather data: $e');

        if (_cache.containsKey(cacheKey)) {
          return WeatherModel.fromJson(_cache[cacheKey]);
        }

        return await _getWeatherByUserLocation();
      }
    } catch (e) {
      AppLogger.error('Unexpected error in getLocalWeather: $e');
      return null;
    }
  }

  Future<WeatherModel?> _getWeatherByUserLocation() async {
    try {
      String location = '';

      // First check if we already have user data in the controller
      final user = _profileController.user.value;
      if (user?.city != null && user!.city!.isNotEmpty) {
        location = user.city!;
        AppLogger.info('Using city from profile controller: $location');
      } else if (user?.state != null && user!.state!.isNotEmpty) {
        location = user.state!;
        AppLogger.info('Using state from profile controller: $location');
      }
      // If not, try to get it from storage service
      else {
        location = await _getDistrictFromLocationService();
      }

      // If we still don't have a location, use default
      if (location.isEmpty) {
        location = 'New Delhi';
        AppLogger.warning(
            'No location found in any source, defaulting to: $location');
      }

      AppLogger.info('Getting weather for location: $location');
      return await getWeatherByLocation(location);
    } catch (e) {
      AppLogger.error('Error getting weather by user location: $e');
      return null;
    }
  }

  Future<String> _getDistrictFromLocationService() async {
    try {
      // Get the user data directly from storage service
      final storageService = Get.find<UserStorageService>();
      final userData = await storageService.getUser();

      // Use city first if available
      if (userData?.city != null && userData!.city!.isNotEmpty) {
        AppLogger.info('Using city from storage service: ${userData.city}');
        return userData.city!;
      }

      // Fall back to state if city isn't available
      if (userData?.state != null && userData!.state!.isNotEmpty) {
        AppLogger.info('Using state from storage service: ${userData.state}');
        return userData.state!;
      }

      return '';
    } catch (e) {
      AppLogger.error('Error getting location from storage service: $e');
      return '';
    }
  }

  Future<WeatherModel?> getWeatherByLocation(String location) async {
    if (location.isEmpty) {
      AppLogger.error('Empty location provided');
      return null;
    }

    final cacheKey = 'weather_location_$location';

    if (_isCacheValid(cacheKey)) {
      return WeatherModel.fromJson(_cache[cacheKey]);
    }

    try {
      final url = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$location,in&appid=$_apiKey&units=metric');

      AppLogger.info(
          'Fetching weather data for location: ${url.toString().replaceAll(_apiKey, 'API_KEY')}');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _cache[cacheKey] = data;
        _cacheTimestamps[cacheKey] = DateTime.now().millisecondsSinceEpoch;
        return WeatherModel.fromJson(data);
      } else {
        AppLogger.error(
            'Failed to load weather data for location. Status code: ${response.statusCode}');

        if (_cache.containsKey(cacheKey)) {
          return WeatherModel.fromJson(_cache[cacheKey]);
        }

        if (location.contains(' ')) {
          AppLogger.info('Trying to get weather with simplified location name');
          final simplifiedLocation = location.split(' ')[0];
          return await getWeatherByLocation(simplifiedLocation);
        }

        return null;
      }
    } catch (e) {
      AppLogger.error('Error fetching weather data for location: $e');

      if (_cache.containsKey(cacheKey)) {
        return WeatherModel.fromJson(_cache[cacheKey]);
      }

      return null;
    }
  }

  bool _isCacheValid(String key) {
    if (!_cache.containsKey(key) || !_cacheTimestamps.containsKey(key)) {
      return false;
    }

    final timestamp = _cacheTimestamps[key];
    final now = DateTime.now().millisecondsSinceEpoch;
    return now - timestamp! < _cacheDuration.inMilliseconds;
  }
}
