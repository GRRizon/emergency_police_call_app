class Notification {
  final String notificationId;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final String? relatedId;
  final bool isRead;
  final DateTime timestamp;
  final DateTime? readAt;

  Notification({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.relatedId,
    this.isRead = false,
    required this.timestamp,
    this.readAt,
  });

  Notification copyWith({
    String? notificationId,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    String? relatedId,
    bool? isRead,
    DateTime? timestamp,
    DateTime? readAt,
  }) {
    return Notification(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  String toString() =>
      'Notification(notificationId: $notificationId, title: $title, type: $type)';
}

enum NotificationType {
  emergency,
  dispatch,
  contactMessage,
  systemAlert,
  sosConfirmation,
  statusUpdate
}
