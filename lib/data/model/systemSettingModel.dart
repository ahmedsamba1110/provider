class PaymentGatewaysSettings {
  PaymentGatewaysSettings({
    this.razorpayApiStatus,
    this.razorpayMode,
    this.razorpayCurrency,
    this.razorpayKey,
    this.paystackStatus,
    this.paystackMode,
    this.paystackCurrency,
    this.paystackKey,
    this.stripeStatus,
    this.stripeMode,
    this.stripeCurrency,
    this.stripePublishableKey,
    this.stripeSecretKey,
    this.paypalStatus,
    this.isOnlinePaymentEnable,
    this.isPayLaterEnable,
    this.isFlutterwaveEnable,
    this.flutterwaveWebsiteUrl,
    this.paypalWebsiteUrl,
  });

  PaymentGatewaysSettings.fromJson(final Map<String, dynamic> json) {
    isPayLaterEnable = json["cod_setting"]?.toString() ?? "1";
    isOnlinePaymentEnable = json["payment_gateway_setting"]?.toString() ?? "0";
    razorpayApiStatus = json["razorpayApiStatus"] ?? "disable";
    razorpayMode = json["razorpay_mode"];
    razorpayCurrency = json["razorpay_currency"];
    razorpayKey = json["razorpay_key"];
    paystackStatus = json["paystack_status"] ?? "disable";
    paystackMode = json["paystack_mode"];
    paystackCurrency = json["paystack_currency"];
    paystackKey = json["paystack_key"];

    stripeStatus = json["stripe_status"] ?? "disable";
    stripeMode = json["stripe_mode"];
    stripeCurrency = json["stripe_currency"];
    stripePublishableKey = json["stripe_publishable_key"];
    stripeSecretKey = json["stripe_secret_key"];
    paypalStatus = json["paypal_status"] ?? "disable";
    isFlutterwaveEnable = json["flutterwave_status"];
    flutterwaveWebsiteUrl = json["flutterwave_website_url"];
    paypalWebsiteUrl = json["paypal_website_url"];
  }

  String? razorpayApiStatus;
  String? razorpayMode;
  String? razorpayCurrency;
  String? razorpayKey;
  String? paystackStatus;
  String? paystackMode;
  String? paystackCurrency;
  String? paystackKey;
  String? stripeStatus;
  String? stripeMode;
  String? stripeCurrency;
  String? stripePublishableKey;
  String? stripeSecretKey;
  String? paypalStatus;
  String? isPayLaterEnable;
  String? isOnlinePaymentEnable;
  String? isFlutterwaveEnable;
  String? flutterwaveWebsiteUrl;
  String? paypalWebsiteUrl;
}

class GeneralSettings {
  GeneralSettings({
    this.supportEmail,
    this.phone,
    this.address,
    this.shortDescription,
    this.copyrightDetails,
    this.supportHours,
    this.atDoorStepOptionAvailable,
    this.atStoreOptionAvailable,
    this.isOrderOTPConfirmationEnable,
    this.maxFilesOrImagesInOneMessage,
    this.maxFileSizeInMBCanBeSent,
    this.maxCharactersInATextMessage,
    this.allowPostBookingChat,
    this.allowPreBookingChat,
  });

  GeneralSettings.fromJson(Map<String, dynamic> json) {
    supportEmail = json['support_email'];
    phone = json['phone'];
    isOrderOTPConfirmationEnable = json['otp_system'];
    address = json['address'];
    shortDescription = json['short_description'];
    copyrightDetails = json['copyright_details'];
    supportHours = json['support_hours'];
    atStoreOptionAvailable = json['at_store'];
    atDoorStepOptionAvailable = json['at_doorstep'];

    maxCharactersInATextMessage = json['maxCharactersInATextMessage'];
    maxFileSizeInMBCanBeSent = json['maxFileSizeInMBCanBeSent'];
    maxFilesOrImagesInOneMessage = json['maxFilesOrImagesInOneMessage'];
    allowPostBookingChat =
        json['allow_post_booking_chat'] == '1' ? true : false;
    allowPreBookingChat = json['allow_pre_booking_chat'] == '1' ? true : false;
  }

