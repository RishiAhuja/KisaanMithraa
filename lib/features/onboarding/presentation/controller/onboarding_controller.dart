import 'package:cropconnect/features/onboarding/domain/models/crop_model.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  final RxString selectedLanguage = ''.obs;
  final RxString name = ''.obs;
  final RxString selectedState = ''.obs;
  final RxString selectedCity = ''.obs;
  final RxDouble progress = 0.2.obs;

  final RxList<String> selectedCrops = <String>[].obs;

  final List<CropModel> availableCrops = [
    CropModel(
      id: 'crop',
      name: 'Crop',
      imageUrl: 'assets/crops/corn.svg',
      description: 'Major cereal grain',
    ),
    CropModel(
      id: 'fruits',
      name: 'Fruits',
      imageUrl: 'assets/crops/fruits.svg',
      description: 'Staple food crop',
    ),
    CropModel(
      id: 'rice',
      name: 'Rice',
      imageUrl: 'assets/crops/rice.svg',
      description: 'Versatile grain crop',
    ),
    CropModel(
      id: 'tomato',
      name: 'Tomato',
      imageUrl: 'assets/crops/tomato.svg',
      description: 'Versatile grain crop',
    ),
  ];

  final Map<String, List<String>> stateCities = {
    'Uttar Pradesh': ['Siddharthnagar', 'Balrampur', 'Lucknow', 'Kanpur'],
    'Bihar': ['Patna', 'Gaya', 'Bhagalpur'],
    'Punjab': ['Amritsar', 'Ludhiana', 'Jalandhar'],
  }.obs;

  void setLanguage(String language) {
    selectedLanguage.value = language;
    progress.value = 0.4;
  }

  void setName(String userName) {
    name.value = userName;
    progress.value = 0.6;
  }

  void setState(String state) {
    selectedState.value = state;
    selectedCity.value = '';
    progress.value = 0.8;
  }

  void setCity(String city) {
    selectedCity.value = city;
    progress.value = 1.0;
  }

  void resetLanguage() {
    progress.value = 0.2;
  }

  List<String> getCitiesForState(String state) {
    return stateCities[state] ?? [];
  }

  void toggleCropSelection(String cropId) {
    if (selectedCrops.contains(cropId)) {
      selectedCrops.remove(cropId);
    } else {
      selectedCrops.add(cropId);
    }
    progress.value = 0.9; // Update progress
  }
}
