import 'package:cropconnect/core/services/debug/debug_service.dart';
import 'package:cropconnect/core/presentation/widgets/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class DebugScreen extends GetView<DebugService> {
  const DebugScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CommonAppBar(
        title: 'Debug Tools',
        showNotificationIcon: false,
        showProfileIcon: false,
        customActions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Clear Debug Data',
            onPressed: controller.clearDebugData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWarningBanner(theme),
            const SizedBox(height: 16),
            _buildRandomUsersCard(theme),
            const SizedBox(height: 16),
            _buildRandomCooperativeCard(theme),
            const SizedBox(height: 16),
            _buildPodcastUploadCard(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningBanner(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Debug mode is active. Data generated here will be added to your live database. Use with caution.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.amber[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRandomUsersCard(ThemeData theme) {
    final userCountController = TextEditingController(text: '5');

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generate Random Users',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: userCountController,
                    decoration: const InputDecoration(
                      labelText: 'Number of Users',
                      hintText: 'Enter number of users',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Obx(() => ElevatedButton(
                      onPressed: controller.isGeneratingData.value
                          ? null
                          : () async {
                              final count =
                                  int.tryParse(userCountController.text) ?? 5;
                              final users =
                                  await controller.generateRandomUsers(
                                count: count,
                              );
                              _showResultDialog('Users Created',
                                  'Created ${users.length} random users');
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 8),
                      ),
                      child: controller.isGeneratingData.value
                          ? const SizedBox(
                              width: 30,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Generate'),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRandomCooperativeCard(ThemeData theme) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final memberCountController = TextEditingController(text: '10');
    final Rx<LatLng?> selectedLocation = Rx<LatLng?>(null);
    final Rx<GoogleMapController?> mapController =
        Rx<GoogleMapController?>(null);

    final initialPosition = const CameraPosition(
      target: LatLng(20.5937, 78.9629),
      zoom: 5,
    );

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generate Random Cooperative',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Cooperative Name',
                hintText: 'Enter cooperative name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter cooperative description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: memberCountController,
              decoration: const InputDecoration(
                labelText: 'Number of Members',
                hintText: 'Enter number of members',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cooperative Location',
                  style: theme.textTheme.titleSmall,
                ),
                Obx(
                  () => selectedLocation.value != null
                      ? TextButton.icon(
                          icon: const Icon(Icons.clear, size: 16),
                          label: const Text('Clear Selection'),
                          onPressed: () {
                            selectedLocation.value = null;
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 250,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: initialPosition,
                      onMapCreated: (controller) {
                        mapController.value = controller;
                      },
                      onTap: (latLng) {
                        selectedLocation.value = latLng;
                        Get.snackbar(
                          'Location Selected',
                          'Lat: ${latLng.latitude.toStringAsFixed(4)}, Lng: ${latLng.longitude.toStringAsFixed(4)}',
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(seconds: 1),
                        );
                      },
                      markers: {
                        if (selectedLocation.value != null)
                          Marker(
                            markerId: const MarkerId('selectedLocation'),
                            position: selectedLocation.value!,
                            infoWindow: InfoWindow(
                              title: 'Cooperative Location',
                              snippet:
                                  'Lat: ${selectedLocation.value!.latitude.toStringAsFixed(4)}, Lng: ${selectedLocation.value!.longitude.toStringAsFixed(4)}',
                            ),
                          ),
                      },
                      zoomControlsEnabled: true,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      mapToolbarEnabled: true,
                      compassEnabled: true,
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                  hintText: 'Search for a location',
                                  border: InputBorder.none,
                                  suffixIcon: Icon(Icons.search, size: 20),
                                ),
                                onSubmitted: (value) async {
                                  if (value.isNotEmpty) {
                                    try {
                                      final geocoding =
                                          GeocodingPlatform.instance;
                                      final locations = await geocoding!
                                          .locationFromAddress(value);

                                      if (locations.isNotEmpty) {
                                        final location = locations.first;
                                        final latLng = LatLng(
                                          location.latitude,
                                          location.longitude,
                                        );

                                        selectedLocation.value = latLng;
                                        mapController.value?.animateCamera(
                                          CameraUpdate.newLatLngZoom(
                                              latLng, 12),
                                        );
                                      }
                                    } catch (e) {
                                      Get.snackbar(
                                        'Error',
                                        'Could not find location: $value',
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 100,
                      right: 8,
                      child: Column(
                        children: [
                          _buildMapButton(
                            icon: Icons.location_city,
                            tooltip: 'Zoom to Delhi',
                            onPressed: () {
                              mapController.value?.animateCamera(
                                CameraUpdate.newLatLngZoom(
                                  const LatLng(28.6139, 77.2090),
                                  10,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          _buildMapButton(
                            icon: Icons.beach_access,
                            tooltip: 'Zoom to Mumbai',
                            onPressed: () {
                              mapController.value?.animateCamera(
                                CameraUpdate.newLatLngZoom(
                                  const LatLng(19.0760, 72.8777),
                                  10,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          _buildMapButton(
                            icon: Icons.computer,
                            tooltip: 'Zoom to Bangalore',
                            onPressed: () {
                              mapController.value?.animateCamera(
                                CameraUpdate.newLatLngZoom(
                                  const LatLng(12.9716, 77.5946),
                                  10,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Selected coordinates display
            Obx(
              () => selectedLocation.value != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Selected: ${selectedLocation.value!.latitude.toStringAsFixed(6)}, ${selectedLocation.value!.longitude.toStringAsFixed(6)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: Obx(() => ElevatedButton(
                    onPressed: (controller.isGeneratingData.value ||
                            selectedLocation.value == null)
                        ? null
                        : () async {
                            if (nameController.text.isEmpty ||
                                descriptionController.text.isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Please fill in all fields',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            final memberCount =
                                int.tryParse(memberCountController.text) ?? 10;

                            final cooperative =
                                await controller.generateCooperative(
                              name: nameController.text,
                              description: descriptionController.text,
                              latitude: selectedLocation.value!.latitude,
                              longitude: selectedLocation.value!.longitude,
                              memberCount: memberCount,
                            );

                            if (cooperative != null) {
                              _showResultDialog(
                                'Cooperative Created',
                                'Created cooperative "${cooperative.name}" with ${cooperative.members.length} members',
                              );

                              // Clear form
                              nameController.clear();
                              descriptionController.clear();
                              selectedLocation.value = null;
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: controller.isGeneratingData.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Generate Cooperative'),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodcastUploadCard(ThemeData theme) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final authorController = TextEditingController(text: 'CropConnect Admin');
    final durationController = TextEditingController();

    // RxVariables for file selections and language
    final Rx<File?> audioFile = Rx<File?>(null);
    final Rx<File?> imageFile = Rx<File?>(null);
    final RxString selectedLanguage = 'en'.obs;
    final RxList<String> selectedTags = <String>[].obs;

    // List of available tags and languages
    final availableTags = [
      'Farming',
      'Weather',
      'Crops',
      'Market',
      'Technology',
      'Government',
      'Tips',
      'Interview'
    ];

    final availableLanguages = [
      {'code': 'en', 'name': 'English'},
      {'code': 'hi', 'name': 'Hindi'},
      {'code': 'pa', 'name': 'Punjabi'},
      {'code': 'ta', 'name': 'Tamil'},
      {'code': 'te', 'name': 'Telugu'},
      {'code': 'mr', 'name': 'Marathi'},
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.podcasts, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Upload Test Podcast',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Title field
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Podcast Title',
                hintText: 'Enter podcast title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Description field
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter podcast description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Author and duration in same row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: authorController,
                    decoration: const InputDecoration(
                      labelText: 'Author',
                      hintText: 'Enter author name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: durationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration (seconds)',
                      hintText: 'Enter duration',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Language dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Language',
                border: OutlineInputBorder(),
              ),
              value: selectedLanguage.value,
              items: availableLanguages.map((language) {
                return DropdownMenuItem(
                  value: language['code'],
                  child: Text('${language['name']} (${language['code']})'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedLanguage.value = value;
                }
              },
            ),
            const SizedBox(height: 16),

            // Tags selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tags',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: availableTags.map((tag) {
                    return Obx(() {
                      final isSelected = selectedTags.contains(tag);
                      return FilterChip(
                        label: Text(tag),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            selectedTags.add(tag);
                          } else {
                            selectedTags.remove(tag);
                          }
                        },
                        checkmarkColor: theme.colorScheme.onPrimary,
                        selectedColor: theme.colorScheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                        ),
                      );
                    });
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // File selection
            Row(
              children: [
                Expanded(
                  child: Obx(() => _buildFileSelectionButton(
                        label: 'Audio File',
                        icon: Icons.audio_file,
                        file: audioFile.value,
                        onTap: () async {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            type: FileType.audio,
                          );

                          if (result != null &&
                              result.files.single.path != null) {
                            audioFile.value = File(result.files.single.path!);
                            // Try to extract duration if not provided
                            if (durationController.text.isEmpty) {
                              // Ideally would extract real duration, but simplified for debugging
                              final fileSize = await audioFile.value!.length();
                              // Very rough estimate: 1MB ≈ 1 minute of audio
                              final estimatedDuration =
                                  (fileSize / (1024 * 1024) * 60).round();
                              durationController.text =
                                  estimatedDuration.toString();
                            }
                          }
                        },
                      )),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() => _buildFileSelectionButton(
                        label: 'Cover Image',
                        icon: Icons.image,
                        file: imageFile.value,
                        onTap: () async {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            type: FileType.image,
                          );

                          if (result != null &&
                              result.files.single.path != null) {
                            imageFile.value = File(result.files.single.path!);
                          }
                        },
                      )),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Upload button
            Align(
              alignment: Alignment.centerRight,
              child: Obx(() => ElevatedButton.icon(
                    icon: Icon(Icons.cloud_upload),
                    label: controller.isGeneratingData.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Upload Podcast'),
                    onPressed: (controller.isGeneratingData.value ||
                            audioFile.value == null ||
                            imageFile.value == null ||
                            titleController.text.isEmpty ||
                            descriptionController.text.isEmpty ||
                            durationController.text.isEmpty ||
                            selectedTags.isEmpty)
                        ? null
                        : () async {
                            // Validate input
                            final duration =
                                int.tryParse(durationController.text);
                            if (duration == null) {
                              Get.snackbar(
                                'Error',
                                'Please enter a valid duration in seconds',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            try {
                              controller.isGeneratingData.value = true;

                              final podcast = await controller.uploadPodcast(
                                title: titleController.text,
                                description: descriptionController.text,
                                author: authorController.text,
                                duration: duration,
                                audioFile: audioFile.value!,
                                imageFile: imageFile.value!,
                                tags: selectedTags.toList(),
                                languageCode: selectedLanguage.value,
                              );

                              if (podcast != null) {
                                _showResultDialog(
                                  'Podcast Uploaded',
                                  'Successfully uploaded podcast "${podcast.title}"',
                                );

                                // Clear form
                                titleController.clear();
                                descriptionController.clear();
                                durationController.clear();
                                audioFile.value = null;
                                imageFile.value = null;
                                selectedTags.clear();
                              }
                            } catch (e) {
                              Get.snackbar(
                                'Upload Failed',
                                'Error: ${e.toString()}',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red[100],
                                colorText: Colors.red[900],
                                duration: const Duration(seconds: 5),
                              );
                            } finally {
                              controller.isGeneratingData.value = false;
                            }
                          },
                  )),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for file selection buttons
  Widget _buildFileSelectionButton({
    required String label,
    required IconData icon,
    required File? file,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              file != null ? Icons.check_circle : icon,
              color: file != null ? Colors.green : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              file != null ? file.path.split('/').last : 'Select $label',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: file != null ? Colors.black : Colors.grey.shade700,
                fontWeight: file != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (file != null)
              Text(
                '${(file.lengthSync() / 1024).toStringAsFixed(1)} KB',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showResultDialog(String title, String message) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Helper method for custom map control buttons
  Widget _buildMapButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        tooltip: tooltip,
        onPressed: onPressed,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
      ),
    );
  }
}
