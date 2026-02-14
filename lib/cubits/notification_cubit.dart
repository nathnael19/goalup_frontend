import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/notification.dart';
import '../services/api_service.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<Notification> notifications;
  NotificationLoaded(this.notifications);

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
}

class NotificationCubit extends Cubit<NotificationState> {
  final ApiService _apiService;
  Timer? _pollingTimer;

  NotificationCubit(this._apiService) : super(NotificationInitial());

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _fetchNotificationsSilently();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
  }

  Future<void> _fetchNotificationsSilently() async {
    try {
      final List<dynamic> jsonList = await _apiService.getNotifications();
      final List<Notification> notifications = jsonList
          .map((json) => Notification.fromJson(json))
          .toList();
      emit(NotificationLoaded(notifications));
    } catch (e) {
      // Silent error during polling
    }
  }

  Future<void> fetchNotifications() async {
    emit(NotificationLoading());
    try {
      final List<dynamic> jsonList = await _apiService.getNotifications();
      final List<Notification> notifications = jsonList
          .map((json) => Notification.fromJson(json))
          .toList();
      emit(NotificationLoaded(notifications));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _apiService.markNotificationAsRead(id);
      await fetchNotifications();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiService.markAllNotificationsAsRead();
      await fetchNotifications();
    } catch (e) {
      // Handle error
    }
  }

  @override
  Future<void> close() {
    stopPolling();
    return super.close();
  }
}
