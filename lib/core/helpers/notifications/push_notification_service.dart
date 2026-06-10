import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// ID of the Android notification channel created in [PushNotificationService.init].
/// Must match `default_notification_channel_id` in AndroidManifest.xml so foreground
/// (locally shown) and background (system-shown) notifications use one channel.
const String kHighImportanceChannelId = 'high_importance_channel';

/// FCM background / killed-state handler.
///
/// MUST be a top-level (or static) function annotated with `@pragma('vm:entry-point')`:
/// it runs in a separate isolate that does not inherit the main isolate's state, so it
/// re-initializes Firebase before touching any Firebase API. Keep it minimal — no
/// navigation here (that's Phase C). The OS renders the tray notification itself for
/// `notification`-type payloads; this handler only logs in debug builds.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    debugPrint(
      '[FCM] background message: id=${message.messageId} '
      'title=${message.notification?.title}',
    );
  }
}

/// App-wide push-notification service (FCM + local notifications for foreground display).
///
/// Registered as a lazy singleton in `service_locator.dart` and initialized once from
/// `main.dart` after `di.setup()`. Cross-platform: iOS code paths are written correctly
/// but iOS will not function until `GoogleService-Info.plist` is added to the project.
class PushNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Background/killed-state handler must be registered before runApp continues.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _initLocalNotifications();
    await _requestPermission();
    await _safeDeviceToken();

    // Foreground messages are NOT auto-displayed by the OS — show them ourselves.
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
  }

  /// Initializes flutter_local_notifications and creates the high-importance Android
  /// channel used to display foreground notifications as heads-up banners.
  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    await _localNotifications.initialize(initSettings);

    const channel = AndroidNotificationChannel(
      kHighImportanceChannelId,
      'High Importance Notifications',
      description: 'Used for important notifications.',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _requestPermission() async {
    // Covers the iOS prompt and the Android 13+ POST_NOTIFICATIONS runtime prompt.
    final settings = await _messaging.requestPermission();
    if (kDebugMode) {
      debugPrint(
        '[FCM] permission status: ${settings.authorizationStatus}',
      );
    }
  }

  /// Guarded token fetch. Returns null instead of throwing so the app never crashes
  /// on devices without Google Play Services (the MISSING_INSTANCEID_SERVICE bug).
  Future<String?> _safeDeviceToken() async {
    try {
      final token = await _messaging.getToken();
      if (kDebugMode) {
        debugPrint('[FCM] device token: ${token ?? 'null'}');
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FCM] getToken failed: $e');
      }
      return null;
    }
  }

  /// Public, safe accessor for the device token. Use this to send the token to the
  /// backend in a later task (registration/deregistration is out of scope here).
  Future<String?> getDeviceToken() => _safeDeviceToken();

  void _onForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint(
        '[FCM] foreground message: id=${message.messageId} '
        'title=${message.notification?.title}',
      );
    }

    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          kHighImportanceChannelId,
          'High Importance Notifications',
          channelDescription: 'Used for important notifications.',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
