import 'package:cropconnect/features/cooperative/presentation/controllers/cooperative_management_controller.dart';
import 'package:cropconnect/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Add this import
import '../../../auth/domain/model/user/user_model.dart';

class MemberDetailsDialog extends StatelessWidget {
  final UserModel member;
  final bool isCurrentUser;
  final bool isAdmin;
  final String cooperativeId;
  final VoidCallback? onKickSuccess;

  const MemberDetailsDialog({
    Key? key,
    required this.member,
    required this.isCurrentUser,
    required this.isAdmin,
    required this.cooperativeId,
    this.onKickSuccess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAdmin && !isCurrentUser) ...[
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(
                    LucideIcons.userX2,
                    color: theme.colorScheme.error,
                    size: 28,
                  ),
                  onPressed: () => _showKickConfirmation(context),
                  tooltip: 'Remove Member',
                ),
              ),
            ],
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Text(
                    member.name[0].toUpperCase(),
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
                        member.name,
                        style: theme.textTheme.titleLarge,
                      ),
                      Text(
                        member.phoneNumber,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoSection(
              theme,
              'Location',
              '${member.city ?? 'Unknown'}, ${member.state ?? 'Unknown'}',
            ),
            if (member.crops?.isNotEmpty ?? false) ...[
              const SizedBox(height: 16),
              _buildInfoSection(
                theme,
                'Crops',
                member.crops!.join(', '),
              ),
            ],
            if (member.soilType != null) ...[
              const SizedBox(height: 16),
              _buildInfoSection(
                theme,
                'Soil Type',
                member.soilType!,
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(ThemeData theme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }

  void _showKickConfirmation(BuildContext context) {
    final controller = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Remove Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This action cannot be undone. To confirm, please type:',
              style: Get.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              member.name,
              style: Get.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Type member name here',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim() == member.name) {
                AppLogger.info('Kicking member: ${member.name}');
                _kickMember(context);
              } else {
                Get.snackbar(
                  'Error',
                  'Name does not match',
                  backgroundColor: Get.theme.colorScheme.error,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.error,
            ),
            child: Text('Remove Member'),
          ),
        ],
      ),
    );
  }

  Future<void> _kickMember(BuildContext context) async {
    try {
      final controller = Get.find<CooperativeManagementController>();
      await controller.kickMember(member.id);
      AppLogger.debug('Member removed: ${member.name}: Closing dialogs');

      Navigator.of(context).pop();
      Navigator.of(context).pop();

      Future.delayed(const Duration(milliseconds: 300), () {
        Get.snackbar(
          'Success',
          '${member.name} has been removed from the cooperative',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primaryContainer,
          colorText: Get.theme.colorScheme.onPrimaryContainer,
          duration: const Duration(seconds: 3),
        );
      });

      // Call success callback if provided
      if (onKickSuccess != null) onKickSuccess!();
    } catch (e) {
      AppLogger.error('Failed to remove member: $e');
      Get.snackbar(
        'Error',
        'Failed to remove member: ${e.toString()}',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
