import 'package:cropconnect/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cropconnect/core/presentation/widgets/bottom_nav_bar.dart';
import 'package:cropconnect/core/presentation/widgets/common_app_bar.dart';
import 'package:cropconnect/core/presentation/widgets/rounded_icon_button.dart';
import 'package:cropconnect/features/mandi_prices/presentation/controllers/mandi_price_controller.dart';
import 'package:cropconnect/features/mandi_prices/presentation/widgets/market_selector.dart';
import 'package:cropconnect/features/mandi_prices/presentation/widgets/commodity_list.dart';

class MandiPriceScreen extends StatelessWidget {
  const MandiPriceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MandiPriceController());
    final theme = Theme.of(context);

    return Scaffold(
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
      appBar: CommonAppBar(
        title: 'Mandi Prices',
        showBottomBorder: false,
        customActions: [
          RoundedIconButton(
            icon: Icons.refresh,
            onTap: () => controller.fetchCropPrices(),
            tooltip: 'Refresh Prices',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() => Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => controller.isWatchlistView.value = false,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: !controller.isWatchlistView.value
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'All Prices',
                              style: TextStyle(
                                color: !controller.isWatchlistView.value
                                    ? theme.colorScheme.primary
                                    : Colors.grey[600],
                                fontWeight: !controller.isWatchlistView.value
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => controller.isWatchlistView.value = true,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: controller.isWatchlistView.value
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Watchlist',
                                style: TextStyle(
                                  color: controller.isWatchlistView.value
                                      ? theme.colorScheme.primary
                                      : Colors.grey[600],
                                  fontWeight: controller.isWatchlistView.value
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: controller.isWatchlistView.value
                                      ? theme.colorScheme.primary
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  controller.watchlist.length.toString(),
                                  style: TextStyle(
                                    color: controller.isWatchlistView.value
                                        ? Colors.white
                                        : Colors.grey[700],
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.hasError.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => controller.fetchCropPrices(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              }

              if (controller.allPrices.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No price data available for ${controller.selectedDistrict} in ${controller.selectedState}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                );
              }

              // Show empty watchlist message
              if (controller.isWatchlistView.value &&
                  controller.watchlist.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star_border,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your watchlist is empty',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Star your favorite crops to add them here',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () =>
                            controller.isWatchlistView.value = false,
                        icon: const Icon(Icons.format_list_bulleted,
                            color: AppColors.backgroundLight),
                        label: Text(
                          'Go to All Prices',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.backgroundLight),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  if (!controller.isWatchlistView.value)
                    Obx(() => MarketSelector(
                          markets: controller.markets,
                          selectedMarket: controller.selectedMarket.value,
                          onMarketSelected: (market) =>
                              controller.selectMarket(market),
                          isUsingCachedData: controller.isUsingCachedData.value,
                          cacheTimestampText:
                              controller.cacheTimestampText.value,
                        )),

                  if (controller.isWatchlistView.value)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.blue[700], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your watchlist shows prices for your starred items from all markets',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Last updated info
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.update, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          controller.isUsingCachedData.value
                              ? 'Using cached data'
                              : 'Prices as of today',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.monetization_on,
                                  size: 14, color: Colors.green[700]),
                              const SizedBox(width: 4),
                              Text(
                                'Prices in ₹/Quintal',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Commodity list
                  Expanded(
                    child: Obx(() => CommodityList(
                          groupedCommodities:
                              controller.getGroupedCommodities(),
                          showWatchlistStars: true,
                        )),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
