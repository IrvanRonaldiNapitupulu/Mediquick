import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mediquick/core/constants/api_constants.dart';
import 'package:mediquick/widgets/kelas/kelas_card.dart';
import 'package:mediquick/widgets/kelas/kelas_search_bar.dart';

class KelasScreen extends StatefulWidget {
  const KelasScreen({super.key});

  @override
  State<KelasScreen> createState() => _KelasScreenState();
}

class _KelasScreenState extends State<KelasScreen> {
  List<Map<String, dynamic>> allModules = [];
  List<Map<String, dynamic>> filteredModules = [];

  final _baseUrl = ApiConstants.courseModuleApi;

  @override
  void initState() {
    super.initState();
    fetchModules();
  }

  Future<void> fetchModules() async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl?action=read"));
      final data = json.decode(response.body);

      if (data['success'] == true && data['data'] is List) {
        setState(() {
          allModules = (data['data'] as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          filteredModules = allModules;
        });
      }
    } catch (e) {
      debugPrint("Error fetching modules: $e");
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      filteredModules = allModules.where((modul) {
        final title = (modul['title'] ?? '').toString().toLowerCase();
        return title.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EDED),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              ClassSearchBar(onChanged: _onSearchChanged),
              const SizedBox(height: 24),
              ClassCardGrid(classes: filteredModules),
            ],
          ),
        ),
      ),
    );
  }
}
