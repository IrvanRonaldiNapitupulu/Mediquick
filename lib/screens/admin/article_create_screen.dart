// admin/article/article_create_screen.dart
import 'package:flutter/material.dart';
import 'package:mediquick/widgets/admin/article_form.dart';

class ArticleCreateScreen extends StatelessWidget {
  const ArticleCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ArticleForm(
      isEdit: false,
      article: null,
    );
  }
}
