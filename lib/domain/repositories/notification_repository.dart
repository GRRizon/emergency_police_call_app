import '../../domain/entities/notification.dart';

abstract class NotificationRepository {
  Future<List<Notification>> getNotificationsByUserId(String userId);

  Future<Notification?> getNotificationById(String notificationId);

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

  Stream<List<Notification>> watchNotifications(String userId);

  Stream<Notification> watchNewNotifications(String userId);
}
