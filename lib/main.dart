import 'package:cropconnect/features/auth/domain/model/user_model.dart';
import 'package:cropconnect/features/auth/presentation/screens/otp_screen.dart';
import 'package:cropconnect/features/home/presentation/bindings/home_bindings.dart';
import 'package:cropconnect/features/home/presentation/screen/home_screen.dart';
import 'package:cropconnect/features/profile/screens/profile_screen.dart';
import 'package:cropconnect/features/splash/presentation/screen/splash.dart';
import 'package:cropconnect/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/bindings/auth_binding.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/profile/bindings/profile_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLogger.initializeLogger();
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  await Hive.openBox<UserModel>('users');

  await Firebase.initializeApp();

  await Get.putAsync<SharedPreferences>(() => SharedPreferences.getInstance(),
      permanent: true);

  final binding = AuthBinding();
  binding.dependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Your App Name',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/splash',
      getPages: [
        GetPage(
          name: '/splash',
          page: () => const SplashScreen(),
        ),
        GetPage(
          name: '/register',
          page: () => const RegisterScreen(),
        ),
        GetPage(
          name: '/otp',
          page: () => const OTPScreen(),
        ),
        GetPage(
          name: '/home',
          page: () => const HomeScreen(),
          binding: HomeBinding(),
        ),
        GetPage(
          name: '/profile',
          page: () => const ProfileScreen(),
          binding: ProfileBinding(),
        ),
      ],
    );
  }
}
