import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;
  String? userName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('user_profiles')
          .select('name')
          .eq('user_id', user.id)
          .maybeSingle();

      setState(() {
        userName = response != null && response['name'] != null
            ? response['name']
            : user.email;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        userName = user.email;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final greetingName = userName ?? 'there';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Encomunita Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/auth');
              }
            },
          ),
        ],
      ),
      body: const DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFFEFF9F0), // Light green background
        ),
        child: Center(
          child: SizedBox.shrink(), // Placeholder
        ),
      ),
      bottomNavigationBar: _isLoading
          ? const Padding(
              padding: EdgeInsets.only(bottom: 24.0),
              child: Center(child: CircularProgressIndicator()),
            )
          : Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Center(
                child: Text(
                  'Welcome, $greetingName 👋',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
    );
  }
}
