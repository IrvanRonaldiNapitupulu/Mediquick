// widget/apotek/all_products_screen.dart
import 'package:flutter/material.dart';
import 'package:mediquick/widgets/apotek/popular_products_section.dart';
import 'package:mediquick/widgets/apotek/search_bar_widget.dart'; // import search bar milikmu

class AllProductsScreen extends StatelessWidget {
  const AllProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Produk'),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SearchBarApotek(),
            SizedBox(height: 16),
            PopularProducts(showAll: true),
          ],
        ),
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}
