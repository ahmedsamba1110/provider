import 'package:edemand_partner/data/model/chat/chatMessage.dart';
import 'package:edemand_partner/data/model/chat/chatUser.dart';
import 'package:path/path.dart' as p;

import '../../../app/generalImports.dart';

class ChatRepository {
  Future<Map<String, dynamic>> fetchChatUsers({required int offset, String? searchString}) async {
    try {
      final response = await Api.post(
        url: Api.getChatUsers,
        useAuthToken: true,
        parameter: {
          "offset": offset.toString(),
          "limit": "25",
          if (searchString != null) "search": searchString
        },
      );

      final List<ChatUser> chatUsers = [];

      for (int i = 0; i < response['data'].length; i++) {
        chatUsers.add(ChatUser.fromJson(response['data'][i]));
      }

      return {
        "chatUsers": chatUsers,
        "totalItems": int.tryParse((response['total'] ?? "1").toString()),
        "totalUnreadUsers": 0, //unused response['total_unread_users'] ??
      };
    } catch (error) {
      throw ApiException(error.toString());
    }
  }

  Future<Map<String, dynamic>> fetchChatMessages({
    required int offset,
    required String bookingId,
    required String type,
    required String customerId,
  }) async {
    try {
      final Map<String, dynamic> parameter = {
        "offset": offset.toString(),
        "limit": "25",
        "booking_id": bookingId,
        "type": type,
        "customer_id": customerId,
      };

      parameter.removeWhere((key, value) =>
          value == null ||
          value == "null" ||
          (key == "booking_id" && (value == "0" || value == "-1")) ||
          value == "-");

      final response =
          await Api.post(url: Api.getChatMessages, useAuthToken: true, parameter: parameter);

      final List<ChatMessage> chatMessage = [];

      for (int i = 0; i < response['data'].length; i++) {
        chatMessage.add(ChatMessage.fromJsonAPI(response['data'][i]));
      }

      return {
        "chatMessages": chatMessage,
        "totalItems": int.tryParse((response['total'] ?? "0").toString()),
      };
    } catch (error) {
      throw ApiException(error.toString());
    }
  }

  Future<ChatMessage> sendChatMessage({
    required String message,
    List<String> filePaths = const [],
    required String receiverId,

    ///0 : Admin 1: Provider
    required String sendMessageTo,
    String? bookingId,
  }) async {
    try {
      //
      final Map<String, dynamic> parameter = {
        "receiver_id": receiverId,
        "message": message,
        "receiver_type": sendMessageTo,
        "booking_id": bookingId,
      };
      if (bookingId == "0" || bookingId == "-1") {
        parameter.remove("booking_id");
      }
      if (receiverId == "-") {
        parameter.remove("receiver_id");
      }
      if (message.isEmpty) {
        parameter.remove("message");
      }
      if (filePaths.isNotEmpty) {
        for (int i = 0; i < filePaths.length; i++) {
          final imagePart = await MultipartFile.fromFile(
            filePaths[i],
            filename: p.basename(filePaths[i]),
          );
          parameter["attachment[$i]"] = imagePart;
        }
      }

      final response =
          await Api.post(url: Api.sendChatMessage, parameter: parameter, useAuthToken: true);

      return ChatMessage.fromJsonAPI(response['data']);
    } catch (e) {
      throw ApiException("somethingWentWrong");
    }
  }
}
