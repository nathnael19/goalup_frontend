import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubits/notification_cubit.dart';
import '../cubits/navigation_cubit.dart';
import '../models/notification.dart' as model;
import '../utils/responsive.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => context.read<NotificationCubit>().markAllAsRead(),
            child: Text(
              'Mark all read',
              style: TextStyle(color: colorScheme.primary),
            ),
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationError) {
            return Center(child: Text(state.message));
          }

          if (state is NotificationLoaded) {
            final notifications = state.notifications;

            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 64.sp,
                      color: Colors.grey.withValues(alpha: 0.5),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No notifications yet',
                      style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<NotificationCubit>().fetchNotifications(),
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _NotificationItem(notification: notification);
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final model.Notification notification;

  const _NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: notification.isRead
            ? Colors.transparent
            : colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(
          color: notification.isRead
              ? Colors.white.withValues(alpha: 0.05)
              : colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: _buildIcon(context),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead
                ? FontWeight.normal
                : FontWeight.bold,
            fontSize: 15.sp,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),
            Text(
              notification.message,
              style: TextStyle(color: Colors.grey[400], fontSize: 13.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              DateFormat('MMM d, HH:mm').format(notification.createdAt),
              style: TextStyle(color: Colors.grey[600], fontSize: 11.sp),
            ),
          ],
        ),
        onTap: () {
          if (!notification.isRead) {
            context.read<NotificationCubit>().markAsRead(notification.id);
          }
          if (notification.type == 'news') {
            context.read<NavigationCubit>().setIndex(1);
            Navigator.pop(
              context,
            ); // Go back to home screen which now shows news
          }
        },
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    IconData iconData;
    Color color;

    switch (notification.type) {
      case 'news':
        iconData = Icons.newspaper_rounded;
        color = Colors.blue;
        break;
      case 'match':
        iconData = Icons.sports_soccer_rounded;
        color = Colors.green;
        break;
      default:
        iconData = Icons.notifications_rounded;
        color = Theme.of(context).colorScheme.primary;
    }

    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color, size: 20.sp),
    );
  }
}
