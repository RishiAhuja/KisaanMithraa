import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cropconnect/core/theme/app_colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FeaturesGridWidget extends StatelessWidget {
  const FeaturesGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.grid_view_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  localizations.quickAccess,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.85,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildFeatureCard(
                context,
                icon: Icons.group_rounded,
                title: localizations.farmerGroups,
                bgColor: Colors.purple,
              ),
              _buildFeatureCard(
                context,
                icon: Icons.menu_book_rounded,
                title: localizations.podcasts,
                bgColor: Colors.green,
              ),
              _buildFeatureCard(
                context,
                icon: Icons.local_shipping_rounded,
                title: localizations.transport,
                bgColor: Colors.orange,
              ),
              _buildFeatureCard(
                context,
                icon: Icons.account_balance_wallet_rounded,
                title: localizations.loans,
                bgColor: Colors.blue,
              ),
              _buildFeatureCard(
                context,
                icon: Icons.water_drop_rounded,
                title: localizations.weather,
                bgColor: Colors.teal,
              ),
              _buildFeatureCard(
                context,
                icon: Icons.headset_mic_rounded,
                title: localizations.helpDesk,
                bgColor: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color bgColor,
  }) {
    String getNavigationRoute() {
      switch (title) {
        case 'Farmer Groups':
          return '/cooperatives';
        case 'Podcasts':
          return '/podcasts';
        case 'Transport':
          return '/transport';
        case 'Loans':
          return '/loans';
        case 'Weather':
          return '/weather-details';
        case 'Help Desk':
          return '/help-desk';
        default:
          return '/home';
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Get.toNamed(getNavigationRoute()),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          bgColor.withOpacity(0.8),
                          bgColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: bgColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
