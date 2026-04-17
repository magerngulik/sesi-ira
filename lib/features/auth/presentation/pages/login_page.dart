import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/supabase_config.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const String name = 'login';
  static const String path = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthViewState>(
      listener: (context, state) {
        final message = state.message;
        if (message != null && message.isNotEmpty) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
          context.read<AuthCubit>().clearMessage();
        }

        if (state.status == AuthStatus.authenticated) {
          context.go(HomePage.path);
        }
      },
      builder: (context, state) {
        final isBusy = state.status == AuthStatus.loading;
        final isConfigured = SupabaseConfig.isConfigured;
        final isLoginMode = state.isLoginMode;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[Color(0xFFEAF7F2), Color(0xFFF7F4EA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Card(
                      elevation: 0,
                      color: Colors.white.withValues(alpha: 0.92),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0F766E),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.lock_person_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                isLoginMode
                                    ? 'Masuk ke Sesi Ira'
                                    : 'Buat akun baru',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isLoginMode
                                    ? 'Login dengan email dan password Supabase kamu.'
                                    : 'Daftarkan akun baru untuk mulai memakai aplikasi.',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 24),
                              if (!isConfigured) ...<Widget>[
                                _ConfigWarningCard(
                                  url: SupabaseConfig.url,
                                  anonKey: SupabaseConfig.anonKey,
                                ),
                                const SizedBox(height: 20),
                              ],
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.mail_outline_rounded),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Email wajib diisi.';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Format email belum valid.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icon(Icons.key_rounded),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password wajib diisi.';
                                  }
                                  if (value.length < 6) {
                                    return 'Minimal 6 karakter.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: !isConfigured || isBusy
                                      ? null
                                      : () => _submit(context, isLoginMode),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                  ),
                                  child: Text(
                                    isBusy
                                        ? 'Memproses...'
                                        : isLoginMode
                                        ? 'Masuk'
                                        : 'Daftar',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Center(
                                child: TextButton(
                                  onPressed: isBusy
                                      ? null
                                      : context
                                            .read<AuthCubit>()
                                            .toggleAuthMode,
                                  child: Text(
                                    isLoginMode
                                        ? 'Belum punya akun? Daftar'
                                        : 'Sudah punya akun? Masuk',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _submit(BuildContext context, bool isLoginMode) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final authCubit = context.read<AuthCubit>();

    if (isLoginMode) {
      await authCubit.signIn(email: email, password: password);
      return;
    }

    await authCubit.signUp(email: email, password: password);
  }
}

class _ConfigWarningCard extends StatelessWidget {
  const _ConfigWarningCard({required this.url, required this.anonKey});

  final String url;
  final String anonKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF4C26B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.info_outline_rounded, color: Color(0xFFA16207)),
              const SizedBox(width: 10),
              Text(
                'Supabase belum diisi',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Jalankan app dengan dart define berikut agar login aktif:',
          ),
          const SizedBox(height: 10),
          SelectableText(
            'flutter run --dart-define=SUPABASE_URL=... '
            '--dart-define=SUPABASE_ANON_KEY=...',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
            ),
          ),
          if (url.isNotEmpty || anonKey.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              'Config saat ini terdeteksi sebagian. Pastikan dua-duanya terisi.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
