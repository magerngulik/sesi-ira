import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/feature_support_widgets.dart';
import '../../../cases/data/models/case_summary_model.dart';
import '../../data/models/session_model.dart';
import '../../data/repositories/sessions_repository.dart';
import 'create_session_page.dart';

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

  @override
  void initState() {
    super.initState();
    _sessionsFuture = _repository.fetchSessions(caseId: widget.caseSummary.id);
  }

  Future<void> _reload() async {
    setState(() {
      _sessionsFuture = _repository.fetchSessions(
        caseId: widget.caseSummary.id,
      );
    });

    await _sessionsFuture;
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
              if (sessions.isEmpty) {
                return StateMessage(
                  title: 'Belum ada session',
                  subtitle:
                      'Tambahkan session pertama untuk mulai mencatat perkembangan case ini.',
                  actionLabel: 'Tambah Session',
                  onPressed: _openCreateSessionPage,
                );
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEAECF0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.caseSummary.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: <Widget>[
                            InfoBadge(
                              icon: Icons.person_outline_rounded,
                              value: widget.caseSummary.clientName ?? 'Klien',
                            ),
                            InfoBadge(
                              icon: Icons.psychology_alt_outlined,
                              value:
                                  widget.caseSummary.psychologistName ??
                                  'Psikolog',
                            ),
                            InfoBadge(
                              icon: Icons.category_outlined,
                              value:
                                  widget.caseSummary.category ??
                                  'Tanpa kategori',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...sessions.map(
                    (session) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _SessionCard(session: session),
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

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});

  final SessionModel session;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final style = _sessionStatusStyle(session.status);

    return Container(
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
        ],
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
