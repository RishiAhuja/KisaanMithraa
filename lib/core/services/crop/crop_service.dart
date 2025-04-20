import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cropconnect/features/onboarding/domain/models/crop_model.dart';

class CropService extends GetxService {
  final List<CropModel> crops = [
    CropModel(
      id: 'wheat',
      name: 'Wheat',
      icon: Icons.agriculture,
      states: [
        'Punjab',
        'Haryana',
        'Uttar Pradesh',
        'Madhya Pradesh',
        'Rajasthan',
        'Bihar'
      ],
    ),
    CropModel(
      id: 'rice',
      name: 'Rice',
      icon: Icons.grass,
      states: [
        'West Bengal',
        'Uttar Pradesh',
        'Punjab',
        'Bihar',
        'Odisha',
        'Assam',
        'Chhattisgarh'
      ],
    ),
    CropModel(
      id: 'sugarcane',
      name: 'Sugarcane',
      icon: Icons.agriculture,
      states: [
        'Uttar Pradesh',
        'Maharashtra',
        'Karnataka',
        'Tamil Nadu',
        'Andhra Pradesh'
      ],
    ),
    CropModel(
      id: 'cotton',
      name: 'Cotton',
      icon: Icons.local_florist,
      states: [
        'Maharashtra',
        'Gujarat',
        'Andhra Pradesh',
        'Telangana',
        'Punjab',
        'Haryana'
      ],
    ),
    CropModel(
      id: 'mustard',
      name: 'Mustard',
      icon: Icons.eco,
      states: [
        'Rajasthan',
        'Haryana',
        'Uttar Pradesh',
        'Punjab',
        'Madhya Pradesh'
      ],
    ),
    CropModel(
      id: 'potato',
      name: 'Potato',
      icon: Icons.eco,
      states: ['Uttar Pradesh', 'West Bengal', 'Bihar', 'Punjab', 'Gujarat'],
    ),
    CropModel(
      id: 'tomato',
      name: 'Tomato',
      icon: Icons.eco,
      states: [
        'Andhra Pradesh',
        'Karnataka',
        'Maharashtra',
        'Odisha',
        'West Bengal'
      ],
    ),
    CropModel(
      id: 'banana',
      name: 'Banana',
      icon: Icons.spa,
      states: [
        'Tamil Nadu',
        'Maharashtra',
        'Gujarat',
        'Andhra Pradesh',
        'Kerala'
      ],
    ),
    CropModel(
      id: 'onion',
      name: 'Onion',
      icon: Icons.eco,
      states: [
        'Maharashtra',
        'Karnataka',
        'Madhya Pradesh',
        'Gujarat',
        'Rajasthan'
      ],
    ),
    CropModel(
      id: 'maize',
      name: 'Maize',
      icon: Icons.grass,
      states: [
        'Karnataka',
        'Andhra Pradesh',
        'Madhya Pradesh',
        'Maharashtra',
        'Bihar'
      ],
    ),
    CropModel(
      id: 'groundnut',
      name: 'Groundnut',
      icon: Icons.eco,
      states: [
        'Gujarat',
        'Andhra Pradesh',
        'Tamil Nadu',
        'Karnataka',
        'Rajasthan'
      ],
    ),
    CropModel(
      id: 'chili',
      name: 'Chili',
      icon: Icons.local_offer,
      states: [
        'Andhra Pradesh',
        'Karnataka',
        'Tamil Nadu',
        'Madhya Pradesh',
        'Uttar Pradesh'
      ],
    ),
    CropModel(
      id: 'apple',
      name: 'Apple',
      icon: Icons.local_florist,
      states: [
        'Himachal Pradesh',
        'Jammu and Kashmir',
        'Uttarakhand',
        'Punjab'
      ],
    ),
    CropModel(
      id: 'grapes',
      name: 'Grapes',
      icon: Icons.eco,
      states: ['Maharashtra', 'Karnataka', 'Andhra Pradesh', 'Tamil Nadu'],
    ),
    CropModel(
      id: 'peas',
      name: 'Peas',
      icon: Icons.grass,
      states: [
        'Uttar Pradesh',
        'Madhya Pradesh',
        'Haryana',
        'Punjab',
        'Rajasthan'
      ],
    ),
    CropModel(
      id: 'papaya',
      name: 'Papaya',
      icon: Icons.spa,
      states: [
        'Uttar Pradesh',
        'Bihar',
        'West Bengal',
        'Madhya Pradesh',
        'Kerala'
      ],
    ),
    CropModel(
      id: 'cucumber',
      name: 'Cucumber',
      icon: Icons.eco,
      states: [
        'Uttar Pradesh',
        'Maharashtra',
        'Karnataka',
        'Bihar',
        'West Bengal'
      ],
    ),
    CropModel(
      id: 'carrot',
      name: 'Carrot',
      icon: Icons.eco,
      states: [
        'Himachal Pradesh',
        'Uttarakhand',
        'Rajasthan',
        'Madhya Pradesh'
      ],
    ),
    CropModel(
      id: 'pineapple',
      name: 'Pineapple',
      icon: Icons.spa,
      states: ['Kerala', 'West Bengal', 'Assam', 'Karnataka', 'Goa'],
    ),
    CropModel(
      id: 'spinach',
      name: 'Spinach',
      icon: Icons.eco,
      states: [
        'Haryana',
        'Punjab',
        'Uttar Pradesh',
        'Madhya Pradesh',
        'Gujarat'
      ],
    ),
    CropModel(
      id: 'mango',
      name: 'Mango',
      icon: Icons.local_florist,
      states: [
        'Uttar Pradesh',
        'Andhra Pradesh',
        'Maharashtra',
        'Karnataka',
        'Tamil Nadu'
      ],
    ),
    CropModel(
      id: 'cabbage',
      name: 'Cabbage',
      icon: Icons.eco,
      states: [
        'Himachal Pradesh',
        'Punjab',
        'Uttar Pradesh',
        'West Bengal',
        'Madhya Pradesh'
      ],
    ),
  ];

  List<String> getAllCropNames() {
    return crops.map((crop) => crop.name).toList();
  }

  List<CropModel> getRecommendedCropsForState(String state) {
    if (state.isEmpty) return [];
    return crops.where((crop) => crop.isGrownIn(state)).toList();
  }

  List<CropModel> getAllCrops() {
    return crops;
  }

  CropModel? getCropById(String id) {
    try {
      return crops.firstWhere((crop) => crop.id == id);
    } catch (e) {
      return null;
    }
  }

  CropModel? getCropByName(String name) {
    try {
      return crops.firstWhere((crop) => crop.name == name);
    } catch (e) {
      return null;
    }
  }
}
