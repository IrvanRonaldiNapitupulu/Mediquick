import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mediquick/core/constants/api_constants.dart';
import 'package:mediquick/core/utils/logger.dart';
import 'package:mediquick/models/article_model.dart';
import 'package:mediquick/widgets/edukasi/education_card.dart';

class LihatSemuaKesehatanScreen extends StatefulWidget {
  const LihatSemuaKesehatanScreen({super.key});

  @override
  State<LihatSemuaKesehatanScreen> createState() => _LihatSemuaKesehatanScreenState();
}

class _LihatSemuaKesehatanScreenState extends State<LihatSemuaKesehatanScreen> {
  List<Article> articles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    final url = Uri.parse('${ApiConstants.articles}?type=Artikel Kesehatan');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['status'] == true && body['data'] is List) {
          setState(() {
            articles = (body['data'] as List)
                .map((json) => Article.fromJson(Map<String, dynamic>.from(json as Map)))
                .toList();
            isLoading = false;
          });
        }
      } else {
        throw Exception('Gagal memuat artikel');
      }
    } catch (e) {
      AppLogger.debug('Error: $e');
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Artikel Kesehatan"),
        backgroundColor: const Color(0xFF6482AD),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5EDED),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: EducationCard(article: articles[index]),
                );
              },
            ),
    );
  }
}
