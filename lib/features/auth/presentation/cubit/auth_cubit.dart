import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthViewState> {
  AuthCubit({AuthRepository? repository})
    : _repository = repository ?? const AuthRepository(),
      super(const AuthViewState());

  final AuthRepository _repository;
  StreamSubscription<AuthState>? _authSubscription;

  Future<void> bootstrap() async {
    emit(state.copyWith(status: AuthStatus.loading, clearMessage: true));

    final user = _repository.currentUser;
    emit(
      state.copyWith(
        status: user == null
            ? AuthStatus.unauthenticated
            : AuthStatus.authenticated,
        user: user,
      ),
    );

    await _authSubscription?.cancel();
    _authSubscription = _repository.authStateChanges.listen((authState) {
      final user = authState.session?.user;
      emit(
        state.copyWith(
          status: user == null
              ? AuthStatus.unauthenticated
              : AuthStatus.authenticated,
          user: user,
          clearMessage: true,
        ),
      );
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(state.copyWith(status: AuthStatus.loading, clearMessage: true));

    try {
      final response = await _repository.signInWithPassword(
        email: email,
        password: password,
      );
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: response.user,
          message: 'Login berhasil.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(status: AuthStatus.failure, message: error.toString()),
      );
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    emit(state.copyWith(status: AuthStatus.loading, clearMessage: true));

    try {
      final response = await _repository.signUp(
        email: email,
        password: password,
      );
      final user = response.user;
      emit(
        state.copyWith(
          status: user == null
              ? AuthStatus.unauthenticated
              : AuthStatus.authenticated,
          user: user,
          message: user == null
              ? 'Akun berhasil dibuat. Cek email untuk verifikasi sebelum login.'
              : 'Akun berhasil dibuat dan langsung aktif.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(status: AuthStatus.failure, message: error.toString()),
      );
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> signOut() async {
    emit(state.copyWith(status: AuthStatus.loading, clearMessage: true));

    try {
      await _repository.signOut();
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
          message: 'Kamu sudah logout.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(status: AuthStatus.failure, message: error.toString()),
      );
      emit(
        state.copyWith(
          status: state.user == null
              ? AuthStatus.unauthenticated
              : AuthStatus.authenticated,
        ),
      );
    }
  }

  void toggleAuthMode() {
    emit(state.copyWith(isLoginMode: !state.isLoginMode, clearMessage: true));
  }

  void clearMessage() {
    emit(state.copyWith(clearMessage: true));
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}
