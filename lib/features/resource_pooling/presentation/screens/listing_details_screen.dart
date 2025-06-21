import 'package:cropconnect/core/services/hive/hive_storage_service.dart';
import 'package:cropconnect/features/auth/domain/model/user/user_model.dart';
import 'package:cropconnect/features/resource_pooling/domain/resouce_listing_model.dart';
import 'package:cropconnect/features/resource_pooling/domain/resource_offer_model.dart';
import 'package:cropconnect/features/resource_pooling/presentation/controller/resource_pooling_controller.dart';
import 'package:cropconnect/core/presentation/widgets/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ListingDetailsScreen extends GetView<ResourcePoolingController> {
  const ListingDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listing = Get.arguments['listing'] as ResourceListing;
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: CommonAppBar(
        title: listing.title,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(theme, listing.listingType),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            listing.listingType.name.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(theme, listing.status)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            listing.status.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _getStatusColor(theme, listing.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      listing.title,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      listing.description,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<UserModel?>(
                      future: controller.getUserDetails(listing.userId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final requester = snapshot.data;
                        if (requester == null) {
                          return const SizedBox();
                        }

                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(requester.name[0].toUpperCase()),
                            ),
                            title: Text('Posted by ${requester.name}'),
                            subtitle: Text(
                              'Posted on ${DateFormat('dd MMM yyyy').format(listing.createdAt)}',
                              style: theme.textTheme.bodySmall,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.call),
                              onPressed: () async {
                                final Uri telUri = Uri.parse(
                                    'tel:+91${requester.phoneNumber}');
                                if (await canLaunchUrl(telUri)) {
                                  await launchUrl(telUri);
                                } else {
                                  throw 'Could not launch $telUri';
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DetailRow(
                              label: appLocalizations?.quantity ?? 'Quantity',
                              value:
                                  '${listing.quantityRequired} ${listing.unit}',
                            ),
                            const SizedBox(height: 8),
                            _DetailRow(
                              label: appLocalizations?.pricePerUnit ??
                                  'Price per unit',
                              value: '₹${listing.pricePerUnit}',
                            ),
                            const SizedBox(height: 8),
                            _DetailRow(
                              label: appLocalizations?.availableFrom ??
                                  'Available from',
                              value: DateFormat('dd MMM yyyy')
                                  .format(listing.availableFrom),
                            ),
                            if (listing.availableTo != null) ...[
                              const SizedBox(height: 8),
                              _DetailRow(
                                label: appLocalizations?.availableUntil ??
                                    'Available until',
                                value: DateFormat('dd MMM yyyy')
                                    .format(listing.availableFrom),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '${appLocalizations?.offers ?? 'Offers'} (${listing.offers.length})',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: controller.getOffersWithUsers(
                          listing.id, listing.cooperativeId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              appLocalizations?.errorLoadingOffers ??
                                  'Error loading offers',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          );
                        }

                        final offers = snapshot.data ?? [];

                        if (offers.isEmpty) {
                          return Center(
                            child: Text(
                              appLocalizations?.noOffersYet ?? 'No offers yet',
                              style: theme.textTheme.bodyLarge,
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: offers.length,
                          itemBuilder: (context, index) {
                            final offer =
                                offers[index]['offer'] as ResourceOffer;
                            final user = offers[index]['user'] as UserModel;

                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(user.name[0].toUpperCase()),
                              ),
                              title: Row(
                                children: [
                                  Text('${offer.quantity} ${listing.unit}'),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(by ${user.name})',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '₹${offer.pricePerUnit} per ${listing.unit}'),
                                  Text(
                                    'Offered on ${DateFormat('dd MMM yyyy').format(offer.offerTime)}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(theme, offer.status)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  offer.status.toUpperCase(),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: _getStatusColor(theme, offer.status),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ElevatedButton(
            onPressed: listing.status == 'active'
                ? () => _showMakeOfferDialog(context, listing)
                : null,
            child: Text(appLocalizations?.makeOffer ?? 'Make Offer',
                style:
                    theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(ThemeData theme, ListingType type) {
    switch (type) {
      case ListingType.request:
        return theme.colorScheme.primary;
      case ListingType.offer:
        return theme.colorScheme.secondary;
    }
  }

  Color _getStatusColor(ThemeData theme, String status) {
    switch (status) {
      case 'active':
        return theme.colorScheme.primary;
      case 'fulfilled':
        return theme.colorScheme.secondary;
      case 'cancelled':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.onSurface;
    }
  }

  void _showMakeOfferDialog(BuildContext context, ResourceListing listing) {
    final quantityController = TextEditingController();
    final priceController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final appLocalizations = AppLocalizations.of(context);

    Get.dialog(
      AlertDialog(
        title: Text(appLocalizations?.makeOffer ?? 'Make Offer',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: quantityController,
                decoration: InputDecoration(
                  labelText:
                      '${appLocalizations?.quantity ?? 'Quantity'} (${listing.unit})',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return appLocalizations?.pleaseEnterQuantity ??
                        'Please enter quantity';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity <= 0) {
                    return appLocalizations?.pleaseEnterValidQuantity ??
                        'Please enter valid quantity';
                  }
                  if (quantity > listing.quantityRequired) {
                    return appLocalizations?.cannotExceedQuantity ??
                        'Cannot exceed required quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText:
                      appLocalizations?.pricePerUnit ?? 'Price per unit (₹)',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return appLocalizations?.pleaseEnterPrice ??
                        'Please enter price';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return appLocalizations?.pleaseEnterValidPrice ??
                        'Please enter valid price';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(appLocalizations?.cancel ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final quantity = int.parse(quantityController.text);
                final price = double.parse(priceController.text);

                final user = await Get.find<UserStorageService>().getUser();
                if (user == null) {
                  Get.snackbar('Error', 'User not found');
                  return;
                }

                try {
                  await controller.makeOffer(
                    listing.id,
                    ResourceOffer(
                      id: '',
                      listingId: listing.id,
                      userId: user.id,
                      cooperativeId: listing.cooperativeId,
                      quantity: quantity,
                      pricePerUnit: price,
                      offerTime: DateTime.now(),
                      status: 'pending',
                    ),
                  );
                  Get.back();
                  Get.snackbar(
                      'Success',
                      appLocalizations?.offerSubmittedSuccess ??
                          'Offer submitted successfully');
                } catch (e) {
                  Get.snackbar(
                      'Error',
                      appLocalizations?.failedToSubmitOffer ??
                          'Failed to submit offer');
                }
              }
            },
            child: Text(appLocalizations?.submit ?? 'Submit'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
