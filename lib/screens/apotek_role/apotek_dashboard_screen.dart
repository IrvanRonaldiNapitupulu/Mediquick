import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mediquick/core/constants/api_constants.dart';
import 'package:mediquick/screens/apotek_role/apotek_chat_list_screen.dart';
import 'package:mediquick/screens/apotek_role/order/order_list_screen.dart';
import 'package:mediquick/screens/apotek_role/product_list_screen.dart';
import 'package:mediquick/screens/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApotekDashboardScreen extends StatefulWidget {
  const ApotekDashboardScreen({super.key});

  @override
  State<ApotekDashboardScreen> createState() => _ApotekDashboardScreenState();
}

class _ApotekDashboardScreenState extends State<ApotekDashboardScreen> {
  String userName = 'Apotek';
  String status = 'closed';
  int lowStockCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadLowStock();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('id');

    if (id == null) return;

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.getApotekProfile}?user_id=$id'),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success']) {
          setState(() {
            userName = jsonData['name'] ?? 'Apotek';
            status = jsonData['status'] ?? 'closed';
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _updateStatus(String newStatus) async {
    final prefs = await SharedPreferences.getInstance();
    final apotekProfileId = prefs.getString('apotek_profile_id');

    if (apotekProfileId == null || apotekProfileId.isEmpty) {
      _showSnackbar('Gagal mengubah status: ID apotek tidak ditemukan');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.updateStatus),
        body: {'id': apotekProfileId, 'status': newStatus},
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success']) {
          setState(() => status = newStatus);
          _showSnackbar('Status berhasil diperbarui');
        } else {
          _showSnackbar('Gagal update status: ${result['message']}');
        }
      } else {
        _showSnackbar('Terjadi kesalahan server');
      }
    } catch (e) {
      _showSnackbar('Tidak dapat terhubung ke server');
    }
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _loadLowStock() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.productsReadAll));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success']) {
          final List products = jsonData['data'];
          final lowStockProducts =
              products.where((item) => (item['stok'] ?? 0) <= 5).toList();

          setState(() => lowStockCount = lowStockProducts.length);
        }
      }
    } catch (_) {}
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Logout'),
            content: const Text(
              'Apakah Anda yakin ingin keluar dari aplikasi?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Logout'),
              ),
            ],
          ),
    );

    if (shouldLogout == true) {
      _logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOpen = status == 'open';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Apotek'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _confirmLogout),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHeader(userName, isOpen),
            const SizedBox(height: 20),
            if (lowStockCount > 0) _buildStockAlert(lowStockCount),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.3,
                children: [
                  _buildDashboardCard(
                    icon: Icons.inventory,
                    title: "Manajemen Produk",
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProductListScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    icon: Icons.shopping_cart,
                    title: "Pesanan",
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrderListScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    icon: Icons.chat,
                    title: "Chat Customer",
                    color: Colors.teal,
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final profileIdString = prefs.getString(
                        'apotek_profile_id',
                      );
                      final apotekProfileId =
                          int.tryParse(profileIdString ?? '') ?? 0;

                      if (apotekProfileId != 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ApotekChatListScreen(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Gagal membuka daftar chat: ID apotek tidak valid',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name, bool isOpen) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.local_pharmacy, size: 30, color: Colors.white),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "Status: ${isOpen ? 'Buka' : 'Tutup'}",
                        style: TextStyle(
                          color: isOpen ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Switch(
                        value: isOpen,
                        onChanged: (value) {
                          _updateStatus(value ? 'open' : 'closed');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockAlert(int count) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Stok Menipis'),
                content: Text(
                  '$count produk memiliki stok kurang dari atau sama dengan 5.\nSegera lakukan restok.',
                ),
                actions: [
                  TextButton(
                    child: const Text('Tutup'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "$count produk stok hampir habis",
                style: TextStyle(
                  color: Colors.orange[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
