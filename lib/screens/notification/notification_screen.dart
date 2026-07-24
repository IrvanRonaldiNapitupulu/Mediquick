import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mediquick/core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    markNotificationsAsRead();
    fetchNotifications();
  }

  Future<void> markNotificationsAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('id');
    if (userId == null) return;

    final response = await http.post(
      Uri.parse(ApiConstants.orderMarkAllRead),
      body: {'user_id': userId},
    );

    if (response.statusCode == 200) {
      debugPrint("✅ Semua notifikasi ditandai sebagai dibaca");
    } else {
      debugPrint("❌ Gagal menandai notifikasi sebagai dibaca");
    }
  }

  Future<void> fetchNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('id');

    if (userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User ID tidak ditemukan")));
      return;
    }

    final url = Uri.parse(
      '${ApiConstants.orderGetNotifications}?user_id=$userId',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        setState(() {
          notifications = data['data'] is List ? data['data'] : [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text((data['message'] ?? 'Gagal mengambil notifikasi').toString()),
          ),
        );
      }
    } else {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal terhubung ke server')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifikasi")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : notifications.isEmpty
              ? const Center(child: Text("Belum ada notifikasi"))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  final isRead = notif['is_read'].toString() == '1';
                  return Card(
                    elevation: 2,
                    color: !isRead ? Colors.blue.shade50 : Colors.white,
                    child: ListTile(
                      leading: Icon(
                        !isRead ? Icons.notifications_active : Icons.notifications_none,
                        color: !isRead ? Colors.blue : Colors.grey,
                      ),
                      title: Text(
                        (notif['title'] ?? 'Notifikasi').toString(),
                        style: TextStyle(
                          fontWeight: !isRead ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text((notif['message'] ?? '').toString()),
                          const SizedBox(height: 4),
                          Text(
                            (notif['created_at'] ?? '').toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
