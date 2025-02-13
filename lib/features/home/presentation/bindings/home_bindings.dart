import 'package:cropconnect/features/home/presentation/provider/home_provider.dart';
import 'package:get/get.dart';
import 'package:cropconnect/core/services/hive/hive_storage_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Register storage service if not already registered
    if (!Get.isRegistered<UserStorageService>()) {
      Get.put(UserStorageService(), permanent: true);
    }

    // Register home controller
    Get.lazyPut<HomeController>(
      () => HomeController(Get.find<UserStorageService>()),
      fenix: true,
    );
  }
}
