import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

import '../app/generalImports.dart';

class UiUtils {
  //key for Global navigation
  static GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static GlobalKey<MainActivityState> bottomNavigationBarGlobalKey =
      GlobalKey<MainActivityState>();
  static GlobalKey<MainActivityState> mainActivityNavigationBarGlobalKey =
      GlobalKey<MainActivityState>();

  static int animationDuration = 1; //value is in seconds

  //Price formats
  static String? systemCurrency;
  static String? systemCurrencyCountryCode;
  static String? decimalPointsForPrice;

  static int resendOTPCountDownTime = 30; //in seconds

  static int limit = 10;

  //
  /// Toast message display duration
  static const int messageDisplayDuration = 3000;

  ///space from bottom for buttons
  static const double bottomButtonSpacing = 56;

  ///required days to create PromoCode
  static const int noOfDaysAllowToCreatePromoCode = 365;

  static const int minimumMobileNumberDigit = 6;
  static const int maximumMobileNumberDigit = 15;

  static Locale getLocaleFromLanguageCode(String languageCode) {
    final List<String> result = languageCode.split('-');
    return result.length == 1
        ? Locale(result.first)
        : Locale(result.first, result.last);
  }

  //border radius
  static const double borderRadiusOf5 = 5;
  static const double borderRadiusOf10 = 10;
  static const double borderRadiusOf15 = 15;
  static const double borderRadiusOf20 = 20;
  static const double borderRadiusOf50 = 50;

//chat message sending related controls
  static int? maxFilesOrImagesInOneMessage;
  static int?
      maxFileSizeInMBCanBeSent; //1000000 = 1 MB (default is 10000000 = 10 MB)
  static int? maxCharactersInATextMessage;

