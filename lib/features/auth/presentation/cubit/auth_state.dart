import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthStatus {
  initial,
  loading,
  unauthenticated,
  authenticated,
  failure,
}

class AuthViewState extends Equatable {
  const AuthViewState({
    this.status = AuthStatus.initial,
    this.user,
    this.message,
    this.isLoginMode = true,
  });

  final AuthStatus status;
  final User? user;
  final String? message;
  final bool isLoginMode;

  AuthViewState copyWith({
    AuthStatus? status,
    User? user,
    String? message,
    bool clearMessage = false,
    bool? isLoginMode,
  }) {
    return AuthViewState(
      status: status ?? this.status,
      user: user ?? this.user,
      message: clearMessage ? null : (message ?? this.message),
      isLoginMode: isLoginMode ?? this.isLoginMode,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, user, message, isLoginMode];
}
