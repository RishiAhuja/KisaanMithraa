import 'package:cropconnect/utils/app_logger.dart';
import 'package:cropconnect/utils/location_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/services/hive/hive_storage_service.dart';
import '../../domain/models/cooperative_model.dart';

class MyCooperativesController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _storageService = Get.find<UserStorageService>();

  final isLoading = true.obs;
  final error = Rxn<String>();
  final cooperatives = <CooperativeWithRole>[].obs;

  final userLocation = Rx<LatLng?>(null);
  final nearbyCooperatives = <CooperativeModel>[].obs;

  Stream<List<CooperativeWithRole>> get cooperativesStream async* {
    final user = await _storageService.getUser();
    if (user == null) {
      yield [];
      return;
    }

    yield* _firestore
        .collection('cooperatives')
        .where('members', arrayContains: user.id)
        .snapshots()
        .asyncMap((snapshot) async {
      final coops = <CooperativeWithRole>[];

      for (var doc in snapshot.docs) {
        final coop = CooperativeModel.fromMap(doc.data());
        final role = doc.data()['createdBy'] == user.id ? 'admin' : 'member';
        coops.add(CooperativeWithRole(cooperative: coop, role: role));
      }

      return coops;
    });
  }

  @override
  void onInit() {
    super.onInit();
    setupStream();
    _getCurrentLocation();
    _fetchNearbyCooperatives();
  }

  void setupStream() {
    cooperativesStream.listen((coops) {
      cooperatives.value = coops;
      isLoading.value = false;
    }, onError: (error) {
      this.error.value = error.toString();
      isLoading.value = false;
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          AppLogger.warning('Location permission denied by user');
          _handleLocationPermissionDenied();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        AppLogger.warning('Location permission permanently denied');
        _handleLocationPermissionDenied();
        _showLocationPermissionSettingsDialog();
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      userLocation.value = LatLng(position.latitude, position.longitude);
    } catch (e) {
      AppLogger.error('Error getting location: $e');
      _handleLocationPermissionDenied();
    }
  }

  void _handleLocationPermissionDenied() {
    userLocation.value = LatLng(28.6139, 77.2090);

    _tryGetApproximateLocationFromStorage();
  }

  Future<void> _tryGetApproximateLocationFromStorage() async {
    try {
      final user = await _storageService.getUser();
      if (user != null && user.latitude != null && user.longitude != null) {
        userLocation.value = LatLng(user.latitude!, user.longitude!);
        AppLogger.info('Using location from user profile');
      }
    } catch (e) {
      AppLogger.error('Error getting location from storage: $e');
    }
  }

  void _showLocationPermissionSettingsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
            'For the best experience, please enable location access in your device settings. '
            'This allows us to show you nearby cooperatives and provide accurate distance information.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await Geolocator.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchNearbyCooperatives() async {
    try {
      if (userLocation.value == null) {
        await _getCurrentLocation();
      }

      final location = userLocation.value!;
      final cooperatives = await _firestore
          .collection('cooperatives')
          .where('status', isEqualTo: 'verified')
          .get();

      final nearby = <CooperativeModel>[];

      for (final doc in cooperatives.docs) {
        final coop = CooperativeModel.fromMap(doc.data());
        final distance = LocationUtils.calculateDistance(
          GeoPoint(location.latitude, location.longitude),
          GeoPoint(coop.latitude, coop.longitude),
        );

        if (distance <= 20000) {
          nearby.add(coop);
        }
      }

      nearbyCooperatives.assignAll(nearby);
    } catch (e) {
      print('Error fetching nearby cooperatives: $e');
    }
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
