import 'package:cropconnect/features/auth/domain/model/user/user_model.dart';
import 'package:cropconnect/features/notification/domain/model/notifications_model.dart';
import 'package:cropconnect/features/resource_pooling/domain/resouce_listing_model.dart';
import 'package:cropconnect/features/resource_pooling/domain/resource_offer_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../utils/app_logger.dart';

class ResourcePoolingController extends GetxController {
  final _firestore = FirebaseFirestore.instance;

  final listings = <ResourceListing>[].obs;
  final myListings = <ResourceListing>[].obs;
  final selectedListing = Rxn<ResourceListing>();
  final isLoading = false.obs;
  final error = Rxn<String>();

  final formKey = GlobalKey<FormState>();
  final listingType = Rxn<ListingType>();
  final transactionType = Rxn<TransactionType>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final quantityController = TextEditingController();
  final unitController = TextEditingController();
  final priceController = TextEditingController();
  final availableFrom = Rxn<DateTime>();
  final availableTo = Rxn<DateTime>();

  final _userCache = <String, UserModel>{};

  Future<UserModel?> getUserDetails(String userId) async {
    try {
      if (_userCache.containsKey(userId)) {
        return _userCache[userId];
      }

      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return null;
      }

      final user = UserModel.fromMap(userDoc.data()!, userDoc.id);
      _userCache[userId] = user;
      return user;
    } catch (e) {
      AppLogger.error('Error fetching user details: $e');
      return null;
    }
  }

  Future<void> selectAvailableTo(BuildContext context) async {
    if (availableFrom.value == null) {
      Get.snackbar(
        'Error',
        'Please select start date first',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final date = await showDatePicker(
      context: context,
      initialDate: availableFrom.value!.add(const Duration(days: 1)),
      firstDate: availableFrom.value!.add(const Duration(days: 1)),
      lastDate: availableFrom.value!.add(const Duration(days: 365)),
    );

    if (date != null) {
      availableTo.value = date;
    }
  }

  Future<List<Map<String, dynamic>>> getOffersWithUsers(
    String listingId,
    String cooperativeId,
  ) async {
    try {
      final listingRef = _firestore
          .collection('cooperatives')
          .doc(cooperativeId)
          .collection('resource_listings')
          .doc(listingId);

      final listingDoc = await listingRef.get();
      if (!listingDoc.exists) {
        return [];
      }

      final listing =
          ResourceListing.fromMap(listingDoc.data()!, listingDoc.id);
      final offers = <Map<String, dynamic>>[];

      for (final offer in listing.offers) {
        final user = await getUserDetails(offer.userId);
        if (user != null) {
          offers.add({
            'offer': offer,
            'user': user,
          });
        }
      }

      // Sort by offer time, most recent first
      offers.sort((a, b) {
        final offerA = a['offer'] as ResourceOffer;
        final offerB = b['offer'] as ResourceOffer;
        return offerB.offerTime.compareTo(offerA.offerTime);
      });

      return offers;
    } catch (e) {
      AppLogger.error('Error fetching offers with users: $e');
      return [];
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    quantityController.dispose();
    unitController.dispose();
    priceController.dispose();
    super.onClose();
  }

  Stream<List<ResourceListing>> getListingsStream(String cooperativeId) {
    return _firestore
        .collection('cooperatives')
        .doc(cooperativeId)
        .collection('resource_listings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ResourceListing.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<ResourceListing>> getMyListingsStream(String userId) {
    return _firestore
        .collectionGroup('resource_listings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ResourceListing.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> createListing(ResourceListing listing) async {
    try {
      isLoading.value = true;
      error.value = null;

      final doc = await _firestore
          .collection('cooperatives')
          .doc(listing.cooperativeId)
          .collection('resource_listings')
          .add(listing.toMap());

      listings.add(listing.copyWith(id: doc.id));

      AppLogger.info('Created new resource listing: ${listing.title}');
    } catch (e) {
      error.value = 'Failed to create listing: ${e.toString()}';
      AppLogger.error('Error creating listing: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> makeOffer(String listingId, ResourceOffer offer) async {
    try {
      isLoading.value = true;
      error.value = null;

      // Generate a new ID for the offer
      final offerId = _firestore.collection('dummy').doc().id;

      final offerWithId = offer.copyWith(
        id: offerId,
        status: 'pending',
      );

      AppLogger.debug('Creating offer: ${offerWithId.toMap()}'); // Add logging

      await _firestore
          .collection('cooperatives')
          .doc(offer.cooperativeId)
          .collection('resource_listings')
          .doc(listingId)
          .update({
        'offers': FieldValue.arrayUnion([offerWithId.toMap()]),
      });

      AppLogger.info('Offer created successfully');
      Get.back();
      Get.snackbar(
        'Success',
        'Offer submitted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      AppLogger.error('Error making offer: $e');
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to submit offer: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateListingStatus(String listingId, String status) async {
    try {
      isLoading.value = true;
      error.value = null;

      await _firestore
          .collection('cooperatives')
          .doc(selectedListing.value!.cooperativeId)
          .collection('resource_listings')
          .doc(listingId)
          .update({'status': status});

      final index = listings.indexWhere((listing) => listing.id == listingId);
      if (index != -1) {
        listings[index] = listings[index].copyWith(status: status);
      }

      AppLogger.info('Updated listing status: $listingId to $status');
    } catch (e) {
      error.value = 'Failed to update status: ${e.toString()}';
      AppLogger.error('Error updating listing status: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectAvailableFrom(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      availableFrom.value = date;

      if (availableTo.value != null && availableTo.value!.isBefore(date)) {
        availableTo.value = null;
      }
    }
  }

  Future<void> acceptOffer(
      String listingId, String offerId, String cooperativeId) async {
    try {
      isLoading.value = true;
      error.value = null;

      AppLogger.debug(
          'Starting offer acceptance - listingId: $listingId, offerId: $offerId, cooperativeId: $cooperativeId');

      final listingRef = _firestore
          .collection('cooperatives')
          .doc(cooperativeId)
          .collection('resource_listings')
          .doc(listingId);

      final listingDoc = await listingRef.get();
      if (!listingDoc.exists) {
        throw Exception('Listing not found');
      }

      final listing = ResourceListing.fromMap(listingDoc.data()!, listingId);
      AppLogger.debug('Found listing: ${listing.title}');

      final updatedOffers = listing.offers
          .map((offer) => offer.copyWith(
                status: offer.id == offerId ? 'accepted' : 'rejected',
              ))
          .toList();

      final batch = _firestore.batch();

      batch.update(listingRef, {
        'status': 'fulfilled',
        'offers': updatedOffers.map((o) => o.toMap()).toList(),
      });

      final acceptedOffer = listing.offers.firstWhere((o) => o.id == offerId);

      final acceptedNotificationRef = _firestore
          .collection('notifications')
          .doc(acceptedOffer.userId)
          .collection('items')
          .doc();

      batch.set(
        acceptedNotificationRef,
        NotificationModel(
          id: acceptedNotificationRef.id,
          userId: acceptedOffer.userId,
          type: NotificationType.offerAccepted,
          title: 'Offer Accepted',
          message: 'Your offer for ${listing.title} has been accepted',
          cooperativeId: cooperativeId,
          createdAt: DateTime.now(),
          isRead: false,
          action: NotificationAction.viewListing,
          actionData: {
            'listingId': listingId,
            'cooperativeId': cooperativeId,
          },
        ).toMap(),
      );

      for (final offer in listing.offers.where((o) => o.id != offerId)) {
        final rejectedNotificationRef = _firestore
            .collection('notifications')
            .doc(offer.userId)
            .collection('items')
            .doc();

        batch.set(
          rejectedNotificationRef,
          NotificationModel(
            id: rejectedNotificationRef.id,
            userId: offer.userId,
            type: NotificationType.offerRejected,
            title: 'Offer Not Selected',
            message: 'Another offer was selected for ${listing.title}',
            cooperativeId: cooperativeId,
            createdAt: DateTime.now(),
            isRead: false,
            action: NotificationAction.viewListing,
            actionData: {
              'listingId': listingId,
              'cooperativeId': cooperativeId,
            },
          ).toMap(),
        );
      }

      await batch.commit();

      AppLogger.info('Successfully accepted offer and sent notifications');
      Get.back();
      Get.snackbar(
        'Success',
        'Offer accepted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      AppLogger.error('Error accepting offer: $e');
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to accept offer: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
