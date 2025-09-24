import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase configuration with security best practices
class SupabaseConfig {
  // Production Supabase credentials
  static const String supabaseUrl = 'https://uroeoeqcqasuxfmkrysu.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVyb2VvZXFjcWFzdXhmbWtyeXN1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg0MTgwOTMsImV4cCI6MjA3Mzk5NDA5M30.KerxHGr43G8CdfE8YVmM2Im1SaI9Fh3cpSFZlLHuTHw';

  /// Initialize Supabase with security configurations
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: false, // Disable debug in production
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce, // More secure PKCE flow
        autoRefreshToken: true,
      ),
    );

  }

  /// Get the Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;

  /// Get the current user
  static User? get currentUser => client.auth.currentUser;

  /// Get the current session
  static Session? get currentSession => client.auth.currentSession;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Database table names
  static const String userProfilesTable = 'user_profiles';
  static const String communitiesTable = 'communities';
  static const String eventsTable = 'events';
  static const String eventRsvpsTable = 'event_rsvps';
  static const String marketplaceListingsTable = 'marketplace_listings';
  static const String marketplaceInquiriesTable = 'marketplace_inquiries';
}