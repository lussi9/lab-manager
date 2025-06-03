import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initNotification() async {
    if (_isInitialized) return;

    if (!await _requestNotificationPermission()) {
      print('Notification permissions not granted');
      return;
    }

    try {
      tz.initializeTimeZones();
      final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
      print('Current timezone: $currentTimeZone'); // Debug log
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
    } catch (e) {
      print('Error setting timezone: $e');
      tz.setLocalLocation(tz.getLocation('UTC')); // Fallback to UTC
    }

    const AndroidInitializationSettings initializationSettingsAndroid = 
        AndroidInitializationSettings('@mipmap/ic_launcher'); // android initialization settings
    const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ); // iOS initialization settings

    const initSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await notificationsPlugin.initialize(initSettings);
    _isInitialized = true;
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
     android: AndroidNotificationDetails(
      'daily_channel_id',
      'Daily notifications',
      channelDescription: 'Daily Notification Channel',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      ), 
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> showNotification({int id = 0, String? title, String? body}) async {
    return notificationsPlugin.show(id, title, body, notificationDetails(),);
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!await _requestExactAlarmPermission()) {
      print('Exact alarm permission not granted');
      return;
    }

    var tzDate = tz.TZDateTime.from(
      scheduledDate,
      tz.local, // Use the local timezone
    );
    print('Scheduling notification for $tzDate with ID: $id, Title: $title');
    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<bool> _requestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.scheduleExactAlarm.request();
      return status.isGranted;
    }
    return true; // iOS doesn't require this permission
  }

  Future<bool> _requestNotificationPermission() async {
    if (kIsWeb) {
      return false;
    }
    if (Platform.isIOS) {
      final iosStatus = await notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return iosStatus ?? false;
    }
    return true; // Android handles permissions via channel
  }
}