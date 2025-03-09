import 'package:cached_network_image/cached_network_image.dart';
import 'package:cropconnect/core/services/hive/hive_storage_service.dart';
import 'package:cropconnect/core/theme/app_colors.dart';
import 'package:cropconnect/features/auth/domain/model/user/user_model.dart';
import 'package:cropconnect/features/cooperative/domain/models/cooperative_model.dart';
import 'package:cropconnect/features/cooperative/presentation/controllers/my_cooperatives_controller.dart';
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
    final cooperative = args?['cooperative'] as CooperativeModel?;
    final role = args?['role'] as String?;
    final theme = Theme.of(context);

    if (cooperativeId == null) {
      return const Scaffold(
        body: Center(
          child: Text('Cooperative ID not found'),
        ),
      );
    }

    return Scaffold(
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

              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: 200.0,
                      pinned: true,
                      floating: false,
                      elevation: 0,
                      backgroundColor: innerBoxIsScrolled
                          ? theme.colorScheme.surface
                          : Colors.transparent,
                      foregroundColor: innerBoxIsScrolled
                          ? theme.colorScheme.onSurface
                          : Colors.white,
                      title: innerBoxIsScrolled
                          ? Text(
                              cooperative?.name ??
                                  cooperativeName ??
                                  'Listings',
                              style: theme.textTheme.titleMedium,
                            )
                          : null,
                      leading: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.black.withOpacity(0.3),
                            radius: 18,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () => Get.back(),
                            ),
                          ),
                        ),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        background: _buildCooperativeHeaderContent(context,
                            cooperativeId, cooperativeName, cooperative),
                      ),
                    ),

                    // Action Buttons Section
                    CooperativeActionButtons(
                        cooperativeId: cooperativeId,
                        cooperativeName: cooperativeName,
                        cooperative: cooperative,
                        role: role!),
                  ];
                },
                body: listings.isEmpty
                    ? Center(
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
                      )
                    : ListView(
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
                      ),
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
    );
  }

  Widget _buildCooperativeHeaderContent(
    BuildContext context,
    String cooperativeId,
    String? cooperativeName,
    CooperativeModel? cooperative,
  ) {
    final theme = Theme.of(context);
    final coopName = cooperative?.name ?? cooperativeName ?? 'Cooperative';
    final initial = coopName.isNotEmpty ? coopName[0].toUpperCase() : 'C';

    return Stack(
      children: [
        Container(
          color: AppColors.backgroundLight,
          height: 140,
          width: double.infinity,
          child: cooperative?.bannerUrl == null
              ? Container(
                  color: theme.colorScheme.primary,
                )
              : CachedNetworkImage(
                  imageUrl: cooperative!.bannerUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: theme.colorScheme.primary,
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.white54,
                      size: 24,
                    ),
                  ),
                ),
        ),

        Positioned(
          left: 0,
          right: 0,
          top: 120,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 30, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cooperative name below the profile picture
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        coopName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (cooperative != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: cooperative.status.toLowerCase() == 'verified'
                              ? Colors.green
                              : Colors.orange,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              cooperative.status.toLowerCase() == 'verified'
                                  ? Icons.verified
                                  : Icons.pending,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              cooperative.status.capitalize!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                // Location below name
                if (cooperative != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            cooperative.location,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),

        // LinkedIn-style profile picture (half on banner, half below)
        Positioned(
          top:
              90, // Adjusted from 70 to 90 to maintain the half-on-half-off effect
          left: 16,
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getAvatarColor(initial),
              border: Border.all(
                color: theme.cardColor,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initial,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to generate consistent colors based on the initial
  Color _getAvatarColor(String initial) {
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.indigo,
      Colors.red,
      Colors.purple,
      Colors.deepOrange,
      Colors.teal,
      Colors.pink,
    ];

    // Generate consistent color based on ASCII value of initial
    final int index = initial.codeUnitAt(0) % colors.length;
    return colors[index];
  }
}

class _ExpandableSection extends StatelessWidget {
  final String title;
  final List<ResourceListing> listings;
  final bool isOwnListing;

  const _ExpandableSection({
    required this.title,
    required this.listings,
    required this.isOwnListing,
  });

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
    required this.listing,
    required this.isOwnListing,
  });

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

class CooperativeActionButtons extends StatelessWidget {
  final String cooperativeId;
  final String? cooperativeName;
  final CooperativeModel? cooperative;
  final String role;

  const CooperativeActionButtons({
    super.key,
    required this.cooperativeId,
    this.cooperativeName,
    this.cooperative,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.toNamed('/cooperative-details',
                      arguments: CooperativeWithRole(
                          cooperative: cooperative!, role: role));
                },
                icon:
                    Icon(Icons.info_outline, color: AppColors.backgroundLight),
                label: Text('Details',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Contact logic
                  // Get.find<CooperativeDetailsController>().contact();
                },
                icon: Icon(Icons.phone_outlined),
                label: Text('Contact',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: AppColors.primary)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  side: BorderSide(color: theme.colorScheme.primary),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
