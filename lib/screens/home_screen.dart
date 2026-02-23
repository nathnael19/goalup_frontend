import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/banner_ad_widget.dart';
// ... rest of imports ...
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/notification_cubit.dart';
import '../cubits/navigation_cubit.dart';
import '../services/notification_service.dart';
import 'news_feed_screen.dart';
import 'notification_screen.dart';
import 'schedule_screen.dart';
import '../utils/responsive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription<String?>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    // Start polling for notifications when the app starts
    context.read<NotificationCubit>().startPolling();

    // Listen to notification clicks
    _notificationSubscription = NotificationService
        .selectNotificationStream
        .stream
        .listen((String? payload) {
          if (payload != null && payload.contains('"type": "news"')) {
            if (mounted) context.read<NavigationCubit>().setIndex(1);
          }
        });
  }

  @override
  void dispose() {
    // Stop polling when the home screen is destroyed
    context.read<NotificationCubit>().stopPolling();
    _notificationSubscription?.cancel();
    super.dispose();
  }

  final List<Widget> _screens = [
    const ScheduleScreen(),
    const NewsFeedScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final colorScheme = Theme.of(context).colorScheme;
    final currentIndex = context.watch<NavigationCubit>().state;

    return Scaffold(
      appBar: AppBar(
        // ... (title and actions logic remain same)
        title: Row(
          children: [
            Icon(Icons.sports_soccer, color: colorScheme.primary, size: 28.sp),
            SizedBox(width: 8.w),
            Text(
              'GOALUP',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 24.sp,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              int unreadCount = 0;
              if (state is NotificationLoaded) {
                unreadCount = state.unreadCount;
              }

              return Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      unreadCount > 0
                          ? Icons.notifications_rounded
                          : Icons.notifications_none_rounded,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.surface,
                            width: 2.w,
                          ),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16.w,
                          minHeight: 16.w,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: IndexedStack(index: currentIndex, children: _screens),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BannerAdWidget(),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.05),
                  width: 1,
                ),
              ),
            ),
            child: NavigationBar(
              selectedIndex: currentIndex,
              height: 70.h,
              backgroundColor: Colors.transparent,
              onDestinationSelected: (index) {
                context.read<NavigationCubit>().setIndex(index);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month_rounded),
                  label: 'Matches',
                ),
                NavigationDestination(
                  icon: Icon(Icons.newspaper_outlined),
                  selectedIcon: Icon(Icons.newspaper),
                  label: 'News',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
