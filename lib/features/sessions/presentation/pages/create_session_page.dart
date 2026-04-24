import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/feature_support_widgets.dart';
import '../../../cases/data/models/case_summary_model.dart';
import '../../data/models/intervention_model.dart';
import '../../data/repositories/sessions_repository.dart';

class CreateSessionPage extends StatefulWidget {
  const CreateSessionPage({required this.caseSummary, super.key});

  static const String name = 'create-session';
  static const String path = '/sessions/create';

  final CaseSummaryModel caseSummary;

  @override
  State<CreateSessionPage> createState() => _CreateSessionPageState();
}

class _CreateSessionPageState extends State<CreateSessionPage> {
  static const Map<String, String> _statusLabels = <String, String>{
    'scheduled': 'Scheduled',
    'confirmed': 'Confirmed',
    'in_progress': 'In Progress',
    'done': 'Done',
    'cancelled': 'Cancelled',
    'no_show': 'No Show',
    'rescheduled': 'Rescheduled',
  };

  static const Map<String, String> _followUpLabels = <String, String>{
    'finished': 'Finished',
    'routine_control': 'Routine Control',
    'continued_therapy': 'Continued Therapy',
    'external_referral': 'External Referral',
  };

  final SessionsRepository _repository = const SessionsRepository();
  final _complaintController = TextEditingController();
  final _summaryController = TextEditingController();
  final _resultController = TextEditingController();
  final _recommendationController = TextEditingController();
  final _nextPlanController = TextEditingController();
  final _followUpNoteController = TextEditingController();
  final _specialNoteController = TextEditingController();
  final _messageController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _assessmentTypeController = TextEditingController();
  final _assessmentNameController = TextEditingController();
  final _assessmentDescriptionController = TextEditingController();
  final _interventionNoteController = TextEditingController();
  final _planPhaseController = TextEditingController();
  final _beforeConditionController = TextEditingController();
  final _afterConditionController = TextEditingController();
  final _displayDateFormat = DateFormat('dd MMM yyyy');
  final _submitDateFormat = DateFormat('yyyy-MM-dd');

