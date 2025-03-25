import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cropconnect/features/mandi_prices/data/models/crop_price_model.dart';
import 'package:cropconnect/features/mandi_prices/data/models/watchlist_item.dart';
import 'package:cropconnect/features/mandi_prices/data/repositories/mandi_price_repository.dart';
import 'package:cropconnect/utils/app_logger.dart';
import 'package:cropconnect/core/services/hive/hive_storage_service.dart';

class MandiPriceController extends GetxController {
  static const String WATCHLIST_KEY = 'mandi_prices_watchlist';

  final MandiPriceRepository _repository = MandiPriceRepository();
  final UserStorageService _storageService = Get.find<UserStorageService>();

  final RxString selectedState = ''.obs;
  final RxString selectedDistrict = ''.obs;
  final RxString selectedMarket = ''.obs;

  final RxList<CropPriceModel> allPrices = <CropPriceModel>[].obs;
  final RxList<String> markets = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Cache-related observables
  final RxBool isUsingCachedData = false.obs;
  final RxString cacheTimestampText = ''.obs;

  // Watchlist-related observables
  final RxList<WatchlistItem> watchlist = <WatchlistItem>[].obs;
  final RxBool isWatchlistView = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserLocation();
    _loadWatchlist();
  }

  // Load watchlist from local storage
  Future<void> _loadWatchlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedWatchlist = prefs.getString(WATCHLIST_KEY);

      if (savedWatchlist != null) {
        final List<dynamic> decoded = jsonDecode(savedWatchlist);
        final items =
            decoded.map((item) => WatchlistItem.fromJson(item)).toList();
        watchlist.assignAll(items);
        AppLogger.debug('Loaded ${watchlist.length} items from watchlist');

        // Auto-switch to watchlist view if there are items
        if (watchlist.isNotEmpty) {
          isWatchlistView.value = true;
        }
      }
    } catch (e) {
      AppLogger.error('Error loading watchlist: $e');
    }
  }

  // Save watchlist to local storage
  Future<void> _saveWatchlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = watchlist.map((item) => item.toJson()).toList();
      await prefs.setString(WATCHLIST_KEY, jsonEncode(jsonList));
      AppLogger.debug('Saved ${watchlist.length} items to watchlist');
    } catch (e) {
      AppLogger.error('Error saving watchlist: $e');
    }
  }

  // Add item to watchlist
  void addToWatchlist(CropPriceModel price) {
    final item = WatchlistItem(
      market: price.market,
      commodity: price.commodity,
      variety: price.variety,
      state: price.state,
      district: price.district,
    );

    if (!isInWatchlist(price)) {
      watchlist.add(item);
      _saveWatchlist();
      Get.snackbar(
        'Added to Watchlist',
        '${price.commodity} from ${price.market} added to your watchlist',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
      );
    }
  }

  // Remove item from watchlist
  void removeFromWatchlist(CropPriceModel price) {
    final itemIndex = watchlist.indexWhere((item) =>
        item.market == price.market &&
        item.commodity == price.commodity &&
        item.variety == price.variety);

    if (itemIndex >= 0) {
      watchlist.removeAt(itemIndex);
      _saveWatchlist();
      Get.snackbar(
        'Removed from Watchlist',
        '${price.commodity} from ${price.market} removed from your watchlist',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  // Toggle item in watchlist
  void toggleWatchlist(CropPriceModel price) {
    if (isInWatchlist(price)) {
      removeFromWatchlist(price);
    } else {
      addToWatchlist(price);
    }
  }

  // Check if item is in watchlist
  bool isInWatchlist(CropPriceModel price) {
    return watchlist.any((item) =>
        item.market == price.market &&
        item.commodity == price.commodity &&
        item.variety == price.variety);
  }

  // Switch between all prices and watchlist
  void toggleView() {
    isWatchlistView.value = !isWatchlistView.value;
  }

  // Get watchlist items with current prices
  List<CropPriceModel> getWatchlistPrices() {
    return allPrices
        .where((price) => watchlist.any((item) =>
            item.market == price.market &&
            item.commodity == price.commodity &&
            item.variety == price.variety))
        .toList();
  }

  // Group watchlist items by market for display
  Map<String, List<CropPriceModel>> getGroupedWatchlistItems() {
    final watchlistPrices = getWatchlistPrices();
    final Map<String, List<CropPriceModel>> grouped = {};

    // Group by market
    for (final price in watchlistPrices) {
      if (!grouped.containsKey(price.market)) {
        grouped[price.market] = [];
      }
      grouped[price.market]!.add(price);
    }

    // Sort items within each market by commodity name
    for (final market in grouped.keys) {
      grouped[market]!.sort((a, b) => a.commodity.compareTo(b.commodity));
    }

    return grouped;
  }

  Future<void> _loadUserLocation() async {
    try {
      final userData = await _storageService.getUser();

      if (userData != null) {
        // Use stored user state and city (district)
        selectedState.value = userData.state ?? 'Punjab'; // Fallback if null
        selectedDistrict.value =
            userData.city ?? 'Jalandhar'; // Fallback if null

        AppLogger.debug(
            'Loaded user location: ${selectedState.value}, ${selectedDistrict.value}');
      } else {
        // Fallback to defaults if user data not available
        selectedState.value = 'Punjab';
        selectedDistrict.value = 'Jalandhar';

        AppLogger.debug('No user data found, using default location');
      }

      // Load prices after getting location
      fetchCropPrices();
    } catch (e) {
      AppLogger.error('Error loading user location: $e');
      // Use defaults if there's an error
      selectedState.value = 'Punjab';
      selectedDistrict.value = 'Jalandhar';
      fetchCropPrices();
    }
  }

  void updateLocation(String state, String district) {
    selectedState.value = state;
    selectedDistrict.value = district;
    fetchCropPrices();
  }

  void selectMarket(String market) {
    selectedMarket.value = market;
  }

  Future<void> fetchCropPrices() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
    isUsingCachedData.value = false;
    cacheTimestampText.value = '';

    try {
      final prices = await _repository.getCropPrices(
        selectedState.value,
        selectedDistrict.value,
      );

      if (prices.isEmpty) {
        hasError.value = true;
        errorMessage.value = 'No prices available for this location.';
        AppLogger.debug(
            'No prices available for ${selectedState.value}, ${selectedDistrict.value}');
      } else {
        allPrices.value = prices;

        // Check if we're using cached data
        final cacheTimestamp = await _repository.getCacheTimestamp(
            selectedState.value, selectedDistrict.value);

        // If the cache timestamp is from a previous day, we're using cached data
        if (cacheTimestamp != null &&
            !_isSameDay(cacheTimestamp, DateTime.now())) {
          isUsingCachedData.value = true;
          cacheTimestampText.value = _formatCacheDate(cacheTimestamp);
          AppLogger.debug(
              'Using cached data from ${cacheTimestamp.toString()}');
        }

        _updateMarketsFromPrices();
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to fetch prices: $e';
      AppLogger.error('Error in fetchCropPrices: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _updateMarketsFromPrices() {
    // Extract unique markets from the data
    final uniqueMarkets =
        allPrices.map((price) => price.market).toSet().toList();
    uniqueMarkets.sort(); // Sort markets alphabetically
    markets.value = uniqueMarkets;

    // Select first market by default if none selected
    if (selectedMarket.isEmpty && markets.isNotEmpty) {
      selectedMarket.value = markets[0];
    } else if (!markets.contains(selectedMarket.value) && markets.isNotEmpty) {
      // If previously selected market is no longer available, select first one
      selectedMarket.value = markets[0];
    }
  }

  List<CropPriceModel> getPricesForSelectedMarket() {
    if (selectedMarket.isEmpty) {
      return [];
    }

    return allPrices
        .where((price) => price.market == selectedMarket.value)
        .toList();
  }

  // Helper function to check if two dates are from the same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Format the cache timestamp into a human-readable string
  String _formatCacheDate(DateTime timestamp) {
    // Today vs Yesterday vs specific date
    final now = DateTime.now();
    final formatter = DateFormat('MMM d, yyyy');

    if (_isSameDay(timestamp, now)) {
      return 'Today at ${DateFormat('h:mm a').format(timestamp)}';
    } else if (_isSameDay(timestamp, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday at ${DateFormat('h:mm a').format(timestamp)}';
    } else {
      return formatter.format(timestamp);
    }
  }

  // Group commodities by category for better organization
  Map<String, List<CropPriceModel>> getGroupedCommodities() {
    // Use watchlist if in watchlist view
    if (isWatchlistView.value) {
      return getGroupedWatchlistItems();
    }

    final pricesForMarket = getPricesForSelectedMarket();
    final Map<String, List<CropPriceModel>> grouped = {};

    // Define main categories
    const categories = {
      'Vegetables': [
        'Potato',
        'Onion',
        'Tomato',
        'Brinjal',
        'Cabbage',
        'Cauliflower',
        'Green Chilli',
        'Bhindi',
        'Capsicum',
        'Carrot',
        'Cucumbar',
        'Pumpkin',
        'Bottle gourd',
        'Raddish',
        'Spinach',
        'Coriander',
        'Peas Wet',
        'Garlic',
        'Ginger',
        'Tinda',
        'Turnip',
        'Season Leaves'
      ],
      'Fruits': [
        'Apple',
        'Banana',
        'Orange',
        'Grapes',
        'Papaya',
        'Pomegranate',
        'Kinnow',
        'Guava',
        'Plum',
        'Water Melon',
        'Karbuja',
        'Mousambi',
        'Jack Fruit',
        'Pineapple',
        'Tender Coconut',
        'Lemon'
      ],
      'Others': []
    };

    // Initialize categories
    for (final category in categories.keys) {
      grouped[category] = [];
    }

    // Sort commodities into categories
    for (final price in pricesForMarket) {
      bool categorized = false;

      for (final entry in categories.entries) {
        final categoryName = entry.key;
        final categoryItems = entry.value;

        // Check if this commodity belongs in this category
        if (categoryItems.any((item) => price.commodity.contains(item))) {
          grouped[categoryName]!.add(price);
          categorized = true;
          break;
        }
      }

      // If not found in any specific category, add to Others
      if (!categorized) {
        grouped['Others']!.add(price);
      }
    }

    // Remove empty categories
    grouped.removeWhere((key, value) => value.isEmpty);

    // Sort items within each category by name
    for (final category in grouped.keys) {
      grouped[category]!.sort((a, b) => a.commodity.compareTo(b.commodity));
    }

    return grouped;
  }
}
