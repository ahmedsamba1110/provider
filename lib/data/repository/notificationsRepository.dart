import '../../app/generalImports.dart';

class NotificationsRepository {
  Future<List<NotificationDataModel>> getNotifications({required bool isAuthTokenRequired}) async {
    try {
      final Map<String, dynamic> parameters = {Api.limit: '100', Api.offset: '0'};

      final Map<String, dynamic> response =
          await Api.post(url: Api.getNotifications, parameter: parameters, useAuthToken: true);
      final List<dynamic> data = response['data'];

      return data.map((value) => NotificationDataModel.fromMap(value)).toList();
    } catch (error) {
      throw ApiException(error.toString());
    }
  }
}
