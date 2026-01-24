import '../../core/exceptions/app_exceptions.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationDataSource dataSource;

  NotificationRepositoryImpl({required this.dataSource});

  @override
  Future<List<Notification>> getNotificationsByUserId(String userId) async {
    try {
      return await dataSource.getNotificationsByUserId(userId);
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<Notification?> getNotificationById(String notificationId) async {
    try {
      return await dataSource.getNotificationById(notificationId);
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      return await dataSource.markAsRead(notificationId);
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      return await dataSource.markAllAsRead(userId);
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      return await dataSource.deleteNotification(notificationId);
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<void> deleteAllNotifications(String userId) async {
    try {
      return await dataSource.deleteAllNotifications(userId);
    } on AppException {
      rethrow;
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
      return await dataSource.sendNotification(
        userId: userId,
        title: title,
        message: message,
        type: type,
        relatedId: relatedId,
      );
    } on AppException {
      rethrow;
    }
  }

  @override
  Stream<List<Notification>> watchNotifications(String userId) {
    // ignore: todo
    // TODO: Implement realtime subscription
    throw UnimplementedError();
  }

  @override
  Stream<Notification> watchNewNotifications(String userId) {
    // ignore: todo
    // TODO: Implement realtime subscription
    throw UnimplementedError();
  }
}
