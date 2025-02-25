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
    return Column(
      children: [
        // Map Section (50% of screen)
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Obx(() {
            if (controller.userLocation.value == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  controller.userLocation.value!.latitude,
                  controller.userLocation.value!.longitude,
                ),
                zoom: 12,
              ),
              markers: _buildMarkers(),
              circles: _buildCircles(),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
            );
          }),
        ),

        // List of cooperatives
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Join a Cooperative Near You',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),

                // List of cooperatives
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (controller.nearbyCooperatives.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            lottie.Lottie.asset(
                              'assets/animations/empty_state.json',
                              width: 200,
                              height: 200,
                            ),
                            const Text('No cooperatives found nearby'),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: onNext,
                              child: const Text('Skip for now'),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: controller.nearbyCooperatives.length,
                      itemBuilder: (context, index) {
                        final coop = controller.nearbyCooperatives[index];
                        final distance = LocationUtils.calculateDistance(
                          controller.userLocation.value!,
                          GeoPoint(coop.latitude, coop.longitude),
                        );

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(coop.name[0]),
                            ),
                            title: Text(coop.name),
                            subtitle: Text(
                                '${(distance / 1000).toStringAsFixed(1)} km away'),
                            trailing: ElevatedButton(
                              onPressed: () => _showCooperativeDetails(coop),
                              child: const Text('View'),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),

                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: onBack,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back'),
                      ),
                      ElevatedButton(
                        onPressed: onNext,
                        child: const Text('Continue'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Set<Marker> _buildMarkers() {
    return controller.nearbyCooperatives.map((coop) {
      return Marker(
        markerId: MarkerId(coop.id),
        position: LatLng(coop.latitude, coop.longitude),
        infoWindow: InfoWindow(
          title: coop.name,
          snippet: '${coop.members.length} members • Tap to view details',
          onTap: () => _showCooperativeDetails(coop),
        ),
      );
    }).toSet();
  }

  Set<Circle> _buildCircles() {
    final circles = <Circle>{
      // User's search radius circle
      Circle(
        circleId: const CircleId('searchRadius'),
        center: LatLng(
          controller.userLocation.value!.latitude,
          controller.userLocation.value!.longitude,
        ),
        radius: 10000, // 10km radius
        fillColor: Colors.blue.withOpacity(0.1),
        strokeColor: Colors.blue,
        strokeWidth: 1,
      ),
    };

    for (final coop in controller.nearbyCooperatives) {
      circles.add(
        Circle(
          circleId: CircleId('coop_${coop.id}'),
          center: LatLng(coop.latitude, coop.longitude),
          radius: 200.0, // 200 meters radius
          fillColor: AppColors.primary.withOpacity(0.2),
          strokeColor: AppColors.primary,
          strokeWidth: 2,
        ),
      );
    }

    return circles;
  }

  void _showCooperativeDetails(CooperativeModel coop) {
    final distance = LocationUtils.calculateDistance(
      controller.userLocation.value!,
      GeoPoint(coop.latitude, coop.longitude),
    );

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      coop.name,
                      style: Get.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.people,
                label: 'Members',
                value: coop.members.length.toString(),
              ),
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.location_on,
                label: 'Distance',
                value: '${(distance / 1000).toStringAsFixed(1)} km away',
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    controller.requestToJoin(coop);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Join Cooperative'),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Get.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: Get.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
