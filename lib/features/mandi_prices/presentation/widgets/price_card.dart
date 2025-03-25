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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetailDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Commodity icon or image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    _getCommodityIcon(),
                    color: Theme.of(context).colorScheme.primary,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Commodity information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cropPrice.commodity,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cropPrice.variety == 'Other'
                          ? 'General Variety'
                          : cropPrice.variety,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Grade: ${cropPrice.grade}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Price information
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '₹${cropPrice.modalPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Avg. Price',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              // Add watchlist button
              Obx(() => IconButton(
                    icon: Icon(
                      controller.isInWatchlist(cropPrice)
                          ? Icons.star
                          : Icons.star_border,
                      color: controller.isInWatchlist(cropPrice)
                          ? Colors.amber
                          : Colors.grey,
                    ),
                    onPressed: () => controller.toggleWatchlist(cropPrice),
                    tooltip: controller.isInWatchlist(cropPrice)
                        ? 'Remove from Watchlist'
                        : 'Add to Watchlist',
                  )),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCommodityIcon() {
    final commodity = cropPrice.commodity.toLowerCase();

    if (commodity.contains('apple') ||
        commodity.contains('banana') ||
        commodity.contains('fruit') ||
        commodity.contains('grape') ||
        commodity.contains('orange')) {
      return Icons.emoji_food_beverage;
    } else if (commodity.contains('potato') ||
        commodity.contains('onion') ||
        commodity.contains('tomato')) {
      return Icons.kitchen;
    } else if (commodity.contains('chilli') ||
        commodity.contains('garlic') ||
        commodity.contains('ginger')) {
      return Icons.restaurant;
    } else {
      return Icons.spa;
    }
  }

  void _showDetailDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildDetailSheet(context),
    );
  }

  Widget _buildDetailSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Commodity title and market
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    _getCommodityIcon(),
                    color: Theme.of(context).colorScheme.primary,
                    size: 25,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cropPrice.commodity,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      'at ${cropPrice.market}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Variety and grade
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                    context,
                    'Variety',
                    cropPrice.variety == 'Other'
                        ? 'General Variety'
                        : cropPrice.variety,
                    Icons.category),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                    context, 'Grade', cropPrice.grade, Icons.grade),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Price breakdown
          const Text(
            'Price Range (₹ per quintal)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildPriceCard(
                    context, 'Minimum', cropPrice.minPrice, Colors.orange),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPriceCard(
                    context, 'Average', cropPrice.modalPrice, Colors.green),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPriceCard(
                    context, 'Maximum', cropPrice.maxPrice, Colors.blue),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Date information
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Price as of ${cropPrice.arrivalDate}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Close button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(
      BuildContext context, String type, double price, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            type,
            style: TextStyle(
              fontSize: 13,
              color: color.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${price.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
