import 'package:cropconnect/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import '../../domain/models/cooperative_model.dart';

class CooperativeMapScreen extends StatefulWidget {
  final CooperativeModel cooperative;

  const CooperativeMapScreen({
    Key? key,
    required this.cooperative,
  }) : super(key: key);

  @override
  State<CooperativeMapScreen> createState() => _CooperativeMapScreenState();
}

class _CooperativeMapScreenState extends State<CooperativeMapScreen> {
  GoogleMapController? mapController;
  final Set<Marker> markers = {};
  final Set<Circle> circles = {};
  static const double COOPERATIVE_RADIUS = 200.0;

  @override
  void initState() {
    super.initState();
    _addCooperativeMarker();
    _addCooperativeCircle();
  }

  void _addCooperativeMarker() {
    markers.add(
      Marker(
        markerId: MarkerId(widget.cooperative.id),
        position: LatLng(
          widget.cooperative.latitude,
          widget.cooperative.longitude,
        ),
        infoWindow: InfoWindow(
          title: widget.cooperative.name,
          snippet: '${widget.cooperative.members.length} members',
          onTap: () => _showCooperativeDetails(),
        ),
      ),
    );
  }

  void _showCooperativeDetails() {
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
                      widget.cooperative.name,
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
                value: widget.cooperative.members.length.toString(),
              ),
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.location_on,
                label: 'Location',
                value: '${widget.cooperative.latitude.toStringAsFixed(6)}, '
                    '${widget.cooperative.longitude.toStringAsFixed(6)}',
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
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

  void _addCooperativeCircle() {
    circles.add(
      Circle(
        circleId: CircleId(widget.cooperative.id),
        center: LatLng(
          widget.cooperative.latitude,
          widget.cooperative.longitude,
        ),
        radius: COOPERATIVE_RADIUS,
        fillColor: AppColors.primary.withOpacity(0.2),
        strokeColor: AppColors.primary,
        strokeWidth: 2,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            widget.cooperative.latitude,
            widget.cooperative.longitude,
          ),
          zoom: 15,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cooperative.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.layers),
            onPressed: () {
              // TODO: Add map type selector
            },
          ),
        ],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(
            widget.cooperative.latitude,
            widget.cooperative.longitude,
          ),
          zoom: 15,
        ),
        markers: markers,
        circles: circles, // Add this
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        mapType: MapType.normal,
        zoomControlsEnabled: true,
        zoomGesturesEnabled: true,
      ),
    );
  }
}

// Add this widget class at the bottom of the file
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
