import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cropconnect/core/constants/app_constants.dart';
import 'package:cropconnect/core/services/hive/hive_storage_service.dart';
import 'package:cropconnect/features/auth/domain/model/user/cooperative_membership_model.dart';
import 'package:cropconnect/features/auth/domain/model/user/user_model.dart';
import 'package:cropconnect/features/notification/domain/model/notifications_model.dart';
import 'package:cropconnect/utils/app_logger.dart';
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

      AppLogger.info('notfications: ${snapshot.docs.length}');

      notifications.value = snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.id, doc.data()))
          .toList();

      AppLogger.info("notfications: $notifications");
      AppLogger.info("userId: ${user.id}");
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
        pendingInvites[inviteIndex] = {
          ...pendingInvites[inviteIndex],
          'userId': user.id,
          'status': 'accepted',
          'acceptedAt': Timestamp.now(),
        };
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
      if (verificationRequirements['acceptedInvites'] >=
          (AppConstants.minimumCooperativeMemberCount - 1)) {
        status = 'verified';
      }

      final existingCropTypes = List<String>.from(coopData['cropTypes'] ?? []);
      final newCropTypes = {
        ...existingCropTypes,
        ...(user.crops ?? []),
      }.toList();

      batch.update(coopRef, {
        'pendingInvites': pendingInvites,
        'members': members,
        'verificationRequirements': verificationRequirements,
        'status': status,
        'cropTypes': newCropTypes,
      });

      final userRef = _firestore.collection('users').doc(user.id);

      final updatedPendingInvites = user.pendingInvites
          .where((invite) => invite.cooperativeId != notification.cooperativeId)
          .toList();

      final updatedCooperatives = [...user.cooperatives];
      if (!updatedCooperatives
          .any((coop) => coop.cooperativeId == notification.cooperativeId)) {
        updatedCooperatives.add(CooperativeMembership(
          cooperativeId: notification.cooperativeId!,
          role: 'member',
        ));
      }

      batch.update(userRef, {
        'cooperatives': updatedCooperatives.map((x) => x.toMap()).toList(),
        'pendingInvites': updatedPendingInvites.map((x) => x.toMap()).toList(),
      });

      final updatedUser = UserModel(
        id: user.id,
        name: user.name,
        phoneNumber: user.phoneNumber,
        createdAt: user.createdAt,
        soilType: user.soilType,
        crops: user.crops,
        state: user.state,
        city: user.city,
        latitude: user.latitude,
        longitude: user.longitude,
        cooperatives: updatedCooperatives,
        pendingInvites: updatedPendingInvites,
      );

      await _storageService.saveUser(updatedUser);

      final notificationRef = _firestore
          .collection('notifications')
          .doc(user.id)
          .collection('items')
          .doc(notification.id);

      batch.delete(notificationRef);

      for (String memberId in members) {
        if (memberId == user.id) continue;

        final memberNotificationRef = _firestore
            .collection('notifications')
            .doc(memberId)
            .collection('items')
            .doc();

        final memberNotification = NotificationModel(
          id: memberNotificationRef.id,
          userId: memberId,
          type: NotificationType.generalMessage,
          title: 'New Member Joined',
          message: '${user.name} has joined ${coopData['name']}',
          cooperativeId: notification.cooperativeId,
          createdAt: DateTime.now(),
          isRead: false,
          action: NotificationAction.none,
        );

        batch.set(memberNotificationRef, memberNotification.toMap());
      }

      await batch.commit();

      notifications.remove(notification);

      Get.snackbar(
        'Success',
        'You have joined the cooperative successfully',
        snackPosition: SnackPosition.TOP,
      );

      loadNotifications();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to accept invitation: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
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

      // Add notification for cooperative admin
      final adminId = coopData['createdBy'];
      final adminNotificationRef = _firestore
          .collection('notifications')
          .doc(adminId)
          .collection('items')
          .doc();

      final adminNotification = NotificationModel(
        id: adminNotificationRef.id,
        userId: adminId,
        type: NotificationType.generalMessage,
        title: 'Invitation Declined',
        message: '${user.name} has declined to join ${coopData['name']}',
        cooperativeId: notification.cooperativeId,
        createdAt: DateTime.now(),
        isRead: false,
        action: NotificationAction.none,
      );

      batch.set(adminNotificationRef, adminNotification.toMap());

      // Delete the original invitation notification
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
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to decline invitation: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
