import 'package:cropconnect/features/notification/presentation/controller/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/model/notifications_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends GetView<NotificationsController> {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Text(
              'No notifications yet',
              style: theme.textTheme.bodyLarge,
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];
            return _NotificationTile(notification: notification);
          },
        );
      }),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationTile({
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
        child: Icon(
          notification.type == NotificationType.cooperativeInvite
              ? Icons.group_add
              : Icons.notifications,
          color: theme.colorScheme.primary,
        ),
      ),
      title: Text(notification.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notification.message),
          const SizedBox(height: 4),
          Text(
            timeago.format(notification.createdAt),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
      trailing: notification.type == NotificationType.cooperativeInvite
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.check_circle_outline,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () => Get.find<NotificationsController>()
                      .acceptInvite(notification),
                ),
                IconButton(
                  icon: Icon(
                    Icons.cancel_outlined,
                    color: theme.colorScheme.error,
                  ),
                  onPressed: () => Get.find<NotificationsController>()
                      .declineInvite(notification),
                ),
              ],
            )
          : null,
    );
  }
}
