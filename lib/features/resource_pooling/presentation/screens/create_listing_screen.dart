import 'package:cropconnect/core/services/hive/hive_storage_service.dart';
import 'package:cropconnect/features/resource_pooling/domain/resouce_listing_model.dart';
import 'package:cropconnect/features/resource_pooling/presentation/controller/resource_pooling_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CreateListingScreen extends GetView<ResourcePoolingController> {
  const CreateListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Listing'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<ListingType>(
                        decoration: const InputDecoration(
                          labelText: 'Listing Type',
                          border: OutlineInputBorder(),
                        ),
                        items: ListingType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.name.capitalize!),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            controller.listingType.value = value,
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a listing type';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<TransactionType>(
                        decoration: const InputDecoration(
                          labelText: 'Transaction Type',
                          border: OutlineInputBorder(),
                        ),
                        items: TransactionType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.name.capitalize!),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            controller.transactionType.value = value,
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a transaction type';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: controller.titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: controller.descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: controller.quantityController,
                              decoration: const InputDecoration(
                                labelText: 'Quantity',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) return 'Required';
                                if (int.tryParse(value!) == null) {
                                  return 'Invalid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: controller.unitController,
                              decoration: const InputDecoration(
                                labelText: 'Unit',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) return 'Required';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: controller.priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price per unit (₹)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Required';
                          if (double.tryParse(value!) == null) {
                            return 'Invalid price';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Availability',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () =>
                                  controller.selectAvailableFrom(context),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'From',
                                  border: OutlineInputBorder(),
                                ),
                                child: Obx(
                                  () => Text(
                                    controller.availableFrom.value != null
                                        ? DateFormat('dd MMM yyyy').format(
                                            controller.availableFrom.value!)
                                        : 'Select Date',
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Obx(() {
                              return controller.transactionType.value ==
                                      TransactionType.rent
                                  ? InkWell(
                                      onTap: () =>
                                          controller.selectAvailableTo(context),
                                      child: InputDecorator(
                                        decoration: const InputDecoration(
                                          labelText: 'To',
                                          border: OutlineInputBorder(),
                                        ),
                                        child: Text(
                                          controller.availableTo.value != null
                                              ? DateFormat('dd MMM yyyy')
                                                  .format(controller
                                                      .availableTo.value!)
                                              : 'Select Date',
                                        ),
                                      ),
                                    )
                                  : const SizedBox();
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () async {
                  if (!controller.formKey.currentState!.validate()) {
                    return;
                  }

                  final args = Get.arguments as Map<String, dynamic>?;
                  final cooperativeId = args?['cooperativeId'] as String?;

                  if (cooperativeId == null) {
                    Get.snackbar('Error', 'Cooperative ID not found');
                    return;
                  }

                  final user = await Get.find<UserStorageService>().getUser();
                  if (user == null) {
                    Get.snackbar('Error', 'User not found');
                    return;
                  }

                  final listing = ResourceListing(
                    id: '',
                    cooperativeId: cooperativeId,
                    userId: user.id,
                    title: controller.titleController.text,
                    description: controller.descriptionController.text,
                    listingType: controller.listingType.value!,
                    transactionType: controller.transactionType.value!,
                    pricePerUnit: double.parse(controller.priceController.text),
                    quantityRequired:
                        int.parse(controller.quantityController.text),
                    unit: controller.unitController.text,
                    createdAt: DateTime.now(),
                    availableFrom: DateTime.now(),
                    availableTo: controller.availableTo.value,
                    status: 'active',
                    offers: [],
                  );

                  try {
                    await controller.createListing(listing);
                    Get.back();
                    Get.snackbar('Success', 'Listing created successfully');
                  } catch (e) {
                    Get.snackbar('Error', 'Failed to create listing');
                  }
                },
                child: const Text('Create Listing'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
