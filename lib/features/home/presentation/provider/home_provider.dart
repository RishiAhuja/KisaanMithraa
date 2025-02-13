import 'package:get/get.dart';
import 'package:cropconnect/features/auth/domain/model/user_model.dart';
import 'package:cropconnect/core/services/hive/hive_storage_service.dart';

class HomeController extends GetxController {
  final UserStorageService _storageService;
  final Rx<UserModel?> user = Rx<UserModel?>(null);

  HomeController(this._storageService);

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final userData = await _storageService.getUser();
      if (userData != null) {
        user.value = userData;
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }
}
