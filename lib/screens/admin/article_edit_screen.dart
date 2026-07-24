// admin/article/article_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:mediquick/models/article_model.dart';
import 'package:mediquick/widgets/admin/article_form.dart';

class ArticleEditScreen extends StatelessWidget {
  final Article article;

  const ArticleEditScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return ArticleForm(isEdit: true, article: article);
  }
}
