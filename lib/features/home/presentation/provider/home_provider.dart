import 'dart:convert';
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

  @override
  void onInit() {
    super.onInit();
    _loadUser();
    loadWatchlistedPrices();
  }

  Future<void> _loadUser() async {
    try {
      final userData = await _storageService.getUser();
      user.value = userData;
    } catch (e) {
      print('Error loading user: $e');
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
