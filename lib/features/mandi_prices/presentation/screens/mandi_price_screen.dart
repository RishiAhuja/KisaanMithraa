import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cropconnect/core/constants/localization_standards.dart';
import 'package:cropconnect/core/presentation/widgets/bottom_nav_bar.dart';
import 'package:cropconnect/core/presentation/widgets/common_app_bar.dart';
import 'package:cropconnect/core/presentation/widgets/rounded_icon_button.dart';
import 'package:cropconnect/core/theme/app_colors.dart';
import 'package:cropconnect/features/mandi_prices/presentation/controllers/mandi_price_controller.dart';
import 'package:cropconnect/features/mandi_prices/presentation/widgets/commodity_list.dart';
import 'package:cropconnect/features/mandi_prices/presentation/widgets/market_location_selector.dart';

class MandiPriceScreen extends StatelessWidget {
  const MandiPriceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MandiPriceController());
    final appLocalizations = LocalizationStandards.getLocalizations(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
      appBar: CommonAppBar(
        title: appLocalizations.mandiPrices,
        showBottomBorder: false,
        customActions: [
          RoundedIconButton(
            icon: Icons.refresh_rounded,
            onTap: () => controller.fetchCropPrices(),
            tooltip: appLocalizations.refreshPrices,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Compact Header
          Container(
            color: theme.colorScheme.background,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: [
                // Tab Bar
                Container(
                  height: 40,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Obx(() => Row(
                        children: [
                          Expanded(
                            child: _buildTab(
                              context: context,
                              controller: controller,
                              text: appLocalizations.allPrices,
                              isSelected: !controller.isWatchlistView.value,
                              onTap: () =>
                                  controller.isWatchlistView.value = false,
                            ),
                          ),
                          Expanded(
                            child: _buildTab(
                              context: context,
                              controller: controller,
                              text: appLocalizations.watchlist,
                              isSelected: controller.isWatchlistView.value,
                              onTap: () =>
                                  controller.isWatchlistView.value = true,
                              badge: controller.watchlist.length,
                            ),
                          ),
                        ],
                      )),
                ),

                const SizedBox(height: 12),

                // Market Selector & Status
                Obx(() {
                  if (!controller.isWatchlistView.value) {
                    return MarketLocationSelector(controller: controller);
                  } else {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.primary,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              appLocalizations.watchlistShowsPrices,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                }),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: Obx(() =>
                _buildContent(context, controller, appLocalizations, theme)),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required BuildContext context,
    required MandiPriceController controller,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
    int? badge,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: theme.textTheme.labelMedium!.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              child: Text(text),
            ),
            if (badge != null && badge > 0) ...[
              const SizedBox(width: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.9)
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: theme.textTheme.labelSmall!.copyWith(
                    color: isSelected ? AppColors.primary : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  child: Text(badge.toString()),
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
              strokeWidth: 2.5,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              appLocalizations.loadingPrices,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
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
      return _buildEmptyState(
          context, controller, appLocalizations, theme, 'noPriceData');
    }

    if (controller.isWatchlistView.value && controller.watchlist.isEmpty) {
      return _buildEmptyState(
          context, controller, appLocalizations, theme, 'emptyWatchlist');
    }

    return CommodityList(
      groupedCommodities: controller.getGroupedCommodities(),
      showWatchlistStars: true,
    );
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 32,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              appLocalizations.unableToLoadMarketPrices,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => controller.fetchCropPrices(),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(appLocalizations.tryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, MandiPriceController controller,
      appLocalizations, ThemeData theme, String type) {
    late IconData icon;
    late String title;
    late String subtitle;
    late String buttonText;
    late VoidCallback buttonAction;

    switch (type) {
      case 'emptyWatchlist':
        icon = Icons.star_border_rounded;
        title = appLocalizations.yourWatchlistIsEmpty;
        subtitle = appLocalizations.starYourFavoriteCrops;
        buttonText = appLocalizations.goToAllPrices;
        buttonAction = () => controller.isWatchlistView.value = false;
        break;
      case 'noPriceData':
      default:
        icon = Icons.info_outline_rounded;
        title = appLocalizations.noPriceDataAvailable
            .replaceAll('{district}', controller.selectedDistrict)
            .replaceAll('{state}', controller.selectedState);
        subtitle = appLocalizations.selectMarket;
        buttonText = appLocalizations.refreshPrices;
        buttonAction = () => controller.fetchCropPrices();
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: buttonAction,
              icon: Icon(
                type == 'emptyWatchlist'
                    ? Icons.format_list_bulleted_rounded
                    : Icons.refresh_rounded,
                size: 16,
              ),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