  late Future<_CreateSessionOptions> _optionsFuture;
  int _currentStep = 0;
  DateTime _sessionDate = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _selectedStatus = 'scheduled';
  String? _selectedFollowUpType;
  String? _selectedInterventionId;
  DateTime? _planDate;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _optionsFuture = _loadOptions();
  }

  @override
  void dispose() {
    _complaintController.dispose();
    _summaryController.dispose();
    _resultController.dispose();
    _recommendationController.dispose();
    _nextPlanController.dispose();
    _followUpNoteController.dispose();
    _specialNoteController.dispose();
    _messageController.dispose();
    _diagnosisController.dispose();
    _assessmentTypeController.dispose();
    _assessmentNameController.dispose();
    _assessmentDescriptionController.dispose();
    _interventionNoteController.dispose();
    _planPhaseController.dispose();
    _beforeConditionController.dispose();
    _afterConditionController.dispose();
    super.dispose();
  }

  Future<_CreateSessionOptions> _loadOptions() async {
    final sessions = await _repository.fetchSessions(
      caseId: widget.caseSummary.id,
    );
    final interventions = await _repository.fetchInterventions();

    return _CreateSessionOptions(
      nextSessionNumber: sessions.isEmpty
          ? 1
          : sessions.first.sessionNumber + 1,
      interventions: interventions,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Session Baru')),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFFF8FAFC), Color(0xFFEFF4FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<_CreateSessionOptions>(
            future: _optionsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return StateMessage(
                  title: 'Form session belum bisa dibuka',
                  subtitle: '${snapshot.error}',
                  actionLabel: 'Tutup',
                  onPressed: () => Navigator.of(context).pop(),
                );
              }

              final options = snapshot.data!;

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
                          _SessionStepIndicator(currentStep: _currentStep),
                          const SizedBox(height: 24),
                          Text(
                            widget.caseSummary.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF101828),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${widget.caseSummary.clientName ?? 'Klien'} • Session ${options.nextSessionNumber}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF667085),
                            ),
                          ),
                          const SizedBox(height: 22),
                          if (_currentStep == 0)
                            _buildInfoStep(options)
                          else if (_currentStep == 1)
                            _buildNotesStep()
                          else if (_currentStep == 2)
                            _buildClinicalStep(options)
                          else
                            _buildFollowUpStep(),
                          const SizedBox(height: 24),
                          _buildActions(options),
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

  Widget _buildInfoStep(_CreateSessionOptions options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _SectionTitle(title: 'Informasi Utama'),
        const SizedBox(height: 12),
        _ReadOnlyField(
          label: 'Nomor Session',
          value: 'Session ${options.nextSessionNumber}',
        ),
        const SizedBox(height: 12),
        _DateField(
          label: 'Tanggal Session',
          value: _displayDateFormat.format(_sessionDate),
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
          items: _statusLabels.entries
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
            });
          },
        ),
      ],
    );
  }

  Widget _buildNotesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _SectionTitle(title: 'Catatan Session'),
        const SizedBox(height: 12),
        TextFormField(
          controller: _complaintController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Complaint'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _summaryController,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(labelText: 'Summary'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _resultController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Result'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _recommendationController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Recommendation'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nextPlanController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Next Plan'),
        ),
      ],
    );
  }

  Widget _buildClinicalStep(_CreateSessionOptions options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _SectionTitle(title: 'Pendukung Klinis'),
        const SizedBox(height: 12),
        TextFormField(
          controller: _diagnosisController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Diagnosis',
            hintText: 'Isi diagnosis utama untuk session ini',
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _assessmentTypeController,
          decoration: const InputDecoration(labelText: 'Assessment Type'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _assessmentNameController,
          decoration: const InputDecoration(labelText: 'Assessment Name'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _assessmentDescriptionController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Assessment Description',
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _selectedInterventionId,
          decoration: const InputDecoration(labelText: 'Intervention'),
          items: options.interventions
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item.id,
                  child: Text('${item.code} • ${item.name}'),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedInterventionId = value;
            });
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _interventionNoteController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Intervention Note'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _planPhaseController,
          decoration: const InputDecoration(labelText: 'Intervention Phase'),
        ),
        const SizedBox(height: 12),
        _DateField(
          label: 'Plan Date',
          value: _planDate == null
              ? 'Pilih tanggal'
              : _displayDateFormat.format(_planDate!),
          onTap: _pickPlanDate,
          isPlaceholder: _planDate == null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _beforeConditionController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Before Condition'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _afterConditionController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'After Condition'),
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
          decoration: const InputDecoration(labelText: 'Follow Up Type'),
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
          decoration: const InputDecoration(labelText: 'Follow Up Note'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _specialNoteController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Special Note'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _messageController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Message'),
        ),
      ],
    );
  }

  Widget _buildActions(_CreateSessionOptions options) {
    final isLastStep = _currentStep == 3;

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
                : () => isLastStep ? _submit(options) : _goToNextStep(),
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
                  ? 'Simpan Session'
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

    if (_currentStep == 1 && _summaryController.text.trim().isEmpty) {
      _showMessage('Summary session wajib diisi.');
      return;
    }

    setState(() {
      _currentStep += 1;
    });
  }

  Future<void> _submit(_CreateSessionOptions options) async {
    if (_startTime == null || _endTime == null) {
      _showMessage('Jam mulai dan jam selesai wajib diisi.');
      return;
    }

    final durationMinutes = _calculateDurationMinutes();
    if (durationMinutes == null) {
      _showMessage('Jam selesai harus lebih besar dari jam mulai.');
      return;
    }

    if (_summaryController.text.trim().isEmpty) {
      _showMessage('Summary session wajib diisi.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _repository.createSession(
        caseId: widget.caseSummary.id,
        psychologistId: widget.caseSummary.assignedPsychologistId,
        sessionNumber: options.nextSessionNumber,
        sessionDate: _submitDateFormat.format(_sessionDate),
        startTime: _toTimeString(_startTime),
        endTime: _toTimeString(_endTime),
        status: _selectedStatus,
        complaint: _complaintController.text,
        summary: _summaryController.text,
        result: _resultController.text,
        recommendation: _recommendationController.text,
        nextPlan: _nextPlanController.text,
        followUpType: _selectedFollowUpType,
        followUpNote: _followUpNoteController.text,
        durationMinutes: durationMinutes,
        specialNote: _specialNoteController.text,
        message: _messageController.text,
        diagnoses: _diagnosisController.text.trim().isEmpty
            ? const <CreateSessionDiagnosisInput>[]
            : <CreateSessionDiagnosisInput>[
                CreateSessionDiagnosisInput(
                  diagnosisText: _diagnosisController.text,
                ),
              ],
        assessments: _assessmentTypeController.text.trim().isEmpty
            ? const <CreateSessionAssessmentInput>[]
            : <CreateSessionAssessmentInput>[
                CreateSessionAssessmentInput(
                  assessmentType: _assessmentTypeController.text,
                  assessmentName: _assessmentNameController.text,
                  description: _assessmentDescriptionController.text,
                ),
              ],
        interventions: _selectedInterventionId == null
            ? const <CreateSessionInterventionInput>[]
            : <CreateSessionInterventionInput>[
                CreateSessionInterventionInput(
                  interventionId: _selectedInterventionId!,
                  note: _interventionNoteController.text,
                ),
              ],
        interventionPlans: _planPhaseController.text.trim().isEmpty
            ? const <CreateSessionInterventionPlanInput>[]
            : <CreateSessionInterventionPlanInput>[
                CreateSessionInterventionPlanInput(
                  phase: _planPhaseController.text,
                  planDate: _planDate == null
                      ? null
                      : _submitDateFormat.format(_planDate!),
                  beforeCondition: _beforeConditionController.text,
                  afterCondition: _afterConditionController.text,
                ),
              ],
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Session baru berhasil dibuat.')),
        );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage('Gagal membuat session: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _pickSessionDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _sessionDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected != null) {
      setState(() {
        _sessionDate = selected;
      });
    }
  }

  Future<void> _pickPlanDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _planDate ?? _sessionDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected != null) {
      setState(() {
        _planDate = selected;
      });
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final current = isStart ? _startTime : _endTime;
    final selected = await showTimePicker(
      context: context,
      initialTime: current ?? TimeOfDay.now(),
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

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CreateSessionOptions {
  const _CreateSessionOptions({
    required this.nextSessionNumber,
    required this.interventions,
  });

  final int nextSessionNumber;
  final List<InterventionModel> interventions;
}

class _SessionStepIndicator extends StatelessWidget {
  const _SessionStepIndicator({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    const titles = <String>['Info', 'Catatan', 'Klinis', 'Follow Up'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List<Widget>.generate(titles.length * 2 - 1, (rawIndex) {
        if (rawIndex.isOdd) {
          final stepIndex = rawIndex ~/ 2;
          return Expanded(
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

        return Column(
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
            SizedBox(
              width: 72,
              child: Text(
                titles[index],
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isActive
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF667085),
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      }),
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
    this.isPlaceholder = false,
  });

  final String label;
  final String value;
  final bool isPlaceholder;
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
                      color: isPlaceholder
                          ? const Color(0xFF98A2B3)
                          : const Color(0xFF101828),
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
