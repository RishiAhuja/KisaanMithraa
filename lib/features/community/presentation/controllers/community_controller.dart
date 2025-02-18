import 'package:cropconnect/features/auth/domain/model/user_model.dart';
import 'package:cropconnect/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../cooperative/domain/models/cooperative_model.dart';

enum SearchType { farmers, cooperatives }

class CommunityController extends GetxController {
  final FirebaseFirestore _firestore;

  final currentSearchType = SearchType.farmers.obs;
  final isLoading = false.obs;
  final farmers = <UserModel>[].obs;
  final cooperatives = <CooperativeModel>[].obs;
  final searchQuery = ''.obs;

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
            .collection('coup')
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
}
