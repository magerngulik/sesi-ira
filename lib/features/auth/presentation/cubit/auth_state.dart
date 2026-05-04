import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthStatus {
  initial,
  loading,
  unauthenticated,
  authenticated,
  failure,
}

enum LoginRole {
  admin,
  psychologist;

  String get title => switch (this) {
    LoginRole.admin => 'Admin',
    LoginRole.psychologist => 'Psikolog',
  };

  String get emailLabel => switch (this) {
    LoginRole.admin => 'Email Admin',
    LoginRole.psychologist => 'Email Psikolog',
  };

  String get emailHint => switch (this) {
    LoginRole.admin => 'Masukkan email admin',
    LoginRole.psychologist => 'Masukkan email psikolog',
  };

  String get subtitle => switch (this) {
    LoginRole.admin => 'Masukkan kredensial Anda untuk mengakses panel admin.',
    LoginRole.psychologist =>
      'Masukkan kredensial Anda untuk mengakses sistem psikolog.',
  };
}

class AuthViewState extends Equatable {
  const AuthViewState({
    this.status = AuthStatus.initial,
    this.user,
    this.message,
    this.selectedRole,
  });

  final AuthStatus status;
  final User? user;
  final String? message;
  final LoginRole? selectedRole;

  AuthViewState copyWith({
    AuthStatus? status,
    User? user,
    String? message,
    bool clearMessage = false,
    LoginRole? selectedRole,
    bool clearSelectedRole = false,
  }) {
    return AuthViewState(
      status: status ?? this.status,
      user: user ?? this.user,
      message: clearMessage ? null : (message ?? this.message),
      selectedRole: clearSelectedRole
          ? null
          : (selectedRole ?? this.selectedRole),
    );
  }

  @override
  List<Object?> get props => <Object?>[status, user, message, selectedRole];
}
