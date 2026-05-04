import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/widgets/feature_support_widgets.dart';
import '../../../cases/data/models/case_summary_model.dart';
import '../../data/models/assessment_type_model.dart';
import '../../data/models/intervention_model.dart';
import '../../data/models/session_model.dart';
import '../../data/repositories/assessment_types_repository.dart';
import '../../data/repositories/intervention_master_repository.dart';
import '../../data/repositories/sessions_repository.dart';

class UpdateSessionArgs {
  const UpdateSessionArgs({required this.caseSummary, required this.sessionId});

  final CaseSummaryModel caseSummary;
  final String sessionId;
}

class UpdateSessionPage extends StatefulWidget {
  const UpdateSessionPage({required this.args, super.key});

  static const String name = 'update-session';
  static const String path = '/sessions/update';

  final UpdateSessionArgs args;

  @override
  State<UpdateSessionPage> createState() => _UpdateSessionPageState();
}

class _UpdateSessionPageState extends State<UpdateSessionPage> {
  static const Map<String, String> _statusLabels = <String, String>{
    'scheduled': 'Scheduled',
    'confirmed': 'Confirmed',
    'done': 'Done',
    'cancelled': 'Cancelled',
  };

  static const Map<String, List<String>> _allowedTransitions =
      <String, List<String>>{
        'scheduled': <String>['scheduled', 'confirmed', 'cancelled'],
        'confirmed': <String>['confirmed', 'done', 'cancelled'],
        'done': <String>['done'],
        'cancelled': <String>['cancelled'],
      };

  static const Map<String, String> _followUpLabels = <String, String>{
    'finished': 'Finished',
    'routine_control': 'Routine Control',
    'continued_therapy': 'Continued Therapy',
    'external_referral': 'External Referral',
  };

  final SessionsRepository _repository = const SessionsRepository();
  final AssessmentTypesRepository _assessmentTypesRepository =
      const AssessmentTypesRepository();
  final InterventionMasterRepository _interventionMasterRepository =
      const InterventionMasterRepository();
  final _complaintController = TextEditingController();
  final _assessmentDescriptionController = TextEditingController();
  final _interventionNoteController = TextEditingController();
  final _summaryController = TextEditingController();
  final _followUpNoteController = TextEditingController();
  final _specialNoteController = TextEditingController();
  final _messageController = TextEditingController();
  final _displayDateFormat = DateFormat('dd MMM yyyy');
  final _submitDateFormat = DateFormat('yyyy-MM-dd');

  late Future<SessionModel> _sessionFuture;
  late Future<List<AssessmentTypeModel>> _assessmentTypesFuture;
  late Future<List<InterventionModel>> _interventionsFuture;
  int _currentStep = 0;
  DateTime? _sessionDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _selectedStatus = 'scheduled';
  String _initialStatus = 'scheduled';
  String? _selectedFollowUpType;
  bool _isSubmitting = false;
  final Set<String> _selectedAssessmentTypeIds = <String>{};
  final Map<String, String> _assessmentTypeNamesById = <String, String>{};
  final Set<String> _selectedInterventionIds = <String>{};

  bool get _isFullFlow => _selectedStatus == 'done';

  List<String> get _stepTitles => _isFullFlow
      ? const <String>[
          'Jadwal & Status',
          'Assessment',
          'Intervention',
          'Catatan',
          'Follow Up',
        ]
      : const <String>['Jadwal & Status', 'Catatan'];

  List<String> get _availableStatuses =>
      _allowedTransitions[_initialStatus] ?? _allowedTransitions['scheduled']!;

  @override
  void initState() {
    super.initState();
    _sessionFuture = _repository.fetchSessionDetail(widget.args.sessionId);
    _assessmentTypesFuture = _assessmentTypesRepository.fetchAssessmentTypes();
    _interventionsFuture = _interventionMasterRepository.fetchInterventions();
  }

