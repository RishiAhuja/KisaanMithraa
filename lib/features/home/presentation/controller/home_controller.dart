import 'dart:convert';
import 'package:cropconnect/features/home/services/farming_tip_service.dart';
import 'package:cropconnect/features/home/services/weather_api_service.dart';
import 'package:get/get.dart';
import 'package:cropconnect/features/mandi_prices/data/models/crop_price_model.dart';
import 'package:cropconnect/features/mandi_prices/data/models/watchlist_item.dart';
import 'package:cropconnect/features/mandi_prices/data/repositories/mandi_price_repository.dart';
import 'package:cropconnect/core/services/hive/hive_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController {
  static const String WATCHLIST_KEY = 'mandi_prices_watchlist';

  final UserStorageService _storageService = Get.find<UserStorageService>();
  final MandiPriceRepository _mandiRepository = MandiPriceRepository();

  final Rx<dynamic> user = Rx<dynamic>(null);
  final RxList<CropPriceModel> topCropPrices = <CropPriceModel>[].obs;
  final RxBool isLoadingPrices = false.obs;
  final RxBool isUsingCachedPrices = false.obs;
  final RxBool hasWatchlist = false.obs;

  final RxBool isLoadingWeather = false.obs;
  final RxBool isLoadingTips = false.obs;
  final RxBool hasFetchedWeather = false.obs;
  final RxBool hasFetchedTips = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadUser();

    if (user.value != null) {
      await Future.wait([
        loadWatchlistedPrices(),
        loadWeatherData(),
        loadTips(),
      ]);
    }
  }

  Future<void> _loadUser() async {
    try {
      final userData = await _storageService.getUser();
      user.value = userData;
    } catch (e) {
      print('Error loading user: $e');
    }
  }

  Future<bool> retryLoadUser() async {
    try {
      print('Retrying user data load');
      await _loadUser();

      if (user.value != null) {
        loadWatchlistedPrices();
        loadWeatherData();
        loadTips();
        return true;
      }
      return false;
    } catch (e) {
      print('Error in retry loading user: $e');
      return false;
    }
  }

  Future<void> loadWeatherData() async {
    if (isLoadingWeather.value) return;

    isLoadingWeather.value = true;
    try {
      if (user.value == null) {
        await _loadUser();
        if (user.value == null) return;
      }

      final weatherController = Get.find<WeatherApiService>();
      await weatherController.getLocalWeather();
      hasFetchedWeather.value = true;
    } catch (e) {
      print('Error loading weather data: $e');
    } finally {
      isLoadingWeather.value = false;
    }
  }

  Future<void> loadTips() async {
    if (isLoadingTips.value) return;

    isLoadingTips.value = true;
    try {
      if (user.value == null) {
        await _loadUser();
        if (user.value == null) return;
      }

      final tipController = Get.find<FarmingTipService>();

      await tipController.fetchTips();
      hasFetchedTips.value = true;
    } catch (e) {
      print('Error loading AI tips: $e');
    } finally {
      isLoadingTips.value = false;
    }
  }

  Future<void> loadWatchlistedPrices() async {
    if (user.value == null) {
      await _loadUser();
    }

    isLoadingPrices.value = true;

    try {
      final state = user.value?.state ?? 'Punjab';
      final district = user.value?.city ?? 'Jalandhar';

      final List<WatchlistItem> watchlist = await _loadWatchlist();

      if (watchlist.isEmpty) {
        hasWatchlist.value = false;
        await _loadTopCrops(state, district);
        return;
      }

      hasWatchlist.value = true;

      final prices = await _mandiRepository.getCropPrices(state, district);

      final cacheTimestamp =
          await _mandiRepository.getCacheTimestamp(state, district);
      if (cacheTimestamp != null) {
        final now = DateTime.now();
        if (now.difference(cacheTimestamp).inHours > 12) {
          isUsingCachedPrices.value = true;
        }
      }

      if (prices.isNotEmpty) {
        final watchlistedPrices = prices
            .where((price) => watchlist.any((item) =>
                item.market == price.market &&
                item.commodity == price.commodity &&
                item.variety == price.variety))
            .toList();

        if (watchlistedPrices.isEmpty) {
          await _loadTopCrops(state, district);
        } else {
          topCropPrices.value = watchlistedPrices;
        }
      } else {
        await _loadTopCrops(state, district);
      }
    } catch (e) {
      print('Error loading watchlisted crop prices: $e');
      topCropPrices.value = [];
    } finally {
      isLoadingPrices.value = false;
    }
  }

  Future<void> _loadTopCrops(String state, String district) async {
    try {
      final prices = await _mandiRepository.getCropPrices(state, district);

      if (prices.isNotEmpty) {
        final importantCrops = _filterImportantCrops(prices);

        importantCrops.sort((a, b) => b.modalPrice.compareTo(a.modalPrice));

        topCropPrices.value = importantCrops.take(5).toList();
      }
    } catch (e) {
      print('Error loading top crop prices: $e');
      topCropPrices.value = [];
    }
  }

  Future<List<WatchlistItem>> _loadWatchlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedWatchlist = prefs.getString(WATCHLIST_KEY);

      if (savedWatchlist != null) {
        final List<dynamic> decoded = jsonDecode(savedWatchlist);
        return decoded.map((item) => WatchlistItem.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error loading watchlist: $e');
    }
    return [];
  }

  List<CropPriceModel> _filterImportantCrops(List<CropPriceModel> prices) {
    final importantCropNames = [
      'Wheat',
      'Paddy',
      'Rice',
      'Maize',
      'Corn',
      'Potato',
      'Tomato',
      'Onion',
      'Cotton',
      'Soybean',
      'Mustard',
      'Gram',
      'Groundnut',
      'Barley'
    ];

    final importantCrops = prices
        .where((price) => importantCropNames.any((crop) =>
            price.commodity.toLowerCase().contains(crop.toLowerCase())))
        .toList();

    if (importantCrops.length >= 5) {
      return importantCrops;
    }

    final otherCrops = prices
        .where((price) => !importantCropNames.any((crop) =>
            price.commodity.toLowerCase().contains(crop.toLowerCase())))
        .toList();

    importantCrops.addAll(otherCrops);
    return importantCrops.take(5).toList();
  }

  Map<String, dynamic> getPriceChange(CropPriceModel crop) {
    final int cropHash = crop.commodity.hashCode + crop.market.hashCode;
    final seedValue = cropHash.abs() % 1000;

    final changePercent = (seedValue % 20) - 8;

    final change = (crop.modalPrice * changePercent / 100).round();
    final isPositive = change >= 0;

    return {
      'amount': change.abs(),
      'isPositive': isPositive,
      'percentText':
          '${isPositive ? '+' : '-'}${change.abs() * 100 ~/ crop.modalPrice}%',
      'text': '${isPositive ? '+' : '-'}₹${change.abs()}'
    };
  }

  String formatPrice(double price) {
    if (price >= 1000) {
      return '₹${(price / 1000).toStringAsFixed(1)}K';
    }
    return '₹${price.toStringAsFixed(0)}';
  }
}
