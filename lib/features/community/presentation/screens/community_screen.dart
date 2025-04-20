import 'package:cropconnect/core/theme/app_colors.dart';
import 'package:cropconnect/features/auth/domain/model/user/user_model.dart';
import 'package:cropconnect/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cropconnect/features/cooperative/domain/models/cooperative_model.dart';
// import 'package:cropconnect/features/cooperative/presentation/screens/cooperative_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/presentation/widgets/bottom_nav_bar.dart';
import '../controllers/community_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CommunityScreen extends GetView<CommunityController> {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations?.community ?? 'Community'),
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() => SegmentedButton<SearchType>(
                        selected: {controller.currentSearchType.value},
                        onSelectionChanged: (Set<SearchType> selection) {
                          controller.switchSearchType(selection.first);
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.resolveWith<Color>((states) {
                            if (states.contains(WidgetState.selected)) {
                              return AppColors.primary;
                            }
                            return Colors.white;
                          }),
                          iconColor:
                              WidgetStateProperty.resolveWith<Color>((states) {
                            if (states.contains(WidgetState.selected)) {
                              return Colors.white;
                            }
                            return AppColors.primary;
                          }),
                          foregroundColor:
                              WidgetStateProperty.resolveWith<Color>((states) {
                            if (states.contains(WidgetState.selected)) {
                              return Colors.white;
                            }
                            return AppColors.primary;
                          }),
                        ),
                        segments: [
                          ButtonSegment<SearchType>(
                            value: SearchType.farmers,
                            label: Text(
                              appLocalizations?.farmers ?? 'Farmers',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            icon: Icon(Icons.person, size: 20),
                          ),
                          ButtonSegment<SearchType>(
                            value: SearchType.cooperatives,
                            label: Text(
                              appLocalizations?.cooperatives ?? 'Cooperatives',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            icon: Icon(Icons.groups, size: 20),
                          ),
                        ],
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: controller.updateSearchQuery,
              decoration: InputDecoration(
                hintText: appLocalizations?.search ?? 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: controller.currentSearchType.value == SearchType.farmers
                    ? _buildFarmersList(context)
                    : _buildCooperativesList(context),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildFarmersList(context) {
    final theme = Theme.of(context);

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return ListView.builder(
        itemCount: controller.farmers.length,
        itemBuilder: (context, index) {
          final farmer = controller.farmers[index];
          return Hero(
            tag: 'farmer-${farmer.id}',
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: InkWell(
                onTap: () => _showFarmerDetails(context, farmer),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor:
                            theme.colorScheme.primary.withOpacity(0.1),
                        child: Text(
                          farmer.name[0].toUpperCase(),
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              farmer.name,
                              style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  size: 16,
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.7),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  farmer.phoneNumber,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.chevron_right,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildCooperativesList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return ListView.builder(
        itemCount: controller.cooperatives.length,
        itemBuilder: (context, index) {
          final cooperative = controller.cooperatives[index];
          return Hero(
            tag: 'cooperative-${cooperative.id}',
            child: Card(
              elevation: 0,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                onTap: () => _showCooperativeDetails(context, cooperative),
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.groups, color: Colors.white),
                ),
                title: Text(cooperative.name),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          );
        },
      );
    });
  }

  void _showFarmerDetails(BuildContext context, UserModel farmer) {
    final theme = Theme.of(context);
    final appLocalizations = AppLocalizations.of(context);

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Farmer name and avatar
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      farmer.name[0].toUpperCase(),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          farmer.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${appLocalizations?.memberSince ?? 'Member since'} ${_formatDate(farmer.createdAt)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Contact Information
              _buildSectionTitle(
                  theme,
                  appLocalizations?.contactInformation ??
                      'Contact Information'),
              const SizedBox(height: 8),
              _buildDetailItem(
                theme,
                Icons.phone,
                appLocalizations?.phone ?? 'Phone',
                farmer.phoneNumber,
              ),
              const SizedBox(height: 24),

              // Location Information
              if (farmer.state != null || farmer.city != null) ...[
                _buildSectionTitle(
                    theme, appLocalizations?.location ?? 'Location'),
                const SizedBox(height: 8),
                if (farmer.city != null)
                  _buildDetailItem(
                    theme,
                    Icons.location_city,
                    appLocalizations?.city ?? 'City',
                    farmer.city!,
                  ),
                if (farmer.state != null) ...[
                  const SizedBox(height: 8),
                  _buildDetailItem(
                    theme,
                    Icons.map,
                    appLocalizations?.state ?? 'State',
                    farmer.state!,
                  ),
                ],
                const SizedBox(height: 24),
              ],

              // Farming Details
              _buildSectionTitle(
                  theme, appLocalizations?.farmingDetails ?? 'Farming Details'),
              const SizedBox(height: 8),
              if (farmer.soilType != null)
                _buildDetailItem(
                  theme,
                  Icons.landscape,
                  appLocalizations?.soilType ?? 'Soil Type',
                  farmer.soilType!,
                ),

              // Crops Section
              if (farmer.crops != null && farmer.crops!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSectionTitle(theme, appLocalizations?.crops ?? 'Crops'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: farmer.crops!
                      .map((crop) => Chip(
                            label: Text(crop),
                            backgroundColor:
                                theme.colorScheme.primary.withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ))
                      .toList(),
                ),
              ],

              const SizedBox(height: 32),

              // Message Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement messaging functionality
                    Get.snackbar(
                      appLocalizations?.comingSoon ?? 'Coming Soon',
                      appLocalizations?.messagingFeature ??
                          'Messaging feature will be available soon!',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  icon: const Icon(Icons.message_rounded),
                  label:
                      Text(appLocalizations?.messageUser ?? 'Message Farmer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  void _showCooperativeDetails(
      BuildContext context, CooperativeModel cooperative) {
    final theme = Theme.of(context);
    final appLocalizations = AppLocalizations.of(context);

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ElevatedButton(
              //   onPressed: () => Get.to(
              //       () => CooperativeMapScreen(cooperative: cooperative)),
              //   child: const Text('View on Map'),
              // ),
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.colorScheme.primary,
                    child:
                        const Icon(Icons.groups, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cooperative.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${appLocalizations?.memberSince ?? 'Created'} ${_formatDate(cooperative.createdAt)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Description section
              if (cooperative.description?.isNotEmpty ?? false) ...[
                _buildSectionTitle(theme, appLocalizations?.about ?? 'About'),
                const SizedBox(height: 8),
                Text(
                  cooperative.description!,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
              ],

              // Location section
              _buildSectionTitle(
                  theme, appLocalizations?.location ?? 'Location'),
              const SizedBox(height: 8),
              _buildDetailItem(
                theme,
                Icons.location_on,
                appLocalizations?.location ?? 'Address',
                cooperative.location,
              ),
              const SizedBox(height: 8),

              // Members section
              _buildSectionTitle(
                  theme, appLocalizations?.memberSince ?? 'Membership'),
              const SizedBox(height: 8),
              _buildDetailItem(
                theme,
                Icons.group,
                appLocalizations?.totalMembers ?? 'Total Members',
                cooperative.members.length.toString(),
              ),
              const SizedBox(height: 8),
              _buildDetailItem(
                theme,
                Icons.admin_panel_settings,
                appLocalizations?.admin ?? 'Admin',
                cooperative.createdBy,
              ),
              const SizedBox(height: 32),

              // Join button if not a member
              if (!cooperative.members
                  .contains(Get.find<AuthController>().user.value?.id))
                SizedBox(
                  width: double.infinity,
                  child: Obx(() => ElevatedButton(
                        onPressed: controller.isJoiningCoop.value
                            ? null
                            : () => controller.requestToJoin(cooperative),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: controller.isJoiningCoop.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                appLocalizations?.joinCooperative ??
                                    'Join Cooperative',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      )),
                ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  Widget _buildDetailItem(
      ThemeData theme, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ],
    );
  }

  // Helper method to format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Helper method for section titles
  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }
}
