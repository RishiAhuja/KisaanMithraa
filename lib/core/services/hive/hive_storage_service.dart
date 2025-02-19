import 'package:cropconnect/features/auth/domain/model/user/user_model.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserStorageService {
  static const String boxName = 'users';
  static const String userKey = 'current_user';
  static const String hasLoggedInKey = 'hasLoggedIn';

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

  Future<void> setHasLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(hasLoggedInKey, value);
  }

  Future<bool> getHasLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(hasLoggedInKey) ?? false;
  }
}
