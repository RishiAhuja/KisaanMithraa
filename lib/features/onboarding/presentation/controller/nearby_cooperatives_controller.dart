import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cropconnect/core/services/hive/hive_storage_service.dart';
import 'package:cropconnect/features/cooperative/domain/models/cooperative_model.dart';
import 'package:cropconnect/features/notification/domain/model/notifications_model.dart';
import 'package:cropconnect/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../utils/location_utils.dart';

class NearbyCooperativesController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _storageService = Get.find<UserStorageService>();
  late final ConfettiController confettiController;
  final isJoiningCoop = false.obs;
  final userLocation = Rxn<GeoPoint>();
  final nearbyCooperatives = <CooperativeModel>[].obs;
  final isLoading = true.obs;

  static const double MAX_DISTANCE = 10000; // 10km in meters

  @override
  void onInit() {
    super.onInit();
    _initConfetti();
    _initializeLocation();
  }

  void _initConfetti() {
    confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void onClose() {
    confettiController.dispose();
    super.onClose();
  }

  Future<void> _initializeLocation() async {
    try {
      isLoading.value = true;

      // Request location permissions
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final result = await Geolocator.requestPermission();
        if (result == LocationPermission.denied) {
          Get.snackbar(
            'Permission Denied',
            'Location permission is required to find nearby cooperatives',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }

      // Get current location
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      userLocation.value = GeoPoint(position.latitude, position.longitude);

      // Find nearby cooperatives
      await findNearbyCooperatives(userLocation.value!);
    } catch (e) {
      AppLogger.error('Error initializing location: $e');
      Get.snackbar(
        'Error',
        'Failed to get location. Please check your settings.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> findNearbyCooperatives(GeoPoint currentLocation) async {
    try {
      isLoading.value = true;
      userLocation.value = currentLocation;

      final snapshot = await _firestore.collection('cooperatives').get();

      final allCooperatives = snapshot.docs
          .map((doc) => CooperativeModel.fromMap(doc.data()))
          .toList();

      final nearby = allCooperatives.where((coop) {
        final distance = LocationUtils.calculateDistance(
          currentLocation,
          GeoPoint(coop.latitude, coop.longitude),
        );
        return distance <= MAX_DISTANCE;
      }).toList();

      nearby.sort((a, b) {
        final distA = LocationUtils.calculateDistance(
            currentLocation, GeoPoint(a.latitude, a.longitude));
        final distB = LocationUtils.calculateDistance(
            currentLocation, GeoPoint(b.latitude, b.longitude));
        return distA.compareTo(distB);
      });

      nearbyCooperatives.value = nearby;
    } catch (e) {
      AppLogger.error('Error finding nearby cooperatives: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> requestToJoin(CooperativeModel cooperative) async {
    try {
      AppLogger.info("Joining ${cooperative.name}");
      final currentUser = await _storageService.getUser();
      if (currentUser == null) {
        Get.snackbar(
          'Error',
          'User not found',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      isJoiningCoop.value = true;
      final coopDoc =
          await _firestore.collection('cooperatives').doc(cooperative.id).get();

      final members = List<String>.from(coopDoc.data()?['members'] ?? []);
      if (members.contains(currentUser.id)) {
        Get.snackbar(
          'Already a Member',
          'You are already a member of this cooperative',
          snackPosition: SnackPosition.TOP,
        );
        isJoiningCoop.value = false;
        return;
      }

      final existingRequests = List<Map<String, dynamic>>.from(
          coopDoc.data()?['joinRequests'] ?? []);

      if (existingRequests.any((req) => req['userId'] == currentUser.id)) {
        Get.snackbar(
          'Already Requested',
          'You have already sent a request to join this cooperative',
          snackPosition: SnackPosition.TOP,
        );
        isJoiningCoop.value = false;
        return;
      }

      final batch = _firestore.batch();
      final coopRef = _firestore.collection('cooperatives').doc(cooperative.id);

      final joinRequest = {
        'userId': currentUser.id,
        'requestedAt': DateTime.now(),
        'status': 'accepted',
        'userName': currentUser.name,
      };

      batch.update(coopRef, {
        'joinRequests': FieldValue.arrayUnion([joinRequest]),
      });

      batch.update(coopRef, {
        'members': FieldValue.arrayUnion([currentUser.id]),
      });

      final adminId = cooperative.createdBy;
      final notificationRef = _firestore
          .collection('notifications')
          .doc(adminId)
          .collection('items')
          .doc();

      final notification = NotificationModel.generalMessage(
          id: notificationRef.id,
          userId: adminId,
          title: "New Member Joined",
          message: "${currentUser.name} joined ${cooperative.name}");

      batch.set(notificationRef, notification.toMap());
      await batch.commit();

      AppLogger.info('Successfully joined cooperative');

      final dialogConfetti =
          ConfettiController(duration: const Duration(seconds: 3));
      _showJoinSuccessDialog(cooperative.name, dialogConfetti);
    } catch (e) {
      AppLogger.error('Error joining cooperative: $e');
      Get.snackbar(
        'Error',
        'Failed to join cooperative',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } finally {
      isJoiningCoop.value = false;
    }
  }

  void _showJoinSuccessDialog(
      String cooperativeName, ConfettiController dialogConfetti) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome to the Cooperative! 🎉',
                    style: Get.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You have successfully joined $cooperativeName',
                    style: Get.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        dialogConfetti.dispose();
                        Get.offAllNamed('/home');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Go to Home'),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              child: ConfettiWidget(
                confettiController: dialogConfetti..play(),
                blastDirection: pi / 2,
                maxBlastForce: 5,
                minBlastForce: 2,
                emissionFrequency: 0.05,
                numberOfParticles: 50,
                gravity: 0.05,
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }
}
