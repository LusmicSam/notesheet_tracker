import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Replace these with your actual Supabase credentials
  static const String supabaseUrl = 'https://qoouvohlmhkgesguerhe.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFvb3V2b2hsbWhrZ2VzZ3VlcmhlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI2Mzg2OTcsImV4cCI6MjA2ODIxNDY5N30.tICw-X_wyTElzK6TXiSrlZC61l64VyBsMukrrSUsrrA';

  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
