import 'dart:developer';

class NotifyContactsService {
  static Future<void> notify() async {
    log(
      "Emergency notification sent",
      name: "NotifyContactsService",
    );
  }
}
