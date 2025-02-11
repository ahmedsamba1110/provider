import 'package:edemand_partner/app/generalImports.dart';
import 'package:edemand_partner/data/model/chat/chatNotificationData.dart';
import 'package:edemand_partner/data/model/chat/chatUser.dart';
import 'package:edemand_partner/data/repository/chat/chatNotificationRepository.dart';
import 'package:edemand_partner/utils/Notification/chatNotificationsUtils.dart';

class NotificationService {
  static FirebaseMessaging messagingInstance = FirebaseMessaging.instance;
  static LocalAwesomeNotification localNotification =
      LocalAwesomeNotification();
  static late StreamSubscription<RemoteMessage> foregroundStream;
  static late StreamSubscription<RemoteMessage> onMessageOpen;

  static Future<void> requestPermission() async {
    await messagingInstance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  static Future<void> init(context) async {
    try {
      await ChatNotificationsUtils.initialize();

      await requestPermission();
      await registerListeners(context);
    } catch (_) {}
  }

  static Future<void> foregroundNotificationHandler() async {
    foregroundStream =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      //
      if (message.data["type"] == "chat") {
        ChatNotificationsUtils.addChatStreamAndShowNotification(
            message: message);
      } else {
        //in ios awesome notification will automatically generate a notification
        if (message.data['type'] == "order" && Platform.isAndroid) {
          localNotification.createSoundNotification(
            title: message.notification?.title ?? "",
            body: message.notification?.body ?? "",
            notificationData: message,
            isLocked: false,
          );
        } else {
          if (message.data["image"] == null && Platform.isAndroid) {
            localNotification.createNotification(
              isLocked: false,
              notificationData: message,
              playCustomSound: false,
            );
          } else if (Platform.isAndroid) {
            localNotification.createImageNotification(
              isLocked: false,
              notificationData: message,
              playCustomSound: false,
            );
          }
        }
      }
    });
  }

  @pragma('vm:entry-point')
  static Future<void> onBackgroundMessageHandler(RemoteMessage message) async {
    if (message.data["type"] == "chat") {
      //background chat message storing
      final List<ChatNotificationData> oldList =
          await ChatNotificationsRepository()
              .getBackgroundChatNotificationData();
      final messageChatData =
          ChatNotificationData.fromRemoteMessage(remoteMessage: message);
      oldList.add(messageChatData);

      ChatNotificationsRepository()
          .setBackgroundChatNotificationData(data: oldList);
      if (Platform.isAndroid) {
        ChatNotificationsUtils.createChatNotification(
            chatData: messageChatData, message: message);
      }
    } else {
      if (message.data['type'] == "order" && Platform.isAndroid) {
        localNotification.createSoundNotification(
          title: message.notification?.title ?? "",
          body: message.notification?.body ?? "",
          notificationData: message,
          isLocked: false,
        );
      } else {
        if (message.data["image"] == null && Platform.isAndroid) {
          localNotification.createNotification(
            isLocked: false,
            notificationData: message,
            playCustomSound: false,
          );
        } else if (Platform.isAndroid) {
          localNotification.createImageNotification(
            isLocked: false,
            notificationData: message,
            playCustomSound: false,
          );
        }
      }
    }
  }

  static Future<void> terminatedStateNotificationHandler() async {
    FirebaseMessaging.instance.getInitialMessage().then(
      (RemoteMessage? message) {
        if (message == null) {
          return;
        }
        if (message.data["image"] == null) {
          localNotification.createNotification(
            isLocked: false,
            notificationData: message,
            playCustomSound: false,
          );
        } else {
          localNotification.createImageNotification(
            isLocked: false,
            notificationData: message,
            playCustomSound: false,
          );
        }
      },
    );
  }

  static Future<void> onTapNotificationHandler(context) async {
    onMessageOpen = FirebaseMessaging.onMessageOpenedApp.listen(
      (message) async {
        if (message.data["type"] == "chat") {
          //get off the route if already on it
          if (Routes.currentRoute == Routes.chatMessages) {
            UiUtils.rootNavigatorKey.currentState?.pop();
          }
          await UiUtils.rootNavigatorKey.currentState
              ?.pushNamed(Routes.chatMessages, arguments: {
            "chatUser": ChatUser.fromNotificationData(message.data)
          });
        } else if (message.data["type"] == "order") {
          //navigate to booking tab
          UiUtils.mainActivityNavigationBarGlobalKey.currentState
              ?.selectedIndexOfBottomNavigationBar.value = 1;
        } else if (message.data["type"] == "job_notification") {
          UiUtils.mainActivityNavigationBarGlobalKey.currentState
              ?.selectedIndexOfBottomNavigationBar.value = 2;
        } else if (message.data["type"] == "withdraw_request") {
          Navigator.pushNamed(context, Routes.withdrawalRequests);
        } else if (message.data["type"] == "settlement") {
          //
        } else if (message.data["type"] == "provider_request_status") {
          if (message.data['status'] == "approve") {
          } else {}
        } else if (message.data["type"] == "url") {
          final String url = message.data["url"].toString();
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
      },
    );
  }

  static Future<void> registerListeners(context) async {
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);
    //
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessageHandler);

    await foregroundNotificationHandler();
    await terminatedStateNotificationHandler();
    await onTapNotificationHandler(context);
  }

  static void disposeListeners() {
    ChatNotificationsUtils.dispose();

    onMessageOpen.cancel();
    foregroundStream.cancel();
  }
}
