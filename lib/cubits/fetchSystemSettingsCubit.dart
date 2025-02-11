import '../../app/generalImports.dart';

abstract class FetchSystemSettingsState {}

class FetchSystemSettingsInitial extends FetchSystemSettingsState {}

class FetchSystemSettingsInProgress extends FetchSystemSettingsState {}

class FetchSystemSettingsSuccess extends FetchSystemSettingsState {
  final String termsAndConditions;
  final String privacyPolicy;
  final String aboutUs;
  final String contactUs;
  final String availableAmount;
  final String isDemoModeEnable;
  final String isAcceptingCustomJob;
  final GeneralSettings generalSettings;
  final PaymentGatewaysSettings paymentGatewaysSettings;
  final SubscriptionInformation subscriptionInformation;
  final AppSetting appSetting;
  final List<SocialMediaURL> socialMediaURLs;

  FetchSystemSettingsSuccess({
    required this.termsAndConditions,
    required this.privacyPolicy,
    required this.aboutUs,
    required this.contactUs,
    required this.availableAmount,
    required this.isDemoModeEnable,
    required this.isAcceptingCustomJob,
    required this.paymentGatewaysSettings,
    required this.generalSettings,
    required this.subscriptionInformation,
    required this.socialMediaURLs,
    required this.appSetting,
  });

  FetchSystemSettingsSuccess copyWith({
    String? termsAndConditions,
    String? privacyPolicy,
    String? aboutUs,
    String? contactUs,
    String? availableAmount,
    String? isAcceptingCustomJob,
    GeneralSettings? generalSettings,
    AppSetting? appSetting,
    PaymentGatewaysSettings? paymentGatewaysSettings,
    SubscriptionInformation? subscriptionInformation,
    List<SocialMediaURL>? socialMediaURLs,
  }) {
    return FetchSystemSettingsSuccess(
      generalSettings: generalSettings ?? this.generalSettings,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      privacyPolicy: privacyPolicy ?? this.privacyPolicy,
      aboutUs: aboutUs ?? this.aboutUs,
      contactUs: contactUs ?? this.contactUs,
      isDemoModeEnable: isDemoModeEnable,
      availableAmount: availableAmount ?? this.availableAmount,
      isAcceptingCustomJob: isAcceptingCustomJob ?? this.isAcceptingCustomJob,
      paymentGatewaysSettings:
          paymentGatewaysSettings ?? this.paymentGatewaysSettings,
      subscriptionInformation:
          subscriptionInformation ?? this.subscriptionInformation,
      socialMediaURLs: socialMediaURLs ?? this.socialMediaURLs,
      appSetting: appSetting ?? this.appSetting,
    );
  }
}

class FetchSystemSettingsFailure extends FetchSystemSettingsState {
  final String errorMessage;

  FetchSystemSettingsFailure(this.errorMessage);
}

class FetchSystemSettingsCubit extends Cubit<FetchSystemSettingsState> {
  FetchSystemSettingsCubit() : super(FetchSystemSettingsInitial());
  final SettingsRepository _settingsRepository = SettingsRepository();

  Future<void> getSettings({required bool isAnonymous}) async {
    try {
      emit(FetchSystemSettingsInProgress());
      final result =
          await _settingsRepository.getSystemSettings(isAnonymous: isAnonymous);
      //
      emit(
        FetchSystemSettingsSuccess(
          socialMediaURLs: ((result["social_media"] ?? []) as List).isNotEmpty
              ? (result["social_media"] as List)
                  .map((e) => SocialMediaURL.fromJson(Map.from(e)))
                  .toList()
              : [],
          generalSettings:
              GeneralSettings.fromJson(result['general_settings'] ?? {}),
          privacyPolicy: result['privacy_policy']['privacy_policy'] ?? "",
          aboutUs: result['about_us']['about_us'] ?? "",
          availableAmount: result['balance'] ?? '',
          isDemoModeEnable: result['demo_mode'] ?? '0',
          isAcceptingCustomJob: result['is_accepting_custom_jobs'] ?? "0",
          termsAndConditions:
              result['terms_conditions']['terms_conditions'] ?? "",
          contactUs: result['contact_us']['contact_us'] ?? "",
          subscriptionInformation: result["subscription_information"] != null
              ? SubscriptionInformation.fromJson(
                  Map.from(result["subscription_information"] ?? {}))
              : SubscriptionInformation(),
          paymentGatewaysSettings: PaymentGatewaysSettings.fromJson(
              result["payment_gateways_settings"] ?? {}),
          appSetting: AppSetting.fromJson(result["app_settings"] ?? {}),
        ),
      );
    } catch (e) {
      emit(FetchSystemSettingsFailure(e.toString()));
    }
  }

  bool isOrderOTPVerificationEnable() {
    if (state is FetchSystemSettingsSuccess) {
      return (state as FetchSystemSettingsSuccess)
              .generalSettings
              .isOrderOTPConfirmationEnable ==
          '1';
    }
    return true;
  }

  bool isDoorstepOptionAvailable() {
    if (state is FetchSystemSettingsSuccess) {
      return (state as FetchSystemSettingsSuccess)
              .generalSettings
              .atDoorStepOptionAvailable ==
          '1';
    }
    return true;
  }

  bool isStoreOptionAvailable() {
    if (state is FetchSystemSettingsSuccess) {
      return (state as FetchSystemSettingsSuccess)
              .generalSettings
              .atStoreOptionAvailable ==
          '1';
    }
    return true;
  }

