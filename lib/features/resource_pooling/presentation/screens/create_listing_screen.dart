import 'package:cropconnect/core/services/hive/hive_storage_service.dart';
import 'package:cropconnect/core/presentation/widgets/common_app_bar.dart';
import 'package:cropconnect/features/resource_pooling/domain/resouce_listing_model.dart';
import 'package:cropconnect/features/resource_pooling/presentation/controller/resource_pooling_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateListingScreen extends GetView<ResourcePoolingController> {
  const CreateListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: FormAppBar(
        title: appLocalizations?.createListing ?? 'Create Listing',
        onSavePressed: _handleSave,
        isSaving: controller.isLoading.value,
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
                        decoration: InputDecoration(
                          labelText:
                              appLocalizations?.listingType ?? 'Listing Type',
                          border: const OutlineInputBorder(),
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
                        decoration: InputDecoration(
                          labelText: appLocalizations?.transactionType ??
                              'Transaction Type',
                          border: const OutlineInputBorder(),
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
                        decoration: InputDecoration(
                          labelText: appLocalizations?.title ?? 'Title',
                          border: const OutlineInputBorder(),
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
                        decoration: InputDecoration(
                          labelText:
                              appLocalizations?.description ?? 'Description',
                          border: const OutlineInputBorder(),
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
                              decoration: InputDecoration(
                                labelText:
                                    appLocalizations?.quantity ?? 'Quantity',
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true)
                                  return appLocalizations?.required ??
                                      'Required';
                                if (int.tryParse(value!) == null) {
                                  return appLocalizations?.invalidNumber ??
                                      'Invalid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: controller.unitController,
                              decoration: InputDecoration(
                                labelText: appLocalizations?.unit ?? 'Unit',
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true)
                                  return appLocalizations?.required ??
                                      'Required';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: controller.priceController,
                        decoration: InputDecoration(
                          labelText: appLocalizations?.pricePerUnit ??
                              'Price per unit (₹)',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true)
                            return appLocalizations?.required ?? 'Required';
                          if (double.tryParse(value!) == null) {
                            return appLocalizations?.invalidPrice ??
                                'Invalid price';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        appLocalizations?.availability ?? 'Availability',
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
                                decoration: InputDecoration(
                                  labelText: appLocalizations?.from ?? 'From',
                                  border: const OutlineInputBorder(),
                                ),
                                child: Obx(
                                  () => Text(
                                    controller.availableFrom.value != null
                                        ? DateFormat('dd MMM yyyy').format(
                                            controller.availableFrom.value!)
                                        : appLocalizations?.selectDate ??
                                            'Select Date',
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
                                        decoration: InputDecoration(
                                          labelText:
                                              appLocalizations?.to ?? 'To',
                                          border: const OutlineInputBorder(),
                                        ),
                                        child: Text(
                                          controller.availableTo.value != null
                                              ? DateFormat('dd MMM yyyy')
                                                  .format(controller
                                                      .availableTo.value!)
                                              : appLocalizations?.selectDate ??
                                                  'Select Date',
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
          ],
        ),
      ),
    );
  }

  // Helper method for FormAppBar save functionality
  void _handleSave() async {
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
      quantityRequired: int.parse(controller.quantityController.text),
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
  }
}
