import 'package:cropconnect/features/auth/domain/model/user_model.dart';
import 'package:cropconnect/features/home/presentation/provider/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Get.toNamed('/profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Obx(() {
            final user = controller.user.value;
            if (user == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${user.name}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  _buildInfoCard(
                    context,
                    title: 'Personal Information',
                    items: {
                      'Phone': user.phoneNumber,
                      'Member since': user.createdAt.toString().split(' ')[0],
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    context,
                    title: 'Farm Details',
                    items: {
                      'Soil Type': user.soilType ?? 'Not specified',
                      'Location': _formatLocation(user),
                      'Crops': _formatCrops(user.crops),
                    },
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required Map<String, String> items,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...items.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.key}: ',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Expanded(
                        child: Text(entry.value),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  String _formatLocation(UserModel user) {
    if (user.city != null && user.state != null) {
      return '${user.city}, ${user.state}';
    }
    return 'Location not set';
  }

  String _formatCrops(List<String>? crops) {
    if (crops == null || crops.isEmpty) {
      return 'No crops specified';
    }
    return crops.join(', ');
  }
}
