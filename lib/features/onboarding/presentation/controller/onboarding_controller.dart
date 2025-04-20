import 'package:cropconnect/features/onboarding/domain/models/crop_model.dart';
import 'package:cropconnect/features/onboarding/domain/services/location_service.dart';
import 'package:get/get.dart';
import 'package:cropconnect/core/services/crop/crop_service.dart';

class OnboardingController extends GetxController {
  final RxString selectedLanguage = ''.obs;
  final RxString name = ''.obs;
  final RxString selectedState = ''.obs;
  final RxString selectedCity = ''.obs;
  final RxDouble progress = 0.2.obs;

  final RxList<String> selectedCrops = <String>[].obs;
  final LocationSelectionService _locationService =
      Get.find<LocationSelectionService>();

  final RxBool showRecommended = true.obs;

  final CropService _cropService = Get.find<CropService>();

  Map<String, List<String>> get stateCities =>
      _locationService.stateDistrictMap;

  @override
  void onInit() {
    super.onInit();
    if (!_locationService.isLoaded) {
      _locationService.loadStateDistrictData();
    }
  }

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
    return _locationService.getDistrictsForState(state);
  }

  List<String> getAllStates() {
    return _locationService.getAllStates();
  }

  void toggleCropSelection(String cropId) {
    if (selectedCrops.contains(cropId)) {
      selectedCrops.remove(cropId);
    } else {
      selectedCrops.add(cropId);
    }
    progress.value = 0.9;
  }

  List<CropModel> get availableCrops => _cropService.getAllCrops();

  List<CropModel> getRecommendedCrops() {
    if (selectedState.isEmpty) return [];
    return _cropService.getRecommendedCropsForState(selectedState.value);
  }

  void toggleCropView() {
    showRecommended.value = !showRecommended.value;
  }
}
