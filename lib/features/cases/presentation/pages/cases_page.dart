import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/feature_support_widgets.dart';
import '../../data/models/case_summary_model.dart';
import '../../data/repositories/cases_repository.dart';
import '../../../sessions/presentation/pages/sessions_page.dart';
import 'create_case_page.dart';

class CasesPage extends StatefulWidget {
  const CasesPage({super.key});

  static const String name = 'cases';
  static const String path = '/cases';

  @override
  State<CasesPage> createState() => _CasesPageState();
}

class _CasesPageState extends State<CasesPage> {
  final CasesRepository _repository = const CasesRepository();
  final TextEditingController _searchController = TextEditingController();
  late Future<List<CaseSummaryModel>> _casesFuture;

  String _selectedStatusFilter = 'all';
  String _selectedPsychologistFilter = 'all';
  String _selectedSortFilter = 'latest';

  @override
  void initState() {
    super.initState();
    _casesFuture = _repository.fetchCases();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _casesFuture = _repository.fetchCases();
    });

    await _casesFuture;
  }

  Future<void> _openCreateCasePage() async {
    final shouldRefresh = await context.push<bool>(CreateCasePage.path);

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
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<List<CaseSummaryModel>>(
            future: _casesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return StateMessage(
                  title: 'Gagal memuat case',
                  subtitle: '${snapshot.error}',
                  actionLabel: 'Coba Lagi',
                  onPressed: _reload,
                );
              }

              final allCases = snapshot.data ?? <CaseSummaryModel>[];
              final psychologistOptions = _buildPsychologistOptions(allCases);
              final filteredCases = _filterCases(allCases);

              return RefreshIndicator(
                onRefresh: _reload,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const SizedBox(width: 48),
                        Expanded(
                          child: Text(
                            'Case Saya',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF101828),
                            ),
                          ),
                        ),
                        _TopActionButton(
                          icon: Icons.add_rounded,
                          backgroundColor: const Color(0xFF2563EB),
                          iconColor: Colors.white,
                          onTap: _openCreateCasePage,
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari case, client, atau psikolog...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchController.text.isEmpty
                            ? null
                            : IconButton(
                                onPressed: _searchController.clear,
                                icon: const Icon(Icons.close_rounded),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: <Widget>[
                        _FilterButton(
                          label: _statusFilterLabel(_selectedStatusFilter),
                          onTap: () => _pickStatusFilter(context),
                        ),
                        _FilterButton(
                          label: _psychologistFilterLabel(
                            _selectedPsychologistFilter,
                            psychologistOptions,
                          ),
                          onTap: () => _pickPsychologistFilter(
                            context,
                            psychologistOptions,
                          ),
                        ),
                        _FilterButton(
                          label: _sortFilterLabel(_selectedSortFilter),
                          leadingIcon: Icons.calendar_today_outlined,
                          onTap: () => _pickSortFilter(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    if (allCases.isEmpty)
                      StateMessage(
                        title: 'Belum ada case',
                        subtitle:
                            'Buat case pertama untuk mulai menghubungkan klien dan psikolog.',
                        actionLabel: 'Buat Case',
                        onPressed: _openCreateCasePage,
                      )
                    else if (filteredCases.isEmpty)
                      _EmptyFilterState(onPressed: _resetFilters)
                    else
                      ...filteredCases.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _CaseListCard(
                            item: item,
                            onRefresh: _reload,
                            onTap: () =>
                                context.push(SessionsPage.path, extra: item),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<CaseSummaryModel> _filterCases(List<CaseSummaryModel> cases) {
    final query = _searchController.text.trim().toLowerCase();

    final filtered = cases.where((item) {
      final statusMatch =
          _selectedStatusFilter == 'all' ||
          item.status == _selectedStatusFilter;
      final psychologistMatch =
          _selectedPsychologistFilter == 'all' ||
          item.psychologistName == _selectedPsychologistFilter;

      final haystacks = <String>[
        item.title,
        item.clientName ?? '',
        item.psychologistName ?? '',
        item.category ?? '',
      ].map((value) => value.toLowerCase());

      final queryMatch =
          query.isEmpty || haystacks.any((value) => value.contains(query));

      return statusMatch && psychologistMatch && queryMatch;
    }).toList();

    filtered.sort((a, b) {
      switch (_selectedSortFilter) {
        case 'oldest':
          return a.startDate.compareTo(b.startDate);
        case 'title':
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case 'latest':
        default:
          return b.startDate.compareTo(a.startDate);
      }
    });

    return filtered;
  }

  List<String> _buildPsychologistOptions(List<CaseSummaryModel> cases) {
    final values =
        cases
            .map((item) => item.psychologistName)
            .whereType<String>()
            .where((value) => value.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    return values;
  }

  Future<void> _pickStatusFilter(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        const options = <MapEntry<String, String>>[
          MapEntry('all', 'Semua Status'),
          MapEntry('active', 'Active'),
          MapEntry('on_hold', 'On Hold'),
          MapEntry('completed', 'Completed'),
          MapEntry('cancelled', 'Cancelled'),
        ];

        return _SelectionSheet<String>(
          title: 'Filter Status',
          value: _selectedStatusFilter,
          options: options
              .map(
                (entry) =>
                    _SelectionOption(value: entry.key, label: entry.value),
              )
              .toList(),
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedStatusFilter = result;
      });
    }
  }

  Future<void> _pickPsychologistFilter(
    BuildContext context,
    List<String> psychologists,
  ) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final options = <_SelectionOption<String>>[
          const _SelectionOption(value: 'all', label: 'Semua Psikolog'),
          ...psychologists.map(
            (name) => _SelectionOption(value: name, label: name),
          ),
        ];

        return _SelectionSheet<String>(
          title: 'Filter Psikolog',
          value: _selectedPsychologistFilter,
          options: options,
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedPsychologistFilter = result;
      });
    }
  }

  Future<void> _pickSortFilter(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        const options = <MapEntry<String, String>>[
          MapEntry('latest', 'Terbaru'),
          MapEntry('oldest', 'Terlama'),
          MapEntry('title', 'Judul A-Z'),
        ];

        return _SelectionSheet<String>(
          title: 'Urutkan',
          value: _selectedSortFilter,
          options: options
              .map(
                (entry) =>
                    _SelectionOption(value: entry.key, label: entry.value),
              )
              .toList(),
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedSortFilter = result;
      });
    }
  }

  String _statusFilterLabel(String value) {
    return switch (value) {
      'active' => 'Active',
      'on_hold' => 'On Hold',
      'completed' => 'Completed',
      'cancelled' => 'Cancelled',
      _ => 'Semua Status',
    };
  }

  String _psychologistFilterLabel(String value, List<String> options) {
    if (value == 'all' || !options.contains(value)) {
      return 'Semua Psikolog';
    }

    return value;
  }

  String _sortFilterLabel(String value) {
    return switch (value) {
      'oldest' => 'Terlama',
      'title' => 'Judul A-Z',
      _ => 'Terbaru',
    };
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatusFilter = 'all';
      _selectedPsychologistFilter = 'all';
      _selectedSortFilter = 'latest';
    });
  }
}

