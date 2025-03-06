import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/presentation/widgets/bottom_nav_bar.dart';
import '../controllers/my_cooperatives_controller.dart';

class MyCooperativesScreen extends GetView<MyCooperativesController> {
  const MyCooperativesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cooperatives'),
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder<List<CooperativeWithRole>>(
        stream: controller.cooperativesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final cooperatives = snapshot.data ?? [];

          if (cooperatives.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No cooperatives yet',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Get.toNamed('/create-cooperative'),
                    child: const Text('Create Cooperative'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cooperatives.length,
            itemBuilder: (context, index) {
              final coopWithRole = cooperatives[index];
              return _CooperativeCard(coopWithRole: coopWithRole);
            },
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}

class _CooperativeCard extends StatelessWidget {
  final CooperativeWithRole coopWithRole;

  const _CooperativeCard({
    required this.coopWithRole,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final coop = coopWithRole.cooperative;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        coop.name,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: coopWithRole.role == 'admin'
                            ? theme.colorScheme.primary
                            : theme.colorScheme.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        coopWithRole.role.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  coop.description ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      coop.location,
                      style: theme.textTheme.bodySmall,
                    ),
                    const Spacer(),
                    Text(
                      '${coop.members.length} members',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                if (coop.status == 'unverified') ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Unverified',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Row(
            children: [
              if (coopWithRole.role == 'admin')
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () => Get.toNamed(
                      '/cooperative-management',
                      arguments: coopWithRole,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: theme.dividerColor),
                          right: BorderSide(color: theme.dividerColor),
                        ),
                      ),
                      child: Text(
                        'Manage',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () => Get.toNamed(
                      '/cooperative-details',
                      arguments: coopWithRole,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: theme.dividerColor),
                          right: BorderSide(color: theme.dividerColor),
                        ),
                      ),
                      child: Text(
                        'Details',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                  ),
                ),
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: () => Get.toNamed(
                    '/resource-pool',
                    arguments: {
                      'cooperativeId': coop.id,
                      'cooperativeName': coop.name,
                    },
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: theme.dividerColor),
                      ),
                    ),
                    child: Text(
                      'Open Marketplace',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
