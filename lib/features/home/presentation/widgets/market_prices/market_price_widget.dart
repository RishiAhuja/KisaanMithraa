import 'package:cropconnect/features/home/presentation/widgets/market_prices/crop_price_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cropconnect/core/theme/app_colors.dart';
import 'package:cropconnect/features/home/presentation/controller/home_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MarketPricesWidget extends StatelessWidget {
  const MarketPricesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<HomeController>();
    final localizations = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        controller.hasWatchlist.value
                            ? Icons.star_rounded
                            : Icons.trending_up_rounded,
                        color: controller.hasWatchlist.value
                            ? Colors.amber.shade700
                            : AppColors.secondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      controller.hasWatchlist.value
                          ? localizations.yourWatchlist
                          : localizations.marketPrices,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => Get.toNamed('/agri-mart'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        localizations.seeAll,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded, size: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Dynamic market price cards based on API data
          Obx(() {
            if (controller.isLoadingPrices.value) {
              return _buildPricesLoadingShimmer();
            }

            if (controller.topCropPrices.isEmpty) {
              return controller.hasWatchlist.value
                  ? _buildEmptyWatchlistView(context)
                  : _buildNoPricesAvailable(context);
            }

            // Cache indicator if using cached data
            final Widget cacheIndicator = controller.isUsingCachedPrices.value
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 14,
                          color: Colors.amber[700],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          localizations.showingCachedPrices,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.amber[700],
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                cacheIndicator,
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                    itemCount: controller.topCropPrices.length,
                    itemBuilder: (context, index) {
                      final crop = controller.topCropPrices[index];
                      final priceChange = controller.getPriceChange(crop);
                      final cropIcon = getCropIcon(crop.commodity);

                      return CropPriceCard(
                        crop: crop.commodity,
                        market: crop.market,
                        price: controller.formatPrice(crop.modalPrice),
                        change: priceChange['text'],
                        isPositive: priceChange['isPositive'],
                        icon: cropIcon,
                        isWatchlisted: controller.hasWatchlist.value,
                        cropPrice: crop,
                      );
                    },
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPricesLoadingShimmer() {
    return SizedBox(
      height: 156,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            width: 150,
            height: 140,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 80,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 60,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 70,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyWatchlistView(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_border_rounded, size: 36, color: Colors.amber[700]),
            const SizedBox(height: 12),
            Text(
              localizations.emptyWatchlist,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              localizations.addToWatchlistHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.amber[700]?.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/mandi-prices'),
              icon: const Icon(Icons.add_rounded),
              label: Text(localizations.addToWatchlist),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPricesAvailable(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sync_problem_rounded, size: 36, color: Colors.grey[500]),
            const SizedBox(height: 12),
            Text(
              localizations.unableToLoadPrices,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                final controller = Get.find<HomeController>();
                controller.loadWatchlistedPrices();
              },
              child: Text(localizations.retry),
            ),
          ],
        ),
      ),
    );
  }

  String getCropIcon(String commodity) {
    final lcCommodity = commodity.toLowerCase();

    if (lcCommodity.contains('wheat') || lcCommodity.contains('barley')) {
      return '🌾';
    } else if (lcCommodity.contains('rice') || lcCommodity.contains('paddy')) {
      return '🍚';
    } else if (lcCommodity.contains('corn') || lcCommodity.contains('maize')) {
      return '🌽';
    } else if (lcCommodity.contains('potato')) {
      return '🥔';
    } else if (lcCommodity.contains('onion')) {
      return '🧅';
    } else if (lcCommodity.contains('tomato')) {
      return '🍅';
    } else if (lcCommodity.contains('carrot')) {
      return '🥕';
    } else if (lcCommodity.contains('apple')) {
      return '🍎';
    } else if (lcCommodity.contains('banana')) {
      return '🍌';
    } else if (lcCommodity.contains('mango')) {
      return '🥭';
    } else if (lcCommodity.contains('cotton')) {
      return '🧵';
    } else if (lcCommodity.contains('soybean') ||
        lcCommodity.contains('gram') ||
        lcCommodity.contains('pulse')) {
      return '🌱';
    } else if (lcCommodity.contains('sugar') || lcCommodity.contains('cane')) {
      return '🍭';
    } else {
      return '🌿';
    }
  }
}
