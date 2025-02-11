import 'package:edemand_partner/app/generalImports.dart';
import 'package:edemand_partner/data/model/chat/chatUser.dart';
import 'package:flutter/material.dart';

class LocalAwesomeNotification {
  /*
   ios payload should be like this
   "notification": {
      "title": "Check this Mobile (title)",
      "body": "Rich Notification testing (body)",
      "mutable_content": true,
      "sound" :"default"
      },
    "data" : {
        "type" : "new_order"
    }
   */
  /* android payload should be like this
      "data" : {
            "title": "Check this Mobile (title)",
            "body": "Rich Notification testing (body)",
            "type" : "new_order"
            }
  */
  static const String soundNotificationChannel = "soundNotification";
  static const String normalNotificationChannel = "normalNotification";
  static String chatNotificationChannel = "chat_notification";

  static AwesomeNotifications notification = AwesomeNotifications();

  static Future<void> init(final BuildContext context) async {
    await requestPermission();
    await NotificationService.init(context);

    notification.initialize(
      null,
      [
        NotificationChannel(
          channelKey: soundNotificationChannel,
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel',
          importance: NotificationImportance.High,
          playSound: true,
          soundSource: Platform.isIOS
              ? "order_sound.aiff"
              : "resource://raw/order_sound",
          ledColor: Theme.of(context).colorScheme.lightGreyColor,
        ),
        NotificationChannel(
          channelKey: normalNotificationChannel,
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel',
          importance: NotificationImportance.High,
          playSound: true,
          ledColor: Theme.of(context).colorScheme.lightGreyColor,
        ),
        NotificationChannel(
            channelKey: chatNotificationChannel,
            channelName: "Chat notifications",
            channelDescription: "Notification related to chat",
            vibrationPattern: highVibrationPattern,
            importance: NotificationImportance.High)
      ],
      channelGroups: [],
    );
    await setupAwesomeNotificationListeners(context);
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
    ReceivedAction event,
  ) async {
    if (Platform.isAndroid) {
      final data = event.payload;
      if (data?["type"] == "chat") {
        try {
          //get off the route if already on it
          if (Routes.currentRoute == Routes.chatMessages) {
            UiUtils.rootNavigatorKey.currentState?.pop();
          }

          await UiUtils.rootNavigatorKey.currentState
              ?.pushNamed(Routes.chatMessages, arguments: {
            "chatUser": ChatUser.fromNotificationData(data ?? {})
          });
        } catch (_) {}
      } else if (data?["type"] == "order") {
        //navigate to booking tab
        UiUtils.mainActivityNavigationBarGlobalKey.currentState
            ?.selectedIndexOfBottomNavigationBar.value = 1;
      } else if (data?["type"] == "job_notification") {
        //navigate to booking tab
        UiUtils.mainActivityNavigationBarGlobalKey.currentState
            ?.selectedIndexOfBottomNavigationBar.value = 2;
      } else if (data?["type"] == "withdraw_request") {
        await UiUtils.rootNavigatorKey.currentState
            ?.pushNamed(Routes.withdrawalRequests);
      } else if (data?["type"] == "settlement") {
        //
      } else if (data?["type"] == "provider_request_status") {
        if (data?['status'] == "approve") {
        } else {}
      } else if (data?["type"] == "url") {
        final String url = data!["url"].toString();
        try {
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url),
                mode: LaunchMode.externalApplication);
          } else {
            throw 'Could not launch $url';
          }
        } catch (e) {
          throw 'Something went wrong';
        }
      }
    }
  }

  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code goes here
  }

  @pragma('vm:entry-point')
  static Future<void> setupAwesomeNotificationListeners(
      BuildContext context) async {
    notification.setListeners(
        onActionReceivedMethod: LocalAwesomeNotification.onActionReceivedMethod,
        onNotificationCreatedMethod:
            LocalAwesomeNotification.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            LocalAwesomeNotification.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            LocalAwesomeNotification.onDismissActionReceivedMethod);
  }

  Future<void> createNotification({
    required RemoteMessage notificationData,
    required bool isLocked,
    required bool playCustomSound,
  }) async {
    try {
      await notification.createNotification(
        content: NotificationContent(
          id: Random().nextInt(5000),
          title: notificationData.data["title"],
          locked: isLocked,
          payload: Map.from(notificationData.data),
          body: notificationData.data["body"],
          color: const Color.fromARGB(255, 79, 54, 244),
          wakeUpScreen: true,
          channelKey: playCustomSound
              ? soundNotificationChannel
              : normalNotificationChannel,
          notificationLayout: NotificationLayout.BigText,
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createImageNotification({
    required RemoteMessage notificationData,
    required bool isLocked,
    required bool playCustomSound,
  }) async {
    try {
      await notification.createNotification(
        content: NotificationContent(
          id: Random().nextInt(5000),
          title: notificationData.data["title"],
          locked: isLocked,
          payload: Map.from(notificationData.data),
          autoDismissible: true,
          body: notificationData.data["body"],
          color: const Color.fromARGB(255, 79, 54, 244),
          wakeUpScreen: true,
          largeIcon: notificationData.data["image"],
          bigPicture: notificationData.data["image"],
          notificationLayout: NotificationLayout.BigPicture,
          channelKey: playCustomSound
              ? soundNotificationChannel
              : normalNotificationChannel,
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createSoundNotification({
    required String title,
    required String body,
    required RemoteMessage notificationData,
    required bool isLocked,
  }) async {
    try {
      await notification.createNotification(
        content: NotificationContent(
          id: Random().nextInt(5000),
          title: notificationData.data["title"],
          locked: isLocked,
          payload: Map.from(notificationData.data),
          body: notificationData.data["body"],
          color: const Color.fromARGB(255, 79, 54, 244),
          wakeUpScreen: true,
          largeIcon: notificationData.data["image"],
          bigPicture: notificationData.data['data']?["image"],
          notificationLayout: NotificationLayout.BigPicture,
          channelKey: soundNotificationChannel,
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> requestPermission() async {
    final NotificationSettings notificationSettings =
        await FirebaseMessaging.instance.getNotificationSettings();

    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.notDetermined) {
      await notification.requestPermissionToSendNotifications(
        channelKey: soundNotificationChannel,
        permissions: [
          NotificationPermission.Alert,
          NotificationPermission.Sound,
          NotificationPermission.Badge,
          NotificationPermission.Vibration,
          NotificationPermission.Light
        ],
      );

      if (notificationSettings.authorizationStatus ==
              AuthorizationStatus.authorized ||
          notificationSettings.authorizationStatus ==
              AuthorizationStatus.provisional) {}
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.denied) {
      return;
    }
  }
}
