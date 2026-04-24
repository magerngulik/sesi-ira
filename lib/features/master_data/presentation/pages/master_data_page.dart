import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sesi_ira/core/widgets/dashed_line.dart';

import '../../../cases/presentation/pages/master_case_page.dart';
import '../../../clients/presentation/pages/clients_page.dart';
import '../../../psychologists/presentation/pages/psychologists_page.dart';

class MasterDataPage extends StatelessWidget {
  const MasterDataPage({super.key});

  static const String name = 'master-data';
  static const String path = '/master-data';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final crossAxisCount = screenWidth >= 920 ? 2 : 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Master Data')),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFFF6F8FC), Color(0xFFEEF4F8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF13315C),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Admin Workspace',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Kelola data dasar per modul dari satu tempat.',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Halaman ini jadi pintu masuk admin untuk input dan maintenance data master seperti klien, psikolog, dan struktur case.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Navigasi Modul',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF17212B),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Pilih area master data yang mau diinput atau dirapikan oleh admin.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF526071),
                ),
              ),
              const SizedBox(height: 14),
              GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: screenWidth >= 920 ? 1.4 : 1.12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  _MasterDataCard(
                    title: 'Master Klien',
                    subtitle:
                        'Input biodata, kontak, dan catatan dasar klien sebelum masuk ke case.',
                    badge: 'Client',
                    icon: Icons.groups_2_rounded,
                    accent: const Color(0xFF0F766E),
                    onTap: () => context.push(ClientsPage.path),
                  ),
                  _MasterDataCard(
                    title: 'Master Psikolog',
                    subtitle:
                        'Kelola praktisi aktif yang nanti bisa dipilih saat assignment case.',
                    badge: 'Psychologist',
                    icon: Icons.psychology_alt_rounded,
                    accent: const Color(0xFF1D4ED8),
                    onTap: () => context.push(PsychologistsPage.path),
                  ),
                  _MasterDataCard(
                    title: 'Master Case',
                    subtitle:
                        'Kelola komponen referensi yang harus tersedia dulu sebelum form case bisa dipakai.',
                    badge: 'Case',
                    icon: Icons.assignment_rounded,
                    accent: const Color(0xFFD97706),
                    onTap: () => context.push(MasterCasePage.path),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MasterDataCard extends StatelessWidget {
  const _MasterDataCard({
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
          border: Border.all(color: accent.withValues(alpha: 0.35)),
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
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  'Buka modul',
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
