import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MgrLocalNotification {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// 初始化消息通知器
  static init() async {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    ///安卓
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    ///iOS/MacOS 请求权限，也可以滞后请求
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        print('onDidReceiveLocalNotification');
      },
    );

    ///Linux
    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(
            defaultActionName: 'Open notification',
            defaultIcon: AssetsLinuxIcon('icons/app_icon.png'));

    ///初始化
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            macOS: initializationSettingsDarwin,
            linux: initializationSettingsLinux);
//todo 导致无法在release模式启动app
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            ToolLocalNotification.onDidReceiveNotificationResponse);

    ///请求权限 android
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
    }

    ///请求权限 ios/macos
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }

    ///请求权限 linux
    if (Platform.isLinux) {
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          LinuxFlutterLocalNotificationsPlugin>();
    }
  }
}

class ToolLocalNotification {
  static plainNotification(int id, String title, String msg) async {
    //在这里，第一个参数是通知的 id，对于所有会导致显示通知的方法都是通用的。
    // 这通常为每个通知设置一个唯一的值，因为多次使用相同的 id 会导致通知被更新/覆盖。
    //display a notification with a plain title and body
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel id', 'channel name', //这个会显示再安卓的通知设置里面
      channelDescription: 'updated channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    NotificationDetails notificationDetails =
        const NotificationDetails(android: androidNotificationDetails);
    await MgrLocalNotification.flutterLocalNotificationsPlugin
        .show(id, title, msg, notificationDetails,
            //paylaod 传递给点击通知后的回调函数
            payload: '我的item x');
  }

  //点击通知后的回调
  static onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      print('notification payload: $payload');
    }
    print('点击通知回调');
    //点击通知导航到指定页面
    // await Navigator.push(
    //   context,
    //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
    // );
  }
}
