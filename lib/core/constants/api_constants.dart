class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://mediquick.my.id';
  static const String secureBaseUrl = 'https://mediquick.my.id';

  // Auth
  static const String login = '$baseUrl/login.php';
  static const String register = '$baseUrl/add_users.php';

  // User
  static const String getUser = '$baseUrl/users/get_user.php';
  static const String updateAccount = '$baseUrl/users/update_account.php';
  static const String getApotekProfile =
      '$baseUrl/users/get_apotek_profile.php';
  static const String updateStatus = '$baseUrl/users/update_status.php';

  // Product
  static const String productsReadAll = '$baseUrl/products/read_all.php';
  static const String productsReadDetail = '$baseUrl/products/read_detail.php';
  static const String productsReadByApotek =
      '$baseUrl/products/read_by_apotek.php';
  static const String productsAdd = '$baseUrl/products/add_product.php';
  static const String productsUpdate = '$baseUrl/products/update.php';
  static const String productsDelete = '$baseUrl/products/delete.php';
  static const String productsSearch = '$baseUrl/products/search.php';
  static const String productsFilterByJenis =
      '$baseUrl/products/filter_by_jenis.php';

  // Article
  static const String articles = '$secureBaseUrl/api_article.php';

  // Chat
  static const String chatBase = '$baseUrl/chatbox';
  static const String chatCreateOrGet = '$chatBase/create_or_get_chat.php';
  static const String chatSendMessage = '$chatBase/chat_send_message.php';
  static const String chatGetMessages = '$chatBase/get_messages.php';
  static const String chatGetByUser = '$chatBase/get_chats_by_user.php';
  static const String chatGetByApotek = '$chatBase/get_chats_by_apotek.php';

  // Order & Payment
  static const String orderSnapToken = '$baseUrl/payment/snap_token.php';
  static const String orderGetByApotek =
      '$baseUrl/apotek/get_by_apotek.php';
  static const String orderGetDetail =
      '$baseUrl/orders/get_order_detail.php';
  static const String orderUpdateStatus = '$baseUrl/orders/update_status.php';
  static const String orderGetNotifications =
      '$baseUrl/orders/get_notifications.php';
  static const String orderMarkAllRead =
      '$baseUrl/orders/mark_all_as_read.php';
  static const String orderGetUnreadCount =
      '$baseUrl/orders/get_unread_count.php';

  // Admin
  static const String stats = '$baseUrl/api_stats.php';
  static const String adminRegisterApotek =
      '$baseUrl/endpoints/apotek/register_apotek.php';
  static const String adminDeleteApotek =
      '$secureBaseUrl/endpoints/admin/delete_apotek.php';

  // Course & Quiz
  static const String courseModuleApi =
      '$baseUrl/Course/Admin/module_api.php';
  static const String courseQuizApi =
      '$baseUrl/Course/User/quiz_api.php';

  // Misc
  static const String upload = '$secureBaseUrl/uploads/upload.php';
  static const String nearestAmbulance =
      '$baseUrl/get_nearest_ambulance.php';
}
