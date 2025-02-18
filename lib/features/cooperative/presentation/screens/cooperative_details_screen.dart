import 'package:cropconnect/features/cooperative/presentation/controllers/cooperative_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CooperativeDetailsScreen extends GetView<CooperativeDetailsController> {
  const CooperativeDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(controller.cooperative.value?.name ?? ''),
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About Cooperative',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        coop.description ?? "",
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Location', coop.location, theme),
                      _buildInfoRow('Status', coop.status.toUpperCase(), theme),
                      _buildInfoRow('Members', '${coop.members.length}', theme),
                      _buildInfoRow('Crops', coop.cropTypes.join(', '), theme),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildMembersSection(theme),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMembersSection(ThemeData theme) {
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

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
