// screens/account/edit_account_screen.dart

import 'package:flutter/material.dart';
import 'package:mediquick/core/constants/api_constants.dart';
import 'package:mediquick/core/network/api_client.dart';
import 'package:mediquick/core/security/input_sanitizer.dart';
import 'package:mediquick/core/security/input_validator.dart';
import 'package:mediquick/core/security/secure_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final oldPassController = TextEditingController();
  final newPassController = TextEditingController();

  bool isLoading = false;

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    nameController.text = prefs.getString('nama') ?? '';
    emailController.text = prefs.getString('email') ?? '';
  }

  Future<void> _updateAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final userId = await SecureStorageService.getUserId();

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User ID tidak ditemukan")));
      setState(() => isLoading = false);
      return;
    }

    // Sanitize input data (OWASP A03 Injection & Sanitization)
    final cleanName = InputSanitizer.sanitize(nameController.text);
    final cleanEmail = InputSanitizer.sanitize(emailController.text);
    final oldPassword = oldPassController.text.trim();
    final newPassword = newPassController.text.trim();

    try {
      final res = await ApiClient.post(
        ApiConstants.updateAccount,
        body: {
          'user_id': userId,
          'name': cleanName,
          'email': cleanEmail,
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );

      setState(() => isLoading = false);

      if (res is Map<String, dynamic> && (res['success'] == true || res['status'] == true)) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('nama', cleanName);
        await prefs.setString('email', cleanEmail);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res['message'] ?? 'Berhasil mengubah akun')),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          final msg = res is Map<String, dynamic> ? res['message'] : 'Gagal mengubah akun';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg ?? 'Gagal mengubah akun')),
          );
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    oldPassController.dispose();
    newPassController.dispose();
    super.dispose();
  }

  InputDecoration buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF6482AD), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Akun"),
        backgroundColor: const Color(0xFF6482AD),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: nameController,
                decoration: buildInputDecoration("Nama", Icons.person),
                validator: (val) => InputValidator.validateRequired(val, "Nama"),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: buildInputDecoration("Email", Icons.email),
                validator: InputValidator.validateEmail,
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                "Ubah Password (Opsional)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: oldPassController,
                obscureText: true,
                decoration: buildInputDecoration(
                  "Password Lama",
                  Icons.lock_outline,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPassController,
                obscureText: true,
                decoration: buildInputDecoration("Password Baru", Icons.lock),
                validator: (value) {
                  if (oldPassController.text.isNotEmpty) {
                    return InputValidator.validatePassword(value, minLength: 6);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _updateAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6482AD),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            "Simpan Perubahan",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}