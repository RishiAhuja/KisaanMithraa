import 'package:cropconnect/features/auth/domain/model/user/user_model.dart';
import 'package:cropconnect/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/hive/hive_storage_service.dart';

class ProfileController extends GetxController {
  final UserStorageService _storageService;
  final FirebaseFirestore _firestore;

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

  final states = <String>[
    'Uttar Pradhes', 'Bihar', 'Punjab'
    // Add more states as needed
  ].obs;

  final cities = <String>[].obs;

  final RxList<String> selectedCrops = <String>[].obs;
  final RxList<String> availableCrops = <String>[
    'Rice',
    'Wheat',
    'Corn',
    'Cotton',
    'Sugarcane',
    'Pulses',
    'Vegetables',
    'Fruits'
  ].obs;

  final soilTypes = [
    'Alluvial Soil',
    'Black Soil',
    'Red Soil',
    'Laterite Soil',
    'Desert Soil',
    'Mountain Soil',
  ];

  ProfileController(this._storageService, this._firestore);

  @override
  void onInit() {
    super.onInit();
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
        selectedCrops.value = userData.crops ?? [];

        if (userData.state != null) {
          await loadCities(userData.state!);
        }
      }
      AppLogger.info('User Loaded: ${userData!.id}');
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCities(String state) async {
    cities.value = ['Amritsar', 'Ludhiana', 'Jalandhar'];
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

      // Get current location
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
}
