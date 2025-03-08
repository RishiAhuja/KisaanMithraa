import 'package:auto_size_text/auto_size_text.dart';
import 'package:cropconnect/core/presentation/widgets/bottom_nav_bar.dart';
import 'package:cropconnect/core/services/debug/debug_service.dart';
import 'package:cropconnect/core/theme/app_colors.dart';
// import 'package:cropconnect/features/auth/domain/model/user/user_model.dart';
import 'package:cropconnect/features/home/presentation/provider/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends GetView<HomeController> {
  // ignore: use_super_parameters
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final appLocalizations = AppLocalizations.of(conAutoSizeText)!;
    final debugService = Get.find<DebugService>();
    int debugTapCount = 0;

    return Scaffold(
        backgroundColor: theme.colorScheme.primary,
        bottomNavigationBar: const BottomNavBar(currentIndex: 0),
        extendBody: true,
        body: SafeArea(
          child: Obx(() {
            final user = controller.user.value;
            if (user == null) {
              return Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              );
            }

            return NestedScrollView(
              headerSliverBuilder:
                  (BuildContext conAutoSizeText, bool innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 300.0,
                    floating: false,
                    pinned: true,
                    backgroundColor: theme.colorScheme.primary,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    titleSpacing: 0,
                    toolbarHeight: 64,
                    title: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.white.withOpacity(0.2),
                                child: Icon(
                                  Icons.shield_outlined,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              AutoSizeText(
                                "Farmer's Friend",
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize
                                .min, // Keep row as small as possible
                            children: [
                              Obx(() => debugService.isDebugMode.value
                                  ? IconButton(
                                      padding:
                                          EdgeInsets.zero, // Remove padding
                                      constraints: BoxConstraints(
                                        minWidth: 36, // Reduced minimum width
                                        minHeight: 36, // Reduced minimum height
                                      ),
                                      icon: Icon(Icons.bug_report,
                                          color: Colors.amber),
                                      tooltip: 'Debug Tools',
                                      onPressed: () => Get.toNamed('/debug'),
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        debugTapCount++;
                                        if (debugTapCount >= 5) {
                                          debugTapCount = 0;
                                          debugService.toggleDebugMode();
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.more_vert,
                                          color: Colors.transparent,
                                        ),
                                      ),
                                    )),
                              IconButton(
                                padding: EdgeInsets.zero, // Remove padding
                                constraints: BoxConstraints(
                                  minWidth: 36, // Reduced minimum width
                                  minHeight: 36, // Reduced minimum height
                                ),
                                icon: Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Get.toNamed('/notifications');
                                },
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                                icon: Icon(
                                  Icons.person_rounded,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Get.toNamed('/profile');
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    flexibleSpace: Stack(
                      children: [
                        FlexibleSpaceBar(
                          background: Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                              ),
                            ),
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 70,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Greeting with language selector
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0, vertical: 0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            AutoSizeText(
                                              'Hello ${user.name.split(' ')[0]}, today\'s farming updates!',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                        margin:
                                            EdgeInsets.fromLTRB(16, 4, 16, 16),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: AppColors.backgroundLight
                                              .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.wb_sunny_rounded,
                                                      color: Colors.amber,
                                                      size: 38,
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        AutoSizeText(
                                                          '32°C',
                                                          style: TextStyle(
                                                            fontSize: 28,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        AutoSizeText(
                                                          '${user.city}, ${user.state}',
                                                          style: TextStyle(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.8),
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .water_drop_outlined,
                                                          size: 16,
                                                          color: Colors.white,
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        AutoSizeText(
                                                          '68% Humidity',
                                                          maxLines: 1,
                                                          minFontSize: 10,
                                                          style: theme.textTheme
                                                              .bodyMedium
                                                              ?.copyWith(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.grain,
                                                          size: 16,
                                                          color: Colors.white,
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        AutoSizeText(
                                                          '30% Rain',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10, horizontal: 16),
                                              decoration: BoxDecoration(
                                                color: Colors.amber
                                                    .withOpacity(0.3),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.bolt,
                                                    color: Colors.amber,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: AutoSizeText(
                                                      'AI Tip: Evening is optimal for crop irrigation today',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          titlePadding: EdgeInsets.zero,
                          title: Container(),
                        ),
                      ],
                    ),
                  ),
                ];
              },
              body: Container(
                color: Colors.grey[100],
                padding: EdgeInsets.only(top: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Priority Alerts Section
                      _buildPriorityAlerts(context),

                      // Market Prices Section
                      _buildMarketPricesSection(context),

                      // Features Section
                      _buildFeaturesSection(context),

                      // Extra padding at bottom
                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            );
          }),
        ));
  }

  Widget _buildPriorityAlerts(BuildContext conAutoSizeText) {
    final theme = Theme.of(conAutoSizeText);

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber,
                  ),
                  SizedBox(width: 8),
                  AutoSizeText(
                    'Priority Alerts',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Row(
                  children: [
                    AutoSizeText('View all'),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Alert 1: Heavy Rain
          Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.grain,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        'Heavy rain expected in next 3 days, secure your wheat crop',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: AutoSizeText(
                          'View Tips',
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Alert 2: PM Kisan Scheme
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: Colors.green,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        'PM Kisan Scheme last date March 15th!',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: AutoSizeText(
                          'Apply Now',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketPricesSection(BuildContext conAutoSizeText) {
    final theme = Theme.of(conAutoSizeText);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: AutoSizeText(
            'Market Prices',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              _buildCropPriceCard(
                conAutoSizeText,
                crop: 'Wheat',
                price: '₹2,340',
                change: '+₹120',
                isPositive: true,
                icon: '🌾',
              ),
              _buildCropPriceCard(
                conAutoSizeText,
                crop: 'Corn',
                price: '₹1,890',
                change: '-₹45',
                isPositive: false,
                icon: '🌽',
              ),
              _buildCropPriceCard(
                conAutoSizeText,
                crop: 'Potato',
                price: '₹1,450',
                change: '+₹85',
                isPositive: true,
                icon: '🥔',
              ),
              _buildCropPriceCard(
                conAutoSizeText,
                crop: 'Rice',
                price: '₹2,100',
                change: '+₹95',
                isPositive: true,
                icon: '🌾',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCropPriceCard(
    BuildContext conAutoSizeText, {
    required String crop,
    required String price,
    required String change,
    required bool isPositive,
    required String icon,
  }) {
    final theme = Theme.of(conAutoSizeText);

    return Container(
      width: 150,
      margin: EdgeInsets.symmetric(horizontal: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: AutoSizeText(
              icon,
              style: TextStyle(fontSize: 24),
            ),
          ),
          SizedBox(height: 12),
          AutoSizeText(
            crop,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 4),
          AutoSizeText(
            'Per Quintal',
            maxLines: 1,
            minFontSize: 10,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 8),
          AutoSizeText(
            price,
            maxLines: 1,
            minFontSize: 14,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          AutoSizeText(
            change,
            maxLines: 1,
            minFontSize: 12,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isPositive
                  ? theme.colorScheme.tertiary
                  : theme.colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext conAutoSizeText) {
    final theme = Theme.of(conAutoSizeText);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: AutoSizeText(
            'Features',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            childAspectRatio: 0.9,
            children: [
              _buildFeatureCard(conAutoSizeText,
                  icon: Icons.group, title: 'Farmer Groups'),
              _buildFeatureCard(conAutoSizeText,
                  icon: Icons.insert_chart, title: 'Market Rates'),
              _buildFeatureCard(conAutoSizeText,
                  icon: Icons.menu_book, title: 'Farming Guide'),
              _buildFeatureCard(conAutoSizeText,
                  icon: Icons.local_shipping, title: 'Transport'),
              _buildFeatureCard(conAutoSizeText,
                  icon: Icons.account_balance_wallet, title: 'Loans'),
              _buildFeatureCard(conAutoSizeText,
                  icon: Icons.water_drop, title: 'Weather'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(BuildContext conAutoSizeText,
      {required IconData icon, required String title}) {
    final theme = Theme.of(conAutoSizeText);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.green[700],
                ),
              ),
              SizedBox(height: 12),
              AutoSizeText(
                title,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // String _formatLocation(UserModel user) {
  //   List<String> locationParts = [];

  //   if (user.city != null && user.state != null) {
  //     locationParts.add('${user.city}, ${user.state}');
  //   }

  //   if (user.latitude != null && user.longitude != null) {
  //     locationParts.add(
  //       '(${user.latitude!.toStringAsFixed(6)}, ${user.longitude!.toStringAsFixed(6)})',
  //     );
  //   }

  //   return locationParts.isEmpty
  //       ? 'Location not set'
  //       : locationParts.join('\n');
  // }

  // String _formatCrops(List<String>? crops) {
  //   if (crops == null || crops.isEmpty) {
  //     return 'No crops specified';
  //   }
  //   return crops.join(', ');
  // }
}

// Add at class level
