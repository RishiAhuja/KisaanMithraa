import 'package:cropconnect/core/services/hive/hive_storage_service.dart';
import 'package:cropconnect/features/auth/domain/model/user/user_model.dart';
import 'package:cropconnect/features/notification/domain/model/notifications_model.dart';
import 'package:cropconnect/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../cooperative/domain/models/cooperative_model.dart';

enum SearchType { farmers, cooperatives }

class CommunityController extends GetxController {
  final FirebaseFirestore _firestore;
  final _storageService = Get.find<UserStorageService>();

  final currentSearchType = SearchType.farmers.obs;
  final isLoading = false.obs;
  final farmers = <UserModel>[].obs;
  final cooperatives = <CooperativeModel>[].obs;
  final searchQuery = ''.obs;
  final isJoiningCoop = false.obs;

  CommunityController(this._firestore);

  void switchSearchType(SearchType type) {
    currentSearchType.value = type;
    performSearch(); // Re-run search when switching types
  }

  @override
  void onInit() {
    super.onInit();
    ever(currentSearchType, (_) => performSearch());
    debounce(
      searchQuery,
      (_) => performSearch(),
      time: const Duration(milliseconds: 500),
    );
    performSearch();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  Future<void> performSearch() async {
    try {
      isLoading.value = true;

      if (currentSearchType.value == SearchType.farmers) {
        final snapshot = await _firestore
            .collection('users')
            .where('name', isGreaterThanOrEqualTo: searchQuery.value)
            .where('name', isLessThanOrEqualTo: '${searchQuery.value}\uf8ff')
            .get();

        farmers.value = snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList();
      } else {
        final snapshot = await _firestore
            .collection('cooperatives')
            .where('name', isGreaterThanOrEqualTo: searchQuery.value)
            .where('name', isLessThanOrEqualTo: '${searchQuery.value}\uf8ff')
            .get();

        cooperatives.value = snapshot.docs
            .map((doc) => CooperativeModel.fromMap(doc.data()))
            .toList();
      }
    } catch (e) {
      AppLogger.debug('Error searching: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> requestToJoin(CooperativeModel cooperative) async {
    try {
      final currentUser = await _storageService.getUser();
      if (currentUser == null) {
        Get.snackbar('Error', 'User not found');
        return;
      }

      isJoiningCoop.value = true;
      final coopDoc =
          await _firestore.collection('cooperatives').doc(cooperative.id).get();

      final existingRequests = List<Map<String, dynamic>>.from(
          coopDoc.data()?['joinRequests'] ?? []);

      if (existingRequests.any((req) => req['userId'] == currentUser.id)) {
        Get.snackbar(
          'Already Requested',
          'You have already sent a request to join this cooperative',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }
      final batch = _firestore.batch();
      final coopRef = _firestore.collection('cooperatives').doc(cooperative.id);
      final joinRequest = {
        'userId': currentUser.id,
        'requestedAt': DateTime.now(),
        'status': 'pending',
        'userName': currentUser.name,
      };

      batch.update(coopRef, {
        'joinRequests': FieldValue.arrayUnion([joinRequest]),
      });

      final adminId = cooperative.createdBy;
      final notificationRef = _firestore
          .collection('notifications')
          .doc(adminId)
          .collection('items')
          .doc();

      final notification = NotificationModel.cooperativeJoinRequest(
        id: notificationRef.id,
        userId: adminId,
        requesterId: currentUser.id,
        requesterName: currentUser.name,
        cooperativeName: cooperative.name,
        cooperativeId: cooperative.id,
      );

      batch.set(notificationRef, notification.toMap());

      await batch.commit();

      AppLogger.info('Join request sent successfully');
      Get.snackbar(
        'Success',
        'Your request to join ${cooperative.name} has been sent',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      AppLogger.error('Error requesting to join cooperative: $e');
      Get.snackbar(
        'Error',
        'Failed to send join request: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isJoiningCoop.value = false;
    }
  }
}
