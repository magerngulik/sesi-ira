import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/auth_state.dart';
import '../cubit/auth_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const String name = 'profile';
  static const String path = '/profile';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthViewState>(
      builder: (context, state) {
        final user = state.user;
        final metadata = user?.userMetadata ?? <String, dynamic>{};

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: <Widget>[
              Center(
                child: Column(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFF0F766E),
                      child: Text(
                        _initials(user?.email),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.email ?? 'Belum login',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user?.id ?? 'Tidak ada user aktif',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              _ProfileSection(
                title: 'Informasi akun',
                children: <Widget>[
                  _ProfileRow(label: 'Email', value: user?.email ?? '-'),
                  _ProfileRow(
                    label: 'Email verified',
                    value: user?.emailConfirmedAt == null ? 'Belum' : 'Ya',
                  ),
                  _ProfileRow(
                    label: 'Last sign in',
                    value: user?.lastSignInAt ?? '-',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ProfileSection(
                title: 'Metadata',
                children: metadata.isEmpty
                    ? const <Widget>[
                        _ProfileRow(
                          label: 'Status',
                          value: 'Belum ada metadata user.',
                        ),
                      ]
                    : metadata.entries
                          .map(
                            (entry) => _ProfileRow(
                              label: entry.key,
                              value: '${entry.value}',
                            ),
                          )
                          .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  String _initials(String? email) {
    if (email == null || email.isEmpty) {
      return 'SI';
    }

    return email.substring(0, 2).toUpperCase();
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
