import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sesi_ira/core/widgets/dashed_line.dart';

import '../../../cases/presentation/pages/cases_page.dart';
import '../../../clients/presentation/pages/clients_page.dart';
import '../../../master_data/presentation/pages/master_data_page.dart';
import '../../../psychologists/presentation/pages/psychologists_page.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const String name = 'home';
  static const String path = '/home';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthViewState>(
      builder: (context, state) {
        final screenWidth = MediaQuery.sizeOf(context).width;
        final isDesktop = screenWidth >= 920;
        final summaryCrossAxisCount = isDesktop ? 4 : 2;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard'),
            actions: <Widget>[
              IconButton(
                onPressed: () => context.read<AuthCubit>().bootstrap(),
                tooltip: 'Refresh Auth',
                icon: const Icon(Icons.sync_rounded),
              ),
              IconButton(
                onPressed: () => context.read<AuthCubit>().signOut(),
                tooltip: 'Logout',
                icon: const Icon(Icons.logout_rounded),
              ),
            ],
          ),
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[Color(0xFFF4F7F3), Color(0xFFE9F3F1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                children: <Widget>[
                  _HeroSection(
                    status: state.status.name,
                    onPrimaryTap: () => context.push(MasterDataPage.path),
                    onSecondaryTap: () => context.push(CasesPage.path),
                  ),
                  const SizedBox(height: 20),
                  _SectionTitle(
                    title: 'Ringkasan Cepat',
                    subtitle: 'Titik masuk utama untuk operasional harian.',
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: summaryCrossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 15,
                    // childAspectRatio: isDesktop ? 1.45 : 1.2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const <Widget>[
                      _SummaryCard(
                        title: 'Klien',
                        value: 'Client intake',
                        description:
                            'Kelola biodata, kontak, dan catatan awal klien.',
                        icon: Icons.groups_rounded,
                        accent: Color(0xFF0F766E),
                      ),
                      _SummaryCard(
                        title: 'Psikolog',
                        value: 'Tim aktif',
                        description:
                            'Atur praktisi yang menangani proses terapi.',
                        icon: Icons.psychology_alt_rounded,
                        accent: Color(0xFF0F4C81),
                      ),
                      _SummaryCard(
                        title: 'Case',
                        value: 'Terapi berjalan',
                        description:
                            'Hubungkan klien, tujuan, dan penanggung jawab.',
                        icon: Icons.folder_open_rounded,
                        accent: Color(0xFFB45309),
                      ),
                      _SummaryCard(
                        title: 'Sesi',
                        value: 'Tahap berikutnya',
                        description:
                            'Dashboard siap dilanjutkan ke pencatatan sesi.',
                        icon: Icons.event_note_rounded,
                        accent: Color(0xFF7C3AED),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _SectionTitle(
                    title: 'Navigasi Utama',
                    subtitle:
                        'Pisahkan area admin untuk master data dan area operasional harian.',
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.5,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      _FeatureCard(
                        title: 'Master Data',
                        subtitle:
                            'Pusat navigasi admin untuk input data dasar psikolog, client, dan kebutuhan modul case.',
                        badge: 'Admin',
                        icon: Icons.account_tree_rounded,
                        accent: const Color(0xFF0F4C81),
                        onTap: () => context.push(MasterDataPage.path),
                      ),
                      _FeatureCard(
                        title: 'Manajemen Klien',
                        subtitle:
                            'Mulai dari data dasar klien sebelum masuk ke proses case.',
                        badge: 'Data dasar',
                        icon: Icons.badge_rounded,
                        accent: const Color(0xFF0F766E),
                        onTap: () => context.push(ClientsPage.path),
                      ),
                      _FeatureCard(
                        title: 'Manajemen Psikolog',
                        subtitle:
                            'Lihat praktisi aktif dan siapkan assignment untuk case.',
                        badge: 'Resource',
                        icon: Icons.psychology_rounded,
                        accent: const Color(0xFF1D4ED8),
                        onTap: () => context.push(PsychologistsPage.path),
                      ),
                      _FeatureCard(
                        title: 'Case Monitoring',
                        subtitle:
                            'Buat case baru, tentukan tujuan, dan hubungkan pihak terkait.',
                        badge: 'Core workflow',
                        icon: Icons.assignment_rounded,
                        accent: const Color(0xFFD97706),
                        onTap: () => context.push(CasesPage.path),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.status,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
  });

  final String status;
  final VoidCallback onPrimaryTap;
  final VoidCallback onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFF0F766E),
            Color(0xFF164E63),
            Color(0xFF1E3A5F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x220F172A),
            blurRadius: 28,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -18,
            right: -16,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -36,
            right: 54,
            child: Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Sesi Ira Workspace',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Dashboard admin dan operasional kini dipisah lebih jelas.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Masuk ke area master data untuk input kebutuhan inti tiap modul, lalu lanjutkan workflow harian ke case dan sesi.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  _HeroInfoPill(
                    icon: Icons.shield_outlined,
                    label: 'Status ${status.toUpperCase()}',
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  FilledButton.icon(
                    onPressed: onPrimaryTap,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0F766E),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Buka Master Data'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onSecondaryTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.28),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                    ),
                    icon: const Icon(Icons.assignment_rounded),
                    label: const Text('Buka Case'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF17212B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF526071)),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.description,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String value;
  final String description;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent),
          ),
          const Spacer(),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF526071),
              height: 1.4,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String badge;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(width: 1.0, color: accent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: accent),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF526071),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            DashedLine(color: accent),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  'Buka menu',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, color: accent, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroInfoPill extends StatelessWidget {
  const _HeroInfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
