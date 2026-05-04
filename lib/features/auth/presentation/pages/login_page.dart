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
        final selectedRole = state.selectedRole;

        return Scaffold(
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[Color(0xFFFFF7FB), Color(0xFFF6F1FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: <Widget>[
                const Positioned(
                  top: -80,
                  left: -40,
                  child: _SoftGlow(
                    size: 220,
                    colors: <Color>[Color(0xFFFFC2DE), Color(0x00FFC2DE)],
                  ),
                ),
                const Positioned(
                  top: 180,
                  right: -60,
                  child: _SoftGlow(
                    size: 240,
                    colors: <Color>[Color(0xFFD7C0FF), Color(0x00D7C0FF)],
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: selectedRole == null
                            ? _RoleSelectionView(
                                isConfigured: isConfigured,
                                onRoleSelected: (role) => context
                                    .read<AuthCubit>()
                                    .selectLoginRole(role),
                              )
                            : _RoleLoginView(
                                formKey: _formKey,
                                emailController: _emailController,
                                passwordController: _passwordController,
                                isBusy: isBusy,
                                isConfigured: isConfigured,
                                role: selectedRole,
                                onBack: () {
                                  _formKey.currentState?.reset();
                                  _emailController.clear();
                                  _passwordController.clear();
                                  context.read<AuthCubit>().clearSelectedRole();
                                },
                                onSubmit: () => _submit(context),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final authCubit = context.read<AuthCubit>();
    await authCubit.signIn(email: email, password: password);
  }
}

class _RoleSelectionView extends StatelessWidget {
  const _RoleSelectionView({
    required this.isConfigured,
    required this.onRoleSelected,
  });

  final bool isConfigured;
  final ValueChanged<LoginRole> onRoleSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1FDB2777),
            blurRadius: 26,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: <Color>[Color(0xFFFFE0F1), Color(0xFFEDE2FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.local_florist_rounded,
                color: Color(0xFFE11D8D),
                size: 42,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Selamat datang di Sesi Ira',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1F2937),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Pilih jenis akun untuk melanjutkan ke flow login yang sesuai.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF667085),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (!isConfigured) ...<Widget>[
            _ConfigWarningCard(
              url: SupabaseConfig.url,
              anonKey: SupabaseConfig.anonKey,
            ),
            const SizedBox(height: 20),
          ],
          _RoleCard(
            title: 'Admin',
            subtitle:
                'Kelola data master, pengguna, laporan, dan operasional sistem.',
            icon: Icons.admin_panel_settings_outlined,
            accent: const Color(0xFFE11D8D),
            background: const Color(0xFFFFF1F7),
            onTap: isConfigured ? () => onRoleSelected(LoginRole.admin) : null,
          ),
          const SizedBox(height: 16),
          _RoleCard(
            title: 'Psikolog',
            subtitle: 'Kelola kasus, sesi terapi, asesmen, dan data klien.',
            icon: Icons.psychology_alt_rounded,
            accent: const Color(0xFF7C3AED),
            background: const Color(0xFFF6F1FF),
            onTap: isConfigured
                ? () => onRoleSelected(LoginRole.psychologist)
                : null,
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBFF),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFF3D6EA)),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE4F1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: Color(0xFFE11D8D),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'SSO dilewati sesuai brief. Login hanya pakai email dan password.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF667085),
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleLoginView extends StatefulWidget {
  const _RoleLoginView({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isBusy,
    required this.isConfigured,
    required this.role,
    required this.onBack,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isBusy;
  final bool isConfigured;
  final LoginRole role;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  @override
  State<_RoleLoginView> createState() => _RoleLoginViewState();
}

class _RoleLoginViewState extends State<_RoleLoginView> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final accent = widget.role == LoginRole.admin
        ? const Color(0xFFE11D8D)
        : const Color(0xFF7C3AED);
    final icon = widget.role == LoginRole.admin
        ? Icons.admin_panel_settings_outlined
        : Icons.psychology_alt_rounded;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1A7C3AED),
            blurRadius: 28,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            IconButton(
              onPressed: widget.isBusy ? null : widget.onBack,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: <Color>[
                      accent.withValues(alpha: 0.16),
                      accent.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(icon, color: accent, size: 46),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Text(
                'Login sebagai ${widget.role.title}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                widget.role.subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF667085),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (!widget.isConfigured) ...<Widget>[
              _ConfigWarningCard(
                url: SupabaseConfig.url,
                anonKey: SupabaseConfig.anonKey,
              ),
              const SizedBox(height: 20),
            ],
            Text(
              widget.role.emailLabel,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: widget.emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: widget.role.emailHint,
                prefixIcon: const Icon(Icons.mail_outline_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '${widget.role.emailLabel} wajib diisi.';
                }
                if (!value.contains('@')) {
                  return 'Format email belum valid.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Password',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: widget.passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: 'Masukkan password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
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
                onPressed: !widget.isConfigured || widget.isBusy
                    ? null
                    : widget.onSubmit,
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  widget.isBusy
                      ? 'Memproses...'
                      : 'Masuk sebagai ${widget.role.title}',
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: TextButton(
                onPressed: widget.isBusy ? null : widget.onBack,
                child: Text(
                  'Bukan akun ${widget.role.title.toLowerCase()}? Kembali',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.background,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Color background;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: accent.withValues(alpha: 0.16)),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accent, size: 34),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Login sebagai',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF667085),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: accent,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF475467),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftGlow extends StatelessWidget {
  const _SoftGlow({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
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
