import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mediquick/core/constants/api_constants.dart';
import 'package:mediquick/core/utils/logger.dart';
import 'package:mediquick/screens/apotek/all_products_screen.dart';
import 'package:mediquick/screens/apotek/produk_detail_screen.dart';

class PopularProducts extends StatefulWidget {
  final bool showAll;

  const PopularProducts({super.key, this.showAll = false});

  @override
  State<PopularProducts> createState() => _PopularProductsState();
}

class _PopularProductsState extends State<PopularProducts> {
  List<dynamic> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final url = Uri.parse(ApiConstants.productsReadAll);
    try {
      final response = await http.get(url);
      AppLogger.debug('RESPONSE: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _products = data['data'];
            _loading = false;
          });
        } else {
          showError(data['message'] ?? 'Gagal memuat produk');
        }
      } else {
        showError('Gagal memuat produk');
      }
    } catch (e) {
      showError('Terjadi kesalahan: $e');
    }
  }

  void showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    setState(() => _loading = false);
  }

  String formatRupiah(dynamic number) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final value = int.tryParse(number.toString()) ?? 0;
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final displayProducts = widget.showAll
        ? _products
        : _products.take(4).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Telusuri Produk Kami', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 12),
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _products.isEmpty
                  ? const Center(child: Text('Tidak ada produk tersedia'))
                  : Column(
                      children: [
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.7,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: displayProducts.map((product) {
                            return PharmacyCard(
                              productId: int.parse(product['id'].toString()),
                              imagePath: product['gambar_url'] ?? '',
                              title: product['nama'] ?? '',
                              price: formatRupiah(product['harga']),
                              pharmacyName: product['nama_apotek'] ?? 'Apotek',
                            );
                          }).toList(),
                        ),
                        if (!widget.showAll && _products.length > 4)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AllProductsScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Lihat Semua Produk',
                                style: TextStyle(color: Colors.teal),
                              ),
                            ),
                          ),
                      ],
                    ),
        ],
      ),
    );
  }
}

class PharmacyCard extends StatelessWidget {
  final int productId;
  final String imagePath;
  final String title;
  final String price;
  final String pharmacyName;

  const PharmacyCard({
    super.key,
    required this.productId,
    required this.imagePath,
    required this.title,
    required this.price,
    required this.pharmacyName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: productId),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imagePath.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imagePath,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 60),
                    ),
                  )
                : const Icon(Icons.image, size: 60),
            const SizedBox(height: 14),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(price, style: const TextStyle(color: Colors.teal)),
            const SizedBox(height: 35),
            Text(
              pharmacyName.isNotEmpty ? pharmacyName : 'Apotek',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
