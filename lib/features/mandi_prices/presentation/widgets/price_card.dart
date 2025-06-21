import 'package:cropconnect/core/theme/app_colors.dart';
import 'package:cropconnect/features/mandi_prices/presentation/controllers/mandi_price_controller.dart';
import 'package:flutter/material.dart';
import 'package:cropconnect/features/mandi_prices/data/models/crop_price_model.dart';
import 'package:get/get.dart';

class PriceCard extends StatelessWidget {
  final CropPriceModel cropPrice;
  final MandiPriceController controller = Get.find<MandiPriceController>();

  PriceCard({
    super.key,
    required this.cropPrice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showDetailDialog(context),
            child: Stack(
              children: [
                // Main content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Crop icon or emoji
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            _getCropIcon(cropPrice.commodity),
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Info column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Crop name
                            Text(
                              cropPrice.commodity,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Market location
                            Row(
                              children: [
                                Icon(
                                  Icons.store_rounded,
                                  size: 12,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    cropPrice.market,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Variety info
                            Text(
                              cropPrice.variety == 'Other'
                                  ? 'General Variety'
                                  : cropPrice.variety,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 8),

                            // Price row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${cropPrice.modalPrice.toStringAsFixed(0)}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Text(
                                    '/qtl',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                const Spacer(),

                                // Price range
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundSecondary,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '₹${cropPrice.minPrice.toStringAsFixed(0)} - ₹${cropPrice.maxPrice.toStringAsFixed(0)}',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Watchlist button (positioned in top right)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Obx(() {
                    final isInWatchlist = controller.isInWatchlist(cropPrice);
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          topRight: Radius.circular(16),
                        ),
                        onTap: () => controller.toggleWatchlist(cropPrice),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isInWatchlist
                                ? AppColors.secondary.withOpacity(0.1)
                                : AppColors.backgroundSecondary,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Icon(
                            isInWatchlist
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: isInWatchlist
                                ? AppColors.secondary
                                : AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetailDialog(BuildContext context) {
    // showModalBottomSheet(
    //   context: context,
    //   isScrollControlled: true,
    //   shape: const RoundedRectangleBorder(
    //     borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    //   ),
    //   builder: (context) => _buildDetailSheet(context),
    // );

    _showCropPriceDetails(context, cropPrice);
  }

  void _showCropPriceDetails(
    BuildContext context,
    CropPriceModel cropPrice,
  ) {
    final theme = Theme.of(context);
    final controller = Get.find<MandiPriceController>();
    final icon = _getCropIcon(cropPrice.commodity);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.only(top: 60),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle for dragging
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                height: 5,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),

            // Header with crop name and icon
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      icon,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cropPrice.commodity,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.store_rounded,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                cropPrice.market,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Watchlist button
                  Obx(() {
                    final isInWatchlist = controller.isInWatchlist(cropPrice);
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () => controller.toggleWatchlist(cropPrice),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isInWatchlist
                                ? AppColors.secondary.withOpacity(0.1)
                                : AppColors.backgroundSecondary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isInWatchlist
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: isInWatchlist
                                ? AppColors.secondary
                                : AppColors.textSecondary,
                            size: 26,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const Divider(),

            // Price details
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Price',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Show price with larger font
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${cropPrice.modalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          'per quintal',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Price breakdown section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price Breakdown',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Min, Modal, and Max prices
                  Row(
                    children: [
                      _buildPriceDetailItem(
                        'Min Price',
                        '₹${cropPrice.minPrice.toStringAsFixed(0)}',
                        Colors.orange,
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.grey[200],
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      _buildPriceDetailItem(
                        'Modal Price',
                        '₹${cropPrice.modalPrice.toStringAsFixed(0)}',
                        theme.colorScheme.primary,
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.grey[200],
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      _buildPriceDetailItem(
                        'Max Price',
                        '₹${cropPrice.maxPrice.toStringAsFixed(0)}',
                        Colors.green,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Additional details
                  _buildDetailRow('Variety', cropPrice.variety),
                  _buildDetailRow('Grade', cropPrice.grade),
                  _buildDetailRow('District', cropPrice.district),
                  _buildDetailRow('State', cropPrice.state),
                  _buildDetailRow('Arrival Date', cropPrice.arrivalDate),
                ],
              ),
            ),

            const Divider(height: 1),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

// Helper method for price breakdown items
  Widget _buildPriceDetailItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

// Helper method for detail rows
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCropIcon(String commodity) {
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