  static Future<dynamic> showModelBottomSheets({
    required BuildContext context,
    required Widget child,
    Color? backgroundColor,
    bool? enableDrag,
    bool? useSafeArea,
    bool? isScrollControlled,
    BoxConstraints? constraints,
  }) async {
    final result = await showModalBottomSheet(
      enableDrag: enableDrag ?? false,
      isScrollControlled: isScrollControlled ?? true,
      useSafeArea: useSafeArea ?? false,
      backgroundColor: Theme.of(context).colorScheme.secondaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadiusOf20),
          topRight: Radius.circular(borderRadiusOf20),
        ),
      ),
      context: context,
      builder: (final _) {
        //using backdropFilter to blur the background screen
        //while bottomSheet is open
        return BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 1, sigmaY: 1), child: child);
      },
    );

    return result;
  }

  static void removeFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  // Only numbers can be entered
  static List<TextInputFormatter> allowOnlyDigits() {
    return <TextInputFormatter>[
      FilteringTextInputFormatter.digitsOnly,
    ];
  }

  static SystemUiOverlayStyle getSystemUiOverlayStyle({
    required BuildContext context,
  }) {
    return SystemUiOverlayStyle(
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarColor: Theme.of(context).colorScheme.primaryColor,
      systemNavigationBarIconBrightness:
          context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
              ? Brightness.light
              : Brightness.dark,
      //
      statusBarColor: Theme.of(context).colorScheme.secondaryColor,
      statusBarIconBrightness:
          context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
              ? Brightness.light
              : Brightness.dark,
    );
  }

  static dynamic showDemoModeWarning({required BuildContext context}) {
    return showMessage(
      context,
      message: 'demoModeWarning'.translate(context: context),
      type: ToastificationType.warning,
    );
  }

  static void showMessage(
    BuildContext context, {
    required String message,
    required ToastificationType type,
    VoidCallback? onMessageClosed,
  }) {
    toastification
      ..dismissAll()
      ..show(
        context: context,
        type: type,
        style: ToastificationStyle.fillColored,
        autoCloseDuration: const Duration(seconds: 3),
        title: Text(
          message,
          maxLines: 100,
          softWrap: true,
          overflow: TextOverflow.visible,
          style: const TextStyle(fontSize: 14, color: Colors.white),
        ),
        alignment: Alignment.bottomCenter,
        direction: ui.TextDirection.ltr,
        animationDuration: const Duration(milliseconds: 300),
        icon: const Icon(Icons.check),
        showIcon: true,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x07000000),
            blurRadius: 16,
            offset: Offset(0, 16),
          ),
        ],
        showProgressBar: false,
        closeButtonShowType: CloseButtonShowType.always,
        closeOnClick: false,
        pauseOnHover: false,
        dragToClose: true,
        applyBlurEffect: true,
      );

    // Trigger the callback after the duration (if provided)
    if (onMessageClosed != null) {
      Future.delayed(const Duration(seconds: 3), onMessageClosed);
    }
  }

  // static Future<void> showMessage(
  //   BuildContext context,
  //   String text,
  //   MessageType type, {
  //   Alignment? alignment,
  //   Duration? duration,
  //   VoidCallback? onMessageClosed,
  // }) async {
  //   // ignore: prefer_final_locals
  //   OverlayState? overlayState = Overlay.of(context);
  //   OverlayEntry overlayEntry;
  //   overlayEntry = OverlayEntry(
  //     builder: (BuildContext context) {
  //       return Positioned(
  //         top: alignment != null
  //             ? (alignment == Alignment.topCenter ? 50 : null)
  //             : null,
  //         left: 5,
  //         right: 5,
  //         bottom: alignment != null
  //             ? (alignment == Alignment.bottomCenter ? 5 : null)
  //             : 5,
  //         child: MessageContainer(context: context, text: text, type: type),
  //       );
  //     },
  //   );
  //   SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
  //     overlayState.insert(overlayEntry);
  //   });
  //   await Future.delayed(duration ?? const Duration(seconds: 3));

  //   overlayEntry.remove();
  //   onMessageClosed?.call();
  // }

  static Future<Object?> showAnimatedDialog(
      {required BuildContext context, required Widget child}) async {
    final result = await showGeneralDialog(
      context: context,
      pageBuilder: (final context, final animation, final secondaryAnimation) =>
          const CustomContainer(),
      transitionBuilder: (final context, final animation,
              final secondaryAnimation, Widget _) =>
          Transform.scale(
        scale: Curves.easeInOut.transform(animation.value),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: child,
          ),
        ),
      ),
    );
    return result;
  }

  static TextButton bottomBarTextButton(
      BuildContext context,
      int selectedIndex,
      int index,
      void Function() onPressed,
      String? imgName,
      String? iconTitle) {
    return TextButton(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomSvgPicture(
            imgName!,
            color: selectedIndex != index
                ? Theme.of(context).colorScheme.lightGreyColor
                : Theme.of(context).colorScheme.accentColor,
          ),
          selectedIndex == index ? const SizedBox(height: 2) : const SizedBox(),
          Text(iconTitle!.toUpperCase(),
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onPrimary))
        ],
      ),
      onPressed: () => onPressed(),
    );
  }

  static Color getStatusColor(
      {required final BuildContext context, required final String statusVal}) {
    Color stColor;
    switch (statusVal) {
      case "awaiting":
        stColor = Colors.grey.shade500;
        break;
      case "confirmed":
        stColor = Colors.green.shade500;
        break;
      case "started":
        stColor = const Color(0xff0096FF);
        break;
      case "rescheduled": //Rescheduled
        stColor = Colors.grey.shade500;
        break;
      case "cancelled": //Cancelled
        stColor = Colors.red;
        break;
      case "completed":
        stColor = Colors.green;
        break;
      case "booking_ended":
        stColor = Colors.green.shade700;
      default:
        stColor = Colors.green;
        break;
    }
    return stColor;
  }

  static String formatTimeWithDateTime(
    DateTime dateTime,
  ) {
    if (dateAndTimeSetting["use24HourFormat"]) {
      return DateFormat("kk:mm").format(dateTime);
    } else {
      return DateFormat("hh:mm a").format(dateTime);
    }
  }

  static Future<void> downloadOrShareFile({
    required String url,
    String? customFileName,
    required bool isDownload,
  }) async {
    try {
      String downloadFilePath = isDownload
          ? (await getApplicationDocumentsDirectory()).path
          : (await getTemporaryDirectory()).path;
      downloadFilePath =
          "$downloadFilePath/${customFileName != null ? customFileName : DateTime.now().toIso8601String()}";

      if (await File(downloadFilePath).exists()) {
        if (isDownload) {
          OpenFilex.open(downloadFilePath);
        } else {
          Share.shareXFiles([XFile(downloadFilePath)]);
        }
        return;
      }

      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();
      final bytes = await consolidateHttpClientResponseBytes(response);

      await File(downloadFilePath).writeAsBytes(
        bytes,
        flush: !isDownload,
      );
      if (isDownload) {
        OpenFilex.open(downloadFilePath);
      } else {
        Share.shareXFiles([XFile(downloadFilePath)]);
      }
    } catch (_) {}
  }

//add  gradient color to show in the chart on home screen
  static List<LinearGradient> gradientColorForBarChart = [
    LinearGradient(
      colors: [Colors.green.shade300, Colors.green],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Colors.blue.shade300, Colors.blue],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Colors.purple.shade300, Colors.purple],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];

  static List<String> chatPredefineMessagesForProvider = [
    "chatPreDefineMessageForCustomer1",
    "chatPreDefineMessageForCustomer2",
    "chatPreDefineMessageForCustomer3",
    "chatPreDefineMessageForCustomer4",
    "chatPreDefineMessageForCustomer5",
    "chatPreDefineMessageForCustomer6",
  ];
  static List<String> chatPredefineMessagesForAdmin = [
    "chatPreDefineMessageForAdmin1",
    "chatPreDefineMessageForAdmin2",
    "chatPreDefineMessageForAdmin3",
    "chatPreDefineMessageForAdmin4",
    "chatPreDefineMessageForAdmin5",
    "chatPreDefineMessageForAdmin6",
  ];
}

// to manage snackBar/toast/message
enum MessageType { success, error, warning }

Map<MessageType, Color> messageColors = {
  MessageType.success: Colors.green,
  MessageType.error: Colors.red,
  MessageType.warning: Colors.orange
};

Map<MessageType, IconData> messageIcon = {
  MessageType.success: Icons.done_rounded,
  MessageType.error: Icons.error_outline_rounded,
  MessageType.warning: Icons.warning_amber_rounded
};

//scroll controller extension
extension ScrollEndListen on ScrollController {
  ///It will check if scroll is at the bottom or not
  bool isEndReached() {
    return offset >= position.maxScrollExtent;
  }
}
