import 'package:cropconnect/core/constants/app_constants.dart';
import 'package:cropconnect/core/services/hive/hive_storage_service.dart';
import 'package:cropconnect/features/auth/domain/model/user/cooperative_membership_model.dart';
import 'package:cropconnect/features/auth/domain/model/user/user_model.dart';
import 'package:cropconnect/features/cooperative/domain/models/cooperative_invite_model.dart';
import 'package:cropconnect/features/cooperative/domain/models/verification_requirements.dart';
import 'package:cropconnect/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/models/cooperative_model.dart';
import 'package:cropconnect/features/notification/domain/model/notifications_model.dart';

// Add these imports at the top
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class CreateCooperativeController extends GetxController {
  final FirebaseFirestore _firestore;
  final _storageService = Get.find<UserStorageService>();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final isLoading = false.obs;

  final selectedMembers = <UserModel>[].obs;
  final userLocation = Rxn<Position>();
  final currentUser = Rxn<UserModel>();

  final cropTypes = [
    'Rice',
    'Wheat',
    'Corn',
    'Cotton',
    'Sugarcane',
    'Pulses',
    'Vegetables',
    'Fruits',
  ];

  final searchResults = <UserModel>[].obs;

  final Rxn<File> selectedImage = Rxn<File>();
  final isUploadingImage = false.obs;
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CreateCooperativeController(this._firestore);

  @override
  void onInit() {
    super.onInit();
    _loadUser();
    getCurrentLocation();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    searchResults.clear();
    super.onClose();
  }

  Future<void> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      userLocation.value = position;
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _loadUser() async {
    try {
      final userData = await _storageService.getUser();
      if (userData != null) {
        currentUser.value = userData;
      } else {
        Get.snackbar(
          'Error',
          'User data not found',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offAllNamed('/login');
      }
    } catch (e) {
      AppLogger.error('Error loading user data: $e');
      Get.snackbar(
        'Error',
        'Failed to load user data',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> createCooperative() async {
    if (currentUser.value == null) {
      Get.snackbar(
        'Error',
        'Please wait while user data loads',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (!formKey.currentState!.validate()) return;
    if (selectedMembers.length <
        AppConstants.minimumCooperativeMemberCount - 1) {
      Get.snackbar(
        'Error',
        'Please select at least ${AppConstants.minimumCooperativeMemberCount - 1} members',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      AppLogger.debug(currentUser.value?.id ?? "null");
      isLoading.value = true;

      String? bannerUrl;
      if (selectedImage.value != null) {
        bannerUrl = await uploadImage();
      }

      final uniqueCropTypes = selectedMembers
          .expand((member) => member.crops ?? [])
          .where((crop) => crop != null)
          .map((crop) => crop.toString())
          .toSet()
          .toList();

      final cooperative = CooperativeModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text,
        createdBy: currentUser.value!.id,
        createdAt: DateTime.now(),
        status: 'unverified',
        description: descriptionController.text,
        location: currentUser.value!.city ?? 'Unknown',
        latitude: userLocation.value?.latitude ?? 0,
        longitude: userLocation.value?.longitude ?? 0,
        cropTypes: uniqueCropTypes,
        members: [currentUser.value!.id],
        bannerUrl: bannerUrl,
        pendingInvites: selectedMembers
            .map((member) => CooperativeInvite(
                  userId: member.id,
                  invitedAt: DateTime.now(),
                  status: 'pending',
                ))
            .toList(),
        verificationRequirements: VerificationRequirements(
          minimumMembers: AppConstants.minimumCooperativeMemberCount,
          acceptedInvites: 0,
        ),
      );

      final batch = FirebaseFirestore.instance.batch();

      final coopRef = _firestore.collection('cooperatives').doc(cooperative.id);
      batch.set(coopRef, cooperative.toMap());

      final userRef = _firestore.collection('users').doc(currentUser.value!.id);

      final newCooperativeMembership = CooperativeMembership(
        cooperativeId: cooperative.id,
        role: 'admin',
      );

      final updatedCooperatives = [
        ...currentUser.value!.cooperatives,
        newCooperativeMembership,
      ];

      batch.update(userRef, {
        'cooperatives': updatedCooperatives.map((x) => x.toMap()).toList(),
      });

      for (final member in selectedMembers) {
        final notificationRef = _firestore
            .collection('notifications')
            .doc(member.id)
            .collection('items')
            .doc();

        final notification = NotificationModel.cooperativeInvite(
          id: notificationRef.id,
          userId: member.id,
          cooperativeName: cooperative.name,
          cooperativeId: cooperative.id,
          invitedBy: currentUser.value!.name,
        );

        batch.set(notificationRef, notification.toMap());
      }

      final updatedUser = UserModel(
        id: currentUser.value!.id,
        name: currentUser.value!.name,
        phoneNumber: currentUser.value!.phoneNumber,
        createdAt: currentUser.value!.createdAt,
        soilType: currentUser.value!.soilType,
        crops: currentUser.value!.crops,
        state: currentUser.value!.state,
        city: currentUser.value!.city,
        latitude: currentUser.value!.latitude,
        longitude: currentUser.value!.longitude,
        cooperatives: updatedCooperatives,
        pendingInvites: currentUser.value!.pendingInvites,
      );

      await batch.commit();

      await _storageService.saveUser(updatedUser);
      currentUser.value = updatedUser;

      Get.snackbar(
        'Success',
        'Cooperative created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.offAllNamed('/home');
    } catch (e) {
      AppLogger.error('Error creating cooperative: $e');
      Get.snackbar(
        'Error',
        'Failed to create cooperative',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchMembers(String query) async {
    try {
      if (query.isEmpty) {
        searchResults.clear();
        return;
      }

      // Clean and prepare query strings
      final queryLower = query.toLowerCase().trim();

      // Make phone number search more flexible
      String phoneQuery = query.replaceAll(RegExp(r'[^\d]'), '');
      if (phoneQuery.length == 10 && !phoneQuery.startsWith('91')) {
        // Try both with and without country code
        phoneQuery = phoneQuery;
      }

      // IDs to exclude from search results
      final currentUserId = currentUser.value?.id;
      final excludeIds = [
        ...selectedMembers.map((m) => m.id),
        if (currentUserId != null) currentUserId,
      ];

      // Perform a simple get() instead of complex queries
      final snapshot = await _firestore.collection('users').get();

      // Filter in memory
      final filteredResults = snapshot.docs
          .map((doc) {
            try {
              return UserModel.fromMap(doc.data(), doc.id);
            } catch (e) {
              AppLogger.error('Error parsing user: $e');
              return null;
            }
          })
          .where((user) =>
              user != null &&
              !excludeIds.contains(user.id) &&
              (user.name.toLowerCase().contains(queryLower) ||
                  user.phoneNumber.contains(phoneQuery)))
          .cast<UserModel>()
          .toList();

      // Sort results by relevance
      filteredResults.sort((a, b) {
        // Exact name match gets highest priority
        if (a.name.toLowerCase() == queryLower) return -1;
        if (b.name.toLowerCase() == queryLower) return 1;

        // Exact phone match gets next priority
        if (a.phoneNumber.endsWith(phoneQuery)) return -1;
        if (b.phoneNumber.endsWith(phoneQuery)) return 1;

        // Otherwise sort by name length (shorter names first)
        return a.name.length.compareTo(b.name.length);
      });

      // Update the observable list
      searchResults.value = filteredResults;
      AppLogger.info('Found ${filteredResults.length} users matching "$query"');
    } catch (e) {
      AppLogger.error('Error searching members: $e');
      searchResults.clear();
    }
  }

  void clearSearch() {
    searchResults.clear();
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
      }
    } catch (e) {
      AppLogger.error('Error picking image: $e');
      Get.snackbar(
        'Error',
        'Failed to select image',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<String?> uploadImage() async {
    if (selectedImage.value == null) return null;

    try {
      isUploadingImage.value = true;
      final fileName = path.basename(selectedImage.value!.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef =
          _storage.ref().child('cooperatives/$timestamp-$fileName');

      final uploadTask = storageRef.putFile(
        selectedImage.value!,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      AppLogger.error('Error uploading image: $e');
      Get.snackbar(
        'Warning',
        'Failed to upload image, but cooperative will still be created',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      isUploadingImage.value = false;
    }
  }
}
