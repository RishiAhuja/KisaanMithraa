import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cropconnect/core/constants/localization_standards.dart';
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
    final appLocalizations = LocalizationStandards.getLocalizations(context);
    final theme = Theme.of(context);

    return Scaffold(
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
      appBar: CommonAppBar(
        title: appLocalizations.mandiPrices,
        showBottomBorder: false,
        customActions: [
          RoundedIconButton(
            icon: Icons.refresh,
            onTap: () => controller.fetchCropPrices(),
            tooltip: appLocalizations.refreshPrices,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Modern Tab Bar
          _buildModernTabBar(context, controller, appLocalizations, theme),

          // Content
          Expanded(
            child: Obx(() =>
                _buildContent(context, controller, appLocalizations, theme)),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTabBar(BuildContext context,
      MandiPriceController controller, appLocalizations, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(() => Row(
            children: [
              Expanded(
                child: _buildTabButton(
                  context: context,
                  controller: controller,
                  theme: theme,
                  text: appLocalizations.allPrices,
                  isSelected: !controller.isWatchlistView.value,
                  onTap: () => controller.isWatchlistView.value = false,
                ),
              ),
              Expanded(
                child: _buildTabButton(
                  context: context,
                  controller: controller,
                  theme: theme,
                  text: appLocalizations.watchlist,
                  isSelected: controller.isWatchlistView.value,
                  onTap: () => controller.isWatchlistView.value = true,
                  badge: controller.watchlist.length,
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildTabButton({
    required BuildContext context,
    required MandiPriceController controller,
    required ThemeData theme,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
    int? badge,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
            if (badge != null && badge > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.9)
                      : theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge.toString(),
                  style: TextStyle(
                    color:
                        isSelected ? theme.colorScheme.primary : Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, MandiPriceController controller,
      appLocalizations, ThemeData theme) {
    if (controller.isLoading.value) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading prices...',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (controller.hasError.value) {
      return _buildErrorState(context, controller, appLocalizations, theme);
    }

    if (controller.allPrices.isEmpty) {
      return _buildEmptyPricesState(
          context, controller, appLocalizations, theme);
    }

    if (controller.isWatchlistView.value && controller.watchlist.isEmpty) {
      return _buildEmptyWatchlistState(
          context, controller, appLocalizations, theme);
    }

    return _buildPricesList(context, controller, appLocalizations, theme);
  }

  Widget _buildErrorState(BuildContext context, MandiPriceController controller,
      appLocalizations, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              appLocalizations.unableToLoadPrices,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => controller.fetchCropPrices(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(appLocalizations.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPricesState(BuildContext context,
      MandiPriceController controller, appLocalizations, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.info_outline_rounded,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              appLocalizations.noPriceDataAvailable
                  .replaceAll('{district}', controller.selectedDistrict)
                  .replaceAll('{state}', controller.selectedState),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWatchlistState(BuildContext context,
      MandiPriceController controller, appLocalizations, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star_border_rounded,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              appLocalizations.yourWatchlistIsEmpty,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              appLocalizations.starYourFavoriteCrops,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => controller.isWatchlistView.value = false,
              icon: const Icon(Icons.format_list_bulleted_rounded),
              label: Text(appLocalizations.goToAllPrices),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricesList(BuildContext context, MandiPriceController controller,
      appLocalizations, ThemeData theme) {
    return Column(
      children: [
        // Market Selector (only for All Prices view)
        if (!controller.isWatchlistView.value)
          Obx(() => MarketSelector(
                markets: controller.markets,
                selectedMarket: controller.selectedMarket.value,
                onMarketSelected: (market) => controller.selectMarket(market),
                isUsingCachedData: controller.isUsingCachedData.value,
                cacheTimestampText: controller.cacheTimestampText.value,
              )),

        // Watchlist Info Banner
        if (controller.isWatchlistView.value)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    appLocalizations.watchlistShowsPrices,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Price Info Row
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Cache Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: controller.isUsingCachedData.value
                      ? Colors.orange.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: controller.isUsingCachedData.value
                        ? Colors.orange.shade200
                        : Colors.green.shade200,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.update_rounded,
                      size: 14,
                      color: controller.isUsingCachedData.value
                          ? Colors.orange.shade700
                          : Colors.green.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      controller.isUsingCachedData.value
                          ? appLocalizations.usingCachedData
                          : appLocalizations.pricesAsOfToday,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: controller.isUsingCachedData.value
                            ? Colors.orange.shade700
                            : Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Price Unit Info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.currency_rupee_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      appLocalizations.pricesInRupees,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Commodity List
        Expanded(
          child: Obx(() => CommodityList(
                groupedCommodities: controller.getGroupedCommodities(),
                showWatchlistStars: true,
              )),
        ),
      ],
    );
  }
}
