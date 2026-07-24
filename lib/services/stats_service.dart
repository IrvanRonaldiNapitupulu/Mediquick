// services/stats_service.dart

import 'package:mediquick/core/constants/api_constants.dart';
import 'package:mediquick/core/network/api_client.dart';
import 'package:mediquick/models/stats_model.dart';

/// Service handling admin dashboard statistics retrieval.
class StatService {
  /// Fetches system overview statistics for the admin dashboard.
  Future<StatModel> fetchStats() async {
    final response = await ApiClient.get(ApiConstants.stats);
    if (response is Map<String, dynamic>) {
      return StatModel.fromJson(response);
    } else {
      throw Exception('Gagal memuat statistik sistem');
    }
  }
}
