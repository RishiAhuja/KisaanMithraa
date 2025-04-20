import 'dart:convert';
import 'package:cropconnect/utils/app_logger.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/location_model.dart';

class LocationSelectionService extends GetxService {
  final _stateDistrictMap = <String, List<String>>{}.obs;
  final _isLoaded = false.obs;

  bool get isLoaded => _isLoaded.value;
  Map<String, List<String>> get stateDistrictMap => _stateDistrictMap;

  Future<LocationSelectionService> init() async {
    await loadStateDistrictData();
    return this;
  }

  Future<void> loadStateDistrictData() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/states_districts.json');
      final jsonData = json.decode(jsonString);
      final statesList = (jsonData['states'] as List)
          .map((item) => StateDistrictModel.fromJson(item))
          .toList();

      _stateDistrictMap.clear();
      for (final stateData in statesList) {
        _stateDistrictMap[stateData.state] = stateData.districts;
      }

      _isLoaded.value = true;
    } catch (e) {
      AppLogger.error('Error loading state-district data: $e');
      _stateDistrictMap.value = {
        'Uttar Pradesh': ['Siddharthnagar', 'Balrampur', 'Lucknow', 'Kanpur'],
        'Bihar': ['Patna', 'Gaya', 'Bhagalpur'],
        'Punjab': ['Amritsar', 'Ludhiana', 'Jalandhar'],
      };
      _isLoaded.value = true;
    }
  }

  List<String> getAllStates() {
    final states = _stateDistrictMap.keys.toList();
    states.sort();
    return states;
  }

  List<String> getDistrictsForState(String state) {
    final districts = _stateDistrictMap[state] ?? [];
    districts.sort();
    return districts;
  }
}
