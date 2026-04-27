import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sesi_ira/core/widgets/dashed_line.dart';

import 'assessment_types_page.dart';
import 'intervention_master_page.dart';

class MasterSessionPage extends StatelessWidget {
  const MasterSessionPage({super.key});

  static const String name = 'master-session';
  static const String path = '/master-session';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Master Session')),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFFF7F7FF), Color(0xFFEEF2FF)],
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
                  color: const Color(0xFF4F46E5),
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
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Reference Data',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Siapkan data master yang dibutuhkan sebelum workflow session dipakai.',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Halaman ini jadi tempat kumpulan referensi modul session. Ke depan master session lain bisa ditambah di sini tanpa bikin menu utama makin padat.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Komponen Master',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF17212B),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Kelola tabel referensi yang dipakai oleh form dan administrasi session.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF526071),
                ),
              ),
              const SizedBox(height: 14),
              _MasterSessionCard(
                title: 'Assessment Types',
                subtitle:
                    'Kelola referensi jenis assessment yang dipakai saat administrasi dan dokumentasi sesi.',
                badge: 'Required',
                icon: Icons.fact_check_rounded,
                accent: const Color(0xFF4F46E5),
                onTap: () => context.push(AssessmentTypesPage.path),
              ),
              const SizedBox(height: 12),
              _MasterSessionCard(
                title: 'Intervention Master',
                subtitle:
                    'Kelola referensi intervensi yang dipakai saat pencatatan tindakan atau rencana intervensi sesi.',
                badge: 'Required',
                icon: Icons.healing_rounded,
                accent: const Color(0xFFD97706),
                onTap: () => context.push(InterventionMasterPage.path),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MasterSessionCard extends StatelessWidget {
  const _MasterSessionCard({
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
            const SizedBox(height: 24),
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
                  'Kelola data',
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
