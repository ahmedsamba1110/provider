import 'package:edemand_partner/utils/errorFilter.dart';
import 'package:flutter/foundation.dart';

import '../app/generalImports.dart';

class ApiException implements Exception {
  ApiException(this.errorMessage);

  dynamic errorMessage;

  @override
  String toString() {
    return ErrorFilter.check(errorMessage).error;
  }
}

class Api {
  //headers
  static Map<String, dynamic> headers() {
    final String jwtToken = HiveRepository.getUserToken;
    if (kDebugMode) {
      print('token is $jwtToken');
    }
    return {
      'Authorization': 'Bearer $jwtToken',
    };
  }

//Api list
  static String loginApi = '${baseUrl}login';
  static String getBookings = '${baseUrl}get_orders';
  static String getCustomRequestJob = '${baseUrl}get_custom_job_requests';
  static String getServices = '${baseUrl}get_services';
  static String getServiceCategories = '${baseUrl}get_all_categories';
  static String getCategories = '${baseUrl}get_categories';
  static String getPromocodes = '${baseUrl}get_promocodes';
  static String managePromocode = '${baseUrl}manage_promocode';
  static String updateBookingStatus = '${baseUrl}update_order_status';
  static String manageService = '${baseUrl}manage_service';
  static String deleteService = '${baseUrl}delete_service';
  static String getServiceRatings = '${baseUrl}get_service_ratings';
  static String deletePromocode = '${baseUrl}delete_promocode';
  static String getAvailableSlots = '${baseUrl}get_available_slots';
  static String getStatistics = '${baseUrl}get_statistics';
  static String getSettings = '${baseUrl}get_settings';
  static String getWithdrawalRequest = '${baseUrl}get_withdrawal_request';
  static String sendWithdrawalRequest = '${baseUrl}send_withdrawal_request';
  static String getNotifications = '${baseUrl}get_notifications';
  static String updateFcm = '${baseUrl}update_fcm';
  static String deleteUserAccount = '${baseUrl}delete_provider_account';
  static String verifyUser = '${baseUrl}verify_user';
  static String registerProvider = '${baseUrl}register';
  static String changePassword = '${baseUrl}change-password';
  static String createNewPassword = '${baseUrl}forgot-password';
  static String getTaxes = '${baseUrl}get_taxes';
  static String getCashCollection = '${baseUrl}get_cash_collection';
  static String getSettlementHistory = '${baseUrl}get_settlement_history';
  static String createRazorpayOrder = "${baseUrl}razorpay_create_order";
  static String getSubscriptionsList = "${baseUrl}get_subscription";
  static String addSubscriptionTransaction = "${baseUrl}add_transaction";
  static String getPreviousSubscriptionsHistory =
      "${baseUrl}get_subscription_history";
  static String getBookingSettleManagementHistory =
      "${baseUrl}get_booking_settle_manegement_history";
  static String sendQuery = "${baseUrl}contact_us_api";
  static String getUserInfo = "${baseUrl}get_user_info";
  static String resendOTP = "${baseUrl}resend_otp";
  static String verifyOTP = "${baseUrl}verify_otp";
  static const String manageCustomJobRequest =
      "${baseUrl}manage_custom_job_request_setting";
  static const String applyForCustomJob = "${baseUrl}apply_for_custom_job";
  static const String manageCategoryPreference =
      "${baseUrl}manage_category_preference";

  //chat related APIs
  static const String sendChatMessage = "${baseUrl}send_chat_message";
  static const String getChatMessages = "${baseUrl}get_chat_history";
  static const String getChatUsers = "${baseUrl}get_chat_customers_list";

  //
  ////////* Place API */////

  static String placeApiKey = 'key';
  static String placeAPI = '${baseUrl}get_places_for_app';

  static const String input = 'input';
  static const String types = 'types';
  static const String placeid = 'placeid';

