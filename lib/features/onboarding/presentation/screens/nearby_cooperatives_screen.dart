import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cropconnect/core/theme/app_colors.dart';
import 'package:cropconnect/features/cooperative/domain/models/cooperative_model.dart';
import 'package:cropconnect/features/onboarding/presentation/controller/nearby_cooperatives_controller.dart';
import 'package:cropconnect/utils/location_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart' as lottie;

class NearbyCooperativesPage extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;
  final controller = Get.find<NearbyCooperativesController>();

  NearbyCooperativesPage({
    super.key,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, theme.scaffoldBackgroundColor],
          ),
        ),
        child: Stack(
          // Use Stack as root instead of Column
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: screenHeight,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Obx(() {
                      if (controller.userLocation.value == null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              lottie.Lottie.asset(
                                'assets/animations/map_loading.json',
                                width: 120,
                                height: 120,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Finding your location...',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(24),
                        ),
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              controller.userLocation.value!.latitude,
                              controller.userLocation.value!.longitude,
                            ),
                            zoom: 14.5,
                          ),
                          markers: _buildMarkers(),
                          circles: _buildCircles(),
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          zoomControlsEnabled: true,
                          zoomGesturesEnabled: true,
                          mapToolbarEnabled: false,
                          compassEnabled: true,
                        ),
                      );
                    }),
                  ),
                  Positioned(
                    top: 34,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'Cooperatives Near You',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              top: screenHeight * 0.45 - 24,
              left: 0,
              right: 0,
              bottom: 74, // Leave space for navigation buttons
              child: DraggableScrollableSheet(
                initialChildSize: 1.0, // Initially take full available space
                minChildSize: 0.3,
                maxChildSize: 1.0,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 1,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: CustomScrollView(
                      controller: scrollController,
                      slivers: [
                        // Your existing slivers code...
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              // Handle bar for bottom sheet effect
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 12),
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),

                              // Title for the list
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, bottom: 8),
                                child: Row(
                                  children: [
                                    Text(
                                      "Available Cooperatives",
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    const Spacer(),
                                    Obx(() => Text(
                                          "${controller.nearbyCooperatives.length} found",
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Your existing Obx() with cooperatives list...
                        Obx(() {
                          // Keep your existing SliverFillRemaining and SliverPadding code as is
                          // ...
                          if (controller.isLoading.value) {
                            return SliverFillRemaining(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          theme.primaryColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Finding nearby cooperatives...',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          if (controller.nearbyCooperatives.isEmpty) {
                            return SliverFillRemaining(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    lottie.Lottie.asset(
                                      'assets/animations/empty_state.json',
                                      width: 150,
                                      height: 150,
                                    ),
                                    Text(
                                      'No cooperatives found nearby',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'You can continue without joining a cooperative',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: onNext,
                                      icon: const Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 16),
                                      label: Text('Continue',
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          // Ensure enough bottom padding to avoid overlap with navigation buttons
                          return SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  // Keep your existing card item code
                                  final coop =
                                      controller.nearbyCooperatives[index];
                                  final distance =
                                      LocationUtils.calculateDistance(
                                    controller.userLocation.value!,
                                    GeoPoint(coop.latitude, coop.longitude),
                                  );

                                  return Card(
                                    // Keep your existing card code
                                    // ...
                                    margin: const EdgeInsets.only(bottom: 8),
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: InkWell(
                                      onTap: () =>
                                          _showCooperativeDetails(coop),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          children: [
                                            // Your existing card content
                                            // ...
                                            // Cooperative avatar
                                            Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: theme.primaryColor
                                                    .withOpacity(0.1),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: theme.primaryColor,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  coop.name[0].toUpperCase(),
                                                  style: theme
                                                      .textTheme.titleLarge
                                                      ?.copyWith(
                                                    color: theme.primaryColor,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            const SizedBox(width: 12),

                                            // Cooperative details
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    coop.name,
                                                    style: theme
                                                        .textTheme.titleSmall
                                                        ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.people,
                                                        size: 14,
                                                        color: Colors.grey[600],
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${coop.members.length} members',
                                                        style: theme
                                                            .textTheme.bodySmall
                                                            ?.copyWith(
                                                          color:
                                                              Colors.grey[600],
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Container(
                                                        width: 3,
                                                        height: 3,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[400],
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Icon(
                                                        Icons.location_on,
                                                        size: 14,
                                                        color: Colors.grey[600],
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${(distance / 1000).toStringAsFixed(1)} km',
                                                        style: theme
                                                            .textTheme.bodySmall
                                                            ?.copyWith(
                                                          color:
                                                              Colors.grey[600],
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // View button
                                            Container(
                                              decoration: BoxDecoration(
                                                color: theme.primaryColor
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: IconButton(
                                                iconSize: 16,
                                                padding:
                                                    const EdgeInsets.all(8),
                                                constraints:
                                                    const BoxConstraints(),
                                                icon: Icon(
                                                  Icons
                                                      .arrow_forward_ios_rounded,
                                                  size: 14,
                                                  color: theme.primaryColor,
                                                ),
                                                onPressed: () =>
                                                    _showCooperativeDetails(
                                                        coop),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                childCount:
                                    controller.nearbyCooperatives.length,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Navigation buttons at the bottom - now correctly positioned in the Stack
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    OutlinedButton.icon(
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: Text(
                        'Back',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        side: BorderSide(
                          color: theme.primaryColor,
                          width: 1.5,
                        ),
                      ),
                    ),

                    // Next button
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: onNext,
                        icon: Text('Next',
                            style: theme.textTheme.labelLarge
                                ?.copyWith(color: Colors.white)),
                        label: const Icon(Icons.arrow_forward_rounded,
                            size: 18, color: AppColors.backgroundLight),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
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
    );
  }

  // Changed marker color to red
  Set<Marker> _buildMarkers() {
    return controller.nearbyCooperatives.map((coop) {
      return Marker(
        markerId: MarkerId(coop.id),
        position: LatLng(coop.latitude, coop.longitude),
        infoWindow: InfoWindow(
          title: coop.name,
          snippet: '${coop.members.length} members • Tap for details',
          onTap: () => _showCooperativeDetails(coop),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
    }).toSet();
  }

  // Simplified circles
  Set<Circle> _buildCircles() {
    final circles = <Circle>{
      // User's search radius circle - more subtle
      Circle(
        circleId: const CircleId('searchRadius'),
        center: LatLng(
          controller.userLocation.value!.latitude,
          controller.userLocation.value!.longitude,
        ),
        radius: 5000, // 5km radius
        fillColor: Colors.blue.withOpacity(0.05),
        strokeColor: Colors.blue.withOpacity(0.3),
        strokeWidth: 1,
      ),
    };

    // Simple circles for cooperatives
    for (final coop in controller.nearbyCooperatives) {
      circles.add(
        Circle(
          circleId: CircleId('coop_${coop.id}'),
          center: LatLng(coop.latitude, coop.longitude),
          radius: 300.0,
          fillColor: Colors.red.withOpacity(0.1),
          strokeColor: Colors.red,
          strokeWidth: 1,
        ),
      );
    }

    return circles;
  }

  void _showCooperativeDetails(CooperativeModel coop) {
    final theme = Get.theme;
    final distance = LocationUtils.calculateDistance(
      controller.userLocation.value!,
      GeoPoint(coop.latitude, coop.longitude),
    );

    // Use the standard Flutter showDialog instead of Get.dialog
    showDialog(
      context: Get.context!,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Simplified header
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coop.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(distance / 1000).toStringAsFixed(1)} km away • ${coop.members.length} members',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Fixed close button that uses Navigator directly with the correct context
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Use the context provided by the showDialog builder
                          Navigator.of(context).pop();
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Simplified details section
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Three key details in a simpler format
                    ListTile(
                      leading: Icon(Icons.people, color: theme.primaryColor),
                      title: const Text('Members'),
                      subtitle: Text('${coop.members.length} active members'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    ListTile(
                      leading:
                          Icon(Icons.location_on, color: theme.primaryColor),
                      title: const Text('Distance'),
                      subtitle: Text(
                          '${(distance / 1000).toStringAsFixed(1)} km from you'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),

                    const SizedBox(height: 16),

                    // Join button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Use the builder context to avoid GetX issues
                          Navigator.of(context).pop();
                          controller.requestToJoin(coop);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('Join Cooperative',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
