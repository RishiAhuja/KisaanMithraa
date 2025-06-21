// profile_screen.dart
import 'package:cropconnect/core/presentation/widgets/bottom_nav_bar.dart';
import 'package:cropconnect/core/presentation/widgets/common_app_bar.dart';
import 'package:cropconnect/features/auth/domain/model/user/user_model.dart';
import 'package:cropconnect/features/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cropconnect/core/services/locale/locale_service.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localeService = Get.find<LocaleService>();

    return Scaffold(
      appBar: CommonAppBar(
        title: 'Profile',
        showProfileIcon: false, // Don't show profile icon on profile screen
        customActions: [
          Obx(() => IconButton(
                icon: Icon(
                    controller.isEditMode.value ? Icons.close : Icons.edit),
                tooltip:
                    controller.isEditMode.value ? 'Cancel' : 'Edit Profile',
                onPressed: controller.toggleEditMode,
              )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text("Loading your profile...",
                    style: theme.textTheme.bodyMedium),
              ],
            ),
          );
        }

        final user = controller.user.value;
        if (user == null) return const SizedBox();

        return Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildProfileHeader(user, theme),
              const SizedBox(height: 24),
              _buildSectionCard(
                title: 'Location',
                theme: theme,
                children: [
                  controller.isEditMode.value
                      ? _buildStateDropdown(theme)
                      : _buildInfoRow(
                          icon: Icons.location_on,
                          label: 'State',
                          value: user.state ?? 'Not specified',
                          theme: theme,
                        ),
                  const SizedBox(height: 16),
                  controller.isEditMode.value
                      ? _buildCityDropdown(theme)
                      : _buildInfoRow(
                          icon: Icons.location_city,
                          label: 'City/District',
                          value: user.city ?? 'Not specified',
                          theme: theme,
                        ),
                ],
              ),

              const SizedBox(height: 16),

              // Farming Details
              _buildSectionCard(
                title: 'Farming Details',
                theme: theme,
                children: [
                  if (controller.isEditMode.value)
                    _buildSoilTypeDropdown(theme)
                  else
                    _buildEnhancedSoilTypeDisplay(user.soilType, theme),
                  const SizedBox(height: 20),
                  if (controller.isEditMode.value)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.agriculture_outlined,
                                size: 18, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Select Your Crops',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildEnhancedCropSelection(theme),
                      ],
                    )
                  else
                    _buildEnhancedCropDisplay(user.crops, theme),
                ],
              ),

              const SizedBox(height: 16),

              // Preferences
              _buildSectionCard(
                title: 'Preferences',
                theme: theme,
                children: [
                  Text('Language', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  _buildLanguageSelector(localeService, theme),
                ],
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() => controller.isEditMode.value
          ? _buildEditModeBottomBar(context, theme)
          : const BottomNavBar(currentIndex: 5)), // sentinel number
    );
  }

  Widget _buildProfileHeader(UserModel user, ThemeData theme) {
    final initials = user.name.isNotEmpty
        ? user.name
            .split(' ')
            .map((part) => part.isNotEmpty ? part[0].toUpperCase() : '')
            .join()
            .substring(0, user.name.split(' ').length > 1 ? 2 : 1)
        : 'F';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Fixed size avatar with gradient
            Container(
              width: 56, // Slightly smaller
              height: 56, // Slightly smaller
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22, // Slightly smaller
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12), // Reduced spacing

            // User details with proper constraints
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4), // Reduced spacing
                  Row(
                    children: [
                      Icon(Icons.phone_android_rounded,
                          size: 14, // Smaller icon
                          color: theme.colorScheme.primary.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          user.phoneNumber,
                          style: theme.textTheme.bodySmall?.copyWith(
                            // Smaller text
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (user.state != null || user.city != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4), // Reduced spacing
                      child: Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 14, // Smaller icon
                              color:
                                  theme.colorScheme.primary.withOpacity(0.7)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              [
                                if (user.city != null && user.city!.isNotEmpty)
                                  user.city,
                                if (user.state != null &&
                                    user.state!.isNotEmpty)
                                  user.state,
                              ].join(', '),
                              style: theme.textTheme.bodySmall?.copyWith(
                                // Smaller text
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
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

            // Edit button - more compact
            if (!controller.isEditMode.value)
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  color: theme.colorScheme.primary,
                  size: 18, // Smaller icon
                ),
                onPressed: controller.toggleEditMode,
                tooltip: 'Edit Profile',
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required ThemeData theme,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            Divider(color: theme.colorScheme.primary.withOpacity(0.2)),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.grey[600])),
              Text(value, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStateDropdown(ThemeData theme) {
    return DropdownButtonFormField<String>(
      value: controller.selectedState.value,
      decoration: InputDecoration(
        labelText: 'State',
        prefixIcon: Icon(Icons.location_on, color: theme.colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: controller.states
          .map((state) => DropdownMenuItem(value: state, child: Text(state)))
          .toList(),
      onChanged: (value) => controller.selectedState.value = value,
      validator: (value) =>
          value == null || value.isEmpty ? 'Please select your state' : null,
    );
  }

  Widget _buildCityDropdown(ThemeData theme) {
    return Obx(() {
      final cities = controller.cities;
      final selectedCity = controller.selectedCity.value;
      final effectiveValue =
          cities.contains(selectedCity) ? selectedCity : null;

      return DropdownButtonFormField<String>(
        value: effectiveValue,
        decoration: InputDecoration(
          labelText: 'City/District',
          prefixIcon:
              Icon(Icons.location_city, color: theme.colorScheme.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          hintText: cities.isEmpty
              ? 'Select a state first'
              : 'Select your city/district',
        ),
        items: cities
            .map((city) => DropdownMenuItem(value: city, child: Text(city)))
            .toList(),
        onChanged: cities.isEmpty
            ? null
            : (value) => controller.selectedCity.value = value,
        validator: (value) => controller.selectedState.value != null &&
                cities.isNotEmpty &&
                (value == null || value.isEmpty)
            ? 'Please select your city/district'
            : null,
      );
    });
  }

  Widget _buildSoilTypeDropdown(ThemeData theme) {
    return DropdownButtonFormField<String>(
      value: controller.soilTypeController.text.isEmpty
          ? null
          : controller.soilTypeController.text,
      decoration: InputDecoration(
        labelText: 'Soil Type',
        prefixIcon:
            Icon(Icons.grass_outlined, color: theme.colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: controller.soilTypes
          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
          .toList(),
      onChanged: (value) => controller.soilTypeController.text = value ?? '',
    );
  }

  Widget _buildLanguageSelector(LocaleService localeService, ThemeData theme) {
    return Column(
      children: [
        _buildLanguageOption(
            'English', 'en', localeService.currentLocale.value, theme,
            onTap: () => localeService.changeLocale('en')),
        Divider(color: theme.colorScheme.outline.withOpacity(0.3)),
        _buildLanguageOption(
            'हिंदी', 'hi', localeService.currentLocale.value, theme,
            onTap: () => localeService.changeLocale('hi')),
        Divider(color: theme.colorScheme.outline.withOpacity(0.3)),
        _buildLanguageOption(
            'ਪੰਜਾਬੀ', 'pa', localeService.currentLocale.value, theme,
            onTap: () => localeService.changeLocale('pa')),
      ],
    );
  }

  Widget _buildLanguageOption(
      String label, String code, String currentLocale, ThemeData theme,
      {required VoidCallback onTap}) {
    final isSelected = currentLocale == code;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : null,
        child: Row(
          children: [
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isSelected ? theme.colorScheme.primary : null,
                fontWeight: isSelected ? FontWeight.bold : null,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditModeBottomBar(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Cancel button
          Expanded(
            child: OutlinedButton(
              onPressed:
                  controller.isUpdating.value ? null : controller.cancelEdit,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: theme.colorScheme.primary,
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),

          // Update button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: controller.isUpdating.value
                  ? null
                  : () {
                      controller.updateProfile().then((_) {
                        if (!controller.isUpdating.value) {
                          Get.snackbar(
                            'Success',
                            'Profile updated successfully',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                          );
                          controller.toggleEditMode(); // Return to view mode
                        }
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: controller.isUpdating.value
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Updating...'),
                      ],
                    )
                  : const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSoilTypeDisplay(String? soilType, ThemeData theme) {
    if (soilType == null || soilType.isEmpty) {
      return _buildEmptyInfoCard(
        icon: Icons.landscape,
        title: 'Soil Type',
        message: 'No soil type specified',
        theme: theme,
      );
    }

    // Map of soil types to their descriptions and colors
    final soilInfo = {
      'Alluvial Soil': {
        'description': 'Rich in nutrients, good for most crops',
        'color': Colors.brown[300]!,
      },
      'Black Soil': {
        'description': 'Great for cotton and sugar cane',
        'color': Colors.brown[900]!,
      },
      'Red Soil': {
        'description': 'Suitable for groundnuts and millet',
        'color': Colors.red[300]!,
      },
      'Laterite Soil': {
        'description': 'Good for plantation crops like tea and coffee',
        'color': Colors.orange[400]!,
      },
      'Desert Soil': {
        'description': 'With irrigation, good for drought-resistant crops',
        'color': Colors.amber[200]!,
      },
    };

    final info = soilInfo[soilType] ??
        {
          'description': 'Suitable for various crops',
          'color': Colors.brown[400]!,
        };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: info['color'] as Color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.grass_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Soil Type',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  soilType,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  info['description'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedCropSelection(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select the crops you grow',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => Wrap(
                spacing: 8.0,
                runSpacing: 12.0,
                children: controller.availableCrops.map((crop) {
                  final isSelected = controller.selectedCrops.any((selected) =>
                      selected.toLowerCase() == crop.toLowerCase());

                  // Map crops to their icons (simplistic mapping for example)
                  IconData getCropIcon(String crop) {
                    switch (crop.toLowerCase()) {
                      case 'wheat':
                        return Icons.grass;
                      case 'rice':
                        return Icons.grain;
                      case 'maize':
                        return Icons.agriculture;
                      case 'bajra':
                        return Icons.spa;
                      case 'jowar':
                        return Icons.grass_outlined;
                      case 'cotton':
                        return Icons.ac_unit;
                      default:
                        return Icons.local_florist;
                    }
                  }

                  return FilterChip(
                    avatar: Icon(
                      getCropIcon(crop),
                      size: 18,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    label: Text(crop),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        if (!controller.selectedCrops.any((selected) =>
                            selected.toLowerCase() == crop.toLowerCase())) {
                          controller.selectedCrops.add(crop);
                        }
                      } else {
                        controller.selectedCrops.removeWhere((selected) =>
                            selected.toLowerCase() == crop.toLowerCase());
                      }
                    },
                    showCheckmark: false,
                    selectedColor: theme.colorScheme.primary.withOpacity(0.15),
                    backgroundColor: theme.colorScheme.surface,
                    side: BorderSide(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withOpacity(0.3),
                      width: isSelected ? 1.5 : 1,
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }

  Widget _buildEnhancedCropDisplay(List<String>? crops, ThemeData theme) {
    if (crops == null || crops.isEmpty) {
      return _buildEmptyInfoCard(
        icon: Icons.agriculture_outlined,
        title: 'Crops',
        message: 'No crops specified. Edit your profile to add crops.',
        theme: theme,
      );
    }

    // Map crop names to their icons and colors (simplified example)
    IconData getCropIcon(String crop) {
      switch (crop.toLowerCase()) {
        case 'wheat':
          return Icons.grass;
        case 'rice':
          return Icons.grain;
        case 'maize':
          return Icons.agriculture;
        case 'bajra':
          return Icons.spa;
        case 'jowar':
          return Icons.grass_outlined;
        case 'cotton':
          return Icons.ac_unit;
        default:
          return Icons.local_florist;
      }
    }

    Color getCropColor(String crop, ThemeData theme) {
      switch (crop.toLowerCase()) {
        case 'wheat':
          return Colors.amber[700]!;
        case 'rice':
          return Colors.lightGreen[700]!;
        case 'maize':
          return Colors.yellow[800]!;
        case 'bajra':
          return Colors.brown[300]!;
        case 'jowar':
          return Colors.brown[500]!;
        case 'cotton':
          return Colors.blue[300]!;
        default:
          return theme.colorScheme.primary;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.agriculture_outlined,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Your Crops',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: crops.length,
          itemBuilder: (context, index) {
            final crop = crops[index];
            final cropColor = getCropColor(crop, theme);

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: cropColor.withOpacity(0.1),
                border: Border.all(
                  color: cropColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    getCropIcon(crop),
                    color: cropColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      crop,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyInfoCard({
    required IconData icon,
    required String title,
    required String message,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
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
