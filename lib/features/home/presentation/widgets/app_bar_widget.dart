import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cropconnect/core/services/debug/debug_service.dart';
import 'package:cropconnect/core/presentation/widgets/rounded_icon_button.dart';

class HomeAppBar extends StatelessWidget {
  final String userName;

  const HomeAppBar({
    Key? key,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final debugService = Get.find<DebugService>();
    int debugTapCount = 0;

    return SliverAppBar(
      expandedHeight: 64,
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const SizedBox(width: 12),
                Text(
                  "KisaanMithraa",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Obx(() => debugService.isDebugMode.value
                    ? IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        icon: const Icon(Icons.bug_report, color: Colors.amber),
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
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.more_vert,
                            color: Colors.transparent,
                          ),
                        ),
                      )),
                RoundedIconButton(
                  icon: Icons.notifications_outlined,
                  onTap: () => Get.toNamed('/notifications'),
                  tooltip: 'Notifications',
                ),
                const SizedBox(width: 12),
                RoundedIconButton(
                  icon: Icons.person_rounded,
                  onTap: () => Get.toNamed('/profile'),
                  tooltip: 'Profile',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
