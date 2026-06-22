import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/apartment_provider.dart';
import 'providers/booking_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/apartment_detail_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/add_apartment_screen.dart';
import 'screens/my_bookings_screen.dart';
import 'screens/all_bookings_screen.dart';

void main() {
  runApp(const StudentHousingApp());
}

class StudentHousingApp extends StatelessWidget {
  const StudentHousingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ApartmentProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: MaterialApp(
        title: 'سكنكم',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF1565C0),
          fontFamily: 'Cairo',
        ),
        locale: const Locale('ar'),
        home: const SplashScreen(),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const HomeScreen(),
          '/admin': (_) => const AdminDashboardScreen(),
          '/add-apartment': (_) => const AddApartmentScreen(),
          '/my-bookings': (_) => const MyBookingsScreen(),
          '/all-bookings': (_) => const AllBookingsScreen(),
        },
      ),
    );
  }
}
