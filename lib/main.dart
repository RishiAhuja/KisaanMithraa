import 'package:cropconnect/core/theme/app_theme.dart';
import 'package:cropconnect/features/auth/domain/model/user/user_model.dart';
import 'package:cropconnect/features/auth/presentation/screens/otp_screen.dart';
import 'package:cropconnect/features/community/bindings/community_binding.dart';
import 'package:cropconnect/features/cooperative/bindings/create_cooperative_binding.dart';
import 'package:cropconnect/features/cooperative/presentation/screens/create_cooperative_screen.dart';
import 'package:cropconnect/features/cooperative/presentation/screens/my_cooperatives_screen.dart';
import 'package:cropconnect/features/home/presentation/bindings/home_bindings.dart';
import 'package:cropconnect/features/home/presentation/screen/home_screen.dart';
import 'package:cropconnect/features/notification/presentation/controller/notification_controller.dart';
import 'package:cropconnect/features/notification/presentation/notifications_screen.dart';
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
import 'features/community/presentation/screens/community_screen.dart';

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
      theme: AppTheme.lightTheme,
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
        GetPage(
          name: '/create-cooperative',
          page: () => const CreateCooperativeScreen(),
          binding: CreateCooperativeBinding(),
        ),
        GetPage(
          name: '/community',
          page: () => const CommunityScreen(),
          binding: CommunityBinding(),
        ),
        GetPage(
          name: '/my-cooperatives',
          page: () => const MyCooperativesScreen(),
          // binding: MyCooperativesBinding(),
        ),
        GetPage(
          name: '/notifications',
          page: () => const NotificationsScreen(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => NotificationsController());
          }),
        ),
      ],
    );
  }
}