  @override
  void dispose() {
    _complaintController.dispose();
    _assessmentDescriptionController.dispose();
    _interventionNoteController.dispose();
    _summaryController.dispose();
    _followUpNoteController.dispose();
    _specialNoteController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _hydrate(SessionModel session) {
    if (_sessionDate != null) {
      return;
    }

    _sessionDate = session.sessionDate;
    _startTime = _parseTime(session.startTime);
    _endTime = _parseTime(session.endTime);
    _initialStatus = _normalizeStatus(session.status);
    _selectedStatus = _initialStatus;
    _selectedFollowUpType = session.followUpType;
    _selectedAssessmentTypeIds
      ..clear()
      ..addAll(
        session.assessments
            .map((item) => item.assessmentTypeId.trim())
            .where((item) => item.isNotEmpty),
      );
    _assessmentDescriptionController.text = session.assessments
        .map((item) => item.description?.trim() ?? '')
        .firstWhere((item) => item.isNotEmpty, orElse: () => '');
    _selectedInterventionIds
      ..clear()
      ..addAll(
        session.interventions
            .map((item) => item.interventionId.trim())
            .where((item) => item.isNotEmpty),
      );
    _interventionNoteController.text = session.interventions
        .map((item) => item.note?.trim() ?? '')
        .firstWhere((item) => item.isNotEmpty, orElse: () => '');
    _complaintController.text = session.complaint ?? '';
    _summaryController.text = session.summary ?? '';
    _followUpNoteController.text = session.followUpNote ?? '';
    _specialNoteController.text = session.specialNote ?? '';
    _messageController.text = session.message ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Update Session')),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFFF8FAFC), Color(0xFFEFF4FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<SessionModel>(
            future: _sessionFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return StateMessage(
                  title: 'Data session belum bisa dibuka',
                  subtitle: '${snapshot.error}',
                  actionLabel: 'Tutup',
                  onPressed: () => Navigator.of(context).pop(),
                );
              }

              final session = snapshot.data!;
              _hydrate(session);

              if (session.isLocked) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 28,
                              offset: Offset(0, 16),
                            ),
                          ],
                        ),
                        child: _buildLockedSessionView(session),
                      ),
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 28,
                            offset: Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _SessionStepIndicator(
                            currentStep: _currentStep,
                            titles: _stepTitles,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            widget.args.caseSummary.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF101828),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${widget.args.caseSummary.clientName ?? 'Klien'} • Session ${session.sessionNumber}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF667085),
                            ),
                          ),
                          const SizedBox(height: 22),
                          if (_currentStep == 0)
                            _buildInfoStep(session)
                          else if (_currentStep == 1 && _isFullFlow)
                            _buildAssessmentStep()
                          else if (_currentStep == 2 && _isFullFlow)
                            _buildInterventionStep()
                          else if (_currentStep == 3 && _isFullFlow)
                            _buildNotesStep()
                          else if (_currentStep == 1)
                            _buildStatusNotesStep()
                          else
                            _buildFollowUpStep(),
                          const SizedBox(height: 24),
                          _buildActions(session),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoStep(SessionModel session) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _SectionTitle(title: 'Jadwal & Status'),
        const SizedBox(height: 12),
        _ReadOnlyField(
          label: 'Nomor Session',
          value: 'Session ${session.sessionNumber}',
        ),
        const SizedBox(height: 12),
        _DateField(
          label: 'Tanggal Session',
          value: _displayDateFormat.format(_sessionDate!),
          onTap: _pickSessionDate,
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _TimeField(
                label: 'Jam Mulai',
                value: _formatTime(_startTime),
                placeholder: 'Pilih jam',
                onTap: () => _pickTime(isStart: true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TimeField(
                label: 'Jam Selesai',
                value: _formatTime(_endTime),
                placeholder: 'Pilih jam',
                onTap: () => _pickTime(isStart: false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _selectedStatus,
          decoration: const InputDecoration(labelText: 'Status Session'),
          items: _availableStatuses
              .map(
                (status) => MapEntry(status, _statusLabels[status] ?? status),
              )
              .map(
                (entry) => DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) {
              return;
            }

            setState(() {
              _selectedStatus = value;
              final lastStepIndex = _stepTitles.length - 1;
              if (_currentStep > lastStepIndex) {
                _currentStep = lastStepIndex;
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildLockedSessionView(SessionModel session) {
    final theme = Theme.of(context);
    final lockedAt = session.lockedAt;
    final assessmentNames = session.assessments
        .map(
          (item) =>
              item.assessmentName?.trim() ?? item.assessmentType?.name ?? '',
        )
        .where((item) => item.isNotEmpty)
        .toList();
    final assessmentDescription = session.assessments
        .map((item) => item.description?.trim() ?? '')
        .firstWhere((item) => item.isNotEmpty, orElse: () => '');
    final interventionNames = session.interventions
        .map((item) => item.intervention?.name.trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList();
    final interventionNote = session.interventions
        .map((item) => item.note?.trim() ?? '')
        .firstWhere((item) => item.isNotEmpty, orElse: () => '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFDCE7F5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(Icons.lock_rounded, color: Color(0xFF2563EB)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Session sudah dikunci',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF101828),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lockedAt == null
                          ? 'Session ini sudah selesai dan tidak bisa diedit lagi.'
                          : 'Session ini dikunci pada ${_formatDateTime(lockedAt)} dan tidak bisa diedit lagi.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF475467),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          widget.args.caseSummary.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF101828),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${widget.args.caseSummary.clientName ?? 'Klien'} • Session ${session.sessionNumber}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF667085),
          ),
        ),
        const SizedBox(height: 22),
        _DetailSection(
          title: 'Jadwal & Status',
          rows: <_DetailRowData>[
            _DetailRowData(
              label: 'Tanggal Session',
              value: _displayDateFormat.format(session.sessionDate),
            ),
            _DetailRowData(
              label: 'Jam',
              value:
                  '${_formatTime(_parseTime(session.startTime))} - ${_formatTime(_parseTime(session.endTime))}',
            ),
            _DetailRowData(
              label: 'Durasi',
              value: session.durationMinutes == null
                  ? '-'
                  : '${session.durationMinutes} menit',
            ),
            _DetailRowData(
              label: 'Status',
              value:
                  _statusLabels[_normalizeStatus(session.status)] ??
                  session.status,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _DetailSection(
          title: 'Assessment',
          rows: <_DetailRowData>[
            _DetailRowData(
              label: 'Assessment Dipilih',
              value: assessmentNames.isEmpty ? '-' : assessmentNames.join(', '),
            ),
            _DetailRowData(
              label: 'Catatan Assessment',
              value: assessmentDescription.isEmpty
                  ? '-'
                  : assessmentDescription,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _DetailSection(
          title: 'Intervention',
          rows: <_DetailRowData>[
            _DetailRowData(
              label: 'Intervention Dipilih',
              value: interventionNames.isEmpty
                  ? '-'
                  : interventionNames.join(', '),
            ),
            _DetailRowData(
              label: 'Catatan Intervention',
              value: interventionNote.isEmpty ? '-' : interventionNote,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _DetailSection(
          title: 'Catatan Session',
          rows: <_DetailRowData>[
            _DetailRowData(
              label: 'Keluhan',
              value: _displayOrDash(session.complaint),
            ),
            _DetailRowData(
              label: 'Ringkasan',
              value: _displayOrDash(session.summary),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _DetailSection(
          title: 'Follow Up',
          rows: <_DetailRowData>[
            _DetailRowData(
              label: 'Tipe Follow Up',
              value:
                  _followUpLabels[session.followUpType] ??
                  _displayOrDash(session.followUpType),
            ),
            _DetailRowData(
              label: 'Catatan Follow Up',
              value: _displayOrDash(session.followUpNote),
            ),
            _DetailRowData(
              label: 'Catatan Khusus',
              value: _displayOrDash(session.specialNote),
            ),
            _DetailRowData(
              label: 'Pesan Tambahan',
              value: _displayOrDash(session.message),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Kembali'),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _SectionTitle(title: 'Catatan Pertemuan'),
        const SizedBox(height: 12),
        TextFormField(
          controller: _complaintController,
          minLines: 5,
          maxLines: 8,
          decoration: const InputDecoration(
            labelText: 'Keluhan',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _summaryController,
          minLines: 6,
          maxLines: 10,
          decoration: const InputDecoration(
            labelText: 'Ringkasan Session',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildAssessmentStep() {
    return FutureBuilder<List<AssessmentTypeModel>>(
      future: _assessmentTypesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return StateMessage(
            title: 'Daftar assessment belum bisa dibuka',
            subtitle: '${snapshot.error}',
            actionLabel: 'Coba Lagi',
            onPressed: _reloadAssessmentTypes,
          );
        }

        final assessmentTypes = (snapshot.data ?? const <AssessmentTypeModel>[])
            .where(
              (item) =>
                  item.isActive || _selectedAssessmentTypeIds.contains(item.id),
            )
            .toList();

        for (final item in assessmentTypes) {
          _assessmentTypeNamesById[item.id] = item.name;
        }

        if (assessmentTypes.isEmpty) {
          return StateMessage(
            title: 'Belum ada assessment aktif',
            subtitle:
                'Tambahkan assessment type terlebih dulu sebelum session ditandai Done.',
            actionLabel: 'Muat Ulang',
            onPressed: _reloadAssessmentTypes,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const _SectionTitle(title: 'Assessment'),
            const SizedBox(height: 8),
            Text(
              'Pilih assessment yang digunakan pada session ini sebelum menyelesaikan session.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF667085),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            ...assessmentTypes.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CheckboxListTile(
                  value: _selectedAssessmentTypeIds.contains(item.id),
                  onChanged: (value) {
                    setState(() {
                      if (value ?? false) {
                        _selectedAssessmentTypeIds.add(item.id);
                      } else {
                        _selectedAssessmentTypeIds.remove(item.id);
                      }
                    });
                  },
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFD0D5DD)),
                  ),
                  activeColor: const Color(0xFF2563EB),
                  title: Text(item.name),
                  subtitle: Text(
                    item.description?.trim().isNotEmpty == true
                        ? '${item.code} • ${item.description}'
                        : item.code,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _assessmentDescriptionController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Catatan Assessment',
                hintText: 'Tulis catatan atau deskripsi hasil assessment.',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInterventionStep() {
    return FutureBuilder<List<InterventionModel>>(
      future: _interventionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return StateMessage(
            title: 'Daftar intervention belum bisa dibuka',
            subtitle: '${snapshot.error}',
            actionLabel: 'Coba Lagi',
            onPressed: _reloadInterventions,
          );
        }

        final interventions = (snapshot.data ?? const <InterventionModel>[])
            .where(
              (item) =>
                  item.isActive || _selectedInterventionIds.contains(item.id),
            )
            .toList();

        if (interventions.isEmpty) {
          return StateMessage(
            title: 'Belum ada intervention aktif',
            subtitle:
                'Tambahkan intervention master terlebih dulu sebelum session ditandai Done.',
            actionLabel: 'Muat Ulang',
            onPressed: _reloadInterventions,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const _SectionTitle(title: 'Intervention'),
            const SizedBox(height: 8),
            Text(
              'Pilih intervention yang digunakan pada session ini.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF667085),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            ...interventions.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CheckboxListTile(
                  value: _selectedInterventionIds.contains(item.id),
                  onChanged: (value) {
                    setState(() {
                      if (value ?? false) {
                        _selectedInterventionIds.add(item.id);
                      } else {
                        _selectedInterventionIds.remove(item.id);
                      }
                    });
                  },
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFD0D5DD)),
                  ),
                  activeColor: const Color(0xFF2563EB),
                  title: Text(item.name),
                  subtitle: Text(
                    item.description?.trim().isNotEmpty == true
                        ? '${item.code} • ${item.description}'
                        : item.code,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _interventionNoteController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Catatan Intervention',
                hintText: 'Tulis catatan atau detail intervention.',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusNotesStep() {
    final title = switch (_selectedStatus) {
      'done' => 'Catatan Session',
      'cancelled' => 'Catatan Pembatalan',
      _ => 'Catatan Status',
    };

    final messageLabel = switch (_selectedStatus) {
      'cancelled' => 'Alasan Pembatalan',
      _ => 'Pesan Tambahan',
    };

    final messageHint = switch (_selectedStatus) {
      'cancelled' => 'Jelaskan alasan pembatalan session.',
      _ => 'Isi pesan atau informasi tambahan.',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionTitle(title: title),
        const SizedBox(height: 12),
        if (!_isFullFlow) ...<Widget>[
          TextFormField(
            controller: _complaintController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Keluhan'),
          ),
          const SizedBox(height: 12),
        ],
        TextFormField(
          controller: _messageController,
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: messageLabel,
            hintText: messageHint,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _specialNoteController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Catatan Khusus'),
        ),
      ],
    );
  }

  Widget _buildFollowUpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _SectionTitle(title: 'Follow Up'),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _selectedFollowUpType,
          decoration: const InputDecoration(labelText: 'Tipe Follow Up'),
          items: _followUpLabels.entries
              .map(
                (entry) => DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedFollowUpType = value;
            });
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _followUpNoteController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Catatan Follow Up'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _specialNoteController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Catatan Khusus'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _messageController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Pesan Tambahan'),
        ),
      ],
    );
  }

  Widget _buildActions(SessionModel session) {
    final isLastStep = _currentStep == _stepTitles.length - 1;

    return Row(
      children: <Widget>[
        if (_currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: _isSubmitting
                  ? null
                  : () {
                      setState(() {
                        _currentStep -= 1;
                      });
                    },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Kembali'),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: _isSubmitting
                ? null
                : () => isLastStep ? _submit(session) : _goToNextStep(),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              _isSubmitting
                  ? 'Menyimpan...'
                  : isLastStep
                  ? 'Update Session'
                  : 'Lanjut',
            ),
          ),
        ),
      ],
    );
  }

  void _goToNextStep() {
    if (_currentStep == 0) {
      if (_startTime == null || _endTime == null) {
        _showMessage('Jam mulai dan jam selesai wajib diisi.');
        return;
      }

      if (_calculateDurationMinutes() == null) {
        _showMessage('Jam selesai harus lebih besar dari jam mulai.');
        return;
      }
    }

    if (_isFullFlow &&
        _currentStep == 1 &&
        _selectedAssessmentTypeIds.isEmpty) {
      _showMessage('Pilih minimal satu assessment untuk status Done.');
      return;
    }

    if (_isFullFlow && _currentStep == 2 && _selectedInterventionIds.isEmpty) {
      _showMessage('Pilih minimal satu intervention untuk status Done.');
      return;
    }

    setState(() {
      _currentStep += 1;
    });
  }

  Future<void> _submit(SessionModel session) async {
    if (_startTime == null || _endTime == null) {
      _showMessage('Jam mulai dan jam selesai wajib diisi.');
      return;
    }

    final durationMinutes = _calculateDurationMinutes();
    if (durationMinutes == null) {
      _showMessage('Jam selesai harus lebih besar dari jam mulai.');
      return;
    }

    if (!_availableStatuses.contains(_selectedStatus)) {
      _showMessage('Transisi status session ini tidak diizinkan.');
      return;
    }

    if (_isFullFlow && _summaryController.text.trim().isEmpty) {
      _showMessage('Ringkasan session wajib diisi untuk status Done.');
      return;
    }

    if (_isFullFlow && _selectedAssessmentTypeIds.isEmpty) {
      _showMessage('Pilih minimal satu assessment untuk status Done.');
      return;
    }

    if (_isFullFlow && _selectedInterventionIds.isEmpty) {
      _showMessage('Pilih minimal satu intervention untuk status Done.');
      return;
    }

    if (_selectedStatus == 'cancelled' &&
        _messageController.text.trim().isEmpty) {
      _showMessage('Alasan pembatalan wajib diisi.');
      return;
    }

    if (_selectedStatus == 'done') {
      final shouldContinue = await _confirmDoneStatus();
      if (!shouldContinue) {
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final updatedStatus = await _repository.updateSession(
        sessionId: session.id,
        sessionDate: _submitDateFormat.format(_sessionDate!),
        startTime: _toTimeString(_startTime),
        endTime: _toTimeString(_endTime),
        status: _selectedStatus,
        complaint: _complaintController.text,
        summary: _isFullFlow ? _summaryController.text : null,
        followUpType: _isFullFlow ? _selectedFollowUpType : null,
        followUpNote: _isFullFlow ? _followUpNoteController.text : null,
        durationMinutes: durationMinutes,
        specialNote: _specialNoteController.text,
        message: _messageController.text,
        assessments: _isFullFlow
            ? _selectedAssessmentTypeIds
                  .map(
                    (id) => CreateSessionAssessmentInput(
                      assessmentTypeId: id,
                      assessmentName: _assessmentTypeNamesById[id],
                      description: _assessmentDescriptionController.text,
                    ),
                  )
                  .toList()
            : const <CreateSessionAssessmentInput>[],
        interventions: _isFullFlow
            ? _selectedInterventionIds
                  .map(
                    (id) => CreateSessionInterventionInput(
                      interventionId: id,
                      note: _interventionNoteController.text,
                    ),
                  )
                  .toList()
            : const <CreateSessionInterventionInput>[],
      );

      if (updatedStatus != _selectedStatus) {
        throw Exception(
          'Status tersimpan sebagai "$updatedStatus", bukan "$_selectedStatus".',
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Session berhasil diperbarui.')),
        );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(_formatSubmitError(error));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<bool> _confirmDoneStatus() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Selesaikan Session?'),
          content: const Text(
            'Status session akan diubah menjadi selesai. Setelah disimpan, session ini akan terkunci dan tidak bisa diedit kembali. Pastikan seluruh data sudah benar karena session ini menjadi tahap akhir sebelum laporan dibuat.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Periksa Lagi'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Ya, Selesaikan'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _pickSessionDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _sessionDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected != null) {
      setState(() {
        _sessionDate = selected;
      });
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final current = isStart ? _startTime : _endTime;
    final selected = await showTimePicker(
      context: context,
      initialTime: current ?? TimeOfDay.now(),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (selected == null) {
      return;
    }

    setState(() {
      if (isStart) {
        _startTime = selected;
      } else {
        _endTime = selected;
      }
    });
  }

  int? _calculateDurationMinutes() {
    if (_startTime == null || _endTime == null) {
      return null;
    }

    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
    final diff = endMinutes - startMinutes;
    if (diff <= 0) {
      return null;
    }

    return diff;
  }

  TimeOfDay? _parseTime(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return null;
    }

    final parts = raw.split(':');
    if (parts.length < 2) {
      return null;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return null;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  String? _toTimeString(TimeOfDay? time) {
    if (time == null) {
      return null;
    }

    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) {
      return '';
    }

    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _normalizeStatus(String value) {
    return switch (value) {
      'in_progress' => 'confirmed',
      'no_show' || 'rescheduled' => 'cancelled',
      'confirmed' || 'done' || 'cancelled' => value,
      _ => 'scheduled',
    };
  }

  String _formatSubmitError(Object error) {
    if (error is AppException) {
      return error.message;
    }

    final text = error.toString().trim();
    if (text.startsWith('Exception: ')) {
      return text.substring('Exception: '.length);
    }

    return 'Gagal memperbarui session: $text';
  }

  String _formatDateTime(DateTime value) {
    return DateFormat('dd MMM yyyy, HH:mm').format(value);
  }

  String _displayOrDash(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? '-' : text;
  }

  void _reloadAssessmentTypes() {
    setState(() {
      _assessmentTypesFuture = _assessmentTypesRepository
          .fetchAssessmentTypes();
    });
  }

  void _reloadInterventions() {
    setState(() {
      _interventionsFuture = _interventionMasterRepository.fetchInterventions();
    });
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SessionStepIndicator extends StatelessWidget {
  const _SessionStepIndicator({
    required this.currentStep,
    required this.titles,
  });

  final int currentStep;
  final List<String> titles;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final content = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List<Widget>.generate(titles.length * 2 - 1, (rawIndex) {
            if (rawIndex.isOdd) {
              final stepIndex = rawIndex ~/ 2;
              return SizedBox(
                width: 28,
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.only(top: 16),
                  color: currentStep > stepIndex
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFD0D5DD),
                ),
              );
            }

            final index = rawIndex ~/ 2;
            final isActive = currentStep == index;
            final isCompleted = currentStep > index;

            return SizedBox(
              width: 78,
              child: Column(
                children: <Widget>[
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isActive || isCompleted
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFEAECF0),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    titles[index],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isActive
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF667085),
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),
        );

        if (constraints.maxWidth < 520) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: content,
            ),
          );
        }

        return content;
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: const Color(0xFF101828),
      ),
    );
  }
}

class _DetailRowData {
  const _DetailRowData({required this.label, required this.value});

  final String label;
  final String value;
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.rows});

  final String title;
  final List<_DetailRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 14),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 150,
                    child: Text(
                      row.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF667085),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      row.value,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF101828),
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD0D5DD)),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.calendar_today_outlined, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF667085),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF101828),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  final String label;
  final String value;
  final String placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD0D5DD)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF667085)),
            ),
            const SizedBox(height: 4),
            Text(
              value.isEmpty ? placeholder : value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: value.isEmpty
                    ? const Color(0xFF98A2B3)
                    : const Color(0xFF101828),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
