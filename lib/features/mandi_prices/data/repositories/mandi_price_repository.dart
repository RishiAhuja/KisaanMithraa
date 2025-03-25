import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cropconnect/features/mandi_prices/data/models/crop_price_model.dart';
import 'package:cropconnect/utils/app_logger.dart';

class MandiPriceRepository {
  // Base URL and resource ID
  static const String baseUrl = 'api.data.gov.in';
  static const String resourceId = '9ef84268-d588-465a-a308-a864a43d0070';

  // Cache keys
  static const String CACHE_DATA_KEY_PREFIX = 'mandi_prices_data_';
  static const String CACHE_TIMESTAMP_KEY_PREFIX = 'mandi_prices_timestamp_';

  // Get API key from environment variables
  String get _apiKey => dotenv.env['DATA_GOV_API_KEY'] ?? '';

  Future<List<CropPriceModel>> getCropPrices(
      String state, String district) async {
    try {
      // Validate API key
      if (_apiKey.isEmpty) {
        AppLogger.error('DATA_GOV_API_KEY not found in environment variables');
        return await _loadFromCache(state, district);
      }

      final queryParameters = {
        'api-key': _apiKey,
        'format': 'json',
        'offset': '0',
        'limit': '500',
        'filters[state]': state,
        'filters[district]': district,
      };

      final uri = Uri.https(baseUrl, '/resource/$resourceId', queryParameters);

      AppLogger.debug('Fetching crop prices from: $uri');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'ok') {
          // Check if records array exists and has items
          if (data['records'] != null &&
              data['records'] is List &&
              (data['count'] as int) > 0) {
            final records = data['records'] as List;
            final prices = records
                .map((record) => CropPriceModel.fromJson(record))
                .toList();

            // Cache this valid response for future use
            await _cacheData(state, district, prices);

            AppLogger.debug(
                'Successfully fetched and cached ${prices.length} prices');
            return prices;
          } else {
            // API returned empty records array, try loading from cache
            AppLogger.debug(
                'API returned empty records array, attempting to load from cache');
            return await _loadFromCache(state, district);
          }
        } else {
          AppLogger.error('API returned error: ${data['message']}');
          return await _loadFromCache(state, district);
        }
      } else {
        AppLogger.error('HTTP error ${response.statusCode}: ${response.body}');
        return await _loadFromCache(state, district);
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching crop prices: $e');
      AppLogger.error('Stack trace: $stackTrace');
      return await _loadFromCache(state, district);
    }
  }

  /// Loads cached price data for the specified state and district
  Future<List<CropPriceModel>> _loadFromCache(
      String state, String district) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(state, district);

      // Check if we have cached data
      final cachedData = prefs.getString(cacheKey);
      if (cachedData == null) {
        AppLogger.debug('No cached data found for $state, $district');
        return [];
      }

      // Deserialize the cached data
      final List<dynamic> jsonList = jsonDecode(cachedData);
      final List<CropPriceModel> prices =
          jsonList.map((json) => CropPriceModel.fromJson(json)).toList();

      AppLogger.debug(
          'Loaded ${prices.length} prices from cache for $state, $district');
      return prices;
    } catch (e) {
      AppLogger.error('Error loading from cache: $e');
      return [];
    }
  }

  /// Caches the price data for the specified state and district
  Future<void> _cacheData(
      String state, String district, List<CropPriceModel> prices) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(state, district);
      final timestampKey = _getTimestampKey(state, district);

      // Convert the crop prices to a list of maps for serialization
      final List<Map<String, dynamic>> serializable = prices
          .map((price) => {
                'state': price.state,
                'district': price.district,
                'market': price.market,
                'commodity': price.commodity,
                'variety': price.variety,
                'grade': price.grade,
                'arrival_date': price.arrivalDate,
                'min_price': price.minPrice.toString(),
                'max_price': price.maxPrice.toString(),
                'modal_price': price.modalPrice.toString(),
              })
          .toList();

      // Store the data as JSON
      await prefs.setString(cacheKey, jsonEncode(serializable));

      // Store the current timestamp
      await prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);

      AppLogger.debug('Cached ${prices.length} prices for $state, $district');
    } catch (e) {
      AppLogger.error('Error caching data: $e');
    }
  }

  /// Gets the cache key for a specific state and district
  String _getCacheKey(String state, String district) {
    return '$CACHE_DATA_KEY_PREFIX${state}_$district';
  }

  /// Gets the timestamp key for a specific state and district
  String _getTimestampKey(String state, String district) {
    return '$CACHE_TIMESTAMP_KEY_PREFIX${state}_$district';
  }

  /// Gets the timestamp when the cache was last updated
  /// Returns null if no cache exists
  Future<DateTime?> getCacheTimestamp(String state, String district) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampKey = _getTimestampKey(state, district);

      final timestamp = prefs.getInt(timestampKey);
      if (timestamp == null) {
        return null;
      }

      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      AppLogger.error('Error getting cache timestamp: $e');
      return null;
    }
  }
}
