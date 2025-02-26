import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import '../../../auth/domain/model/user/user_model.dart';

class MemberSelectionWidget extends StatelessWidget {
  final String title;
  final RxList<UserModel> selectedMembers;
  final Function(UserModel) onMemberRemoved;
  final VoidCallback onAddTapped;
  final bool showMinimumText;

  const MemberSelectionWidget({
    super.key,
    required this.title,
    required this.selectedMembers,
    required this.onMemberRemoved,
    required this.onAddTapped,
    this.showMinimumText = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Obx(() {
            final members =
                selectedMembers.toList(); // Create local copy for ListView
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: members.length + 1,
              itemBuilder: (context, index) {
                if (index == members.length) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          theme.colorScheme.primary.withOpacity(0.1),
                      child: Icon(Icons.add, color: theme.colorScheme.primary),
                    ),
                    title: const Text('Add Member'),
                    onTap: onAddTapped,
                  );
                }

                final member = members[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Text(member.name[0].toUpperCase()),
                  ),
                  title: Text(member.name),
                  subtitle: Text(member.phoneNumber),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    color: theme.colorScheme.error,
                    onPressed: () => onMemberRemoved(member),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
