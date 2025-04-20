import 'package:cropconnect/features/auth/domain/model/user/user_model.dart';
import 'package:cropconnect/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/hive/hive_storage_service.dart';
import 'package:cropconnect/core/services/crop/crop_service.dart';
import 'package:cropconnect/features/onboarding/domain/services/location_service.dart';

class ProfileController extends GetxController {
  final UserStorageService _storageService;
  final FirebaseFirestore _firestore;
  final CropService _cropService = Get.find<CropService>();
  final LocationSelectionService _locationService =
      Get.find<LocationSelectionService>();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final soilTypeController = TextEditingController();
  final cropsController = TextEditingController();

  final isLoading = true.obs;
  final isUpdating = false.obs;
  final Rx<UserModel?> user = Rx<UserModel?>(null);

  final selectedState = Rx<String?>(null);
  final selectedCity = Rx<String?>(null);

  List<String> get states => _locationService.getAllStates();

  final cities = <String>[].obs;

  final RxList<String> selectedCrops = <String>[].obs;

  final soilTypes = [
    'Alluvial Soil',
    'Black Soil',
    'Red Soil',
    'Laterite Soil',
    'Desert Soil',
    'Mountain Soil',
  ];

  final isEditMode = false.obs;

  ProfileController(this._storageService, this._firestore);

  @override
  void onInit() {
    super.onInit();

    if (!_locationService.isLoaded) {
      _locationService.loadStateDistrictData();
    }

    ever(selectedState, (state) {
      if (state != null && state.isNotEmpty) {
        loadCities(state);
      } else {
        cities.clear();
      }
    });

    loadUserData();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    soilTypeController.dispose();
    super.onClose();
  }

  Future<void> loadUserData() async {
    try {
      AppLogger.info('Loading user data...');
      isLoading.value = true;

      final userData = await _storageService.getUser();
      if (userData != null) {
        user.value = userData;
        nameController.text = userData.name;
        phoneController.text = userData.phoneNumber;
        soilTypeController.text = userData.soilType ?? '';
        selectedState.value = userData.state;
        selectedCity.value = userData.city;

        AppLogger.info('Crops from storage: ${userData.crops}');

        if (userData.crops != null && userData.crops!.isNotEmpty) {
          selectedCrops.value = List<String>.from(userData.crops!);
        } else {
          selectedCrops.value = [];
        }

        AppLogger.info('Selected crops after loading: $selectedCrops');
      }
      AppLogger.info('User Loaded: ${userData!.id}');
    } catch (e) {
      AppLogger.error('Failed to load user data: $e');
      Get.snackbar('Error', 'Failed to load user data');
    } finally {
      isLoading.value = false;
    }
  }

  void loadCities(String state) {
    cities.value = _locationService.getDistrictsForState(state);

    if (selectedCity.value != null && !cities.contains(selectedCity.value)) {
      selectedCity.value = null;
    }
  }

  Future<Position?> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Error', 'Location permission denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Error',
            'Location permissions permanently denied, please enable in settings');
        return null;
      }

      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      Get.snackbar('Error', 'Failed to get location: $e');
      return null;
    }
  }

  Future<void> updateProfile() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isUpdating.value = true;

      final position = await getCurrentLocation();
      if (position == null) {
        Get.snackbar('Error', 'Could not get current location');
        return;
      }

      final updatedUser = UserModel(
        id: user.value!.id,
        name: nameController.text,
        phoneNumber: user.value!.phoneNumber,
        createdAt: user.value!.createdAt,
        soilType: soilTypeController.text,
        crops: selectedCrops,
        state: selectedState.value,
        city: selectedCity.value,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      await _firestore
          .collection('users')
          .doc(user.value!.id)
          .update(updatedUser.toMap());

      await _storageService.saveUser(updatedUser);

      user.value = updatedUser;
      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
    } finally {
      isUpdating.value = false;
    }
  }

  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;

    if (!isEditMode.value) {
      loadUserData();
    }
  }

  void cancelEdit() {
    isEditMode.value = false;
    loadUserData();
  }

  List<String> get availableCrops => _cropService.getAllCropNames();

  List<String> getRecommendedCrops() {
    if (selectedState.value == null || selectedState.value!.isEmpty) return [];
    return _cropService
        .getRecommendedCropsForState(selectedState.value ?? "")
        .map((crop) => crop.name)
        .toList();
  }
}
