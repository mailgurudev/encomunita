import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'theme.dart';
import 'screens/profile_setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xyhprxckjecmzjzbklcb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh5aHByeGNramVjbXpqemJrbGNiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgxMzQ0MjMsImV4cCI6MjA3MzcxMDQyM30.4NVk6aNel2ZqRGhrB-b6-iykdSXZu3dsu7iGiJbfizs',
  );

  runApp(const EncomunitaApp());
}

class EncomunitaApp extends StatelessWidget {
  const EncomunitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Encomunita',
      theme: appTheme, // ✅ Use custom green theme from theme.dart
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) {
          final session = Supabase.instance.client.auth.currentSession;
          return session == null ? const AuthScreen() : const HomeScreen();
        },
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile-setup': (context) => const ProfileSetupScreen(),
      },
    );
  }
}