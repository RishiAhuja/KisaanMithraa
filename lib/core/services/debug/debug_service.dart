import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cropconnect/core/constants/app_constants.dart';
import 'package:cropconnect/features/auth/domain/model/user/user_model.dart';
import 'package:cropconnect/features/cooperative/domain/models/cooperative_model.dart';
import 'package:cropconnect/features/cooperative/domain/models/verification_requirements.dart';
import 'package:cropconnect/utils/app_logger.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class DebugService extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  static const _uuid = Uuid();
  final faker = Faker();
  final isDebugMode = false.obs;
  final isGeneratingData = false.obs;

  // Indian cities and states for more realistic data
  final List<Map<String, String>> indianLocations = [
    {'city': 'Mumbai', 'state': 'Maharashtra'},
    {'city': 'Delhi', 'state': 'Delhi'},
    {'city': 'Bangalore', 'state': 'Karnataka'},
    {'city': 'Hyderabad', 'state': 'Telangana'},
    {'city': 'Chennai', 'state': 'Tamil Nadu'},
    {'city': 'Kolkata', 'state': 'West Bengal'},
    {'city': 'Ahmedabad', 'state': 'Gujarat'},
    {'city': 'Pune', 'state': 'Maharashtra'},
    {'city': 'Jaipur', 'state': 'Rajasthan'},
    {'city': 'Lucknow', 'state': 'Uttar Pradesh'},
    {'city': 'Kochi', 'state': 'Kerala'},
    {'city': 'Chandigarh', 'state': 'Punjab'},
    {'city': 'Indore', 'state': 'Madhya Pradesh'},
    {'city': 'Bhopal', 'state': 'Madhya Pradesh'},
    {'city': 'Patna', 'state': 'Bihar'},
  ];

  // Common Indian crops
  final List<String> indianCrops = [
    'Rice',
    'Wheat',
    'Maize',
    'Bajra',
    'Jowar',
    'Cotton',
    'Sugarcane',
    'Tea',
    'Coffee',
    'Jute',
    'Groundnut',
    'Mustard',
    'Soybean',
    'Sunflower',
    'Chilli',
    'Turmeric',
    'Potato',
    'Tomato',
    'Onion',
    'Cauliflower'
  ];

  void toggleDebugMode() {
    isDebugMode.toggle();

    if (isDebugMode.value) {
      Get.snackbar(
        'Debug Mode Activated',
        'You now have access to data generation tools',
        backgroundColor: Colors.amber,
        colorText: Colors.black,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Debug Mode Deactivated',
        'Returning to normal app operation',
        backgroundColor: Colors.grey,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<List<UserModel>> generateRandomUsers({
    required int count,
    double? nearLatitude,
    double? nearLongitude,
    double radiusKm = 10.0,
  }) async {
    if (isGeneratingData.value) return [];

    try {
      isGeneratingData.value = true;
      AppLogger.debug('[DEBUG] Generating $count random users');

      final generatedUsers = <UserModel>[];

      if (count <= 0) {
        AppLogger.warning(
            '[DEBUG] Cannot generate 0 or negative number of users');
        return [];
      }

      nearLatitude ??= 20.5937;
      nearLongitude ??= 78.9629;

      for (int i = 0; i < count; i++) {
        try {
          Map<String, double> coords = {'latitude': 0.0, 'longitude': 0.0};

          bool coordsGenerated = false;
          for (int attempt = 0; attempt < 3 && !coordsGenerated; attempt++) {
            try {
              coords = _generateSimpleCoordinatesNear(
                  nearLatitude, nearLongitude, radiusKm);
              coordsGenerated = true;
            } catch (coordError) {
              AppLogger.warning(
                  '[DEBUG] Coordinate generation attempt $attempt failed: $coordError');
            }
          }

          if (!coordsGenerated) {
            AppLogger.warning('[DEBUG] Using fallback coordinates');
            coords = {
              'latitude': nearLatitude + (Random().nextDouble() - 0.5) / 10,
              'longitude': nearLongitude + (Random().nextDouble() - 0.5) / 10,
            };
          }

          final randomLocation =
              indianLocations[Random().nextInt(indianLocations.length)];

          final randomCrops = List.generate(Random().nextInt(3) + 1,
                  (_) => indianCrops[Random().nextInt(indianCrops.length)])
              .toSet()
              .toList();

          final phoneNumber =
              List.generate(10, (_) => Random().nextInt(10).toString()).join();

          final userId = 'debug-${_uuid.v4()}';

          final user = UserModel(
            id: userId,
            name: '${faker.person.firstName()} ${faker.person.lastName()}',
            phoneNumber: phoneNumber,
            createdAt:
                DateTime.now().subtract(Duration(days: Random().nextInt(365))),
            city: randomLocation['city']!,
            state: randomLocation['state']!,
            crops: randomCrops.isEmpty ? ['Wheat'] : randomCrops,
            cooperatives: [],
            pendingInvites: [],
            latitude: coords['latitude']!,
            longitude: coords['longitude']!,
          );

          await _firestore.collection('users').doc(userId).set(user.toMap());
          generatedUsers.add(user);
          AppLogger.debug('[DEBUG] Created user: ${user.name} (${user.id})');
        } catch (userError) {
          AppLogger.error('[DEBUG] Error creating individual user: $userError');
        }
      }

      if (generatedUsers.isEmpty) {
        AppLogger.warning('[DEBUG] Failed to create any users');
      } else {
        AppLogger.debug(
            '[DEBUG] Successfully created ${generatedUsers.length} users');
      }

      return generatedUsers;
    } catch (e) {
      AppLogger.error('[DEBUG] Error generating random users: $e');
      return [];
    } finally {
      isGeneratingData.value = false;
    }
  }

  Future<CooperativeModel?> generateCooperative({
    required String name,
    required String description,
    required double latitude,
    required double longitude,
    int memberCount = 10,
    String? creatorId,
  }) async {
    if (isGeneratingData.value) return null;

    try {
      isGeneratingData.value = true;
      AppLogger.debug('[DEBUG] Starting cooperative generation: "$name"');

      memberCount = memberCount.clamp(1, 20);
      AppLogger.info(memberCount.toString());

      isGeneratingData.value = false;

      final users = await generateRandomUsers(
        count: memberCount,
        nearLatitude: latitude,
        nearLongitude: longitude,
        radiusKm: 15.0,
      );
      isGeneratingData.value = true;

      AppLogger.debug(
          '[DEBUG] Generated ${users.length} users for cooperative');

      if (users.isEmpty) {
        AppLogger.error('[DEBUG] No users generated for cooperative');
        return null;
      }

      UserModel creator;
      List<UserModel> members = List.from(users);

      if (creatorId != null) {
        try {
          final creatorDoc =
              await _firestore.collection('users').doc(creatorId).get();
          if (creatorDoc.exists) {
            creator = UserModel.fromMap(creatorDoc.data()!, creatorDoc.id);
            AppLogger.debug('[DEBUG] Using specified creator: ${creator.name}');
          } else {
            creator = members.removeAt(0);
            AppLogger.debug(
                '[DEBUG] Specified creator not found, using generated user');
          }
        } catch (e) {
          creator = members.removeAt(0);
          AppLogger.error('[DEBUG] Error getting specified creator: $e');
        }
      } else {
        creator = members.removeAt(0);
        AppLogger.debug('[DEBUG] Using first generated user as creator');
      }

      final allCrops = <String>{};

      if (creator.crops != null && creator.crops!.isNotEmpty) {
        allCrops.addAll(creator.crops!);
      }

      for (final member in members) {
        if (member.crops != null && member.crops!.isNotEmpty) {
          allCrops.addAll(member.crops!);
        }
      }

      if (allCrops.isEmpty) {
        allCrops.add('Wheat');
      }

      final allMemberIds = [creator.id, ...members.map((u) => u.id)];
      final cooperativeId = 'debug-${DateTime.now().millisecondsSinceEpoch}';

      final cooperativeData = {
        'id': cooperativeId,
        'name': name,
        'createdBy': creator.id,
        'createdAt': Timestamp.now(),
        'status': 'verified',
        'description': description,
        'location': creator.city ?? 'Unknown',
        'latitude': latitude,
        'longitude': longitude,
        'cropTypes': allCrops.toList(),
        'members': allMemberIds,
        'bannerUrl': null,
        'pendingInvites': [],
        'verificationRequirements': {
          'minimumMembers': AppConstants.minimumCooperativeMemberCount,
          'acceptedInvites': members.length,
        },
      };

      // Save to Firestore
      AppLogger.debug('[DEBUG] Saving cooperative to Firestore');
      try {
        await _firestore
            .collection('cooperatives')
            .doc(cooperativeId)
            .set(cooperativeData);
        AppLogger.debug('[DEBUG] Cooperative document saved');
      } catch (firestoreError) {
        AppLogger.error('[DEBUG] Error saving cooperative: $firestoreError');
        rethrow;
      }

      AppLogger.debug(
          '[DEBUG] Updating user documents with cooperative membership');

      for (final userId in allMemberIds) {
        try {
          String role = (userId == creator.id) ? 'admin' : 'member';

          final membership = {
            'cooperativeId': cooperativeId,
            'role': role,
          };

          await _firestore.collection('users').doc(userId).update({
            'cooperatives': FieldValue.arrayUnion([membership]),
          });

          AppLogger.debug('[DEBUG] Updated user $userId with role: $role');
        } catch (e) {
          AppLogger.warning('[DEBUG] Failed to update user $userId: $e');
        }
      }

      final cooperative = CooperativeModel(
        id: cooperativeId,
        name: name,
        createdBy: creator.id,
        createdAt: DateTime.now(),
        status: 'verified',
        description: description,
        location: creator.city ?? 'Unknown',
        latitude: latitude,
        longitude: longitude,
        cropTypes: allCrops.toList(),
        members: allMemberIds,
        bannerUrl: null,
        pendingInvites: [],
        verificationRequirements: VerificationRequirements(
          minimumMembers: AppConstants.minimumCooperativeMemberCount,
          acceptedInvites: members.length,
        ),
      );

      _logCooperativeDetails(name, creator, members, allCrops.toList());

      AppLogger.debug(
          '[DEBUG] Successfully created cooperative "${name}" with ${allMemberIds.length} members');
      return cooperative;
    } catch (e) {
      AppLogger.error('[DEBUG] Error in cooperative generation: $e');
      return null;
    } finally {
      isGeneratingData.value = false;
    }
  }

  Map<String, double> _generateSimpleCoordinatesNear(
    double? baseLat,
    double? baseLng,
    double radiusKm,
  ) {
    AppLogger.debug("starting simple coordinates generator");
    if (baseLat == null || baseLng == null) {
      AppLogger.info("baseLat && baseLng == null: falling back to default");
      return {
        'latitude': 20.5937 + (Random().nextDouble() * 8.0) - 4.0,
        'longitude': 78.9629 + (Random().nextDouble() * 10.0) - 5.0,
      };
    }

    final latOffset = (Random().nextDouble() - 0.5) * 2 * radiusKm / 111.0;

    double lngFactor = cos(baseLat * pi / 180.0) * 111.0;
    if (lngFactor.abs() < 0.1) lngFactor = 0.1;

    final lngOffset = (Random().nextDouble() - 0.5) * 2 * radiusKm / lngFactor;

    AppLogger.info("Successfully generated coords: ${{
      'latitude': baseLat + latOffset,
      'longitude': baseLng + lngOffset,
    }}");
    return {
      'latitude': baseLat + latOffset,
      'longitude': baseLng + lngOffset,
    };
  }

  Future<void> clearDebugData() async {
    try {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('This will delete ALL debug-generated data. '
              'This action cannot be undone. Are you sure?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete All'),
            ),
          ],
        ),
      );

      if (result != true) return;

      isGeneratingData.value = true;
      AppLogger.debug('[DEBUG] Starting debug data cleanup');

      // First, find all debug users
      try {
        final usersSnapshot = await _firestore
            .collection('users')
            .where(FieldPath.documentId, isGreaterThanOrEqualTo: 'debug-')
            .where(FieldPath.documentId, isLessThan: 'debug-\uf8ff')
            .get();

        AppLogger.debug(
            '[DEBUG] Found ${usersSnapshot.docs.length} debug users to delete');

        // Delete each user document
        int deletedUsers = 0;
        for (var doc in usersSnapshot.docs) {
          try {
            await _firestore.collection('users').doc(doc.id).delete();
            deletedUsers++;
          } catch (e) {
            AppLogger.error('[DEBUG] Failed to delete user ${doc.id}: $e');
          }
        }
        AppLogger.debug('[DEBUG] Successfully deleted $deletedUsers users');
      } catch (e) {
        AppLogger.error('[DEBUG] Error while deleting debug users: $e');
      }

      // Then find and delete all debug cooperatives
      try {
        final cooperativesSnapshot = await _firestore
            .collection('cooperatives')
            .where(FieldPath.documentId, isGreaterThanOrEqualTo: 'debug-')
            .where(FieldPath.documentId, isLessThan: 'debug-\uf8ff')
            .get();

        AppLogger.debug(
            '[DEBUG] Found ${cooperativesSnapshot.docs.length} debug cooperatives to delete');

        // Delete each cooperative document
        int deletedCooperatives = 0;
        for (var doc in cooperativesSnapshot.docs) {
          try {
            await _firestore.collection('cooperatives').doc(doc.id).delete();
            deletedCooperatives++;
          } catch (e) {
            AppLogger.error(
                '[DEBUG] Failed to delete cooperative ${doc.id}: $e');
          }
        }
        AppLogger.debug(
            '[DEBUG] Successfully deleted $deletedCooperatives cooperatives');
      } catch (e) {
        AppLogger.error('[DEBUG] Error while deleting debug cooperatives: $e');
      }

      Get.snackbar(
        'Debug Data Cleared',
        'All debug-generated data has been removed',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      AppLogger.error('[DEBUG] Error clearing debug data: $e');
      Get.snackbar(
        'Error',
        'Failed to clear debug data: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isGeneratingData.value = false;
    }
  }

  void _logCooperativeDetails(
    String name,
    UserModel creator,
    List<UserModel> members,
    List<String> crops,
  ) {
    AppLogger.debug('===== Cooperative Details =====');
    AppLogger.debug('Name: $name');
    AppLogger.debug('Creator: ${creator.name} (${creator.id})');
    AppLogger.debug('Member count: ${members.length + 1}'); // +1 for creator
    AppLogger.debug('Crops: ${crops.join(", ")}');
    AppLogger.debug('===============================');
  }
}
