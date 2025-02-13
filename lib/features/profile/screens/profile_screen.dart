import 'package:cropconnect/features/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: controller.nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  enabled: false, // Phone number cannot be edited
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: controller.selectedState.value,
                  decoration: const InputDecoration(labelText: 'State'),
                  items: controller.states.map((state) {
                    return DropdownMenuItem(value: state, child: Text(state));
                  }).toList(),
                  onChanged: (value) {
                    controller.selectedState.value = value;
                    controller.loadCities(value!);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: controller.selectedCity.value,
                  decoration: const InputDecoration(labelText: 'City'),
                  items: controller.cities.map((city) {
                    return DropdownMenuItem(value: city, child: Text(city));
                  }).toList(),
                  onChanged: (value) => controller.selectedCity.value = value,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: controller.soilTypeController.text.isEmpty
                      ? null
                      : controller.soilTypeController.text,
                  decoration: const InputDecoration(labelText: 'Soil Type'),
                  items: controller.soilTypes.map((soil) {
                    return DropdownMenuItem(value: soil, child: Text(soil));
                  }).toList(),
                  onChanged: (value) =>
                      controller.soilTypeController.text = value ?? '',
                ),
                const SizedBox(height: 16),
                const Text('Select Crops:'),
                Wrap(
                  spacing: 8.0,
                  children: controller.availableCrops.map((crop) {
                    return FilterChip(
                      label: Text(crop),
                      selected: controller.selectedCrops.contains(crop),
                      onSelected: (selected) {
                        if (selected) {
                          controller.selectedCrops.add(crop);
                        } else {
                          controller.selectedCrops.remove(crop);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: controller.isUpdating.value
                      ? null
                      : controller.updateProfile,
                  child: Text(controller.isUpdating.value
                      ? 'Updating...'
                      : 'Update Profile'),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
