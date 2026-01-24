import '../../../domain/entities/notification.dart';

class NotificationModel extends Notification {
  NotificationModel({
    required super.notificationId,
    required super.userId,
    required super.title,
    required super.message,
    required super.type,
    super.relatedId,
    super.isRead,
    required super.timestamp,
    super.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notification_id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: _parseType(json['type'] as String),
      relatedId: json['related_id'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      timestamp: DateTime.parse(json['timestamp'] as String),
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notification_id': notificationId,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'related_id': relatedId,
      'is_read': isRead,
      'timestamp': timestamp.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }

  static NotificationType _parseType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'dispatch':
        return NotificationType.dispatch;
      case 'contactmessage':
        return NotificationType.contactMessage;
      case 'systemalert':
        return NotificationType.systemAlert;
      case 'sosconfirmation':
        return NotificationType.sosConfirmation;
      case 'statusupdate':
        return NotificationType.statusUpdate;
      default:
        return NotificationType.emergency;
    }
  }
}
