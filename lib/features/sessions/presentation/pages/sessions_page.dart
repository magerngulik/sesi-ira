import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/feature_support_widgets.dart';
import '../../../cases/data/models/case_summary_model.dart';
import '../../data/models/session_model.dart';
import '../../data/repositories/sessions_repository.dart';
import 'create_session_page.dart';
import 'update_session_page.dart';

class SessionsPage extends StatefulWidget {
  const SessionsPage({required this.caseSummary, super.key});

  static const String name = 'sessions';
  static const String path = '/sessions';

  final CaseSummaryModel caseSummary;

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  final SessionsRepository _repository = const SessionsRepository();
  late Future<List<SessionModel>> _sessionsFuture;
  late Future<CaseSessionContext> _caseContextFuture;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = _repository.fetchSessions(caseId: widget.caseSummary.id);
    _caseContextFuture = _repository.fetchCaseSessionContext(
      widget.caseSummary.id,
    );
  }

  Future<void> _reload() async {
    setState(() {
      _sessionsFuture = _repository.fetchSessions(
        caseId: widget.caseSummary.id,
      );
      _caseContextFuture = _repository.fetchCaseSessionContext(
        widget.caseSummary.id,
      );
    });

    await Future.wait<dynamic>(<Future<dynamic>>[
      _sessionsFuture,
      _caseContextFuture,
    ]);
  }

  Future<void> _openCreateSessionPage() async {
    final shouldRefresh = await context.push<bool>(
      CreateSessionPage.path,
      extra: widget.caseSummary,
    );

    if (!mounted) {
      return;
    }

    if (shouldRefresh == true) {
      await _reload();
    }
  }

  Future<void> _openUpdateSessionPage(SessionModel session) async {
    final shouldRefresh = await context.push<bool>(
      UpdateSessionPage.path,
      extra: UpdateSessionArgs(
        caseSummary: widget.caseSummary,
        sessionId: session.id,
      ),
    );

    if (!mounted) {
      return;
    }

    if (shouldRefresh == true) {
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Session • ${widget.caseSummary.title}'),
        actions: <Widget>[
          IconButton(
            onPressed: _reload,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateSessionPage,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Session'),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<List<SessionModel>>(
            future: _sessionsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return StateMessage(
                  title: 'Gagal memuat session',
                  subtitle: '${snapshot.error}',
                  actionLabel: 'Coba Lagi',
                  onPressed: _reload,
                );
              }

              final sessions = snapshot.data ?? <SessionModel>[];
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                children: <Widget>[
                  FutureBuilder<CaseSessionContext>(
                    future: _caseContextFuture,
                    builder: (context, caseContextSnapshot) {
                      final caseContext =
                          caseContextSnapshot.data ??
                          const CaseSessionContext();

                      return _CaseSummaryCard(
                        caseSummary: widget.caseSummary,
                        caseTypeName:
                            caseContext.caseTypeName ??
                            widget.caseSummary.caseTypeName,
                        tagNames: caseContext.tagNames.isNotEmpty
                            ? caseContext.tagNames
                            : widget.caseSummary.tagNames,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  if (sessions.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFEAECF0)),
                      ),
                      child: Column(
                        children: <Widget>[
                          Icon(
                            Icons.event_busy_outlined,
                            size: 42,
                            color: const Color(0xFF98A2B3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada session',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF101828),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Case ini sudah dipilih, tapi session-nya masih kosong. Tambahkan session pertama untuk mulai mencatat perkembangannya.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF667085),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _openCreateSessionPage,
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Tambah Session'),
                          ),
                        ],
                      ),
                    )
                  else
                    ...sessions.map(
                      (session) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _SessionCard(
                          session: session,
                          onTap: () => _openUpdateSessionPage(session),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CaseSummaryCard extends StatelessWidget {
  const _CaseSummaryCard({
    required this.caseSummary,
    this.caseTypeName,
    this.tagNames = const <String>[],
  });

  final CaseSummaryModel caseSummary;
  final String? caseTypeName;
  final List<String> tagNames;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Column(
      children: <Widget>[
        _SummarySectionCard(
          title: 'Informasi Case',
          rows: <_SummaryInfoRow>[
            _SummaryInfoRow(
              label: 'Client',
              value: caseSummary.clientName ?? '-',
            ),
            _SummaryInfoRow(
              label: 'Psikolog',
              value: caseSummary.psychologistName ?? '-',
            ),
            _SummaryInfoRow(label: 'Judul Case', value: caseSummary.title),
            _SummaryInfoRow(
              label: 'Kategori',
              value: caseSummary.category ?? '-',
            ),
            _SummaryInfoRow(
              label: 'Tanggal Mulai',
              value: dateFormat.format(caseSummary.startDate),
            ),
            _SummaryInfoRow(label: 'Tipe Kasus', value: caseTypeName ?? '-'),
            _SummaryInfoRow(
              label: 'Status',
              value: _caseStatusLabel(caseSummary.status),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SummarySectionCard(
          title: 'Konten Penanganan',
          rows: <_SummaryInfoRow>[
            _SummaryInfoRow(
              label: 'Keluhan',
              value: _displayOrDash(caseSummary.complaint),
            ),
            _SummaryInfoRow(
              label: 'Tujuan',
              value: _displayOrDash(caseSummary.goal),
            ),
            _SummaryInfoRow(
              label: 'Tags',
              value: tagNames.isEmpty ? '-' : tagNames.join(', '),
            ),
            const _SummaryInfoRow(
              label: 'Tanggal Selesai',
              value: 'Akan diisi saat case ditutup',
            ),
          ],
        ),
      ],
    );
  }
}

class _SummarySectionCard extends StatelessWidget {
  const _SummarySectionCard({required this.title, required this.rows});

  final String title;
  final List<_SummaryInfoRow> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF17212B),
            ),
          ),
          const SizedBox(height: 18),
          ...rows.map((row) => _SummaryInfoRowWidget(row: row)),
        ],
      ),
    );
  }
}

class _SummaryInfoRow {
  const _SummaryInfoRow({required this.label, required this.value});

  final String label;
  final String value;
}

class _SummaryInfoRowWidget extends StatelessWidget {
  const _SummaryInfoRowWidget({required this.row});

  final _SummaryInfoRow row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 132,
            child: Text(
              row.label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              row.value,
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFF1E293B),
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, required this.onTap});

  final SessionModel session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final style = _sessionStatusStyle(session.status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEAECF0)),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x080F172A),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'Session ${session.sessionNumber}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF101828),
                  ),
                ),
                const Spacer(),
                _StatusPill(
                  label: style.label,
                  foregroundColor: style.foregroundColor,
                  backgroundColor: style.backgroundColor,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              dateFormat.format(session.sessionDate),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF475467),
                fontWeight: FontWeight.w600,
              ),
            ),
            if ((session.summary ?? '').isNotEmpty) ...<Widget>[
              const SizedBox(height: 10),
              Text(
                session.summary!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF475467),
                  height: 1.45,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                if (session.startTime != null || session.endTime != null)
                  InfoBadge(
                    icon: Icons.schedule_rounded,
                    value:
                        '${session.startTime ?? '--:--'} - ${session.endTime ?? '--:--'}',
                  ),
                if (session.durationMinutes != null)
                  InfoBadge(
                    icon: Icons.timer_outlined,
                    value: '${session.durationMinutes} menit',
                  ),
                if ((session.followUpType ?? '').isNotEmpty)
                  InfoBadge(
                    icon: Icons.assignment_turned_in_outlined,
                    value: session.followUpType!,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Tap untuk update',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF2563EB),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionStatusStyle {
  const _SessionStatusStyle({
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  final String label;
  final Color foregroundColor;
  final Color backgroundColor;
}

_SessionStatusStyle _sessionStatusStyle(String status) {
  return switch (status) {
    'done' => const _SessionStatusStyle(
      label: 'Done',
      foregroundColor: Color(0xFF027A48),
      backgroundColor: Color(0xFFE7F6EC),
    ),
    'confirmed' => const _SessionStatusStyle(
      label: 'Confirmed',
      foregroundColor: Color(0xFF175CD3),
      backgroundColor: Color(0xFFEAF2FF),
    ),
    'cancelled' => const _SessionStatusStyle(
      label: 'Cancelled',
      foregroundColor: Color(0xFFB42318),
      backgroundColor: Color(0xFFFEE4E2),
    ),
    'no_show' => const _SessionStatusStyle(
      label: 'No Show',
      foregroundColor: Color(0xFFB42318),
      backgroundColor: Color(0xFFFEE4E2),
    ),
    'in_progress' => const _SessionStatusStyle(
      label: 'In Progress',
      foregroundColor: Color(0xFF175CD3),
      backgroundColor: Color(0xFFEAF2FF),
    ),
    'rescheduled' => const _SessionStatusStyle(
      label: 'Rescheduled',
      foregroundColor: Color(0xFFB54708),
      backgroundColor: Color(0xFFFFF4E5),
    ),
    _ => const _SessionStatusStyle(
      label: 'Scheduled',
      foregroundColor: Color(0xFF175CD3),
      backgroundColor: Color(0xFFEAF2FF),
    ),
  };
}

String _caseStatusLabel(String status) {
  return switch (status) {
    'completed' => 'Completed',
    'cancelled' => 'Cancelled',
    'on_hold' => 'On Hold',
    _ => 'Active',
  };
}

String _displayOrDash(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return '-';
  }

  return trimmed;
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  final String label;
  final Color foregroundColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
