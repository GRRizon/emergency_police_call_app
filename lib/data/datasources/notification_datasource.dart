import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/logger/app_logger.dart';
import '../../domain/entities/notification.dart';
import '../models/notification_model.dart';

abstract class NotificationDataSource {
  Future<List<NotificationModel>> getNotificationsByUserId(String userId);

  Future<NotificationModel?> getNotificationById(String notificationId);

  Future<void> markAsRead(String notificationId);

  Future<void> markAllAsRead(String userId);

  Future<void> deleteNotification(String notificationId);

  Future<void> deleteAllNotifications(String userId);

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    required NotificationType type,
    String? relatedId,
  });
}

class NotificationDataSourceImpl implements NotificationDataSource {
  final SupabaseClient supabaseClient;

  NotificationDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<NotificationModel>> getNotificationsByUserId(
      String userId) async {
    try {
      AppLogger.info('Fetching notifications for user: $userId');

      final data = await supabaseClient
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: false);

      final notifications = (data as List)
          .map((notification) => NotificationModel.fromJson(notification))
          .toList();

      AppLogger.info('Fetched ${notifications.length} notifications');
      return notifications;
    } catch (e) {
      AppLogger.error('Get notifications error: $e');
      return [];
    }
  }

  @override
  Future<NotificationModel?> getNotificationById(
    String notificationId,
  ) async {
    try {
      AppLogger.info('Fetching notification: $notificationId');

      final data = await supabaseClient
          .from('notifications')
          .select()
          .eq('notification_id', notificationId)
          .single();

      return NotificationModel.fromJson(data);
    } catch (e) {
      AppLogger.error('Get notification error: $e');
      return null;
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      AppLogger.info('Marking notification as read: $notificationId');

      await supabaseClient.from('notifications').update({
        'is_read': true,
        'read_at': DateTime.now().toIso8601String(),
      }).eq('notification_id', notificationId);

      AppLogger.info('Notification marked as read');
    } catch (e) {
      AppLogger.error('Mark as read error: $e');
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      AppLogger.info('Marking all notifications as read for user: $userId');

      await supabaseClient
          .from('notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('is_read', false);

      AppLogger.info('All notifications marked as read');
    } catch (e) {
      AppLogger.error('Mark all as read error: $e');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      AppLogger.info('Deleting notification: $notificationId');

      await supabaseClient
          .from('notifications')
          .delete()
          .eq('notification_id', notificationId);

      AppLogger.info('Notification deleted');
    } catch (e) {
      AppLogger.error('Delete notification error: $e');
    }
  }

  @override
  Future<void> deleteAllNotifications(String userId) async {
    try {
      AppLogger.info('Deleting all notifications for user: $userId');

      await supabaseClient.from('notifications').delete().eq('user_id', userId);

      AppLogger.info('All notifications deleted');
    } catch (e) {
      AppLogger.error('Delete all notifications error: $e');
    }
  }

  @override
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    required NotificationType type,
    String? relatedId,
  }) async {
    try {
      AppLogger.info('Sending notification to user: $userId');

      final typeString = type.toString().split('.').last;

      await supabaseClient.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'message': message,
        'type': typeString,
        'related_id': relatedId,
        'is_read': false,
        'timestamp': DateTime.now().toIso8601String(),
      });

      AppLogger.info('Notification sent successfully');
    } catch (e) {
      AppLogger.error('Send notification error: $e');
    }
  }
}
