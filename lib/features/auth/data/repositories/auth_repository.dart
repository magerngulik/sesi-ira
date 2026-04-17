import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/services/supabase_service.dart';

class AuthRepository {
  const AuthRepository();

  Stream<AuthState> get authStateChanges {
    if (!SupabaseService.isConfigured) {
      return const Stream<AuthState>.empty();
    }

    return SupabaseService.client.auth.onAuthStateChange;
  }

  User? get currentUser {
    if (!SupabaseService.isConfigured) {
      return null;
    }

    return SupabaseService.client.auth.currentUser;
  }

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    _ensureConfigured();

    try {
      return await SupabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (error) {
      throw AppException(error.message);
    }
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    _ensureConfigured();

    try {
      return await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
      );
    } on AuthException catch (error) {
      throw AppException(error.message);
    }
  }

  Future<void> signOut() async {
    _ensureConfigured();

    try {
      await SupabaseService.client.auth.signOut();
    } on AuthException catch (error) {
      throw AppException(error.message);
    }
  }

  void _ensureConfigured() {
    if (!SupabaseService.isConfigured) {
      throw AppException(
        'Supabase belum dikonfigurasi. Jalankan app dengan --dart-define untuk SUPABASE_URL dan SUPABASE_ANON_KEY.',
      );
    }
  }
}
