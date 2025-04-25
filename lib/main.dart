import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cropconnect/core/debug/presentation/debug_screen.dart';
import 'package:cropconnect/core/services/crop/crop_service.dart';
import 'package:cropconnect/core/services/debug/debug_service.dart';
import 'package:cropconnect/core/services/hive/hive_storage_service.dart'
    show UserStorageService;
import 'package:cropconnect/core/services/locale/locale_service.dart';
import 'package:cropconnect/core/theme/app_theme.dart';
import 'package:cropconnect/features/auth/domain/model/user/pending_invite_model.dart';
import 'package:cropconnect/features/auth/domain/model/user/user_model.dart';
import 'package:cropconnect/features/auth/presentation/screens/auth_choice_screen.dart';
import 'package:cropconnect/features/auth/presentation/screens/otp_screen.dart';
import 'package:cropconnect/features/auth/presentation/screens/register_screen.dart';
import 'package:cropconnect/features/chatbot/presentation/bindings/chatbot_binding.dart';
import 'package:cropconnect/features/chatbot/presentation/screens/chatbot_screen.dart';
import 'package:cropconnect/features/community/bindings/community_binding.dart';
import 'package:cropconnect/features/cooperative/bindings/create_cooperative_binding.dart';
import 'package:cropconnect/features/cooperative/presentation/controllers/cooperative_management_controller.dart';
import 'package:cropconnect/features/cooperative/presentation/controllers/my_cooperatives_controller.dart';
import 'package:cropconnect/features/cooperative/presentation/screens/cooperative_details_screen.dart';
import 'package:cropconnect/features/cooperative/presentation/screens/cooperative_management_screen.dart';
import 'package:cropconnect/features/cooperative/presentation/screens/create_cooperative_screen.dart';
import 'package:cropconnect/features/cooperative/presentation/screens/my_cooperatives_screen.dart';
import 'package:cropconnect/features/cooperative/presentation/screens/search_cooperatives_screen.dart';
import 'package:cropconnect/features/home/presentation/bindings/home_bindings.dart';
import 'package:cropconnect/features/home/presentation/screen/home_screen.dart';
import 'package:cropconnect/features/intro/presentation/screens/intro_screen.dart';
import 'package:cropconnect/features/mandi_prices/presentation/screens/mandi_price_screen.dart';
import 'package:cropconnect/features/notification/presentation/controller/notification_controller.dart';
import 'package:cropconnect/features/notification/presentation/screen/notifications_screen.dart';
import 'package:cropconnect/features/onboarding/domain/services/location_service.dart';
import 'package:cropconnect/features/onboarding/presentation/controller/nearby_cooperatives_controller.dart';
import 'package:cropconnect/features/onboarding/presentation/screens/nearby_cooperatives_screen.dart';
import 'package:cropconnect/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:cropconnect/features/podcasts/data/services/podcast_service.dart';
import 'package:cropconnect/features/podcasts/presentation/screens/podcast_player_screen.dart';
import 'package:cropconnect/features/podcasts/presentation/screens/podcasts_screen.dart';
import 'package:cropconnect/features/profile/controller/profile_controller.dart';
import 'package:cropconnect/features/profile/screens/profile_screen.dart';
import 'package:cropconnect/features/resource_pooling/presentation/controller/resource_pooling_controller.dart';
import 'package:cropconnect/features/resource_pooling/presentation/screens/create_listing_screen.dart';
import 'package:cropconnect/features/resource_pooling/presentation/screens/listing_details_screen.dart';
import 'package:cropconnect/features/resource_pooling/presentation/screens/my_listing_details_screen.dart';
import 'package:cropconnect/features/resource_pooling/presentation/screens/resource_listings_screen.dart';
import 'package:cropconnect/features/splash/presentation/screen/splash.dart';
import 'package:cropconnect/firebase_options.dart';
import 'package:cropconnect/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/agrihelp/presentation/screens/agri_help_screen.dart';
import 'features/auth/bindings/auth_binding.dart';
import 'features/auth/domain/model/user/cooperative_membership_model.dart';
import 'features/cooperative/presentation/controllers/cooperative_details_controller.dart';
import 'features/podcasts/presentation/controllers/podcast_controller.dart';
import 'features/profile/bindings/profile_binding.dart';
import 'features/community/presentation/screens/community_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // await JustAudioBackground.init(
  //   androidNotificationChannelId: 'com.cropconnect.podcast',
  //   androidNotificationChannelName: 'CropConnect Podcasts',
  //   androidNotificationOngoing: true,
  // );

  await AppLogger.initializeLogger();
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(CooperativeMembershipAdapter());
  Hive.registerAdapter(PendingInviteAdapter());
  await Hive.openBox<UserModel>('users');
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.put<SharedPreferences>(sharedPreferences, permanent: true);
  await Get.putAsync<PodcastService>(() => PodcastService().init());
  final localeService = Get.put(LocaleService(), permanent: true);
  await Get.putAsync(() => LocationSelectionService().init());
  Get.put(CropService(), permanent: true);
  localeService.loadSavedLocale();
  final userStorageService = UserStorageService();
  Get.put(userStorageService, permanent: true);
  final profileController =
      ProfileController(userStorageService, FirebaseFirestore.instance);
  Get.put(profileController, permanent: true);

  final binding = AuthBinding();
  binding.dependencies();
  Get.put(LocaleService());
  Get.put(DebugService(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeService = Get.find<LocaleService>();

    return GetX<LocaleService>(
      builder: (_) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Kisaan Mitra',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        locale: localeService.locale,
        supportedLocales: localeService.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialRoute: '/splash',
        getPages: [
          GetPage(
            name: '/splash',
            page: () => const SplashScreen(),
          ),
          GetPage(name: '/auth-choice', page: () => AuthChoiceScreen()),
          GetPage(
            name: '/onboarding',
            page: () => OnboardingScreen(),
          ),
          GetPage(
            name: '/register',
            page: () => Scaffold(body: const RegisterScreen()),
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
          GetPage(name: '/intro', page: () => IntroScreen()),
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
            name: '/agri-help',
            page: () => const AgriHelpScreen(),
            // binding: AgriHelpBinding(),
          ),
          GetPage(
            name: '/agri-mart',
            page: () => const MandiPriceScreen(),
          ),
          GetPage(
            name: '/my-cooperatives',
            page: () => const MyCooperativesScreen(),
            binding: BindingsBuilder(() {
              Get.lazyPut(() => MyCooperativesController());
            }),
          ),
          GetPage(
            name: '/debug',
            page: () => const DebugScreen(),
            binding: BindingsBuilder(() {
              Get.lazyPut(
                () => DebugService(),
              );
            }),
          ),
          GetPage(
            name: '/notifications',
            page: () => const NotificationsScreen(),
            binding: BindingsBuilder(() {
              Get.lazyPut(() => NotificationsController());
            }),
          ),
          GetPage(
            name: '/cooperative-management',
            page: () => const CooperativeManagementScreen(),
            binding: BindingsBuilder(() {
              Get.lazyPut(() => CooperativeManagementController());
            }),
          ),
          GetPage(
            name: '/cooperative-details',
            page: () => const CooperativeDetailsScreen(),
            binding: BindingsBuilder(() {
              Get.lazyPut(() => CooperativeDetailsController());
            }),
          ),
          GetPage(
            name: '/podcasts',
            page: () => const PodcastsScreen(),
            binding: BindingsBuilder(() {
              Get.put(PodcastController());
            }),
          ),
          GetPage(
            name: '/podcasts/player',
            page: () => const PodcastPlayerScreen(),
            transition: Transition.rightToLeft,
          ),
          GetPage(
            name: '/search-cooperatives',
            page: () => const SearchCooperativesScreen(),
            binding: BindingsBuilder(() {
              Get.lazyPut(() => Get.find<MyCooperativesController>());
            }),
          ),
          GetPage(
            name: '/resource-pool',
            page: () => const ResourceListingsScreen(),
            binding: BindingsBuilder(() {
              Get.lazyPut(
                () => ResourcePoolingController(),
              );
            }),
          ),
          GetPage(
            name: '/create-listing',
            page: () => const CreateListingScreen(),
            // binding: ResourcePoolingBinding(),
          ),
          GetPage(
            name: '/listing-details',
            page: () => const ListingDetailsScreen(),
            // binding: ResourcePoolingBinding(),
          ),
          GetPage(
            name: '/my-listing-details',
            page: () => const MyListingDetailsScreen(),
            // binding: ResourcePoolingBinding(),
          ),
          GetPage(
            name: '/chatbot',
            page: () => ChatbotScreen(),
            binding: ChatbotBinding(),
          ),
          GetPage(
            name: '/nearby-cooperatives',
            page: () => NearbyCooperativesPage(
              onBack: () {},
              onNext: () {
                Get.toNamed('/home');
              },
            ),
            binding: BindingsBuilder(() {
              Get.lazyPut(() => NearbyCooperativesController());
            }),
          ),
        ],
      ),
    );
  }
}
