import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/feature_support_widgets.dart';
import '../../../cases/data/models/case_summary_model.dart';
import '../../data/models/session_model.dart';
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
  final _displayDateFormat = DateFormat('dd MMM yyyy');
  final _submitDateFormat = DateFormat('yyyy-MM-dd');

  late Future<SessionModel> _sessionFuture;
  int _currentStep = 0;
  DateTime? _sessionDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _selectedStatus = 'scheduled';
  String? _selectedFollowUpType;
  bool _isSubmitting = false;

  bool get _isFullFlow => _selectedStatus == 'done';

  bool get _requiresScheduleDetails =>
      _selectedStatus != 'cancelled' && _selectedStatus != 'no_show';

  bool get _requiresReasonMessage =>
      _selectedStatus == 'rescheduled' ||
      _selectedStatus == 'cancelled' ||
      _selectedStatus == 'no_show';

  List<String> get _stepTitles => _isFullFlow
      ? const <String>['Pertemuan', 'Catatan', 'Follow Up']
      : const <String>['Status', 'Catatan'];

  @override
  void initState() {
    super.initState();
    _sessionFuture = _repository.fetchSessionDetail(widget.args.sessionId);
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
    super.dispose();
  }

  void _hydrate(SessionModel session) {
    if (_sessionDate != null) {
      return;
    }

    _sessionDate = session.sessionDate;
    _startTime = _parseTime(session.startTime);
    _endTime = _parseTime(session.endTime);
    _selectedStatus = session.status;
    _selectedFollowUpType = session.followUpType;
    _complaintController.text = session.complaint ?? '';
    _summaryController.text = session.summary ?? '';
    _resultController.text = session.result ?? '';
    _recommendationController.text = session.recommendation ?? '';
    _nextPlanController.text = session.nextPlan ?? '';
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
        _SectionTitle(
          title: _requiresScheduleDetails
              ? 'Informasi Pertemuan'
              : 'Perubahan Status',
        ),
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
        if (_requiresScheduleDetails) ...<Widget>[
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
        ] else ...<Widget>[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              'Status ini tidak mewajibkan pengisian detail pertemuan sampai selesai. Cukup update status dan catatan pendukungnya.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF475467),
                height: 1.45,
              ),
            ),
          ),
        ],
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

  Widget _buildNotesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _SectionTitle(title: 'Catatan Pertemuan'),
        const SizedBox(height: 12),
        TextFormField(
          controller: _complaintController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Keluhan'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _summaryController,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(labelText: 'Ringkasan Session'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _resultController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Hasil Pertemuan'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _recommendationController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Rekomendasi'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nextPlanController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Rencana Berikutnya'),
        ),
      ],
    );
  }

  Widget _buildStatusNotesStep() {
    final title = switch (_selectedStatus) {
      'rescheduled' => 'Catatan Reschedule',
      'cancelled' => 'Catatan Pembatalan',
      'no_show' => 'Catatan No Show',
      'in_progress' => 'Catatan Pertemuan',
      _ => 'Catatan Status',
    };

    final messageLabel = switch (_selectedStatus) {
      'rescheduled' => 'Alasan Reschedule',
      'cancelled' => 'Alasan Pembatalan',
      'no_show' => 'Catatan No Show',
      _ => 'Pesan Tambahan',
    };

    final messageHint = switch (_selectedStatus) {
      'rescheduled' =>
        'Jelaskan kenapa sesi dipindahkan dan apa perubahan jadwalnya.',
      'cancelled' => 'Jelaskan alasan pembatalan session.',
      'no_show' => 'Tulis catatan kenapa session dianggap no show.',
      _ => 'Isi pesan atau informasi tambahan.',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionTitle(title: title),
        const SizedBox(height: 12),
        if (_selectedStatus == 'scheduled' ||
            _selectedStatus == 'confirmed' ||
            _selectedStatus == 'in_progress') ...<Widget>[
          TextFormField(
            controller: _complaintController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Keluhan'),
          ),
          const SizedBox(height: 12),
        ],
        if (_selectedStatus == 'in_progress') ...<Widget>[
          TextFormField(
            controller: _summaryController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Ringkasan Sementara'),
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
      if (_requiresScheduleDetails &&
          (_startTime == null || _endTime == null)) {
        _showMessage('Jam mulai dan jam selesai wajib diisi.');
        return;
      }

      if (_requiresScheduleDetails && _calculateDurationMinutes() == null) {
        _showMessage('Jam selesai harus lebih besar dari jam mulai.');
        return;
      }
    }

    setState(() {
      _currentStep += 1;
    });
  }

  Future<void> _submit(SessionModel session) async {
    if (_requiresScheduleDetails && (_startTime == null || _endTime == null)) {
      _showMessage('Jam mulai dan jam selesai wajib diisi.');
      return;
    }

    final durationMinutes = _requiresScheduleDetails
        ? _calculateDurationMinutes()
        : null;
    if (_requiresScheduleDetails && durationMinutes == null) {
      _showMessage('Jam selesai harus lebih besar dari jam mulai.');
      return;
    }

    if (_isFullFlow && _summaryController.text.trim().isEmpty) {
      _showMessage('Ringkasan session wajib diisi untuk status Done.');
      return;
    }

    if (_isFullFlow && _resultController.text.trim().isEmpty) {
      _showMessage('Hasil pertemuan wajib diisi untuk status Done.');
      return;
    }

    if (_requiresReasonMessage && _messageController.text.trim().isEmpty) {
      _showMessage('Catatan alasan status ini wajib diisi.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _repository.updateSession(
        sessionId: session.id,
        sessionDate: _submitDateFormat.format(_sessionDate!),
        startTime: _requiresScheduleDetails ? _toTimeString(_startTime) : null,
        endTime: _requiresScheduleDetails ? _toTimeString(_endTime) : null,
        status: _selectedStatus,
        complaint: _complaintController.text,
        summary: _isFullFlow || _selectedStatus == 'in_progress'
            ? _summaryController.text
            : null,
        result: _isFullFlow ? _resultController.text : null,
        recommendation: _isFullFlow ? _recommendationController.text : null,
        nextPlan: _isFullFlow ? _nextPlanController.text : null,
        followUpType: _isFullFlow ? _selectedFollowUpType : null,
        followUpNote: _isFullFlow ? _followUpNoteController.text : null,
        durationMinutes: durationMinutes,
        specialNote: _specialNoteController.text,
        message: _messageController.text,
      );

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

      _showMessage('Gagal memperbarui session: $error');
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
              width: 82,
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
