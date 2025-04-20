import 'package:cropconnect/features/home/presentation/controller/home_controller.dart';
import 'package:cropconnect/features/home/services/farming_tip_service.dart';
import 'package:cropconnect/features/home/services/weather_api_service.dart';
import 'package:get/get.dart';
import 'package:cropconnect/core/services/hive/hive_storage_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Register storage service if not already registered
    if (!Get.isRegistered<UserStorageService>()) {
      Get.put(UserStorageService(), permanent: true);
    }

    Get.put(WeatherApiService(), permanent: true);
    Get.put(FarmingTipService(), permanent: true);

    // Register home controller
    Get.lazyPut<HomeController>(
      () => HomeController(),
      fenix: true,
    );
  }
}
