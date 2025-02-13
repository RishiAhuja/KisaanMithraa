import 'package:cropconnect/features/auth/domain/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/services/hive/hive_storage_service.dart';

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

  final states = <String>[].obs;
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
    loadStates();
    loadUserData();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      final userData = await _storageService.getUser();
      if (userData != null) {
        user.value = userData;
        nameController.text = userData.name;
        phoneController.text = userData.phoneNumber;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadStates() async {
    states.value = [
      'Maharashtra',
      'Karnataka',
      'Gujarat', /* ... */
    ];
  }

  Future<void> loadCities(String state) async {
    cities.value = ['City 1', 'City 2', 'City 3'];
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> updateProfile() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isUpdating.value = true;

      List<Location> locations = await locationFromAddress(
          '${selectedCity.value}, ${selectedState.value}');

      final updatedUser = UserModel(
        id: user.value!.id,
        name: nameController.text,
        phoneNumber: user.value!.phoneNumber,
        createdAt: user.value!.createdAt,
        soilType: soilTypeController.text,
        crops: selectedCrops,
        state: selectedState.value,
        city: selectedCity.value,
        latitude: locations.first.latitude,
        longitude: locations.first.longitude,
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
