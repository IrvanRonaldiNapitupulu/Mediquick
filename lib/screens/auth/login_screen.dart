// screens/auth/login_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:mediquick/core/constants/api_constants.dart';
import 'package:mediquick/core/network/api_client.dart';
import 'package:mediquick/core/security/input_sanitizer.dart';
import 'package:mediquick/core/security/input_validator.dart';
import 'package:mediquick/core/security/secure_storage_service.dart';
import 'package:mediquick/core/utils/logger.dart';
import 'package:mediquick/screens/admin/admin_dashboard_screen.dart';
import 'package:mediquick/screens/apotek_role/apotek_dashboard_screen.dart';
import 'package:mediquick/screens/auth/forgot_password_screen.dart';
import 'package:mediquick/screens/auth/register_screen.dart';
import 'package:mediquick/screens/navigation_screen.dart';
import 'package:mediquick/services/location_service.dart';
import 'package:mediquick/widgets/auth/custom_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;

  void _handleErrorResponse(dynamic data) {
    final errorMessage =
        data['message']?.toString() ?? 'Terjadi kesalahan. Silakan coba lagi.';
    _showErrorSnackbar(errorMessage);
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> afterLoginSuccess() async {
    try {
      final position = await LocationService.determinePosition();
      final address = await LocationService.getAddressFromPosition(position);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('alamat_user', InputSanitizer.sanitize(address));
      await prefs.setDouble('latitude_user', position.latitude);
      await prefs.setDouble('longitude_user', position.longitude);

      AppLogger.debug("Alamat tersimpan: $address");
    } catch (e) {
      AppLogger.debug("Gagal ambil lokasi: $e");
    }
  }

  Future<void> _validateAndLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Sanitize inputs against XSS and Injection (OWASP A03)
      final cleanEmail = InputSanitizer.sanitize(_emailController.text);
      final cleanPassword = _passwordController.text.trim();

      try {
        final response = await ApiClient.post(
          ApiConstants.login,
          body: {
            "email": cleanEmail,
            "password": cleanPassword,
          },
        );

        if (response != null && response is Map<String, dynamic>) {
          if (response['success'] == true || response.containsKey('token')) {
            await afterLoginSuccess();
            _handleSuccessResponse(response);
          } else {
            _handleErrorResponse(response);
          }
        } else {
          _showErrorSnackbar("Respon server tidak valid");
        }
      } catch (e) {
        _showErrorSnackbar("Terjadi kesalahan: ${e.toString()}");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _handleSuccessResponse(dynamic data) async {
    try {
      final token = data['token']?.toString() ?? '';
      final userData = data['data'];

      if (userData == null) {
        throw const FormatException("Respon server tidak valid");
      }

      final role = InputSanitizer.sanitize(
        userData['role']?.toString().toLowerCase() ?? 'user',
      );

      // Save user session securely (OWASP A02 & A07)
      await SecureStorageService.saveUserSession(
        id: userData['id'].toString(),
        name: userData['name'].toString(),
        email: userData['email'].toString(),
        role: role,
        token: token,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('role', role);
      await prefs.setString('id', userData['id'].toString());
      await prefs.setString('nama', userData['name'].toString());
      await prefs.setString('email', userData['email'].toString());

      if (role == 'apotek') {
        try {
          final apotekRes = await ApiClient.get(
            "${ApiConstants.getApotekProfile}?user_id=${userData['id']}",
          );
          if (apotekRes is Map<String, dynamic> && apotekRes['success'] == true) {
            await prefs.setString(
              'apotek_profile_id',
              apotekRes['apotek_profile_id'].toString(),
            );
            await prefs.setInt(
              'apotek_id',
              int.parse(apotekRes['apotek_profile_id'].toString()),
            );
            await prefs.setString(
              'pharmacy_name',
              InputSanitizer.sanitize((apotekRes['pharmacy_name'] ?? '').toString()),
            );
          }
        } catch (_) {}
      }

      _navigateBasedOnRole(role);
    } catch (e) {
      _showErrorSnackbar(e.toString());
      await SecureStorageService.clearSession();
    }
  }

  void _navigateBasedOnRole(String role) {
    final Map<String, Widget> roleScreens = {
      'admin': const AdminDashboardScreen(),
      'apotek': const ApotekDashboardScreen(),
      'user': const MainScreen(),
    };

    final targetScreen = roleScreens[role] ?? const MainScreen();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => targetScreen),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(key: _formKey, child: _buildLoginForm()),
            ),
          ),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 60),
        const Text(
          "Masuk",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          "Masuk untuk pengalaman terbaik dengan MediQuick",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),
        CustomTextField(
          controller: _emailController,
          hintText: "Email",
          isPassword: false,
          prefixIcon: Icons.email,
          validator: InputValidator.validateEmail,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _passwordController,
          hintText: "Kata Sandi",
          isPassword: true,
          prefixIcon: Icons.lock,
          validator: (val) => InputValidator.validatePassword(val, minLength: 6),
        ),
        const SizedBox(height: 10),
        _buildRememberMeSection(),
        const SizedBox(height: 10),
        _buildLoginButton(),
        const SizedBox(height: 20),
        const _RegisterPrompt(),
      ],
    );
  }

  Widget _buildRememberMeSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged:
                  (value) => setState(() => _rememberMe = value ?? false),
            ),
            const Text("Ingat saya"),
          ],
        ),
        TextButton(
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
              ),
          child: const Text(
            "Lupa kata sandi?",
            style: TextStyle(decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _validateAndLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6482AD),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          "Masuk",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.black54,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              "Memproses...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterPrompt extends StatelessWidget {
  const _RegisterPrompt();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Belum punya akun?"),
          TextButton(
            onPressed:
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
            child: const Text("Daftar", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}
