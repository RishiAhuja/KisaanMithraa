import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cropconnect/core/services/hive/hive_storage_service.dart';
import 'package:cropconnect/features/notification/domain/model/notifications_model.dart';
import 'package:get/get.dart';

class NotificationsController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _storageService = Get.find<UserStorageService>();

  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;

      final user = await _storageService.getUser();
      if (user == null) {
        Get.snackbar('Error', 'User not found');
        return;
      }

      final snapshot = await _firestore
          .collection('notifications')
          .doc(user.id)
          .collection('items')
          .orderBy('createdAt', descending: true)
          .get();

      notifications.value = snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load notifications');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> acceptInvite(NotificationModel notification) async {
    try {
      isLoading.value = true;
      final user = await _storageService.getUser();
      if (user == null) {
        Get.snackbar('Error', 'User not found');
        return;
      }

      final batch = _firestore.batch();
      final coopRef =
          _firestore.collection('cooperatives').doc(notification.cooperativeId);

      final coopDoc = await coopRef.get();
      if (!coopDoc.exists) {
        Get.snackbar('Error', 'Cooperative not found');
        return;
      }

      final coopData = coopDoc.data()!;

      final pendingInvites =
          List<Map<String, dynamic>>.from(coopData['pendingInvites']);
      final inviteIndex =
          pendingInvites.indexWhere((invite) => invite['userId'] == user.id);

      if (inviteIndex != -1) {
        pendingInvites[inviteIndex]['status'] = 'accepted';
      }

      final members = List<String>.from(coopData['members']);
      if (!members.contains(user.id)) {
        members.add(user.id);
      }

      final verificationRequirements =
          Map<String, dynamic>.from(coopData['verificationRequirements']);
      verificationRequirements['acceptedInvites'] =
          (verificationRequirements['acceptedInvites'] ?? 0) + 1;

      String status = coopData['status'];
      if (verificationRequirements['acceptedInvites'] >= 2) {
        status = 'verified';
      }

      batch.update(coopRef, {
        'pendingInvites': pendingInvites,
        'members': members,
        'verificationRequirements': verificationRequirements,
        'status': status,
      });

      final notificationRef = _firestore
          .collection('notifications')
          .doc(user.id)
          .collection('items')
          .doc(notification.id);

      batch.delete(notificationRef);
      await batch.commit();

      notifications.remove(notification);

      Get.snackbar(
        'Success',
        'You have joined the cooperative successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      loadNotifications();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to accept invitation: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> declineInvite(NotificationModel notification) async {
    try {
      isLoading.value = true;

      final user = await _storageService.getUser();
      if (user == null) {
        Get.snackbar('Error', 'User not found');
        return;
      }

      final batch = _firestore.batch();

      final coopRef =
          _firestore.collection('cooperatives').doc(notification.cooperativeId);

      final coopDoc = await coopRef.get();
      if (!coopDoc.exists) {
        Get.snackbar('Error', 'Cooperative not found');
        return;
      }

      final coopData = coopDoc.data()!;
      final pendingInvites =
          List<Map<String, dynamic>>.from(coopData['pendingInvites']);

      final inviteIndex =
          pendingInvites.indexWhere((invite) => invite['userId'] == user.id);
      if (inviteIndex != -1) {
        pendingInvites[inviteIndex]['status'] = 'declined';
      }

      batch.update(coopRef, {
        'pendingInvites': pendingInvites,
      });

      final notificationRef = _firestore
          .collection('notifications')
          .doc(user.id)
          .collection('items')
          .doc(notification.id);

      batch.delete(notificationRef);

      await batch.commit();

      notifications.remove(notification);

      Get.snackbar(
        'Success',
        'Invitation declined',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to decline invitation');
    } finally {
      isLoading.value = false;
    }
  }
}
