import 'package:cropconnect/features/auth/domain/model/user/user_model.dart';
import 'package:cropconnect/features/resource_pooling/domain/resource_offer_model.dart';
import 'package:cropconnect/utils/app_logger.dart';
import 'package:cropconnect/core/presentation/widgets/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cropconnect/features/resource_pooling/domain/resouce_listing_model.dart';
import 'package:cropconnect/features/resource_pooling/presentation/controller/resource_pooling_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyListingDetailsScreen extends GetView<ResourcePoolingController> {
  const MyListingDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listing = Get.arguments['listing'] as ResourceListing;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CommonAppBar(
        title: l10n.myListingDetails,
        customActions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'cancel':
                  controller.updateListingStatus(listing.id, 'cancelled');
                  break;
                case 'delete':
                  // controller.deleteListing(listing.id);
                  break;
              }
            },
            itemBuilder: (context) => [
              if (listing.status == 'active')
                PopupMenuItem(
                  value: 'cancel',
                  child: Text(l10n.cancelListing),
                ),
              PopupMenuItem(
                value: 'delete',
                child: Text(l10n.deleteListing),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Listing Details Card
                  Card(
                    child: Padding(
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
                                  color:
                                      _getTypeColor(theme, listing.listingType),
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
                                    color:
                                        _getStatusColor(theme, listing.status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            listing.title,
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(listing.description),
                          const SizedBox(height: 16),
                          _DetailRow(
                            label: l10n.quantity,
                            value: l10n.quantityValue(
                              listing.quantityRequired.toString(),
                              listing.unit,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _DetailRow(
                            label: l10n.pricePerUnit,
                            value: l10n.priceValue(
                              listing.pricePerUnit.toString(),
                              listing.unit,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    l10n.offerCount(listing.offers.length.toString()),
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // Offers List
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: controller.getOffersWithUsers(
                      listing.id,
                      listing.cooperativeId,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            l10n.errorLoadingOffers,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        );
                      }

                      final offers = snapshot.data ?? [];

                      if (offers.isEmpty) {
                        return Center(
                          child: Text(l10n.noOffersYet),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: offers.length,
                        itemBuilder: (context, index) {
                          final offer = offers[index]['offer'] as ResourceOffer;
                          final user = offers[index]['user'] as UserModel;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        child: Text(
                                          user.name[0].toUpperCase(),
                                          style: theme.textTheme.titleMedium,
                                        ),
                                      ),
                                      const SizedBox(width: 16), // Add spacing
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user.name,
                                              style:
                                                  theme.textTheme.titleMedium,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              l10n.quantityWithUnit(
                                                offer.quantity.toString(),
                                                listing.unit,
                                              ),
                                              style: theme.textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        l10n.pricePerUnitWithUnit(
                                          offer.pricePerUnit.toString(),
                                          listing.unit,
                                        ),
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16), // Add spacing
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (listing.status == 'active' &&
                                          offer.status == 'pending')
                                        TextButton.icon(
                                          icon: const Icon(
                                              Icons.check_circle_outline),
                                          label: Text(l10n.accept),
                                          onPressed: () {
                                            if (offer.id.isEmpty) {
                                              Get.snackbar(
                                                l10n.error,
                                                l10n.cannotAcceptOffer,
                                                snackPosition:
                                                    SnackPosition.TOP,
                                              );
                                              return;
                                            }

                                            AppLogger.info(
                                              'Accepting offer - listing.id: ${listing.id}, offer.id: ${offer.id}',
                                            );
                                            controller.acceptOffer(
                                                listing.id,
                                                offer.id,
                                                listing.cooperativeId);
                                          },
                                        ),
                                      const SizedBox(
                                          width:
                                              8), // Add spacing between buttons
                                      TextButton.icon(
                                        icon: const Icon(Icons.chat_outlined),
                                        label: Text(l10n.chat),
                                        onPressed: () => Get.toNamed(
                                          '/chat',
                                          arguments: {
                                            'userId': user.id,
                                            'userName': user.name,
                                            'listingId': listing.id,
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(value),
      ],
    );
  }
}