  String? supportEmail;
  String? phone;
  String? isOrderOTPConfirmationEnable;
  String? address;
  String? shortDescription;
  String? copyrightDetails;
  String? supportHours;
  String? atStoreOptionAvailable;
  String? atDoorStepOptionAvailable;
  String? maxFilesOrImagesInOneMessage;
  String? maxFileSizeInMBCanBeSent;
  String? maxCharactersInATextMessage;
  bool? allowPostBookingChat;
  bool? allowPreBookingChat;
}

class SocialMediaURL {
  SocialMediaURL({this.imageURL, this.url});

  SocialMediaURL.fromJson(final Map<String, dynamic> json) {
    imageURL = json["file"];
    url = json["url"];
  }

  String? imageURL;
  String? url;
}

class AppSetting {
  AppSetting({
    this.providerCurrentVersionAndroidApp,
    this.providerCurrentVersionIosApp,
    this.providerCompulsaryUpdateForceUpdate,
    this.messageForProviderApplication,
    this.providerAppMaintenanceMode,
    this.countryCurrencyCode,
    this.currency,
    this.decimalPoint,
    this.providerAppAppStoreURL,
    this.providerAppPlayStoreURL,
    this.customerAppAppStoreURL,
    this.customerAppPlayStoreURL,
    this.androidBannerId,
    this.androidInterstitialId,
    this.isAndroidAdEnabled,
    this.iosBannerId,
    this.iosInterstitialId,
    this.isIosAdEnabled,
  });

  AppSetting.fromJson(final Map<String, dynamic> json) {
    providerCurrentVersionAndroidApp =
        json["provider_current_version_android_app"];
    providerCurrentVersionIosApp = json["provider_current_version_ios_app"];
    providerCompulsaryUpdateForceUpdate =
        json["provider_compulsary_update_force_update"];
    messageForProviderApplication = json["message_for_provider_application"];
    providerAppMaintenanceMode = json["provider_app_maintenance_mode"];
    countryCurrencyCode = json["country_currency_code"];
    currency = json["currency"];
    decimalPoint = json["decimal_point"];
    customerAppPlayStoreURL = json['customer_playstore_url'] ?? "";
    customerAppAppStoreURL = json['customer_appstore_url'] ?? "";
    providerAppPlayStoreURL = json['provider_playstore_url'] ?? "";
    providerAppAppStoreURL = json['provider_appstore_url'] ?? "";
    isAndroidAdEnabled = json['android_google_ads_status'] ?? "";
    androidInterstitialId = json['android_google_interstitial_id'] ?? "";
    androidBannerId = json['android_google_banner_id'] ?? "";
    isIosAdEnabled = json['ios_google_ads_status'] ?? "";
    iosInterstitialId = json['ios_google_interstitial_id'] ?? "";
    iosBannerId = json['ios_google_banner_id'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['provider_current_version_android_app'] =
        providerCurrentVersionAndroidApp;
    data['provider_current_version_ios_app'] = providerCurrentVersionIosApp;
    data['provider_compulsary_update_force_update'] =
        providerCompulsaryUpdateForceUpdate;
    data['message_for_provider_application'] = messageForProviderApplication;
    data['provider_app_maintenance_mode'] = providerAppMaintenanceMode;
    data['country_currency_code'] = countryCurrencyCode;
    data['currency'] = currency;
    data['decimal_point'] = decimalPoint;
    data['provider_appstore_url'] = providerAppAppStoreURL;
    data['provider_playstore_url'] = providerAppPlayStoreURL;
    data['customer_appstore_url'] = customerAppAppStoreURL;
    data['customer_playstore_url'] = customerAppPlayStoreURL;
    return data;
  }

  String? providerCurrentVersionAndroidApp;
  String? providerCurrentVersionIosApp;
  String? providerCompulsaryUpdateForceUpdate;
  String? messageForProviderApplication;
  String? providerAppMaintenanceMode;
  String? countryCurrencyCode;
  String? currency;
  String? decimalPoint;
  String? customerAppAppStoreURL;
  String? customerAppPlayStoreURL;
  String? providerAppAppStoreURL;
  String? providerAppPlayStoreURL;
  String? isAndroidAdEnabled;
  String? androidBannerId;
  String? androidInterstitialId;
  String? isIosAdEnabled;
  String? iosBannerId;
  String? iosInterstitialId;
}
