import 'package:cropconnect/features/cooperative/domain/models/cooperative_model.dart';
import 'package:cropconnect/features/cooperative/presentation/controllers/cooperative_search_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cropconnect/utils/location_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import '../../../../core/presentation/widgets/bottom_nav_bar.dart';
import '../controllers/my_cooperatives_controller.dart';

class MyCooperativesScreen extends GetView<MyCooperativesController> {
  const MyCooperativesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TabControllerScope(
        length: 2,
        initialIndex: 0,
        builder: (context, tabController) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Cooperatives',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black),
              ),
              backgroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    Get.toNamed('/search-cooperatives');
                  },
                ),
              ],
              bottom: TabBar(
                controller: tabController,
                onTap: (index) {
                  if (index == 0) {
                    controller.refreshMyCooperatives();
                  }
                },
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor:
                    theme.colorScheme.onSurface.withOpacity(0.7),
                indicatorColor: theme.colorScheme.primary,
                tabs: const [
                  Tab(text: 'My Cooperatives'),
                  Tab(text: 'Suggested Nearby'),
                ],
              ),
            ),
            body: TabBarView(
              controller: tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildMyCooperativesTab(theme, context, tabController),
                _buildSuggestedCooperativesTab(theme),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => Get.toNamed('/create-cooperative'),
              icon: Icon(Icons.add, color: Colors.white),
              label: Text('Create New', style: TextStyle(color: Colors.white)),
              backgroundColor: theme.colorScheme.primary,
            ),
            bottomNavigationBar: const BottomNavBar(currentIndex: 1),
          );
        });
  }

  Widget _buildMyCooperativesTab(
      ThemeData theme, BuildContext context, TabController tabController) {
    return Obx(() {
      if (controller.dataLoaded.value && !controller.isLoading.value) {
        final cooperatives = controller.cooperatives;
        if (cooperatives.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.group_outlined,
                  size: 64,
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'You haven\'t joined any cooperatives yet',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Check out suggested cooperatives near you',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () {
                    tabController.animateTo(1);
                  },
                  icon: const Icon(Icons.explore, size: 18),
                  label: const Text('Explore Nearby Cooperatives'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Show the list of cooperatives
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: cooperatives.length,
          itemBuilder: (context, index) {
            final coopWithRole = cooperatives[index];
            return _CooperativeCard(coopWithRole: coopWithRole);
          },
        );
      }

      // Loading state
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading your cooperatives...',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSuggestedCooperativesTab(ThemeData theme) {
    final searchCtrl = Get.put(CooperativeSearchController());

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          // Enable scrolling when keyboard appears
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              // Min height ensures scrolling works even with little content
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // Map container
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Container(
                      height: 260,
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
                      clipBehavior: Clip.antiAlias,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onHorizontalDragStart: (_) {},
                        onHorizontalDragUpdate: (_) {},
                        onHorizontalDragEnd: (_) {},
                        child: Stack(
                          children: [
                            // Keep your existing map implementation unchanged
                            Obx(() {
                              if (controller.userLocation.value == null) {
                                return const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 8),
                                      Text("Getting location...")
                                    ],
                                  ),
                                );
                              }

                              return GoogleMap(
                                // Your existing GoogleMap properties
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
                                zoomControlsEnabled: true,
                                compassEnabled: true,
                                mapToolbarEnabled: false,
                                liteModeEnabled: false,
                                zoomGesturesEnabled: true,
                                rotateGesturesEnabled: true,
                                scrollGesturesEnabled: true,
                                tiltGesturesEnabled: true,
                                padding: const EdgeInsets.only(bottom: 50),
                                gestureRecognizers: <Factory<
                                    OneSequenceGestureRecognizer>>{
                                  Factory<OneSequenceGestureRecognizer>(
                                    () => EagerGestureRecognizer(),
                                  ),
                                },
                              );
                            }),

                            // Keep your existing overlays
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.5),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                                child: Text(
                                  'Tap on markers to see cooperative details',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),

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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Cooperatives Near You',
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Obx(() => Text(
                                          '${controller.nearbyCooperatives.length} Found',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: Colors.white,
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: searchCtrl.searchController,
                        decoration: InputDecoration(
                          hintText: 'Search cooperatives by name or location',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIcon: Icon(Icons.search,
                              color: theme.colorScheme.primary),
                          suffixIcon: Obx(() => searchCtrl.hasSearched.value
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: Colors.grey),
                                  onPressed: searchCtrl.clearSearch,
                                )
                              : SizedBox.shrink()),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        onChanged: (value) {
                          // Debounce search for better performance
                          Future.delayed(Duration(milliseconds: 300), () {
                            if (searchCtrl.searchController.text == value) {
                              searchCtrl.searchCooperatives(value, controller);
                            }
                          });
                        },
                      ),
                    ),
                  ),

                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() {
                          if (searchCtrl.isSearching.value) {
                            return Text(
                              'Searching...',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          } else if (searchCtrl.hasSearched.value) {
                            return Text(
                              'Found ${searchCtrl.searchResults.length} cooperatives',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          } else {
                            return Text(
                              '${controller.nearbyCooperatives.length} Nearby Cooperatives',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }
                        }),
                        Obx(() {
                          if (controller.userLocation.value == null) {
                            return SizedBox.shrink();
                          }
                          return Text(
                            '5 km radius',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  Divider(indent: 16, endIndent: 16, height: 1),

                  Container(
                    height: 400,
                    child: Obx(() {
                      final cooperatives = searchCtrl.hasSearched.value
                          ? searchCtrl.searchResults
                          : controller.nearbyCooperatives;

                      if (searchCtrl.isSearching.value) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                'Searching cooperatives...',
                                style: theme.textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        );
                      }

                      // Empty state - nothing found
                      if (cooperatives.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              Icon(
                                searchCtrl.hasSearched.value
                                    ? Icons.search_off
                                    : Icons.location_off,
                                size: 64,
                                color: theme.colorScheme.error.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                searchCtrl.hasSearched.value
                                    ? 'No cooperatives found'
                                    : 'No nearby cooperatives found',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  searchCtrl.hasSearched.value
                                      ? 'Try a different search term'
                                      : 'There are no cooperatives within 5km of your current location',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              if (searchCtrl.hasSearched.value)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: OutlinedButton(
                                    onPressed: searchCtrl.clearSearch,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor:
                                          theme.colorScheme.primary,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text('Show Nearby Cooperatives'),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }

                      // Show the list of cooperatives (either search results or nearby)
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        // Enable dismissing keyboard when scrolling
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: cooperatives.length,
                        itemBuilder: (context, index) {
                          final coop = cooperatives[index];
                          return _NearbyCooperativeCard(
                            cooperative: coop,
                            onTap: () => Get.toNamed(
                              '/cooperative-details',
                              arguments: CooperativeWithRole(
                                cooperative: coop,
                                role: 'viewer',
                              ),
                            ),
                            controller: controller,
                          );
                        },
                      );
                    }),
                  ),

                  // Add some bottom padding to ensure content isn't covered by keyboard
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Set<Marker> _buildMarkers() {
    return controller.nearbyCooperatives.map((coop) {
      return Marker(
        markerId: MarkerId(coop.id),
        position: LatLng(coop.latitude, coop.longitude),
        infoWindow: InfoWindow(
          title: coop.name,
          snippet: '${coop.members.length} members',
          onTap: () => Get.toNamed('/cooperative-details',
              arguments: CooperativeWithRole(
                cooperative: coop,
                role: 'viewer',
              )),
        ),
      );
    }).toSet();
  }

  Set<Circle> _buildCircles() {
    return {
      if (controller.userLocation.value != null)
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

// Keep your existing card widgets
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
      clipBehavior: Clip.antiAlias, // Clips InkWell effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Main card area - clickable to open marketplace
          InkWell(
            onTap: () => Get.toNamed(
              '/resource-pool',
              arguments: {
                'cooperativeId': coop.id,
                'cooperativeName': coop.name,
                'cooperative': coop,
                'role': coopWithRole.role,
              },
            ),
            child: Padding(
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
          ),

          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: theme.dividerColor),
              ),
            ),
            child: Row(
              children: [
                if (coopWithRole.role == 'admin')
                  Expanded(
                    child: InkWell(
                      onTap: () => Get.toNamed(
                        '/cooperative-management',
                        arguments: coopWithRole,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.admin_panel_settings,
                                size: 16, color: theme.colorScheme.primary),
                            SizedBox(width: 8),
                            Text(
                              'Manage',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: InkWell(
                      onTap: () => Get.toNamed(
                        '/cooperative-details',
                        arguments: coopWithRole,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline,
                                size: 16,
                                color: theme.textTheme.labelLarge?.color),
                            SizedBox(width: 8),
                            Text(
                              'Details',
                              style: theme.textTheme.labelLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
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
                    cooperative.name.isNotEmpty
                        ? cooperative.name[0].toUpperCase()
                        : '?',
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
              // Join button
              ElevatedButton(
                onPressed: () {
                  Get.toNamed(
                    '/cooperative-details',
                    arguments: CooperativeWithRole(
                      cooperative: cooperative,
                      role: 'viewer',
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size(60, 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text('Join',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TabControllerScope extends StatefulWidget {
  final int length;
  final int initialIndex;
  final Widget Function(BuildContext context, TabController controller) builder;

  const TabControllerScope({
    required this.length,
    this.initialIndex = 0,
    required this.builder,
    Key? key,
  }) : super(key: key);

  @override
  _TabControllerScopeState createState() => _TabControllerScopeState();
}

class _TabControllerScopeState extends State<TabControllerScope>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: widget.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _controller);
  }
}
