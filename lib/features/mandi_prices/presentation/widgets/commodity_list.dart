import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cropconnect/core/constants/localization_standards.dart';
import 'package:cropconnect/core/theme/app_colors.dart';
import 'package:cropconnect/features/mandi_prices/data/models/crop_price_model.dart';
import 'package:cropconnect/features/mandi_prices/presentation/widgets/price_card.dart';
import 'package:cropconnect/features/mandi_prices/presentation/controllers/mandi_price_controller.dart';

class CommodityList extends StatelessWidget {
  final Map<String, List<CropPriceModel>> groupedCommodities;
  final bool showWatchlistStars;

  const CommodityList({
    super.key,
    required this.groupedCommodities,
    this.showWatchlistStars = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MandiPriceController>();
    final appLocalizations = LocalizationStandards.getLocalizations(context);
    final theme = Theme.of(context);

    if (groupedCommodities.isEmpty) {
      return Center(
        child: Text(
          appLocalizations.noCommoditiesAvailable,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return Obx(() {
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
                      ? AppColors.secondary.withOpacity(0.1)
                      : AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isWatchlistView
                        ? AppColors.secondary.withOpacity(0.2)
                        : AppColors.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isWatchlistView
                          ? Icons.store_rounded
                          : Icons.category_rounded,
                      size: 16,
                      color: isWatchlistView
                          ? AppColors.secondary
                          : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        category,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isWatchlistView
                              ? AppColors.secondary
                              : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Commodity count badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isWatchlistView
                            ? AppColors.secondary
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${commodities.length}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
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
    });
  }
}