  static String placeApiDetails = '${baseUrl}get_place_details_for_app';

//parameters
  static const String mobile = 'mobile';
  static const String mobileNumber = 'mobile_number';
  static const String password = 'password';
  static const String countryCode = 'country_code';
  static const String phone = 'phone';
  static const String otp = 'otp';
  static const String oldPassword = 'old';
  static const String newPassword = 'new';
  static const String newPasswords = 'new_password';
  static const String limit = 'limit';
  static const String order = 'order';
  static const String sort = 'sort';
  static const String offset = 'offset';
  static const String search = 'search';
  static const String status = 'status';
  static const String serviceId = 'service_id';
  static const String date = 'date';
  static const String promoId = 'promo_id';
  static const String fcmId = 'fcm_id';
  static const String platform = 'platform';
  static const String customJobValue = 'custom_job_value';

  //
  //register provider
  static const String companyName = 'companyName';
  static const String email = 'email';
  static const String username = 'username';
  static const String companyType = 'type';
  static const String aboutProvider = 'about_provider';
  static const String visitingCharge = 'visiting_charges';
  static const String advanceBookingDays = 'advance_booking_days';
  static const String noOfMember = 'number_of_members';
  static const String currentLocation = 'current_location';
  static const String city = 'city';
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String address = 'address';
  static const String taxName = 'tax_name';
  static const String taxNumber = 'tax_number';
  static const String accountNumber = 'account_number';
  static const String accountName = 'account_name';
  static const String bankCode = 'bank_code';
  static const String swiftCode = 'swift_code';
  static const String bankName = 'bank_name';
  static const String confirmPassword = 'password_confirm';
  static const String days = 'days';
  static const String ascending = 'ASC';
  static const String descending = 'DESC';
  static const String subscriptionID = 'subscription_id';
  static const String transactionID = 'transaction_id';
  static const String message = 'message';
  static const String type = 'type';

  ///post method for API calling
  static Future<Map<String, dynamic>> post({
    required String url,
    required Map<String, dynamic> parameter,
    required bool useAuthToken,
  }) async {
    try {
      final Dio dio = Dio();
      final FormData formData =
          FormData.fromMap(parameter, ListFormat.multiCompatible);
      if (kDebugMode) {
        print('API is $url \n para are $parameter ');
      }
      final Response response = await dio.post(
        url,
        data: formData,
        options: useAuthToken
            ? Options(
                contentType: 'multipart/form-data',
                headers: headers(),
              )
            : Options(
                contentType: 'multipart/form-data',
              ),
      );

      if (kDebugMode) {
        print(
          'success API is $url \n para are $parameter \n response is ${response.data}',
        );
      }
      return Map.from(response.data);
    } on FormatException catch (e) {
      if (kDebugMode) {
        print(
          'failure API is $url \n para are $parameter \n error is ${e.message}',
        );
      }
      throw ApiException(e.message);
    } on DioException catch (e) {
      if (kDebugMode) {
        print(
          'failure API is $url \n para are $parameter \n error is ${e.response}',
        );
      }
      if (e.response?.statusCode == 401) {
        throw ApiException('authenticationFailed');
      } else if (e.response?.statusCode == 500) {
        throw ApiException('internalServerError');
      }
      throw ApiException(
        e.error is SocketException ? 'noInternetFound' : 'somethingWentWrong',
      );
    } on ApiException catch (e) {
      throw ApiException(e.toString());
    } catch (e) {
      throw ApiException('somethingWentWrong');
    }
  }

  static Future<Map<String, dynamic>> get({
    required String url,
    required bool useAuthToken,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      //
      final Dio dio = Dio();

      final Response response = await dio.get(
        url,
        queryParameters: queryParameters,
        options: useAuthToken ? Options(headers: headers()) : null,
      );

      if (response.data['error'] == true) {
        throw ApiException(response.data['code'].toString());
      }

      return Map.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ApiException('authenticationFailed');
      } else if (e.response?.statusCode == 500) {
        throw ApiException('internalServerError');
      }
      throw ApiException(
        e.error is SocketException ? 'noInternetFound' : 'somethingWentWrong',
      );
    } on ApiException {
      throw ApiException('somethingWentWrong');
    } catch (e) {
      throw ApiException('somethingWentWrong');
    }
  }
}
