import 'package:cropconnect/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/cooperative_model.dart';
import '../../../auth/domain/model/user/user_model.dart';

class CooperativeDetailsController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final cooperative = Rxn<CooperativeModel>();
  final members = <UserModel>[].obs;
  final isLoading = true.obs;
  final error = Rxn<String>();
  final role = 'viewer'.obs;

  // New properties for requested features
  final isRequestingJoin = false.obs;
  final resourceListingsCount = 0.obs;
  final isLoadingListings = false.obs;

  @override
  void onInit() {
    super.onInit();
    AppLogger.debug('CooperativeDetailsController.onInit()');

    final args = Get.arguments;

    if (args != null) {
      // Check if args contains a cooperative field (using your original approach)
      if (args.cooperative != null) {
        cooperative.value = args.cooperative;

        // If role is available, set it
        if (args.role != null) {
          role.value = args.role;
        }

        _loadData();
      } else {
        AppLogger.error('Invalid arguments: Cooperative not found');
        Get.snackbar('Error', 'Invalid navigation arguments');
        Get.back();
      }
    } else {
      AppLogger.error('Arguments are null');
      Get.snackbar('Error', 'Invalid navigation arguments');
      Get.back();
    }
  }

  void _loadData() {
    if (cooperative.value == null) return;

    loadMembers();
    loadResourceListings();
  }

  Future<void> loadMembers() async {
    try {
      isLoading.value = true;
      error.value = null;

      final memberDocs = await Future.wait(
        cooperative.value!.members.map((memberId) async {
          final doc = await _firestore.collection('users').doc(memberId).get();
          return doc;
        }),
      );

      members.value = memberDocs
          .where((doc) => doc.exists)
          .map((doc) => UserModel.fromMap(doc.data()!, doc.id))
          .toList();

      members.sort((a, b) {
        if (a.id == cooperative.value!.createdBy) return -1;
        if (b.id == cooperative.value!.createdBy) return 1;
        return a.name.compareTo(b.name);
      });
    } catch (e) {
      error.value = 'Failed to load members';
      AppLogger.error('Error loading members: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void loadResourceListings() {
    if (cooperative.value == null) return;

    AppLogger.debug('Loading resource listings for ${cooperative.value!.id}');
    isLoadingListings.value = true;

    try {
      _firestore
          .collection('cooperatives')
          .doc(cooperative.value!.id)
          .collection('resource_listings')
          .get()
          .then((snapshot) {
        resourceListingsCount.value = snapshot.docs.length;
        AppLogger.debug('Loaded ${snapshot.docs.length} resource listings');
      }).catchError((error) {
        AppLogger.error('Error loading resource listings: $error');
        resourceListingsCount.value = 0;
      }).whenComplete(() {
        isLoadingListings.value = false;
      });
    } catch (e) {
      AppLogger.error('Exception in loadResourceListings: $e');
      resourceListingsCount.value = 0;
      isLoadingListings.value = false;
    }
  }

  void requestToJoin() {
    Get.snackbar(
      'Feature in Development',
      'Join request feature is coming soon!',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
    // When implementing the actual join feature:
    // isRequestingJoin.value = true;
    // ... perform join request logic ...
    // isRequestingJoin.value = false;
  }
}
