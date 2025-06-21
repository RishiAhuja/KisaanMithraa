import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cropconnect/core/constants/localization_standards.dart';
import 'package:cropconnect/core/presentation/widgets/modern_dropdown.dart';
import 'package:cropconnect/core/theme/app_colors.dart';
import 'package:cropconnect/features/mandi_prices/presentation/controllers/mandi_price_controller.dart';

class MarketLocationSelector extends StatelessWidget {
  final MandiPriceController controller;

  const MarketLocationSelector({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = LocalizationStandards.getLocalizations(context);
    final theme = Theme.of(context);

    return Obx(() {
      if (controller.markets.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with location info
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_city_rounded,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${controller.selectedDistrict}, ${controller.selectedState}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Market count indicator
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${controller.markets.length} ${appLocalizations.marketPrices.toLowerCase()}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Modern Dropdown
            ModernDropdown(
              value: controller.selectedMarket.value.isNotEmpty
                  ? controller.selectedMarket.value
                  : null,
              hint: appLocalizations.selectMarket,
              items: controller.markets,
              prefixIcon: Icons.store_rounded,
              onChanged: (value) {
                if (value != null) {
                  controller.selectMarket(value);
                }
              },
            ),

            const SizedBox(height: 8),

            // Status Row
            Row(
              children: [
                // Data freshness indicator
                _buildStatusChip(
                  icon: Icons.update_rounded,
                  label: controller.isUsingCachedData.value
                      ? appLocalizations.usingCachedData
                      : appLocalizations.pricesAsOfToday,
                  color: controller.isUsingCachedData.value
                      ? AppColors.warning
                      : AppColors.success,
                  theme: theme,
                ),

                const SizedBox(width: 8),

                // Refresh button
                InkWell(
                  onTap: () => controller.fetchCropPrices(),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          size: 12,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          appLocalizations.refreshPrices
                              .split(' ')
                              .first, // Just "Refresh"
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Currency indicator
                _buildStatusChip(
                  icon: Icons.currency_rupee_rounded,
                  label: '₹/qtl',
                  color: AppColors.textSecondary,
                  theme: theme,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatusChip({
    required IconData icon,
    required String label,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
