import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cropconnect/features/home/services/farming_tip_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AiTipWidget extends GetView<FarmingTipService> {
  const AiTipWidget({Key? key}) : super(key: key);

  static final carouselController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.hasFetchedTips) {
        controller.fetchTips();
        controller.hasFetchedTips = true;
      }
    });

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange.shade600,
                Colors.amber.shade600,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 122,
          width: double.infinity,
          child: Obx(() {
            if (controller.isLoading.value) {
              return _buildLoadingState(context);
            } else if (controller.tipModels.isEmpty) {
              return _buildNoTipsState(context);
            } else {
              return _buildTipContent(context, carouselController);
            }
          }),
        ),

        // Carousel indicators - outside the container
        Obx(() {
          if (!controller.isLoading.value && controller.tipModels.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: controller.tipModels.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => carouselController.animateToPage(entry.key),
                    child: Container(
                      width: controller.currentTipIndex.value == entry.key
                          ? 20
                          : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: controller.currentTipIndex.value == entry.key
                            ? Colors.amber.shade600
                            : Colors.amber.shade300.withOpacity(0.5),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
      ],
    );
  }

  Widget _buildTipContent(
      BuildContext context, CarouselSliderController carouselController) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 90,
      child: CarouselSlider.builder(
        carouselController: carouselController,
        itemCount: controller.tipModels.length,
        options: CarouselOptions(
          height: 90,
          viewportFraction: 1.0,
          enlargeCenterPage: false,
          enableInfiniteScroll: true,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 8),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
          pauseAutoPlayOnTouch: true,
          onPageChanged: (index, reason) {
            controller.currentTipIndex.value = index;
          },
        ),
        itemBuilder: (context, index, realIndex) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (controller.tipModels.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.format_quote,
                        color: Colors.white.withOpacity(0.7),
                        size: 18,
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.tipModels[index].content,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
            backgroundColor: Colors.white.withOpacity(0.2),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          localizations.gettingTips,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNoTipsState(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.lightbulb_outline,
          color: Colors.white,
          size: 26,
        ),
        const SizedBox(height: 8),
        Text(
          localizations.noTipsAvailable,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
