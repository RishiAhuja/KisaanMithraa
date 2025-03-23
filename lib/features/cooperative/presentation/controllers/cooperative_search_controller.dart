// 1. First, add this class at the top of your file (before MyCooperativesScreen)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cropconnect/features/cooperative/domain/models/cooperative_model.dart';
import 'package:cropconnect/features/cooperative/presentation/controllers/my_cooperatives_controller.dart';
import 'package:cropconnect/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class CooperativeSearchController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxBool isSearching = false.obs;
  final RxBool hasSearched = false.obs;
  final RxList<CooperativeModel> searchResults = <CooperativeModel>[].obs;

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void clearSearch() {
    searchController.clear();
    searchResults.clear();
    hasSearched.value = false;
  }

  Future<void> searchCooperatives(
      String query, MyCooperativesController mainController) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      hasSearched.value = false;
      return;
    }

    isSearching.value = true;
    hasSearched.value = true;

    try {
      final _firestore = FirebaseFirestore.instance;

      // Search by name
      final nameStartsWithQuery = await _firestore
          .collection('cooperatives')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .limit(20)
          .get();

      // Search by location
      final locationStartsWithQuery = await _firestore
          .collection('cooperatives')
          .where('location', isGreaterThanOrEqualTo: query)
          .where('location', isLessThan: '${query}z')
          .limit(20)
          .get();

      final results = <CooperativeModel>[];

      // Add name-based results
      for (var doc in nameStartsWithQuery.docs) {
        results.add(CooperativeModel.fromMap(doc.data()));
      }

      // Add location-based results
      for (var doc in locationStartsWithQuery.docs) {
        results.add(CooperativeModel.fromMap(doc.data()));
      }

      // Remove duplicates and already joined cooperatives
      final uniqueResults = <CooperativeModel>[];
      final addedIds = <String>{};

      // Get the IDs of cooperatives the user is already a member of
      final memberCoopIds = mainController.cooperatives
          .map((coopWithRole) => coopWithRole.cooperative.id)
          .toSet();

      for (var coop in results) {
        if (!addedIds.contains(coop.id) && !memberCoopIds.contains(coop.id)) {
          uniqueResults.add(coop);
          addedIds.add(coop.id);
        }
      }

      searchResults.value = uniqueResults;
      isSearching.value = false;
    } catch (e) {
      AppLogger.error('Error searching cooperatives: $e');
      isSearching.value = false;
    }
  }
}
