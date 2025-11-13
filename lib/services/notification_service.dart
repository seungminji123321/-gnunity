// import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  // final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // TODO: FCM 초기화 및 권한 요청 로직 구현
    // await _fcm.requestPermission();
    // final fcmToken = await _fcm.getToken();
    // print('FCM Token: $fcmToken');
    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    print('Notification service initialized.');
  }
}
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print("Handling a background message: ${message.messageId}");
// }