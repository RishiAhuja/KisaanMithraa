import 'package:cropconnect/core/theme/app_colors.dart';
import 'package:cropconnect/core/presentation/widgets/common_app_bar.dart';
import 'package:cropconnect/features/cooperative/presentation/controllers/cooperative_management_controller.dart';
import 'package:cropconnect/features/cooperative/presentation/widgets/member_details_dialog.dart';
import 'package:cropconnect/features/cooperative/presentation/widgets/member_search_dialog.dart';
import 'package:cropconnect/features/cooperative/presentation/widgets/member_selection_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CooperativeManagementScreen
    extends GetView<CooperativeManagementController> {
  const CooperativeManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CommonAppBar(
        title: 'Manage ${controller.cooperative.value?.name ?? 'Cooperative'}',
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value != null) {
          return Center(child: Text(controller.error.value!));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(theme),
              const SizedBox(height: 16),
              _buildMembersSection(theme),
              const SizedBox(height: 16),
              _buildPendingInvitesSection(theme),
              const SizedBox(height: 16),
              MemberSelectionWidget(
                title: 'Invite New Members',
                selectedMembers: controller.selectedMembers,
                onMemberRemoved: (member) =>
                    controller.selectedMembers.remove(member),
                onAddTapped: () => _showMemberSearchDialog(context),
              ),
              const SizedBox(height: 16),
              Obx(() => ElevatedButton.icon(
                    onPressed: controller.selectedMembers.isEmpty
                        ? null
                        : () => controller.inviteMembers(),
                    icon: controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send,
                            color: AppColors.backgroundLight),
                    label: Text(
                      'Send ${controller.selectedMembers.length} Invites',
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  )),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatusCard(ThemeData theme) {
    final coop = controller.cooperative.value!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cooperative Status',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _buildStatusRow('Status', coop.status.toUpperCase(), theme),
            _buildStatusRow('Members', '${coop.members.length}', theme),
            _buildStatusRow(
              'Pending Invites',
              '${coop.pendingInvites.length}',
              theme,
            ),
            if (coop.status == 'unverified')
              _buildStatusRow(
                'Required Members',
                '${coop.verificationRequirements.minimumMembers}',
                theme,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersSection(ThemeData theme) {
    final currentUserId = controller.cooperative.value!.createdBy;

    return Column(
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
            final isAdmin = member.id == currentUserId;

            return ListTile(
              onTap: isAdmin
                  ? null
                  : () => Get.dialog(
                        MemberDetailsDialog(
                          member: member,
                          isCurrentUser: member.id == currentUserId,
                          isAdmin: true,
                          cooperativeId: controller.cooperative.value!.id,
                          onKickSuccess: () => controller.loadMembers(),
                        ),
                      ),
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Text(
                  member.name[0].toUpperCase(),
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              title: Text(member.name),
              subtitle: Text(member.phoneNumber),
              trailing: Text(
                isAdmin ? 'Admin' : 'Member',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isAdmin
                      ? theme.colorScheme.primary
                      : theme.colorScheme.secondary,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(value, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }

  void _showMemberSearchDialog(BuildContext context) {
    Get.dialog(
      MemberSearchDialog(
        onSearch: controller.searchMembers,
        searchResults: controller.searchResults,
        onMemberSelected: (user) {
          controller.addSelectedMember(user);
        },
      ),
    );
  }

  Widget _buildPendingInvitesSection(ThemeData theme) {
    // Filter only pending invites
    final pendingInvites = controller.cooperative.value!.pendingInvites
        .where((invite) => invite.status == 'pending')
        .toList();

    if (pendingInvites.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pending Invites',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pendingInvites.length,
          itemBuilder: (context, index) {
            final invite = pendingInvites[index];

            return FutureBuilder(
              future: controller.getUserDetails(invite.userId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const ListTile(
                    leading: CircleAvatar(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    title: LinearProgressIndicator(),
                  );
                }

                final user = snapshot.data!;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        theme.colorScheme.secondary.withOpacity(0.1),
                    child: Text(
                      user.name[0].toUpperCase(),
                      style: TextStyle(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.phoneNumber),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Pending',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
