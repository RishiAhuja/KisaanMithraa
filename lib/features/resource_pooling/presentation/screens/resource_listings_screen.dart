// import 'package:cropconnect/core/presentation/widgets/bottom_nav_bar.dart';
import 'package:cropconnect/core/services/hive/hive_storage_service.dart';
import 'package:cropconnect/core/theme/app_colors.dart';
import 'package:cropconnect/features/auth/domain/model/user/user_model.dart';
import 'package:cropconnect/features/resource_pooling/domain/resouce_listing_model.dart';
import 'package:cropconnect/features/resource_pooling/presentation/controller/resource_pooling_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResourceListingsScreen extends GetView<ResourcePoolingController> {
  const ResourceListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final cooperativeId = args?['cooperativeId'] as String?;
    final cooperativeName = args?['cooperativeName'] as String?;

    if (cooperativeId == null) {
      return const Scaffold(
        body: Center(
          child: Text('Cooperative ID not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(cooperativeName ?? 'Resource Pool'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Show filter options
            },
          ),
          IconButton(
            icon: const Icon(Icons.my_library_books_outlined),
            onPressed: () => Get.toNamed('/my-listings'),
          ),
        ],
      ),
      body: StreamBuilder<List<ResourceListing>>(
        stream: controller.getListingsStream(cooperativeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return FutureBuilder<UserModel?>(
            future: Get.find<UserStorageService>().getUser(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final currentUser = userSnapshot.data;
              if (currentUser == null) {
                return const Center(
                  child: Text('User not found'),
                );
              }

              final listings = snapshot.data ?? [];
              final myListings =
                  listings.where((l) => l.userId == currentUser.id).toList();
              final otherListings =
                  listings.where((l) => l.userId != currentUser.id).toList();

              if (listings.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No listings yet',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => Get.toNamed('/create-listing'),
                        icon: const Icon(Icons.add,
                            color: AppColors.backgroundLight),
                        label: const Text('Create Listing'),
                      ),
                    ],
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _ExpandableSection(
                    title: 'My Listings (${myListings.length})',
                    listings: myListings,
                    isOwnListing: true,
                  ),
                  _ExpandableSection(
                    title: 'Marketplace (${otherListings.length})',
                    listings: otherListings,
                    isOwnListing: false,
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(
          '/create-listing',
          arguments: {
            'cooperativeId': cooperativeId,
            'cooperativeName': cooperativeName,
          },
        ),
        child: const Icon(Icons.add),
      ),
      // bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}

class _ExpandableSection extends StatelessWidget {
  final String title;
  final List<ResourceListing> listings;
  final bool isOwnListing;

  const _ExpandableSection({
    Key? key,
    required this.title,
    required this.listings,
    required this.isOwnListing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpanded = true.obs;

    return Column(
      children: [
        InkWell(
          onTap: () => isExpanded.toggle(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Obx(() => Icon(
                      isExpanded.value
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    )),
              ],
            ),
          ),
        ),
        Obx(() => AnimatedCrossFade(
              firstChild: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: listings.length,
                itemBuilder: (context, index) {
                  final listing = listings[index];
                  return _ListingCard(
                    listing: listing,
                    isOwnListing: isOwnListing,
                  );
                },
              ),
              secondChild: const SizedBox(),
              crossFadeState: isExpanded.value
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 300),
            )),
      ],
    );
  }
}

class _ListingCard extends StatelessWidget {
  final ResourceListing listing;
  final bool isOwnListing;

  const _ListingCard({
    Key? key,
    required this.listing,
    required this.isOwnListing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => Get.toNamed(
          isOwnListing ? '/my-listing-details' : '/listing-details',
          arguments: {
            'listing': listing,
            'isOwnListing': isOwnListing,
          },
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add top padding to prevent overlap with "YOUR LISTING" badge
                  SizedBox(height: isOwnListing ? 16 : 0),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getTypeColor(theme, listing.listingType),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          listing.listingType.name.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(theme, listing.status)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          listing.status.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _getStatusColor(theme, listing.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    listing.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<UserModel?>(
                    future: Get.find<ResourcePoolingController>()
                        .getUserDetails(listing.userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      }

                      final user = snapshot.data;
                      if (user == null) {
                        return const Text('Unknown user');
                      }

                      return Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            user.name,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${listing.quantityRequired} ${listing.unit}',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Price: ₹${listing.pricePerUnit}/${listing.unit}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (listing.offers.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${listing.offers.length} offers',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            if (isOwnListing)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  child: Text(
                    'YOUR LISTING',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(ThemeData theme, ListingType type) {
    switch (type) {
      case ListingType.request:
        return theme.colorScheme.primary;
      case ListingType.offer:
        return theme.colorScheme.secondary;
    }
  }

  Color _getStatusColor(ThemeData theme, String status) {
    switch (status) {
      case 'active':
        return theme.colorScheme.primary;
      case 'fulfilled':
        return theme.colorScheme.secondary;
      case 'cancelled':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.onSurface;
    }
  }
}
