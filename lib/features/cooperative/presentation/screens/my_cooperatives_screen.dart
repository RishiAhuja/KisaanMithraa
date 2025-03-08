import 'package:cropconnect/features/cooperative/domain/models/cooperative_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cropconnect/utils/location_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/presentation/widgets/bottom_nav_bar.dart';
import '../controllers/my_cooperatives_controller.dart';

class MyCooperativesScreen extends GetView<MyCooperativesController> {
  const MyCooperativesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cooperatives'),
        backgroundColor: Colors.white,
        actions: [
          // Add search button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
              Get.toNamed('/search-cooperatives');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Map section with rounded corners
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              height: 180, // Fixed height for map
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias, // Important for rounded corners
              child: Stack(
                children: [
                  // Map widget
                  Obx(() {
                    return GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          controller.userLocation.value!.latitude,
                          controller.userLocation.value!.longitude,
                        ),
                        zoom: 11,
                      ),
                      markers: _buildMarkers(),
                      circles: _buildCircles(),
                      myLocationEnabled: true,
                      zoomControlsEnabled: false, // Hide zoom controls
                      compassEnabled: false, // Hide compass
                      mapToolbarEnabled: false, // Hide map toolbar
                      liteModeEnabled: false, // For better performance
                    );
                  }),

                  // Map overlay with gradient and text
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Cooperatives Near You',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Get.toNamed('/explore-cooperatives');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'View All',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // My cooperatives section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'My Cooperatives',
                style: theme.textTheme.titleLarge,
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<List<CooperativeWithRole>>(
              stream: controller.cooperativesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final cooperatives = snapshot.data ?? [];

                if (cooperatives.isEmpty) {
                  // Replace your current empty state with this:
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Empty state message
                        Text(
                          'You haven\'t joined any cooperatives yet',
                          style: theme.textTheme.titleMedium,
                        ),

                        const SizedBox(height: 8),

                        // Suggestion text
                        Text(
                          'Join a nearby cooperative or start your own',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Nearby cooperatives section
                        Obx(() {
                          final nearbyCoops = controller.nearbyCooperatives;

                          if (nearbyCoops.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 20),
                                  Text(
                                    'No nearby cooperatives found',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nearby Cooperatives',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              // Actually use the _NearbyCooperativeCard here
                              ...nearbyCoops
                                  .take(2)
                                  .map((coop) => _NearbyCooperativeCard(
                                        cooperative: coop,
                                        onTap: () => Get.toNamed(
                                            '/cooperative-details',
                                            arguments: {
                                              'cooperativeId': coop.id,
                                            }),
                                        controller: controller,
                                      )),
                              if (nearbyCoops.length > 2)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0),
                                  child: TextButton(
                                    onPressed: () =>
                                        Get.toNamed('/explore-cooperatives'),
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          theme.colorScheme.primary,
                                    ),
                                    child: Text(
                                        'See ${nearbyCoops.length - 2} more nearby'),
                                  ),
                                ),
                            ],
                          );
                        }),

                        const Spacer(),

                        // Create Cooperative Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton.icon(
                            onPressed: () => Get.toNamed('/create-cooperative'),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Create your own cooperative'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cooperatives.length,
                  itemBuilder: (context, index) {
                    final coopWithRole = cooperatives[index];
                    return _CooperativeCard(coopWithRole: coopWithRole);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  // Method to build map markers
  Set<Marker> _buildMarkers() {
    return controller.nearbyCooperatives.map((coop) {
      return Marker(
        markerId: MarkerId(coop.id),
        position: LatLng(coop.latitude, coop.longitude),
        infoWindow: InfoWindow(
          title: coop.name,
          snippet: '${coop.members.length} members',
          onTap: () => Get.toNamed('/cooperative-details', arguments: {
            'cooperativeId': coop.id,
          }),
        ),
      );
    }).toSet();
  }

  // Method to build map circles
  Set<Circle> _buildCircles() {
    return {
      Circle(
        circleId: const CircleId('userRadius'),
        center: LatLng(
          controller.userLocation.value!.latitude,
          controller.userLocation.value!.longitude,
        ),
        radius: 5000, // 5km radius
        fillColor: Colors.blue.withOpacity(0.1),
        strokeColor: Colors.blue,
        strokeWidth: 1,
      ),
    };
  }
}

class _CooperativeCard extends StatelessWidget {
  final CooperativeWithRole coopWithRole;

  const _CooperativeCard({
    required this.coopWithRole,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final coop = coopWithRole.cooperative;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        coop.name,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: coopWithRole.role == 'admin'
                            ? theme.colorScheme.primary
                            : theme.colorScheme.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        coopWithRole.role.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  coop.description ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      coop.location,
                      style: theme.textTheme.bodySmall,
                    ),
                    const Spacer(),
                    Text(
                      '${coop.members.length} members',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                if (coop.status == 'unverified') ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Unverified',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Row(
            children: [
              if (coopWithRole.role == 'admin')
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () => Get.toNamed(
                      '/cooperative-management',
                      arguments: coopWithRole,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: theme.dividerColor),
                          right: BorderSide(color: theme.dividerColor),
                        ),
                      ),
                      child: Text(
                        'Manage',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () => Get.toNamed(
                      '/cooperative-details',
                      arguments: coopWithRole,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: theme.dividerColor),
                          right: BorderSide(color: theme.dividerColor),
                        ),
                      ),
                      child: Text(
                        'Details',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                  ),
                ),
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: () => Get.toNamed(
                    '/resource-pool',
                    arguments: {
                      'cooperativeId': coop.id,
                      'cooperativeName': coop.name,
                    },
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: theme.dividerColor),
                      ),
                    ),
                    child: Text(
                      'Open Marketplace',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NearbyCooperativeCard extends StatelessWidget {
  final CooperativeModel cooperative;
  final VoidCallback onTap;
  final MyCooperativesController controller;

  const _NearbyCooperativeCard({
    required this.cooperative,
    required this.onTap,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Cooperative icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    cooperative.name[0].toUpperCase(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Cooperative details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cooperative.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${cooperative.members.length} members',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Obx(() {
                          if (controller.userLocation.value == null) {
                            return const SizedBox.shrink();
                          }

                          final distance = LocationUtils.calculateDistance(
                            GeoPoint(
                              controller.userLocation.value!.latitude,
                              controller.userLocation.value!.longitude,
                            ),
                            GeoPoint(
                                cooperative.latitude, cooperative.longitude),
                          );

                          return Text(
                            '${(distance / 1000).toStringAsFixed(1)} km',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
