import 'package:flutter/material.dart';
import 'package:mediquick/core/constants/api_constants.dart';
import 'package:mediquick/core/network/api_client.dart';
import 'package:mediquick/screens/apotek/produk_detail_screen.dart';
import 'package:mediquick/screens/apotek/search_results_screen.dart';

class SearchBarApotek extends StatefulWidget {
  const SearchBarApotek({super.key});

  @override
  State<SearchBarApotek> createState() => _SearchBarApotekState();
}

class _SearchBarApotekState extends State<SearchBarApotek> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<dynamic> _suggestions = [];

  void _onTextChanged(String keyword) async {
    if (keyword.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    try {
      final res = await ApiClient.get('${ApiConstants.productsSearch}?query=$keyword');
      if (res is Map<String, dynamic> && res['success'] == true && res['data'] is List) {
        setState(() => _suggestions = res['data']);
      }
    } catch (_) {}
  }

  void _submitSearch() {
    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      setState(() => _suggestions = []);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SearchResultsPage(query: query)),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() => _suggestions = []);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onChanged: _onTextChanged,
                    onSubmitted: (_) => _submitSearch(),
                    decoration: const InputDecoration(
                      hintText: "Cari nama produk...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: _submitSearch,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 48,
                  width: 48,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.search, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = _suggestions[index];
                return ListTile(
                  leading: item['gambar_url'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            item['gambar_url'],
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.image, size: 40),
                  title: Text(item['nama'] ?? ''),
                  onTap: () {
                    setState(() => _suggestions = []);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(
                          productId: int.parse(item['id'].toString()),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
