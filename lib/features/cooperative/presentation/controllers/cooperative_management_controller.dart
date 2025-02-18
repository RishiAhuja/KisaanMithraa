import 'package:cropconnect/core/services/hive/hive_storage_service.dart';
import 'package:cropconnect/features/cooperative/domain/models/cooperative_invite_model.dart';
import 'package:cropconnect/features/notification/domain/model/notifications_model.dart';
import 'package:cropconnect/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/cooperative_model.dart';
import '../../../auth/domain/model/user/user_model.dart';

class CooperativeManagementController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _storageService = Get.find<UserStorageService>();
  final cooperative = Rxn<CooperativeModel>();
  final members = <UserModel>[].obs;
  final isLoading = true.obs;
  final error = Rxn<String>();
  final selectedMembers = <UserModel>[].obs;
  final searchResults = <UserModel>[].obs;
  final _userCache = <String, UserModel>{}.obs;

  @override
  void onInit() {
    super.onInit();
    cooperative.value = Get.arguments.cooperative;
    loadMembers();
  }

  @override
  void onClose() {
    _userCache.clear();
    super.onClose();
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
    } catch (e) {
      error.value = 'Failed to load members';
      AppLogger.error('Error loading members: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> inviteMembers() async {
    try {
      if (cooperative.value == null) {
        Get.snackbar('Error', 'Cooperative data not found');
        return;
      }

      if (selectedMembers.isEmpty) {
        Get.snackbar('Error', 'Please select members to invite');
        return;
      }

      final currentUser = await _storageService.getUser();
      if (currentUser == null) {
        Get.snackbar('Error', 'currentUser not found');
        return;
      }

      isLoading.value = true;

      final batch = _firestore.batch();
      final coopRef =
          _firestore.collection('cooperatives').doc(cooperative.value!.id);

      final newInvites = selectedMembers
          .map((member) => CooperativeInvite(
                userId: member.id,
                invitedAt: DateTime.now(),
                status: 'pending',
              ))
          .toList();

      batch.update(coopRef, {
        'pendingInvites': FieldValue.arrayUnion(
          newInvites.map((invite) => invite.toMap()).toList(),
        ),
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
          cooperativeName: cooperative.value!.name,
          cooperativeId: cooperative.value!.id,
          invitedBy: currentUser.name,
        );

        batch.set(notificationRef, notification.toMap());
      }

      await batch.commit();

      selectedMembers.clear();

      AppLogger.info(
          'Invitations sent successfully to ${newInvites.length} members');

      Get.snackbar(
        'Success',
        'Invitations sent successfully',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      AppLogger.error('Error inviting members: $e');
      Get.snackbar(
        'Error',
        'Failed to send invitations: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
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

      final queryLower = query.toLowerCase();
      final phoneQuery = query.replaceAll(RegExp(r'[^\d]'), '');

      final excludeIds = [
        ...cooperative.value?.members ?? [],
        ...selectedMembers.map((m) => m.id),
      ];

      final snapshot = await _firestore.collection('users').get();

      searchResults.value = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .where((user) =>
              !excludeIds.contains(user.id) &&
              (user.name.toLowerCase().contains(queryLower) ||
                  user.phoneNumber.contains(phoneQuery)))
          .toList();
      AppLogger.info('Search results: ${searchResults.length}');
    } catch (e) {
      AppLogger.error('Error searching members: $e');
      searchResults.clear();
    }
  }

  void addSelectedMember(UserModel user) {
    if (!selectedMembers.contains(user)) {
      selectedMembers.add(user);
      selectedMembers.refresh();
    }
  }

  Future<UserModel> getUserDetails(String userId) async {
    try {
      if (_userCache.containsKey(userId)) {
        return _userCache[userId]!;
      }

      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        throw Exception('User not found');
      }

      final user = UserModel.fromMap(doc.data()!, doc.id);
      _userCache[userId] = user;
      return user;
    } catch (e) {
      AppLogger.error('Error fetching user details: $e');
      rethrow;
    }
  }

  Future<void> kickMember(String userId) async {
    try {
      if (cooperative.value == null) {
        throw Exception('Cooperative not found');
      }

      final batch = _firestore.batch();

      final coopRef =
          _firestore.collection('cooperatives').doc(cooperative.value!.id);

      batch.update(coopRef, {
        'members': FieldValue.arrayRemove([userId]),
      });

      final notificationRef = _firestore
          .collection('notifications')
          .doc(userId)
          .collection('items')
          .doc();

      final notification = NotificationModel.generalMessage(
        id: notificationRef.id,
        userId: userId,
        title: 'Removed from Cooperative',
        message: 'You have been removed from ${cooperative.value!.name}',
      );

      batch.set(notificationRef, notification.toMap());

      final userRef = _firestore.collection('users').doc(userId);
      batch.update(userRef, {
        'cooperatives': FieldValue.arrayRemove([
          {'cooperativeId': cooperative.value!.id}
        ]),
      });

      await batch.commit();

      members.removeWhere((member) => member.id == userId);
      cooperative.value!.members.remove(userId);

      Get.snackbar(
        'Success',
        'Member has been removed',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      AppLogger.error('Error kicking member: $e');
      rethrow;
    }
  }
}
