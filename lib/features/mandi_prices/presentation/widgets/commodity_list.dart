import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cropconnect/features/mandi_prices/data/models/crop_price_model.dart';
import 'package:cropconnect/features/mandi_prices/presentation/widgets/price_card.dart';
import 'package:cropconnect/features/mandi_prices/presentation/controllers/mandi_price_controller.dart';

class CommodityList extends StatelessWidget {
  final Map<String, List<CropPriceModel>> groupedCommodities;
  final bool showWatchlistStars;

  const CommodityList({
    Key? key,
    required this.groupedCommodities,
    this.showWatchlistStars = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MandiPriceController>();

    if (groupedCommodities.isEmpty) {
      return const Center(
        child: Text('No commodities available'),
      );
    }

    // In watchlist view, we're grouped by market
    final bool isWatchlistView = controller.isWatchlistView.value;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedCommodities.length,
      itemBuilder: (context, index) {
        final category = groupedCommodities.keys.elementAt(index);
        final commodities = groupedCommodities[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category header (either category type or market name)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isWatchlistView
                    ? Colors.orange[100] // Different color for market headers
                    : Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isWatchlistView
                        ? Icons.store // Market icon for watchlist
                        : Icons.category, // Category icon for normal view
                    size: 16,
                    color: isWatchlistView
                        ? Colors.orange[800]
                        : Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category,
                    style: TextStyle(
                      color: isWatchlistView
                          ? Colors.orange[800]
                          : Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Commodities in this category/market
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: commodities.length,
              itemBuilder: (context, commodityIndex) {
                return PriceCard(
                  cropPrice: commodities[commodityIndex],
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}
