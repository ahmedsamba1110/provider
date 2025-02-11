import '../../app/generalImports.dart';

class SettingsRepository {
  //
  Future getSystemSettings({required bool isAnonymous}) async {
    try {
      //

      final Map<String, dynamic> response = await Api.post(
        url: Api.getSettings,
        parameter: {},
        useAuthToken: isAnonymous ? false : true,
      );
      return response['data'];
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future updateFCM({required final String fcmId,required final String platform}) async {
    await Api.post(
        url: Api.updateFcm,
        parameter: {
          Api.fcmId: fcmId,
          Api.platform: platform,
        },
        useAuthToken: true);
  }

  //
  Future<String> createRazorpayOrderId({required final String subscriptionID}) async {
    try {
      final Map<String, dynamic> parameters = {Api.subscriptionID: subscriptionID};
      final result =
          await Api.post(parameter: parameters, url: Api.createRazorpayOrder, useAuthToken: true);

      return result['data']['id'];
    } catch (e) {
      throw ApiException(e.toString());
    }
  }


  Future<Map<String, dynamic>> sendQueryToAdmin(
      {required final Map<String, dynamic> parameter}) async {
    try {
      //
      final response =
      await Api.post(url: Api.sendQuery, parameter: parameter, useAuthToken: true);

      return {
        "message":response["message"],
        "error": response['error']
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
