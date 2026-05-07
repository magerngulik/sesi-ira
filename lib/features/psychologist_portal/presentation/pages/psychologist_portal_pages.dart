import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/psychologist_portal_mock_data.dart';
import '../widgets/psychologist_portal_widgets.dart';

class PsychologistDashboardPage extends StatelessWidget {
  const PsychologistDashboardPage({super.key});

  static const String name = 'psychologist-dashboard';
  static const String path = '/psychologist/home';

  @override
  Widget build(BuildContext context) {
    return PsychologistPortalScaffold(
      activeTab: PsychologistNavTab.home,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'Sesi Ira',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: PsychologistPortalPalette.primaryDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => context.push(PsychologistNotificationsPage.path),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: PsychologistPortalPalette.border),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      const Icon(Icons.notifications_none_rounded),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: PsychologistPortalPalette.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Hi, ${PsychologistPortalMockData.psychologistName}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: PsychologistPortalPalette.text,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Semangat menjalani hari ini.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: PsychologistPortalPalette.muted,
            ),
          ),
          const SizedBox(height: 18),
          PsychologistSurfaceCard(
            child: Column(
              children: <Widget>[
                PsychologistSectionHeader(
                  title: 'Jadwal Hari Ini',
                  actionLabel: 'Lihat semua',
                  onTap: () => context.go(PsychologistSchedulePage.path),
                ),
                const SizedBox(height: 14),
                ...PsychologistPortalMockData.todaySchedule.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 56,
                          child: Text(
                            item.timeLabel,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                item.clientName,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              Text(
                                item.sessionLabel,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: PsychologistPortalPalette.muted,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const PsychologistStatusChip(
                          label: 'Upcoming',
                          color: PsychologistPortalPalette.primary,
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PsychologistSurfaceCard(
            child: Column(
              children: <Widget>[
                PsychologistSectionHeader(
                  title: 'Case Aktif',
                  actionLabel: 'Lihat semua',
                  onTap: () => context.go(PsychologistCasesPage.path),
                ),
                const SizedBox(height: 14),
                ...PsychologistPortalMockData.activeCases.take(2).map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      children: <Widget>[
                        PsychologistAvatar(
                          label: item.clientName,
                          backgroundColor: const Color(0xFFFFC8D7),
                          radius: 18,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                item.clientName,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              Text(
                                item.topic,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: PsychologistPortalPalette.muted,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        PsychologistStatusChip(
                          label: item.statusLabel,
                          color: item.statusTone,
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Quick Actions',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: PsychologistPrimaryButton(
                  label: 'Mulai Session',
                  icon: Icons.add_rounded,
                  onTap: () => context.push(PsychologistNewSessionPage.path),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PsychologistPrimaryButton(
                  label: 'Tambah Case',
                  icon: Icons.add_rounded,
                  isOutlined: true,
                  onTap: () => context.go(PsychologistCasesPage.path),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PsychologistSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Aktivitas Terbaru',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                ...PsychologistPortalMockData.recentActivities.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8FFF5),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: PsychologistPortalPalette.success,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(item.title)),
                        Text(
                          item.timeLabel,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: PsychologistPortalPalette.muted,
                              ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PsychologistClientsPage extends StatelessWidget {
  const PsychologistClientsPage({super.key});

  static const String name = 'psychologist-clients';
  static const String path = '/psychologist/clients';

  @override
  Widget build(BuildContext context) {
    return PsychologistPortalScaffold(
      activeTab: PsychologistNavTab.clients,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: <Widget>[
          const PsychologistSearchBar(hintText: 'Cari klien...'),
          const SizedBox(height: 16),
          ...PsychologistPortalMockData.clients.map((client) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: PsychologistClientTile(client: client),
            );
          }),
        ],
      ),
    );
  }
}

class PsychologistCasesPage extends StatelessWidget {
  const PsychologistCasesPage({super.key});

  static const String name = 'psychologist-cases';
  static const String path = '/psychologist/cases';

  @override
  Widget build(BuildContext context) {
    return PsychologistPortalScaffold(
      activeTab: PsychologistNavTab.cases,
      floatingActionButton: FloatingActionButton(
        backgroundColor: PsychologistPortalPalette.primary,
        foregroundColor: Colors.white,
        onPressed: () => context.push(PsychologistCaseDetailPage.path),
        child: const Icon(Icons.add_rounded),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: <Widget>[
          const PsychologistSegmentedSwitch(
            leftLabel: 'Active',
            rightLabel: 'Completed',
            selectLeft: true,
          ),
          const SizedBox(height: 16),
          const PsychologistSearchBar(hintText: 'Cari case...'),
          const SizedBox(height: 16),
          ...PsychologistPortalMockData.activeCases.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: PsychologistCaseTile(
                item: item,
                onTap: () => context.push(PsychologistCaseDetailPage.path),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class PsychologistCaseDetailPage extends StatelessWidget {
  const PsychologistCaseDetailPage({super.key});

  static const String name = 'psychologist-case-detail';
  static const String path = '/psychologist/cases/detail';

  @override
  Widget build(BuildContext context) {
    return PsychologistPortalScaffold(
      activeTab: PsychologistNavTab.cases,
      topBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFFFF67A7), Color(0xFFFF3E90)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                InkWell(
                  onTap: () => context.pop(),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.more_vert_rounded, color: Colors.white),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                const PsychologistAvatar(
                  label: 'Andi Saputra',
                  backgroundColor: Color(0xFFFFD0E2),
                  radius: 32,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const <Widget>[
                      Text(
                        'Andi Saputra',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Anxiety',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const PsychologistStatusChip(
                  label: 'On Progress',
                  color: Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: PsychologistSurfaceCard(
                  child: Column(
                    children: const <Widget>[
                      Icon(Icons.calendar_month_rounded),
                      SizedBox(height: 10),
                      Text('Dibuat'),
                      SizedBox(height: 4),
                      Text(
                        '10 Mei 2024',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PsychologistSurfaceCard(
                  child: Column(
                    children: const <Widget>[
                      Icon(Icons.folder_open_rounded),
                      SizedBox(height: 10),
                      Text('Total Session'),
                      SizedBox(height: 4),
                      Text(
                        '3 Session',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const PsychologistSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Progress',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(child: Text('Improvement')),
                    Text('60%', style: TextStyle(fontWeight: FontWeight.w800)),
                  ],
                ),
                SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                  child: LinearProgressIndicator(
                    value: 0.6,
                    minHeight: 8,
                    color: PsychologistPortalPalette.primary,
                    backgroundColor: Color(0xFFFFE6F1),
                  ),
                ),
                SizedBox(height: 14),
                Text('Notes', style: TextStyle(fontWeight: FontWeight.w800)),
                SizedBox(height: 6),
                Text(
                  'Mulai menunjukkan peningkatan dalam mengelola kecemasan.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PsychologistSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Daftar Session',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                ...PsychologistPortalMockData.caseSessions.map((session) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: session.statusTone.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.note_alt_outlined,
                            color: session.statusTone,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                session.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(session.dateLabel),
                            ],
                          ),
                        ),
                        PsychologistStatusChip(
                          label: session.statusLabel,
                          color: session.statusTone,
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PsychologistPrimaryButton(
            label: 'Tambah Session',
            icon: Icons.add_rounded,
            onTap: () => context.push(PsychologistNewSessionPage.path),
          ),
        ],
      ),
    );
  }
}

class PsychologistNewSessionPage extends StatelessWidget {
  const PsychologistNewSessionPage({super.key});

  static const String name = 'psychologist-new-session';
  static const String path = '/psychologist/sessions/new';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buildSectionLabel(String text) {
      return Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          color: PsychologistPortalPalette.text,
          fontWeight: FontWeight.w800,
        ),
      );
    }

    return PsychologistPortalScaffold(
      showBottomNavigation: false,
      topBar: PsychologistSimpleTopBar(
        title: 'New Session',
        leading: InkWell(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: <Widget>[
          buildSectionLabel('Tanggal Session'),
          const SizedBox(height: 10),
          const PsychologistSurfaceCard(
            child: Row(
              children: <Widget>[
                Expanded(child: Text('12 Mei 2024')),
                Icon(Icons.calendar_today_outlined),
              ],
            ),
          ),
          const SizedBox(height: 18),
          buildSectionLabel('Catatan Session'),
          const SizedBox(height: 10),
          const PsychologistSurfaceCard(
            child: Text(
              'Klien terlihat lebih tenang dan mampu mengidentifikasi pikiran negatif yang muncul.',
            ),
          ),
          const SizedBox(height: 18),
          buildSectionLabel('Intervensi'),
          const SizedBox(height: 10),
          PsychologistSurfaceCard(
            child: Column(
              children: PsychologistPortalMockData.interventions.map((item) {
                final isSelected = PsychologistPortalMockData
                    .selectedInterventions
                    .contains(item);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        isSelected
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded,
                        color: isSelected
                            ? PsychologistPortalPalette.primary
                            : const Color(0xFFB5BAC8),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(item)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),
          buildSectionLabel('Lampiran (Optional)'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBFD),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: PsychologistPortalPalette.border,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.upload_file_rounded,
                      color: PsychologistPortalPalette.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Upload file',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: PsychologistPortalPalette.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'PDF, JPG, PNG (Max. 10MB)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: PsychologistPortalPalette.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          PsychologistPrimaryButton(
            label: 'Simpan Session',
            onTap: () => context.go(PsychologistSessionDetailPage.path),
          ),
        ],
      ),
    );
  }
}

class PsychologistSessionDetailPage extends StatelessWidget {
  const PsychologistSessionDetailPage({super.key});

  static const String name = 'psychologist-session-detail';
  static const String path = '/psychologist/sessions/detail';

  @override
  Widget build(BuildContext context) {
    return PsychologistPortalScaffold(
      showBottomNavigation: false,
      topBar: PsychologistSimpleTopBar(
        title: 'Session 2',
        leading: InkWell(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back_rounded),
        ),
        trailing: const Icon(Icons.more_horiz_rounded),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: <Widget>[
          PsychologistSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  'Informasi',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(child: Text('Tanggal')),
                    Text('10 Mei 2024'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(child: Text('Durasi')),
                    Text('60 menit'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const PsychologistSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Catatan Session',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 12),
                Text(
                  'Klien mulai memahami hubungan antara pikiran, perasaan, dan perilaku. Diberikan tugas rumah untuk mencatat pikiran negatif.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PsychologistSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Intervensi',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                ...PsychologistPortalMockData.selectedInterventions.take(2).map(
                  (item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: <Widget>[
                          const Icon(
                            Icons.check_circle_rounded,
                            color: PsychologistPortalPalette.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(item)),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PsychologistSurfaceCard(
            child: Row(
              children: <Widget>[
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEF5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf_outlined,
                    color: PsychologistPortalPalette.primary,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Worksheet CBT.pdf',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text('PDF  •  1.2 MB'),
                    ],
                  ),
                ),
                const Icon(Icons.download_rounded),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const PsychologistPrimaryButton(
            label: 'Edit Session',
            isOutlined: true,
          ),
        ],
      ),
    );
  }
}

class PsychologistSchedulePage extends StatelessWidget {
  const PsychologistSchedulePage({super.key});

  static const String name = 'psychologist-schedule';
  static const String path = '/psychologist/schedule';

  @override
  Widget build(BuildContext context) {
    const weekDays = <String>['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const calendarDays = <String>[
      '',
      '',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      '11',
      '12',
      '13',
      '14',
      '15',
      '16',
      '17',
      '18',
      '19',
      '20',
      '21',
      '22',
      '23',
      '24',
      '25',
      '26',
      '27',
      '28',
      '29',
      '30',
      '31',
    ];

    return PsychologistPortalScaffold(
      activeTab: PsychologistNavTab.schedule,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: <Widget>[
          Row(
            children: <Widget>[
              InkWell(
                onTap: () => context.pop(),
                child: const Icon(Icons.arrow_back_rounded),
              ),
              const Spacer(),
              Text(
                'Mei 2024',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
          const SizedBox(height: 16),
          PsychologistSurfaceCard(
            child: Column(
              children: <Widget>[
                Row(
                  children: weekDays.map((day) {
                    return Expanded(
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: PsychologistPortalPalette.muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: calendarDays.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisExtent: 34,
                  ),
                  itemBuilder: (context, index) {
                    final label = calendarDays[index];
                    final isSelected = label == '12';
                    return Center(
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? PsychologistPortalPalette.primary
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          label,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : PsychologistPortalPalette.text,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Jadwal Hari Ini',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ...PsychologistPortalMockData.todaySchedule.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: PsychologistSurfaceCard(
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 60,
                      child: Text(
                        item.timeLabel,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            item.clientName,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(item.sessionLabel),
                        ],
                      ),
                    ),
                    const PsychologistStatusChip(
                      label: 'Upcoming',
                      color: PsychologistPortalPalette.primary,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class PsychologistNotificationsPage extends StatelessWidget {
  const PsychologistNotificationsPage({super.key});

  static const String name = 'psychologist-notifications';
  static const String path = '/psychologist/notifications';

  @override
  Widget build(BuildContext context) {
    return PsychologistPortalScaffold(
      activeTab: PsychologistNavTab.home,
      title: 'Notifications',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: <Widget>[
          const PsychologistSegmentedSwitch(
            leftLabel: 'Semua',
            rightLabel: 'Belum Dibaca',
            selectLeft: true,
          ),
          const SizedBox(height: 18),
          ...PsychologistPortalMockData.notifications.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    entry.key,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...entry.value.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PsychologistSurfaceCard(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: item.accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(item.icon, color: item.accent),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    item.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(item.message),
                                ],
                              ),
                            ),
                            Text(
                              item.timeLabel,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: PsychologistPortalPalette.muted,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class PsychologistProfilePage extends StatelessWidget {
  const PsychologistProfilePage({super.key});

  static const String name = 'psychologist-profile';
  static const String path = '/psychologist/profile';

  @override
  Widget build(BuildContext context) {
    Widget buildInfoTile({
      required IconData icon,
      required String title,
      required String subtitle,
    }) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEF5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: PsychologistPortalPalette.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: PsychologistPortalPalette.muted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      );
    }

    return PsychologistPortalScaffold(
      activeTab: PsychologistNavTab.profile,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFFFFA9C8), Color(0xFFFF5B9E)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    InkWell(
                      onTap: () => context.push(PsychologistSettingsPage.path),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.settings_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const PsychologistAvatar(
                  label: 'Ira',
                  backgroundColor: Color(0xFFFFD4E5),
                  radius: 42,
                ),
                const SizedBox(height: 12),
                Text(
                  '${PsychologistPortalMockData.psychologistName}, M.Psi., Psikolog',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  PsychologistPortalMockData.psychologistTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  PsychologistPortalMockData.psychologistEmail,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  PsychologistPortalMockData.psychologistPhone,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          PsychologistSurfaceCard(
            child: Column(
              children: <Widget>[
                buildInfoTile(
                  icon: Icons.workspace_premium_outlined,
                  title: 'Spesialisasi',
                  subtitle: 'Anxiety, CBT, Mindfulness',
                ),
                buildInfoTile(
                  icon: Icons.work_outline_rounded,
                  title: 'Pengalaman',
                  subtitle: '8 tahun',
                ),
                buildInfoTile(
                  icon: Icons.info_outline_rounded,
                  title: 'Tentang',
                  subtitle:
                      'Psikolog klinis dengan pengalaman di bidang terapi kognitif dan kesehatan mental.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const PsychologistPrimaryButton(label: 'Edit Profile'),
        ],
      ),
    );
  }
}

class PsychologistSettingsPage extends StatelessWidget {
  const PsychologistSettingsPage({super.key});

  static const String name = 'psychologist-settings';
  static const String path = '/psychologist/settings';

  @override
  Widget build(BuildContext context) {
    Widget buildSettingTile({
      required IconData icon,
      required String title,
      required String subtitle,
      Widget? trailing,
    }) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEF5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: PsychologistPortalPalette.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: PsychologistPortalPalette.muted,
                    ),
                  ),
                ],
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right_rounded),
          ],
        ),
      );
    }

    return PsychologistPortalScaffold(
      showBottomNavigation: false,
      title: 'Settings',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: <Widget>[
          Text(
            'Preferensi',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          PsychologistSurfaceCard(
            child: Column(
              children: <Widget>[
                buildSettingTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifikasi',
                  subtitle: '',
                ),
                buildSettingTile(
                  icon: Icons.alarm_rounded,
                  title: 'Pengingat Session',
                  subtitle: 'Aktif',
                  trailing: Switch(
                    value: true,
                    onChanged: (_) {},
                    activeThumbColor: Colors.white,
                    activeTrackColor: PsychologistPortalPalette.primary,
                  ),
                ),
                buildSettingTile(
                  icon: Icons.wb_sunny_outlined,
                  title: 'Tampilan',
                  subtitle: 'Light Mode',
                ),
                buildSettingTile(
                  icon: Icons.language_rounded,
                  title: 'Bahasa',
                  subtitle: 'Bahasa Indonesia',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Keamanan',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          PsychologistSurfaceCard(
            child: Column(
              children: <Widget>[
                buildSettingTile(
                  icon: Icons.key_outlined,
                  title: 'Ubah Password',
                  subtitle: '',
                ),
                InkWell(
                  onTap: () => context.read<AuthCubit>().signOut(),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEEF5),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            color: PsychologistPortalPalette.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Logout',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: PsychologistPortalPalette.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Versi 1.0.0',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: PsychologistPortalPalette.muted,
            ),
          ),
        ],
      ),
    );
  }
}
