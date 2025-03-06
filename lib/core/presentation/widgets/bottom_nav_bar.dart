import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      width: double.infinity,
      height: 64 + bottomPadding, // Base height plus bottom padding
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        // boxShadow: [
        //   BoxShadow(
        //     color: theme.colorScheme.primary.withOpacity(0.1),
        //     blurRadius: 10,
        //     offset: const Offset(0, -2),
        //   ),
        // ],
      ),
      child: Row(
        children: [
          _buildNavItem(
            context: context,
            index: 0,
            icon: Icons.home,
            label: 'Home',
            isSelected: currentIndex == 0,
          ),
          _buildNavItem(
            context: context,
            index: 1,
            icon: Icons.group,
            label: 'Community',
            isSelected: currentIndex == 1,
          ),
          _buildNavItem(
            context: context,
            index: 2,
            icon: Icons.storefront,
            label: 'AgriMart',
            isSelected: currentIndex == 2,
          ),
          _buildNavItem(
            context: context,
            index: 3,
            icon: Icons.smart_toy,
            label: 'AgriAssist',
            isSelected: currentIndex == 3,
          ),
          _buildNavItem(
            context: context,
            index: 4,
            icon: Icons.support,
            label: 'AgriHelp',
            isSelected: currentIndex == 4,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: InkWell(
        onTap: () {
          switch (index) {
            case 0:
              Get.offAllNamed('/home');
              break;
            case 1:
              Get.offAllNamed('/my-cooperatives');
              break;
            case 2:
              // AgriMart - leave empty for now
              break;
            case 3:
              Get.offAllNamed('/chatbot');
              break;
            case 4:
              // AgriHelp - leave empty for now
              break;
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.6),
                size: 22, // Slightly reduced icon size for 5 items
              ),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
