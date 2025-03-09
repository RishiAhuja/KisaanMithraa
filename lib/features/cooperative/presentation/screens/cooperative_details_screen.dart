import 'package:cached_network_image/cached_network_image.dart';
import 'package:cropconnect/core/theme/app_colors.dart';
import 'package:cropconnect/features/auth/domain/model/user/user_model.dart';
import 'package:cropconnect/features/cooperative/domain/models/cooperative_model.dart';
import 'package:cropconnect/features/cooperative/presentation/controllers/cooperative_details_controller.dart';
import 'package:cropconnect/features/cooperative/presentation/widgets/crop_marque.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class CooperativeDetailsScreen extends GetView<CooperativeDetailsController> {
  const CooperativeDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Details'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final coop = controller.cooperative.value!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (coop.bannerUrl != null && coop.bannerUrl!.isNotEmpty)
                Container(
                  height: 220,
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: coop.bannerUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: theme.colorScheme.surfaceVariant,
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: theme.colorScheme.primary),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: theme.colorScheme.surfaceVariant,
                            child: Icon(Icons.image_not_supported, size: 40),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.2),
                              Colors.black.withOpacity(0.8),
                            ],
                            stops: [0.4, 1.0],
                          ),
                        ),
                      ),
                      // Status tag - positioned at top right
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: coop.status.toLowerCase() == 'verified'
                                ? Colors.green.withOpacity(0.9)
                                : Colors.orange.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                coop.status.toLowerCase() == 'verified'
                                    ? Icons.verified
                                    : Icons.pending,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                coop.status.toUpperCase(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Content - positioned at bottom
                      Positioned(
                        left: 16,
                        bottom: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              coop.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    blurRadius: 4,
                                    color: Colors.black.withOpacity(0.5),
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (coop.description != null &&
                                coop.description!.isNotEmpty)
                              Text(
                                coop.description!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.white.withOpacity(0.9),
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    coop.location,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  height: 160,
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: theme.colorScheme.surfaceVariant,
                  ),
                  child: Stack(
                    children: [
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              theme.colorScheme.surfaceVariant,
                              theme.colorScheme.surfaceVariant.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: coop.status.toLowerCase() == 'verified'
                                ? Colors.green.withOpacity(0.9)
                                : Colors.orange.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                coop.status.toLowerCase() == 'verified'
                                    ? Icons.verified
                                    : Icons.pending,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                coop.status.toUpperCase(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Icon overlay
                      Center(
                        child: Icon(
                          Icons.business,
                          size: 60,
                          color: theme.colorScheme.onSurfaceVariant
                              .withOpacity(0.3),
                        ),
                      ),
                      // Content - positioned at bottom
                      Positioned(
                        left: 16,
                        bottom: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              coop.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 6),
                            if (coop.description != null &&
                                coop.description!.isNotEmpty)
                              Text(
                                coop.description!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withOpacity(0.8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withOpacity(0.8),
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    coop.location,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant
                                          .withOpacity(0.8),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              _buildCropsMarquee(coop.cropTypes, theme),
              SizedBox(height: 8),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        clipBehavior: Clip.hardEdge,
                        elevation: 1,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${coop.members.length}',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('Members', style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Card(
                        clipBehavior: Clip.hardEdge,
                        elevation: 1,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Obx(
                                () => controller.isLoadingListings.value
                                    ? SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : Text(
                                        '${controller.resourceListingsCount.value}',
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 4),
                              Text('Listings',
                                  style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Card(
                        clipBehavior: Clip.hardEdge,
                        elevation: 1,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${coop.cropTypes.length}',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('Crop Types',
                                  style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              if (controller.role.value == 'viewer')
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 16),
                  child: ElevatedButton.icon(
                    onPressed: controller.isRequestingJoin.value
                        ? null
                        : () => controller.requestToJoin(),
                    icon: controller.isRequestingJoin.value
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white70,
                            ),
                          )
                        : Icon(Icons.person_add, size: 20),
                    label: Text(
                      controller.isRequestingJoin.value
                          ? 'Sending Request...'
                          : 'Join This Cooperative',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              _buildAdminContactCard(coop, theme, context),
              SizedBox(height: 8),
              controller.role.value == 'viewer'
                  ? _buildMembersPreview(coop, theme)
                  : _buildMembersSection(coop, theme),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCropsMarquee(List<String> crops, ThemeData theme) {
    if (crops.isEmpty) return SizedBox.shrink();

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CropMarquee(crops: crops, theme: theme),
    );
  }

  Widget _buildAdminContactCard(
      CooperativeModel coop, ThemeData theme, BuildContext context) {
    final adminId = coop.createdBy;
    final adminMember =
        controller.members.firstWhereOrNull((member) => member.id == adminId);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cooperative Admin',
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(adminMember?.name.isNotEmpty == true
                      ? adminMember!.name[0]
                      : 'A'),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        adminMember?.name ?? 'Admin',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (adminMember?.phoneNumber != null)
                        Text(
                          adminMember!.phoneNumber,
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _launchDialer(adminMember),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  icon: Icon(Icons.phone,
                      color: AppColors.backgroundLight, size: 18),
                  label: Text('Call',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: AppColors.backgroundLight)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _launchDialer(UserModel? admin) async {
    if (admin == null || admin.phoneNumber.isEmpty) {
      Get.snackbar(
        'Contact Error',
        'Admin contact information not available',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
      return;
    }

    final phoneNumber = admin.phoneNumber;
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        Get.snackbar(
          'Call Failed',
          'Could not launch phone dialer',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to make call: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    }
  }

  Widget _buildMembersPreview(CooperativeModel coop, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Members',
                  style: theme.textTheme.titleLarge,
                ),
                Text(
                  'Join to see all',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 40,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  for (int i = 0; i < coop.members.length.clamp(0, 5); i++)
                    Positioned(
                      left: i * 24.0,
                      child: _buildMemberAvatar(i, theme),
                    ),
                  if (coop.members.length > 5)
                    Positioned(
                      left: 5 * 24.0,
                      child: CircleAvatar(
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        child: Text(
                          '+${coop.members.length - 5}',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberAvatar(int index, ThemeData theme) {
    // Colors for avatar background
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      theme.colorScheme.error,
      Colors.teal,
    ];

    if (index < controller.members.length) {
      final member = controller.members[index];
      final isAdmin = member.id == controller.cooperative.value!.createdBy;

      final initial =
          member.name.isNotEmpty ? member.name[0].toUpperCase() : '?';

      return CircleAvatar(
        backgroundColor:
            isAdmin ? theme.colorScheme.primary : colors[index % colors.length],
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return CircleAvatar(
      backgroundColor: colors[index % colors.length],
      child: Text(
        '?',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMembersSection(CooperativeModel coop, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Members',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.members.length,
              itemBuilder: (context, index) {
                final member = controller.members[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(member.name[0]),
                  ),
                  title: Text(member.name),
                  subtitle: Text(member.crops?.join(', ') ?? ''),
                  trailing: Text(
                    member.id == controller.cooperative.value!.createdBy
                        ? 'Admin'
                        : 'Member',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          member.id == controller.cooperative.value!.createdBy
                              ? theme.colorScheme.primary
                              : theme.colorScheme.secondary,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
