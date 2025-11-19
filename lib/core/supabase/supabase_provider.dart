/// Supabase client provider
/// Singleton access to Supabase client throughout the app
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final supabaseAuthProvider = Provider<GoTrueClient>((ref) {
  return ref.watch(supabaseProvider).auth;
});

final supabaseStorageProvider = Provider<SupabaseStorageClient>((ref) {
  return ref.watch(supabaseProvider).storage;
});

final supabaseRealtimeProvider = Provider<RealtimeClient>((ref) {
  return ref.watch(supabaseProvider).realtime;
});
