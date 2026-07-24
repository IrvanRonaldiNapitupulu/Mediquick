import 'package:mediquick/core/constants/api_constants.dart';
import 'package:mediquick/core/network/api_client.dart';
import 'package:mediquick/models/chat_message_model.dart';

class ChatService {
  Future<int?> createOrGetChat(int userId, int apotekId) async {
    try {
      final response = await ApiClient.post(
        ApiConstants.chatCreateOrGet,
        body: {
          'user_id': userId.toString(),
          'apotek_id': apotekId.toString(),
        },
      );

      if (response is Map<String, dynamic> && response['success'] == true) {
        return int.tryParse(response['chat_id']?.toString() ?? '0');
      }
    } catch (_) {}
    return null;
  }

  Future<bool> sendMessage(int chatId, int senderId, String message) async {
    try {
      final response = await ApiClient.post(
        ApiConstants.chatSendMessage,
        body: {
          'chat_id': chatId.toString(),
          'sender_id': senderId.toString(),
          'message': message,
        },
      );

      if (response is Map<String, dynamic>) {
        return response['success'] == true;
      }
    } catch (_) {}

    return false;
  }

  Future<List<ChatMessage>> getMessages(int chatId) async {
    try {
      final url = '${ApiConstants.chatGetMessages}?chat_id=$chatId';
      final response = await ApiClient.get(url);

      if (response is Map<String, dynamic> && response['success'] == true) {
        return (response['messages'] as List)
            .map((msg) => ChatMessage.fromJson(Map<String, dynamic>.from(msg as Map)))
            .toList();
      }
    } catch (_) {}

    return [];
  }
}
