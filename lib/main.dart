import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mediquick/core/theme/app_theme.dart';
import 'package:mediquick/providers/cart_provider.dart';
import 'package:mediquick/screens/admin/admin_dashboard_screen.dart';
import 'package:mediquick/screens/apotek_role/apotek_dashboard_screen.dart';
import 'package:mediquick/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MediQuick(),
    ),
  );
}

class MediQuick extends StatelessWidget {
  const MediQuick({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediQuick',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: SplashScreen(),
      routes: {
        '/admin': (context) => const AdminDashboardScreen(),
        '/apotek': (context) => const ApotekDashboardScreen(),
      },
    );
  }
}
