import 'package:cropconnect/features/auth/domain/model/user_model.dart';
import 'package:hive/hive.dart';

class UserStorageService {
  static const String boxName = 'users';
  static const String userKey = 'current_user';

  Future<void> saveUser(UserModel user) async {
    final box = await Hive.openBox<UserModel>(boxName);
    await box.put(userKey, user);
  }

  Future<UserModel?> getUser() async {
    final box = await Hive.openBox<UserModel>(boxName);
    return box.get(userKey);
  }

  Future<void> deleteUser() async {
    final box = await Hive.openBox<UserModel>(boxName);
    await box.delete(userKey);
  }
}
