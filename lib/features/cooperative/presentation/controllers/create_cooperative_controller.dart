import 'package:cropconnect/core/constants/app_constants.dart';
import 'package:cropconnect/core/services/hive/hive_storage_service.dart';
import 'package:cropconnect/features/auth/domain/model/user/cooperative_membership_model.dart';
import 'package:cropconnect/features/auth/domain/model/user/user_model.dart';
import 'package:cropconnect/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cropconnect/features/cooperative/domain/models/cooperative_invite_model.dart';
import 'package:cropconnect/features/cooperative/domain/models/verification_requirements.dart';
import 'package:cropconnect/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/models/cooperative_model.dart';
import 'package:cropconnect/features/notification/domain/model/notifications_model.dart';

class CreateCooperativeController extends GetxController {
  final FirebaseFirestore _firestore;
  final _storageService = Get.find<UserStorageService>();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final isLoading = false.obs;

  // New fields
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

  // Add these new fields
  final searchResults = <UserModel>[].obs;

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
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      final currentUserId = Get.find<AuthController>().user.value?.id;
      final excludeIds = [
        ...selectedMembers.map((m) => m.id),
        if (currentUserId != null) currentUserId
      ];

      String phoneQuery = query;
      if (query.length == 10 && RegExp(r'^\d+$').hasMatch(query)) {
        phoneQuery = '+91$query';
      }

      final queryLower = query.toLowerCase();

      final nameSnapshot = await _firestore
          .collection('users')
          .orderBy('name')
          .startAt([queryLower]).endAt(['$queryLower\uf8ff']).get();

      final phoneSnapshot = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneQuery)
          .get();

      final allDocs = {...nameSnapshot.docs, ...phoneSnapshot.docs};

      searchResults.value = allDocs
          .map((doc) {
            try {
              final data = doc.data();
              if (data['name'] != null) {
                data['name'] = data['name'].toString().toLowerCase();
              }
              return UserModel.fromMap(data, doc.id);
            } catch (e) {
              AppLogger.error('Error parsing user data: $e');
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

      final sortedResults = List<UserModel>.from(searchResults)
        ..sort((a, b) {
          if (a.name.toLowerCase() == queryLower) return -1;
          if (b.name.toLowerCase() == queryLower) return 1;
          if (a.phoneNumber == phoneQuery) return -1;
          if (b.phoneNumber == phoneQuery) return 1;
          return a.name.length.compareTo(b.name.length);
        });

      searchResults.value = sortedResults;

      AppLogger.debug('Search Results: ${searchResults.length} users found');
    } catch (e) {
      AppLogger.error('Error searching members: $e');
      searchResults.clear();
    }
  }

  // Clear search results when dialog is closed
  void clearSearch() {
    searchResults.clear();
  }
}
