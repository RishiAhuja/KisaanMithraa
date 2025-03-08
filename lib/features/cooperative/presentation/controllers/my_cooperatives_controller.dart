import 'dart:async';

import 'package:cropconnect/features/profile/controller/profile_controller.dart';
import 'package:cropconnect/utils/app_logger.dart';
import 'package:cropconnect/utils/location_utils.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/services/hive/hive_storage_service.dart';
import '../../domain/models/cooperative_model.dart';

class MyCooperativesController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _storageService = Get.find<UserStorageService>();
  ProfileController? _profileController;

  final isLoading = true.obs;
  final error = Rxn<String>();
  final cooperatives = <CooperativeWithRole>[].obs;
  final dataLoaded = false.obs; // Track if data has been loaded

  final userLocation = Rx<LatLng?>(null);
  final nearbyCooperatives = <CooperativeModel>[].obs;

  // Make this a simple Rx to avoid stream issues
  final cooperativesStream = Rxn<Stream<List<CooperativeWithRole>>>();
  final userId = RxnString();

  StreamSubscription? _cooperativesSubscription;

  @override
  void onInit() {
    super.onInit();
    AppLogger.debug('Initializing MyCooperativesController');

    _initializeUserData();
  }

  // Initialize user data and streams
  Future<void> _initializeUserData() async {
    try {
      // Try to get ProfileController
      if (Get.isRegistered<ProfileController>()) {
        _profileController = Get.find<ProfileController>();
        if (_profileController?.user.value != null) {
          userId.value = _profileController?.user.value?.id;
          AppLogger.debug('Got userId from ProfileController: ${userId.value}');
        }
      }

      // If still no userId, try storage
      if (userId.value == null) {
        AppLogger.debug('Trying to get userId from storage');
        final user = await _storageService.getUser();
        if (user != null && user.id.isNotEmpty) {
          userId.value = user.id;
          AppLogger.debug('Got userId from storage: ${userId.value}');
        }
      }

      // Now initialize everything else with userId
      if (userId.value != null) {
        _initializeCooperativesStream();
        _getCurrentLocation();
        _fetchNearbyCooperatives();
      } else {
        AppLogger.error('Failed to get user ID');
        error.value = 'User not found';
        isLoading.value = false;
      }
    } catch (e) {
      AppLogger.error('Error initializing user data: $e');
      error.value = 'Error initializing data';
      isLoading.value = false;
    }
  }

  // Initialize the cooperatives stream
  void _initializeCooperativesStream() {
    if (userId.value == null) {
      AppLogger.warning(
          'Cannot initialize cooperatives stream: userId is null');
      return;
    }

    AppLogger.debug(
        'Initializing cooperatives stream for user ${userId.value}');

    try {
      // Cancel any existing subscription
      _cooperativesSubscription?.cancel();

      final stream = _firestore
          .collection('cooperatives')
          .where('members', arrayContains: userId.value)
          .snapshots()
          .map((snapshot) {
        final coops = snapshot.docs.map((doc) {
          final data = doc.data();
          // Pass doc.id here - this is crucial!
          final coop = CooperativeModel.fromMap(data);
          final role = coop.createdBy == userId.value ? 'admin' : 'member';
          return CooperativeWithRole(cooperative: coop, role: role);
        }).toList();

        AppLogger.debug('Stream received ${coops.length} cooperatives');
        return coops;
      }).asBroadcastStream();

      cooperativesStream.value = stream;

      // Store the subscription so we can cancel it later
      _cooperativesSubscription = stream.listen(
        (coops) {
          // Cache the data in the controller
          cooperatives.value = coops;
          dataLoaded.value = true; // Mark data as loaded
          isLoading.value = false;
          AppLogger.debug('Cached ${coops.length} cooperatives in memory');
        },
        onError: (e) {
          AppLogger.error('Error in cooperatives stream: $e');
          error.value = 'Failed to load cooperatives';
          isLoading.value = false;
        },
      );
    } catch (e) {
      AppLogger.error('Failed to initialize cooperatives stream: $e');
      error.value = 'Failed to initialize cooperatives stream';
      isLoading.value = false;
    }
  }

  // Get current location
  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      userLocation.value = LatLng(position.latitude, position.longitude);
      AppLogger.debug(
          'Got user location: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      AppLogger.error('Error getting location: $e');
    }
  }

  // Fetch nearby cooperatives
  Future<void> _fetchNearbyCooperatives() async {
    try {
      if (userLocation.value == null) {
        await _getCurrentLocation();
      }

      if (userLocation.value == null) {
        AppLogger.error('Could not get user location');
        return;
      }

      final location = userLocation.value!;
      final snapshot = await _firestore
          .collection('cooperatives')
          .where('status', isEqualTo: 'verified')
          .get();

      final nearby = <CooperativeModel>[];

      for (final doc in snapshot.docs) {
        // Pass both data and doc.id
        final coop = CooperativeModel.fromMap(doc.data());
        final distance = LocationUtils.calculateDistance(
          GeoPoint(location.latitude, location.longitude),
          GeoPoint(coop.latitude, coop.longitude),
        );

        if (distance <= 20000) {
          // 20km radius
          nearby.add(coop);
        }
      }

      nearbyCooperatives.assignAll(nearby);
      AppLogger.debug('Found ${nearby.length} nearby cooperatives');
    } catch (e) {
      AppLogger.error('Error fetching nearby cooperatives: $e');
    }
  }

  // Method to refresh my cooperatives data
  void refreshMyCooperatives() {
    if (dataLoaded.value && cooperatives.isNotEmpty) {
      // Data is already loaded, no need to refresh
      return;
    }

    // Otherwise re-initialize the stream
    AppLogger.debug('Refreshing my cooperatives data');
    isLoading.value = true;
    _initializeCooperativesStream();
  }

  // Clean up resources when controller is closed
  @override
  void onClose() {
    _cooperativesSubscription?.cancel();
    super.onClose();
  }
}

class CooperativeWithRole {
  final CooperativeModel cooperative;
  final String role;

  CooperativeWithRole({
    required this.cooperative,
    required this.role,
  });
}
