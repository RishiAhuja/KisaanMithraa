import 'dart:math';

import 'package:cropconnect/features/notification/domain/model/notifications_model.dart';
import 'package:cropconnect/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/cooperative_model.dart';
import '../../../auth/domain/model/user/user_model.dart';
import 'package:cropconnect/core/services/hive/hive_storage_service.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class CooperativeDetailsController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final cooperative = Rxn<CooperativeModel>();
  final members = <UserModel>[].obs;
  final isLoading = true.obs;
  final error = Rxn<String>();
  final role = 'viewer'.obs;

  // New properties for requested features
  final isRequestingJoin = false.obs;
  final resourceListingsCount = 0.obs;
  final isLoadingListings = false.obs;
  final UserStorageService _storageService = Get.find<UserStorageService>();

  @override
  void onInit() {
    super.onInit();
    AppLogger.debug('CooperativeDetailsController.onInit()');

    final args = Get.arguments;

    if (args != null) {
      // Check if args contains a cooperative field (using your original approach)
      if (args.cooperative != null) {
        cooperative.value = args.cooperative;

        // If role is available, set it
        if (args.role != null) {
          role.value = args.role;
        }

        _loadData();
      } else {
        AppLogger.error('Invalid arguments: Cooperative not found');
        Get.snackbar('Error', 'Invalid navigation arguments');
        Get.back();
      }
    } else {
      AppLogger.error('Arguments are null');
      Get.snackbar('Error', 'Invalid navigation arguments');
      Get.back();
    }
  }

  void _loadData() {
    if (cooperative.value == null) return;

    loadMembers();
    loadResourceListings();
  }

  Future<void> loadMembers() async {
    try {
      isLoading.value = true;
      error.value = null;

      final memberDocs = await Future.wait(
        cooperative.value!.members.map((memberId) async {
          final doc = await _firestore.collection('users').doc(memberId).get();
          return doc;
        }),
      );

      members.value = memberDocs
          .where((doc) => doc.exists)
          .map((doc) => UserModel.fromMap(doc.data()!, doc.id))
          .toList();

      members.sort((a, b) {
        if (a.id == cooperative.value!.createdBy) return -1;
        if (b.id == cooperative.value!.createdBy) return 1;
        return a.name.compareTo(b.name);
      });
    } catch (e) {
      error.value = 'Failed to load members';
      AppLogger.error('Error loading members: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void loadResourceListings() {
    if (cooperative.value == null) return;

    AppLogger.debug('Loading resource listings for ${cooperative.value!.id}');
    isLoadingListings.value = true;

    try {
      _firestore
          .collection('cooperatives')
          .doc(cooperative.value!.id)
          .collection('resource_listings')
          .get()
          .then((snapshot) {
        resourceListingsCount.value = snapshot.docs.length;
        AppLogger.debug('Loaded ${snapshot.docs.length} resource listings');
      }).catchError((error) {
        AppLogger.error('Error loading resource listings: $error');
        resourceListingsCount.value = 0;
      }).whenComplete(() {
        isLoadingListings.value = false;
      });
    } catch (e) {
      AppLogger.error('Exception in loadResourceListings: $e');
      resourceListingsCount.value = 0;
      isLoadingListings.value = false;
    }
  }

  Future<void> requestToJoin() async {
    try {
      if (cooperative.value == null) {
        Get.snackbar(
          'Error',
          'Cooperative information not available',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      AppLogger.info("Requesting to join ${cooperative.value!.name}");
      final currentUser = await _storageService.getUser();
      if (currentUser == null) {
        Get.snackbar(
          'Error',
          'User not found. Please login again.',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      isRequestingJoin.value = true;
      final coopDoc = await _firestore
          .collection('cooperatives')
          .doc(cooperative.value!.id)
          .get();

      final existingRequests = List<Map<String, dynamic>>.from(
          coopDoc.data()?['joinRequests'] ?? []);

      // Check if user has already requested to join
      if (existingRequests.any((req) => req['userId'] == currentUser.id)) {
        Get.snackbar(
          'Already Requested',
          'You have already sent a request to join this cooperative',
          snackPosition: SnackPosition.TOP,
        );
        isRequestingJoin.value = false;
        return;
      }

      // Check if user is already a member
      if (cooperative.value!.members.contains(currentUser.id)) {
        Get.snackbar(
          'Already a Member',
          'You are already a member of this cooperative',
          snackPosition: SnackPosition.TOP,
        );
        isRequestingJoin.value = false;
        return;
      }

      final batch = _firestore.batch();
      final coopRef =
          _firestore.collection('cooperatives').doc(cooperative.value!.id);
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

      final adminId = cooperative.value!.createdBy;
      final notificationRef = _firestore
          .collection('notifications')
          .doc(adminId)
          .collection('items')
          .doc();

      final notification = NotificationModel.generalMessage(
          id: notificationRef.id,
          userId: adminId,
          title: "New Member Joined",
          message: "${currentUser.name} joined ${cooperative.value!.name}");

      batch.set(notificationRef, notification.toMap());
      await batch.commit();

      cooperative.update((coop) {
        coop!.members.add(currentUser.id);
      });
      role.value = 'member';

      // Add current user to members list
      final updatedMembers = [...members, currentUser];
      members.value = updatedMembers;

      AppLogger.info('Join request sent successfully');

      final dialogConfetti =
          ConfettiController(duration: const Duration(seconds: 3));
      _showSuccessDialog(cooperative.value!.name, dialogConfetti);
    } catch (e) {
      AppLogger.error('Error requesting to join cooperative: $e');
      Get.snackbar(
        'Error',
        'Failed to send join request',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } finally {
      isRequestingJoin.value = false;
    }
  }

  void _showSuccessDialog(
      String cooperativeName, ConfettiController controller) {
    controller.play();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  ConfettiWidget(
                    confettiController: controller,
                    blastDirection: -pi / 2,
                    emissionFrequency: 0.05,
                    numberOfParticles: 20,
                    maxBlastForce: 20,
                    minBlastForce: 5,
                    gravity: 0.1,
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_outline_rounded,
                          color: Colors.green,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Welcome to $cooperativeName!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'You are now a member of this cooperative. You can access all resources and features.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Get.back(),
                        child: Text('OK'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
