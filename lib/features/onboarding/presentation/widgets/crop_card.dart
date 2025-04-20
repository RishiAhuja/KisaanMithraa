import 'package:cropconnect/features/onboarding/domain/models/crop_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CropCard extends StatelessWidget {
  final CropModel crop;
  final bool isSelected;
  final bool isRecommended;
  final VoidCallback onTap;

  const CropCard({
    super.key,
    required this.crop,
    required this.isSelected,
    this.isRecommended = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            onTap();
            HapticFeedback.lightImpact();
          },
          borderRadius: BorderRadius.circular(20),
          splashColor: theme.primaryColor.withOpacity(0.1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 44,
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.primaryColor.withOpacity(0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? theme.primaryColor
                    : Colors.grey.withOpacity(0.2),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  // Icon
                  Icon(
                    crop.icon,
                    size: 18,
                    color: isSelected ? theme.primaryColor : Colors.grey[600],
                  ),

                  const SizedBox(width: 6),

                  // Crop name
                  Expanded(
                    child: Text(
                      crop.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? theme.primaryColor
                            : theme.textTheme.bodyMedium?.color,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Selection indicator
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isSelected ? theme.primaryColor : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? theme.primaryColor
                            : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 10,
                            color: Colors.white,
                          )
                        : null,
                  ),

                  // Local indicator
                  if (isRecommended)
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.shade500,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
