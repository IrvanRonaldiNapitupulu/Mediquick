// screens/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:mediquick/core/constants/api_constants.dart';
import 'package:mediquick/core/network/api_client.dart';
import 'package:mediquick/core/security/input_sanitizer.dart';
import 'package:mediquick/core/security/input_validator.dart';
import 'package:mediquick/core/utils/logger.dart';
import 'package:mediquick/screens/auth/login_screen.dart';
import 'package:mediquick/widgets/auth/register_input_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  Future<void> _validateAndRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Sanitize input data against XSS and Injection (OWASP A03)
      final cleanName = InputSanitizer.sanitize(_nameController.text);
      final cleanEmail = InputSanitizer.sanitize(_emailController.text);
      final cleanPassword = _passwordController.text.trim();

      try {
        final response = await ApiClient.post(
          ApiConstants.register,
          body: {
            "name": cleanName,
            "email": cleanEmail,
            "password": cleanPassword,
            "role": "user",
          },
        );

        AppLogger.debug("Register response: $response");

        if (response is Map<String, dynamic> &&
            (response['status'] == true || response['success'] == true)) {
          _showSuccessDialog();
        } else if (response is Map<String, dynamic> && response.containsKey('message')) {
          _showSnackBar('Error: ${response['message']}');
        } else {
          _showSuccessDialog();
        }
      } catch (e) {
        _showSnackBar("Gagal mendaftar: ${e.toString()}");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Registrasi Berhasil!'),
            content: const Text('Akun Anda berhasil dibuat. Silakan login untuk melanjutkan.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (ctx) => const LoginScreen()),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Registrasi",
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Buat akun sekarang untuk menikmati\nsemua fitur MediQuick",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 30),
                      RegisterInputField(
                        controller: _nameController,
                        icon: Icons.person,
                        hint: "Nama Lengkap / Username",
                        validator: (v) => InputValidator.validateRequired(v, "Nama"),
                      ),
                      const SizedBox(height: 12),
                      RegisterInputField(
                        controller: _emailController,
                        icon: Icons.email,
                        hint: "Email",
                        validator: InputValidator.validateEmail,
                      ),
                      const SizedBox(height: 12),
                      RegisterInputField(
                        controller: _passwordController,
                        icon: Icons.lock,
                        hint: "Kata Sandi",
                        isPassword: true,
                        validator: (v) => InputValidator.validatePassword(v, minLength: 6),
                      ),
                      const SizedBox(height: 12),
                      RegisterInputField(
                        controller: _confirmPasswordController,
                        icon: Icons.lock,
                        hint: "Konfirmasi Kata Sandi",
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Konfirmasi kata sandi wajib diisi";
                          }
                          if (value != _passwordController.text) {
                            return "Kata sandi dan konfirmasi kata sandi tidak sama";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff6482AD),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _isLoading ? null : _validateAndRegister,
                          child: const Text(
                            "Daftar",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Sudah Punya Akun?",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Masuk",
                                style: TextStyle(color: Color(0xFF3311F5)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
