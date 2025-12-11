// Abstract class for notification services
abstract class NotificationService {
  Future<void> initialize();
  Future<void> sendPush(String userId, String title, String body);
  Future<void> sendSMS(String phoneNumber, String message);
}

class MockNotificationManager implements NotificationService {
  @override
  Future<void> initialize() async {
    // print("Initializing Notification Manager (Firebase/Twilio Mock)...");
  }

  @override
  Future<void> sendPush(String userId, String title, String body) async {
    // print("PUSH -> $userId: [$title] $body");
  }

  @override
  Future<void> sendSMS(String phoneNumber, String message) async {
    // print("SMS -> $phoneNumber: $message");
  }
}