class _CaseListCard extends StatelessWidget {
  const _CaseListCard({
    required this.item,
    required this.onRefresh,
    required this.onTap,
  });

  final CaseSummaryModel item;
  final Future<void> Function() onRefresh;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final statusStyle = _statusPresentation(item.status);
    final latestSession = item.latestSession;
    final progressStyle = _progressPresentation(
      latestSession?.status ?? item.status,
    );
    final dateValue = latestSession?.sessionDate ?? item.startDate;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _Pill(
                    label: statusStyle.label,
                    foregroundColor: statusStyle.foregroundColor,
                    backgroundColor: statusStyle.backgroundColor,
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded),
                    onSelected: (value) {
                      if (value == 'refresh') {
                        onRefresh();
                      }
                    },
                    itemBuilder: (context) => const <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'refresh',
                        child: Text('Refresh data'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF101828),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.clientName ?? 'Klien tidak ditemukan',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF475467),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.psychologistName ?? 'Psikolog tidak ditemukan'}  •  ${item.category ?? 'Tanpa kategori'}',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF667085)),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: Color(0xFF667085),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateFormat.format(dateValue),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF475467),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (latestSession != null) ...<Widget>[
                    const SizedBox(width: 10),
                    const Text(
                      '•',
                      style: TextStyle(color: Color(0xFF98A2B3), fontSize: 16),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Sesi ${latestSession.sessionNumber}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF475467),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(width: 10),
                  const Text(
                    '•',
                    style: TextStyle(color: Color(0xFF98A2B3), fontSize: 16),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: _Pill(
                      label: progressStyle.label,
                      foregroundColor: progressStyle.foregroundColor,
                      backgroundColor: progressStyle.backgroundColor,
                    ),
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

class _TopActionButton extends StatelessWidget {
  const _TopActionButton({
    required this.icon,
    required this.onTap,
    this.backgroundColor = Colors.white,
    this.iconColor = const Color(0xFF344054),
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: iconColor, size: 24),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.onTap,
    this.leadingIcon,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD0D5DD)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (leadingIcon != null) ...<Widget>[
              Icon(leadingIcon, size: 18, color: const Color(0xFF475467)),
              const SizedBox(width: 10),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: const Color(0xFF344054),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}

class _EmptyFilterState extends StatelessWidget {
  const _EmptyFilterState({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Column(
        children: <Widget>[
          Text(
            'Tidak ada case yang cocok',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Coba ubah kata kunci pencarian atau reset filter yang sedang aktif.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF667085)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onPressed, child: const Text('Reset Filter')),
        ],
      ),
    );
  }
}

class _SelectionSheet<T> extends StatelessWidget {
  const _SelectionSheet({
    required this.title,
    required this.value,
    required this.options,
  });

  final String title;
  final T value;
  final List<_SelectionOption<T>> options;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            ...options.map(
              (option) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(option.label),
                trailing: option.value == value
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF2563EB),
                      )
                    : null,
                onTap: () => Navigator.of(context).pop(option.value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionOption<T> {
  const _SelectionOption({required this.value, required this.label});

  final T value;
  final String label;
}

class _Pill extends StatelessWidget {
  const _Pill({
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

class _StatusPresentation {
  const _StatusPresentation({
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  final String label;
  final Color foregroundColor;
  final Color backgroundColor;
}

_StatusPresentation _statusPresentation(String status) {
  return switch (status) {
    'completed' => const _StatusPresentation(
      label: 'Completed',
      foregroundColor: Color(0xFF6941C6),
      backgroundColor: Color(0xFFF4F3FF),
    ),
    'cancelled' => const _StatusPresentation(
      label: 'Cancelled',
      foregroundColor: Color(0xFFB42318),
      backgroundColor: Color(0xFFFEE4E2),
    ),
    'on_hold' => const _StatusPresentation(
      label: 'On Hold',
      foregroundColor: Color(0xFFB54708),
      backgroundColor: Color(0xFFFFF4E5),
    ),
    _ => const _StatusPresentation(
      label: 'Active',
      foregroundColor: Color(0xFF027A48),
      backgroundColor: Color(0xFFE7F6EC),
    ),
  };
}

_StatusPresentation _progressPresentation(String status) {
  return switch (status) {
    'scheduled' => const _StatusPresentation(
      label: 'Scheduled',
      foregroundColor: Color(0xFF175CD3),
      backgroundColor: Color(0xFFEAF2FF),
    ),
    'confirmed' => const _StatusPresentation(
      label: 'Confirmed',
      foregroundColor: Color(0xFF175CD3),
      backgroundColor: Color(0xFFEAF2FF),
    ),
    'in_progress' => const _StatusPresentation(
      label: 'In Progress',
      foregroundColor: Color(0xFF027A48),
      backgroundColor: Color(0xFFE7F6EC),
    ),
    'no_show' => const _StatusPresentation(
      label: 'No Show',
      foregroundColor: Color(0xFFB42318),
      backgroundColor: Color(0xFFFEE4E2),
    ),
    'done' => const _StatusPresentation(
      label: 'Done',
      foregroundColor: Color(0xFF027A48),
      backgroundColor: Color(0xFFE7F6EC),
    ),
    'rescheduled' => const _StatusPresentation(
      label: 'Rescheduled',
      foregroundColor: Color(0xFFB54708),
      backgroundColor: Color(0xFFFFF4E5),
    ),
    'cancelled' => const _StatusPresentation(
      label: 'Cancelled',
      foregroundColor: Color(0xFFB42318),
      backgroundColor: Color(0xFFFEE4E2),
    ),
    'on_hold' => const _StatusPresentation(
      label: 'Paused',
      foregroundColor: Color(0xFFB54708),
      backgroundColor: Color(0xFFFFF4E5),
    ),
    _ => const _StatusPresentation(
      label: 'In Progress',
      foregroundColor: Color(0xFF027A48),
      backgroundColor: Color(0xFFE7F6EC),
    ),
  };
}
