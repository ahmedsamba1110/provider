import '../../app/generalImports.dart';

class AuthRepository {
  static String? verificationId;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool get isLoggedIn {
    return _auth.currentUser != null;
  }

  Future<void> verifyPhoneNumber(
    String phoneNumber, {
    Function(dynamic err)? onError,
    VoidCallback? onCodeSent,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential complete) {},
      verificationFailed: (FirebaseAuthException err) {
        onError?.call(err);
      },
      codeSent: (String verification, int? forceResendingToken) {
        verificationId = verification;
        // this is force resending token
        HiveRepository.setResendToken = forceResendingToken;
        if (onCodeSent != null) {
          onCodeSent();
        }
      },
      forceResendingToken: HiveRepository.getResendToken,
      codeAutoRetrievalTimeout: (String timeout) {},
    );
  }

  Future<Map<String, dynamic>> sendVerificationCodeUsingSMSGateway({
    required final String phoneNumberWithoutCountryCode,
    required final String countryCode,
  }) async {
    final Map<String, dynamic> response = await Api.post(
        url: Api.resendOTP,
        parameter: {
          Api.mobile: '$countryCode$phoneNumberWithoutCountryCode',
        },
        useAuthToken: false);

    return response;
  }

  Future<UserCredential?> verifyOTPUsingFirebase({
    required String code,
  }) async {
    if (verificationId != null) {
      final PhoneAuthCredential phoneAuthCredential =
          PhoneAuthProvider.credential(
              verificationId: verificationId!, smsCode: code);

      final UserCredential userCredential =
          await _auth.signInWithCredential(phoneAuthCredential);
      return userCredential;
    }
    return null;
  }

  Future<Map<String, dynamic>> verifyOTPUsingSMSGateway({
    required final String phoneNumberWithOutCountryCode,
    required final String countryCode,
    required final String otp,
  }) async {
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        Api.mobile: phoneNumberWithOutCountryCode,
        Api.countryCode: countryCode,
        Api.otp: otp,
      };

      final response = await Api.post(
          parameter: parameter, url: Api.verifyOTP, useAuthToken: false);
      return {
        "error": response['error'],
        "message": response['message'],
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> verifyUserMobileNumberFromAPI(
      {required String mobileNumber, required String countryCode}) async {
    try {
      final Map<String, dynamic> parameter = {
        Api.mobile: mobileNumber,
        Api.countryCode: countryCode
      };

      final Map<String, dynamic> response = await Api.post(
          parameter: parameter, url: Api.verifyUser, useAuthToken: false);

      return {
        'error': response['error'],
        'message': response['message'] ?? '',
        'messageCode': response['message_code'] ?? '',
        'authenticationMode': response['authentication_mode'] ?? ''
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> loginUser({
    required String phoneNumber,
    required String password,
    required String countryCode,
    String? fcmId,
  }) async {
    final Map<String, dynamic> parameters = {
      Api.mobile: phoneNumber,
      Api.password: password,
      Api.countryCode: countryCode
    };
    if (fcmId != null) {
      parameters[Api.fcmId] = fcmId;
      parameters[Api.platform] = Platform.isAndroid ? "android" : "ios";
    }
    final Map<String, dynamic> response = await Api.post(
      url: Api.loginApi,
      parameter: parameters,
      useAuthToken: false,
    );

    if (response['token'] != null) {
      HiveRepository.setUserToken = response['token'];
      HiveRepository.setUserData(response['data']);
    }

    if (response['data'] == null) {
      return {
        'userDetails': null,
        'error': true,
        'message': response['message'] ?? ''
      };
    }

    return {
      'userDetails': ProviderDetails.fromJson(response['data'] ?? {}),
      'error': response['error'] ?? false,
      'message': response['message'] ?? ''
    };
  }

  Future logout(BuildContext context) async {
    Future.delayed(
      Duration.zero,
      () {
        HiveRepository.setUserLoggedIn = false;
        HiveRepository.clearBoxValues(boxName: HiveRepository.userDetailBoxKey);
        context.read<AuthenticationCubit>().setUnAuthenticated();
        NotificationService.disposeListeners();
        AppQuickActions.clearShortcutItems();
      },
    );
    //
    Navigator.of(context).popUntil((Route route) => route.isFirst);
    Navigator.pushReplacementNamed(context, Routes.loginScreenRoute);
  }

  Future deleteUserAccount() async {
    await Api.post(
        url: Api.deleteUserAccount, parameter: {}, useAuthToken: true);
  }

  Future<Map<String, dynamic>> registerProvider({
    required Map<String, dynamic> parameters,
    required bool isAuthTokenRequired,
  }) async {
    try {
      //
      final Map<String, dynamic> response = await Api.post(
        url: Api.registerProvider,
        parameter: parameters,
        useAuthToken: isAuthTokenRequired,
      );
      if (response['error']) {
        throw ApiException(response["message"].toString());
      }
      return {
        'providerDetails':
            response['data'] != null && (response['data'] as Map).isNotEmpty
                ? ProviderDetails.fromJson(Map.from(response['data']))
                : ProviderDetails(),
        'message': response['message'],
        'error': response['error'],
      };
    } catch (e) {
     return {
        'message': e.toString(),
        'error': true,
        'providerDetails': ProviderDetails()
      };
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final Map<String, dynamic> parameters = {
        Api.oldPassword: oldPassword,
        Api.newPassword: newPassword,
      };
      final Map<String, dynamic> response = await Api.post(
        url: Api.changePassword,
        parameter: parameters,
        useAuthToken: true,
      );
      return {
        'message': response['message'],
        'error': response['error'],
      };
    } catch (e) {
      return {
        'message': e.toString(),
        'error': true,
      };
    }
  }

  Future<Map<String, dynamic>> createNewPassword({
    required String countryCode,
    required String newPassword,
    required String mobileNumber,
  }) async {
    try {
      //
      final Map<String, dynamic> parameters = {
        Api.countryCode: countryCode,
        Api.mobileNumber: mobileNumber,
        Api.newPasswords: newPassword,
      };
      //
      final Map<String, dynamic> response = await Api.post(
        url: Api.createNewPassword,
        parameter: parameters,
        useAuthToken: false,
      );
      //
      return {
        'message': response['message'],
        'error': response['error'],
      };
    } catch (e) {
      //
      return {
        'message': e.toString(),
        'error': true,
      };
    }
  }

  Future<Map<String, dynamic>> getProviderDetails() async {
    try {
      final Map<String, dynamic> response = await Api.post(
          url: Api.getUserInfo, parameter: {}, useAuthToken: true);
      return response;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
