import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  Future<void> initialize() async {
    // Firebase Messaging設定
    await _setupFirebaseMessaging();
    
    // ローカル通知設定
    await _setupLocalNotifications();
    
    // 権限確認
    await _checkPermissions();
  }
  
  Future<void> _setupFirebaseMessaging() async {
    // 通知設定
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    
    // トークン取得（APNSトークンが利用可能になってから）
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('FCM Token: $token');
        await _saveFCMToken(token);
      }
    } catch (e) {
      print('FCM Token取得エラー（APNSトークン未設定の可能性）: $e');
      // APNSトークンが設定されていない場合は、後で再試行
      Future.delayed(const Duration(seconds: 5), () async {
        try {
          final token = await _firebaseMessaging.getToken();
          if (token != null) {
            print('FCM Token (delayed): $token');
            await _saveFCMToken(token);
          }
        } catch (e) {
          print('FCM Token取得エラー (delayed): $e');
        }
      });
    }
    
    // トークン更新リスナー
    _firebaseMessaging.onTokenRefresh.listen(_saveFCMToken);
    
    // フォアグラウンドメッセージ
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      if (message.notification != null) {
        _showLocalNotification(
          title: message.notification!.title ?? 'SOZO',
          body: message.notification!.body ?? '',
        );
      }
    });
    
    // バックグラウンドメッセージハンドラー（main.dartで設定）
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  
  Future<void> _setupLocalNotifications() async {
    // Android設定
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS設定
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Notification clicked: ${response.payload}');
      },
    );
  }
  
  Future<void> _checkPermissions() async {
    // iOS通知権限
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    print('User granted permission: ${settings.authorizationStatus}');
    
    // Android 13以降の通知権限
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }
  
  Future<void> _saveFCMToken(String token) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client
            .from('user_settings')
            .upsert({
              'user_id': user.id,
              'fcm_token': token,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', user.id);
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }
  
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'sozo_channel',
      'SOZO学習リマインダー',
      channelDescription: '学習リマインダーの通知',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }
  
  // 学習リマインダーのスケジュール設定
  Future<void> scheduleStudyReminder({
    required TimeOfDay time,
    required bool enabled,
  }) async {
    // 既存のスケジュールをキャンセル
    await cancelAllNotifications();
    
    if (!enabled) return;
    
    // タイムゾーンを初期化
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Tokyo'));
    
    // タイムゾーンを使用した通知スケジューリング
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    
    // 今日の時間が過ぎていたら明日に設定
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      '毎日の学習リマインダー',
      channelDescription: '設定した時刻に学習を促す通知',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.zonedSchedule(
      0, // 通知ID
      '今日の学習時間です！',
      '英語学習を始めましょう。目標達成まで頑張りましょう！',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // 毎日同じ時刻に繰り返し
    );
  }
  
  // すべての通知をキャンセル
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }
  
  // 通知権限の状態を取得
  Future<bool> hasNotificationPermission() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }
}

// トップレベル関数（main.dartから呼び出される）
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
} 