  String getAppStoreURL() {
    if (state is FetchSystemSettingsSuccess) {
      return (state as FetchSystemSettingsSuccess)
          .appSetting
          .providerAppAppStoreURL!;
    }
    return "";
  }

  String getPlayStoreURL() {
    if (state is FetchSystemSettingsSuccess) {
      return (state as FetchSystemSettingsSuccess)
          .appSetting
          .providerAppPlayStoreURL!;
    }
    return "";
  }

  void updateAmount(String amount) {
    if (state is FetchSystemSettingsSuccess) {
      emit((state as FetchSystemSettingsSuccess)
          .copyWith(availableAmount: amount));
    }
  }

  String getIsAcceptingCustomJobs() {
    if (state is FetchSystemSettingsSuccess) {
      return (state as FetchSystemSettingsSuccess).isAcceptingCustomJob;
    }
    return "0";
  }

  bool isDemoModeEnable() {
    if (state is FetchSystemSettingsSuccess) {
      return (state as FetchSystemSettingsSuccess).isDemoModeEnable == '1';
    }
    return false;
  }

  PaymentGatewaysSettings getPaymentMethodSettings() {
    if (state is FetchSystemSettingsSuccess) {
      return (state as FetchSystemSettingsSuccess).paymentGatewaysSettings;
    }
    return PaymentGatewaysSettings();
  }

  bool isPayLaterAllowedByAdmin() {
    if (state is FetchSystemSettingsSuccess) {
      return (state as FetchSystemSettingsSuccess)
              .paymentGatewaysSettings
              .isPayLaterEnable ==
          "1";
    }
    return true;
  }

  List<SocialMediaURL>? getSocialMediaLinks() {
    if (state is FetchSystemSettingsSuccess) {
      final List<SocialMediaURL> socialMedia =
          (state as FetchSystemSettingsSuccess).socialMediaURLs;

      return socialMedia;
    }
    return [];
  }

  Map<String, dynamic> getContactUsDetails() {
    if (state is FetchSystemSettingsSuccess) {
      final GeneralSettings generalSettings =
          (state as FetchSystemSettingsSuccess).generalSettings;

      return {
        "email": generalSettings.supportEmail ?? "",
        "mobile": generalSettings.phone ?? "",
        "address": generalSettings.address ?? "",
        "supportHours": generalSettings.supportHours ?? "",
      };
    }
    return {};
  }

  bool isAdEnabled() {
    if (state is FetchSystemSettingsSuccess) {
      final AppSetting appSetting =
          (state as FetchSystemSettingsSuccess).appSetting;
      if (Platform.isAndroid) {
        return appSetting.isAndroidAdEnabled == "1";
      } else if (Platform.isIOS) {
        return appSetting.isIosAdEnabled == "1";
      }
    }
    return false;
  }

  String getBannerAdId() {
    if (state is FetchSystemSettingsSuccess) {
      final AppSetting appSetting =
          (state as FetchSystemSettingsSuccess).appSetting;
      if (Platform.isAndroid) {
        return appSetting.androidBannerId ?? "";
      } else if (Platform.isIOS) {
        return appSetting.iosBannerId ?? "";
      }
    }
    return "";
  }

//
  String getInterstitialAdId() {
    if (state is FetchSystemSettingsSuccess) {
      final AppSetting appSetting =
          (state as FetchSystemSettingsSuccess).appSetting;
      if (Platform.isAndroid) {
        return appSetting.androidInterstitialId ?? "";
      } else if (Platform.isIOS) {
        return appSetting.iosInterstitialId ?? "";
      }
    }
    return "";
  }

  List<Map<String, dynamic>> getEnabledPaymentMethods() {
    if (state is FetchSystemSettingsSuccess) {
      final PaymentGatewaysSettings paymentGatewaySetting =
          (state as FetchSystemSettingsSuccess).paymentGatewaysSettings;

      ///title will be shown in radio button
      ///description will be shown in radio button under title (conditional based on deliverable option)
      ///optionDescription will be shown in radio button under title (conditional based on deliverable option)
      ///image will be shown in radio button (icon)
      ///isEnabled will be shown in radio button (if enabled then only give option to select)
      ///paymentType will be used to identify the payment method (this type will be used in placeOrder)
      final List<Map<String, dynamic>> paymentMethods = [
        {
          "title": 'paypal',
          "description": 'payOnlineNowUsingPaypal',
          "image": "ic_paypal",
          "isEnabled": paymentGatewaySetting.paypalStatus == "enable",
          "paymentType": "paypal"
        },
        {
          "title": 'razorpay',
          "description": 'payOnlineNowUsingRazorpay',
          "image": "ic_razorpay",
          "isEnabled": paymentGatewaySetting.razorpayApiStatus == "enable",
          "paymentType": "razorpay"
        },
        {
          "title": 'paystack',
          "description": 'payOnlineNowUsingPaystack',
          "image": "ic_paystack",
          "isEnabled": paymentGatewaySetting.paystackStatus == "enable",
          "paymentType": "paystack"
        },
        {
          "title": 'stripe',
          "description": 'payOnlineNowUsingStripe',
          "image": "ic_stripe",
          "isEnabled": paymentGatewaySetting.stripeStatus == "enable",
          "paymentType": "stripe"
        },
        {
          "title": 'flutterwave',
          "description": 'payOnlineNowUsingFlutterwave',
          "image": "ic_flutterwave",
          "isEnabled": paymentGatewaySetting.isFlutterwaveEnable == "enable",
          "paymentType": "flutterwave"
        },
      ];

      paymentMethods.removeWhere((element) => !element["isEnabled"]);
      return paymentMethods;
    }
    return [];
  }
}
