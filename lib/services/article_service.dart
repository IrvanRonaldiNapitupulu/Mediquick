import 'package:mediquick/core/constants/api_constants.dart';
import 'package:mediquick/core/network/api_client.dart';
import 'package:mediquick/models/article_model.dart';

class ArticleService {
  static const String _endpoint = ApiConstants.articles;

  Future<List<Article>> getArticles() async {
    final response = await ApiClient.get(_endpoint);

    if (response is Map<String, dynamic> &&
        response['status'] == true &&
        response.containsKey('data')) {
      return (response['data'] as List)
          .map((json) => Article.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();
    } else {
      throw Exception(response['error'] ?? 'Gagal mengambil artikel');
    }
  }

  Future<Article> createArticle(Article article) async {
    try {
      final response = await ApiClient.post(
        _endpoint,
        body: article.toJson(),
      );

      if (response is Map<String, dynamic> && response['status'] == true) {
        final newId = int.tryParse(response['id'].toString()) ?? 0;
        return article.copyWith(id: newId);
      } else {
        throw Exception(response['error'] ?? 'Gagal membuat artikel');
      }
    } catch (e) {
      throw Exception('Gagal membuat artikel: ${e.toString()}');
    }
  }

  Future<void> updateArticle(Article article) async {
    final url = '$_endpoint/${article.id}';
    final response = await ApiClient.post(
      url,
      body: article.toJson(),
    );

    if (response is Map<String, dynamic> && response['status'] != true) {
      throw Exception(response['error'] ?? 'Gagal update artikel');
    }
  }

  Future<void> deleteArticle(int id) async {
    final url = '$_endpoint/$id';
    final response = await ApiClient.get(url);

    if (response is Map<String, dynamic> && response['status'] != true) {
      throw Exception(response['error'] ?? 'Gagal menghapus artikel');
    }
  }
}
