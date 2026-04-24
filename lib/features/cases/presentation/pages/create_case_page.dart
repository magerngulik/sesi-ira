import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/feature_support_widgets.dart';
import '../../../clients/data/models/client_model.dart';
import '../../../clients/data/repositories/clients_repository.dart';
import '../../../psychologists/data/models/psychologist_model.dart';
import '../../../psychologists/data/repositories/psychologists_repository.dart';
import '../../data/models/case_tag_model.dart';
import '../../data/repositories/case_tags_repository.dart';
import '../../data/repositories/cases_repository.dart';

class CreateCasePage extends StatefulWidget {
  const CreateCasePage({super.key});

  static const String name = 'create-case';
  static const String path = '/cases/create';

  @override
  State<CreateCasePage> createState() => _CreateCasePageState();
}

class _CreateCasePageState extends State<CreateCasePage> {
  static const List<String> _categoryOptions = <String>[
    'Anak & Remaja',
    'Dewasa',
    'Keluarga',
    'Pendidikan',
    'Karier',
    'Lainnya',
  ];

  static const Map<String, String> _statusLabels = <String, String>{
    'active': 'Active',
    'on_hold': 'On Hold',
    'completed': 'Completed',
    'cancelled': 'Cancelled',
  };

  final CasesRepository _repository = const CasesRepository();
  final ClientsRepository _clientsRepository = const ClientsRepository();
  final PsychologistsRepository _psychologistsRepository =
      const PsychologistsRepository();
  final CaseTagsRepository _caseTagsRepository = const CaseTagsRepository();
  final _titleController = TextEditingController();
  final _complaintController = TextEditingController();
  final _goalController = TextEditingController();
  final _displayDateFormat = DateFormat('dd MMM yyyy');
  final _submitDateFormat = DateFormat('yyyy-MM-dd');

  late Future<_CreateCaseOptions> _optionsFuture;
  int _currentStep = 0;
  String? _selectedClientId;
  String? _selectedPsychologistId;
  String? _selectedCategory;
  String _selectedStatus = 'active';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  Set<String> _selectedTagIds = <String>{};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _optionsFuture = _loadOptions();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _complaintController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<_CreateCaseOptions> _loadOptions() async {
    final clients = await _clientsRepository.fetchClients();
    final psychologists = await _psychologistsRepository.fetchPsychologists();
    final caseTags = await _caseTagsRepository.fetchCaseTags();

    return _CreateCaseOptions(
      clients: clients,
      psychologists: psychologists,
      caseTags: caseTags,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Case Baru')),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFFF6F8FC), Color(0xFFEEF4FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<_CreateCaseOptions>(
            future: _optionsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return StateMessage(
                  title: 'Form case belum bisa dibuka',
                  subtitle: '${snapshot.error}',
                  actionLabel: 'Tutup',
                  onPressed: () => Navigator.of(context).pop(),
                );
              }

              final options = snapshot.data!;
              if (options.clients.isEmpty || options.psychologists.isEmpty) {
                return StateMessage(
                  title: 'Data master belum lengkap',
                  subtitle:
                      'Pastikan sudah ada minimal 1 klien dan 1 psikolog sebelum membuat case.',
                  actionLabel: 'Tutup',
                  onPressed: () => Navigator.of(context).pop(),
                );
              }

              _selectedClientId ??= options.clients.first.id;
              _selectedPsychologistId ??= options.psychologists.first.id;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
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
                          _StepIndicator(currentStep: _currentStep),
                          const SizedBox(height: 24),
                          if (_currentStep == 0)
                            _buildCaseInfoStep(options, theme),
                          if (_currentStep == 1)
                            _buildExtraDetailStep(options, theme),
                          if (_currentStep == 2)
                            _buildConfirmationStep(options, theme),
                          const SizedBox(height: 28),
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

  Widget _buildCaseInfoStep(_CreateCaseOptions options, ThemeData theme) {
    final selectedClient = options.findClientById(_selectedClientId);
    final selectedPsychologist = options.findPsychologistById(
      _selectedPsychologistId,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Informasi Dasar',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF101828),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Lengkapi data utama case sebelum lanjut ke detail tambahan.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF667085),
          ),
        ),
        const SizedBox(height: 20),
        _EntityPickerField<ClientModel>(
          label: 'Client',
          requiredField: true,
          value: selectedClient,
          titleBuilder: (client) => client.fullName,
          subtitleBuilder: _buildClientSubtitle,
          onTap: () => _pickClient(options.clients),
        ),
        const SizedBox(height: 14),
        _EntityPickerField<PsychologistModel>(
          label: 'Psikolog',
          requiredField: true,
          value: selectedPsychologist,
          titleBuilder: (psychologist) => psychologist.name,
          subtitleBuilder: (psychologist) =>
              psychologist.specializationSummary ?? 'Psikolog',
          onTap: () => _pickPsychologist(options.psychologists),
        ),
        const SizedBox(height: 14),
        const _SectionFieldLabel(label: 'Judul Case', requiredField: true),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          maxLength: 100,
          decoration: const InputDecoration(
            hintText: 'Masukkan judul case',
            counterText: '',
          ),
          onChanged: (_) => setState(() {}),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${_titleController.text.characters.length}/100',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF98A2B3),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const _SectionFieldLabel(label: 'Kategori'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          decoration: const InputDecoration(hintText: 'Pilih kategori'),
          items: _categoryOptions
              .map(
                (category) => DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
        ),
        const SizedBox(height: 14),
        const _SectionFieldLabel(label: 'Keluhan Utama', requiredField: true),
        const SizedBox(height: 8),
        TextFormField(
          controller: _complaintController,
          minLines: 4,
          maxLines: 5,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: 'Tuliskan keluhan utama klien',
            counterText: '',
          ),
          onChanged: (_) => setState(() {}),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${_complaintController.text.characters.length}/500',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF98A2B3),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const _SectionFieldLabel(
          label: 'Tujuan Penanganan',
          requiredField: true,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _goalController,
          minLines: 4,
          maxLines: 5,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: 'Tuliskan tujuan penanganan',
            counterText: '',
          ),
          onChanged: (_) => setState(() {}),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${_goalController.text.characters.length}/500',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF98A2B3),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const _SectionFieldLabel(label: 'Tanggal Mulai', requiredField: true),
        const SizedBox(height: 8),
        _DatePickerField(
          value: _displayDateFormat.format(_startDate),
          onTap: _pickStartDate,
        ),
        const SizedBox(height: 14),
        const _SectionFieldLabel(label: 'Status', requiredField: true),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedStatus,
          decoration: const InputDecoration(hintText: 'Pilih status'),
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

  Widget _buildExtraDetailStep(_CreateCaseOptions options, ThemeData theme) {
    final selectedTags = options.caseTags
        .where((tag) => _selectedTagIds.contains(tag.id))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Detail Tambahan',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF101828),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tambahkan metadata opsional supaya case lebih rapi saat dikelola.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF667085),
          ),
        ),
        const SizedBox(height: 20),
        const _SectionFieldLabel(label: 'Tags'),
        const SizedBox(height: 8),
        _TagPickerField(
          tags: selectedTags,
          onTap: () => _pickTags(options.caseTags),
        ),
        const SizedBox(height: 16),
        const _SectionFieldLabel(label: 'Tanggal Selesai'),
        const SizedBox(height: 8),
        _DatePickerField(
          value: _endDate == null
              ? 'Pilih tanggal selesai'
              : _displayDateFormat.format(_endDate!),
          isPlaceholder: _endDate == null,
          onTap: _pickEndDate,
          onClear: _endDate == null
              ? null
              : () {
                  setState(() {
                    _endDate = null;
                  });
                },
        ),
      ],
    );
  }

  Widget _buildConfirmationStep(_CreateCaseOptions options, ThemeData theme) {
    final selectedClient = options.findClientById(_selectedClientId);
    final selectedPsychologist = options.findPsychologistById(
      _selectedPsychologistId,
    );
    final selectedTags = options.caseTags
        .where((tag) => _selectedTagIds.contains(tag.id))
        .map((tag) => tag.name)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Konfirmasi',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF101828),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Periksa kembali data sebelum case dibuat.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF667085),
          ),
        ),
        const SizedBox(height: 20),
        _SummaryCard(
          title: 'Informasi Case',
          rows: <_SummaryRowData>[
            _SummaryRowData(
              label: 'Client',
              value: selectedClient?.fullName ?? '-',
            ),
            _SummaryRowData(
              label: 'Psikolog',
              value: selectedPsychologist?.name ?? '-',
            ),
            _SummaryRowData(
              label: 'Judul Case',
              value: _displayOrDash(_titleController.text),
            ),
            _SummaryRowData(label: 'Kategori', value: _selectedCategory ?? '-'),
            _SummaryRowData(
              label: 'Tanggal Mulai',
              value: _displayDateFormat.format(_startDate),
            ),
            _SummaryRowData(
              label: 'Status',
              value: _statusLabels[_selectedStatus] ?? _selectedStatus,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _SummaryCard(
          title: 'Konten Penanganan',
          rows: <_SummaryRowData>[
            _SummaryRowData(
              label: 'Keluhan',
              value: _displayOrDash(_complaintController.text),
            ),
            _SummaryRowData(
              label: 'Tujuan',
              value: _displayOrDash(_goalController.text),
            ),
            _SummaryRowData(
              label: 'Tags',
              value: selectedTags.isEmpty ? '-' : selectedTags.join(', '),
            ),
            _SummaryRowData(
              label: 'Tanggal Selesai',
              value: _endDate == null
                  ? '-'
                  : _displayDateFormat.format(_endDate!),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions(_CreateCaseOptions options) {
    final isLastStep = _currentStep == 2;

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
                side: const BorderSide(color: Color(0xFFD0D5DD)),
              ),
              child: const Text('Kembali'),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: _isSubmitting
                ? null
                : () => isLastStep ? _submit() : _goToNextStep(options),
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
                  ? 'Buat Case'
                  : 'Lanjut',
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _goToNextStep(_CreateCaseOptions options) async {
    if (_currentStep == 0 && !_validateFirstStep(options)) {
      return;
    }

    setState(() {
      _currentStep += 1;
    });
  }

  bool _validateFirstStep(_CreateCaseOptions options) {
    if (options.findClientById(_selectedClientId) == null) {
      _showFormMessage('Client wajib dipilih.');
      return false;
    }

    if (options.findPsychologistById(_selectedPsychologistId) == null) {
      _showFormMessage('Psikolog wajib dipilih.');
      return false;
    }

    if (_titleController.text.trim().isEmpty) {
      _showFormMessage('Judul case wajib diisi.');
      return false;
    }

    if (_complaintController.text.trim().isEmpty) {
      _showFormMessage('Keluhan utama wajib diisi.');
      return false;
    }

    if (_goalController.text.trim().isEmpty) {
      _showFormMessage('Tujuan penanganan wajib diisi.');
      return false;
    }

    return true;
  }

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      await _repository.createCase(
        clientId: _selectedClientId!,
        psychologistId: _selectedPsychologistId!,
        title: _titleController.text,
        startDate: _submitDateFormat.format(_startDate),
        endDate: _endDate == null ? null : _submitDateFormat.format(_endDate!),
        category: _selectedCategory,
        complaint: _complaintController.text,
        goal: _goalController.text,
        status: _selectedStatus,
        tagIds: _selectedTagIds.toList(),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Case baru berhasil dibuat.')),
        );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showFormMessage('Gagal membuat case: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _pickClient(List<ClientModel> clients) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            itemCount: clients.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final client = clients[index];
              return _PickerListTile(
                title: client.fullName,
                subtitle: _buildClientSubtitle(client),
                isSelected: client.id == _selectedClientId,
                onTap: () => Navigator.of(context).pop(client.id),
              );
            },
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedClientId = result;
      });
    }
  }

  Future<void> _pickPsychologist(List<PsychologistModel> psychologists) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            itemCount: psychologists.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final psychologist = psychologists[index];
              return _PickerListTile(
                title: psychologist.name,
                subtitle: psychologist.specializationSummary ?? 'Psikolog',
                isSelected: psychologist.id == _selectedPsychologistId,
                onTap: () => Navigator.of(context).pop(psychologist.id),
              );
            },
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedPsychologistId = result;
      });
    }
  }

  Future<void> _pickTags(List<CaseTagModel> tags) async {
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final localSelected = Set<String>.from(_selectedTagIds);

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Pilih Tags',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: tags.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final tag = tags[index];
                          final isSelected = localSelected.contains(tag.id);

                          return CheckboxListTile(
                            value: isSelected,
                            title: Text(tag.name),
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (value) {
                              setSheetState(() {
                                if (value ?? false) {
                                  localSelected.add(tag.id);
                                } else {
                                  localSelected.remove(tag.id);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () =>
                            Navigator.of(context).pop(localSelected),
                        child: const Text('Gunakan Tags'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedTagIds = result;
      });
    }
  }

  Future<void> _pickStartDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _startDate = selected;
      if (_endDate != null && _endDate!.isBefore(_startDate)) {
        _endDate = _startDate;
      }
    });
  }

  Future<void> _pickEndDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate,
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _endDate = selected;
    });
  }

  String _buildClientSubtitle(ClientModel client) {
    final parts = <String>[];
    if ((client.gender ?? '').isNotEmpty) {
      parts.add(client.gender!);
    }

    final birthDate = client.birthDate;
    if (birthDate != null) {
      final now = DateTime.now();
      var age = now.year - birthDate.year;
      final hasHadBirthday =
          now.month > birthDate.month ||
          (now.month == birthDate.month && now.day >= birthDate.day);
      if (!hasHadBirthday) {
        age -= 1;
      }
      parts.add('$age th');
    }

    return parts.isEmpty ? 'Data klien' : parts.join(', ');
  }

  String _displayOrDash(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '-';
    }

    return trimmed;
  }

  void _showFormMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CreateCaseOptions {
  const _CreateCaseOptions({
    required this.clients,
    required this.psychologists,
    required this.caseTags,
  });

  final List<ClientModel> clients;
  final List<PsychologistModel> psychologists;
  final List<CaseTagModel> caseTags;

  ClientModel? findClientById(String? id) {
    for (final client in clients) {
      if (client.id == id) {
        return client;
      }
    }

    return null;
  }

  PsychologistModel? findPsychologistById(String? id) {
    for (final psychologist in psychologists) {
      if (psychologist.id == id) {
        return psychologist;
      }
    }

    return null;
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    const titles = <String>['Informasi Case', 'Detail Lainnya', 'Konfirmasi'];

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
              width: 86,
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

class _SectionFieldLabel extends StatelessWidget {
  const _SectionFieldLabel({required this.label, this.requiredField = false});

  final String label;
  final bool requiredField;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: const Color(0xFF344054),
          fontWeight: FontWeight.w700,
        ),
        children: <InlineSpan>[
          TextSpan(text: label),
          if (requiredField)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
        ],
      ),
    );
  }
}

class _EntityPickerField<T> extends StatelessWidget {
  const _EntityPickerField({
    required this.label,
    required this.value,
    required this.titleBuilder,
    required this.subtitleBuilder,
    required this.onTap,
    this.requiredField = false,
  });

  final String label;
  final bool requiredField;
  final T? value;
  final String Function(T value) titleBuilder;
  final String Function(T value) subtitleBuilder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = value == null ? 'Pilih $label' : titleBuilder(value as T);
    final subtitle = value == null ? null : subtitleBuilder(value as T);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionFieldLabel(label: label, requiredField: requiredField),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD0D5DD)),
            ),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFEFF4FF),
                  child: Text(
                    title.isEmpty ? '?' : title.characters.first.toUpperCase(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF2563EB),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: const Color(0xFF101828),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (subtitle != null) ...<Widget>[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: const Color(0xFF667085)),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.value,
    required this.onTap,
    this.isPlaceholder = false,
    this.onClear,
  });

  final String value;
  final bool isPlaceholder;
  final VoidCallback onTap;
  final VoidCallback? onClear;

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
            const Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: Color(0xFF667085),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isPlaceholder
                      ? const Color(0xFF98A2B3)
                      : const Color(0xFF101828),
                ),
              ),
            ),
            if (onClear != null)
              IconButton(
                onPressed: onClear,
                splashRadius: 18,
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}

class _TagPickerField extends StatelessWidget {
  const _TagPickerField({required this.tags, required this.onTap});

  final List<CaseTagModel> tags;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD0D5DD)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: tags.isEmpty
                  ? Text(
                      'Pilih tags',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF98A2B3),
                      ),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tags
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF4FF),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                tag.name,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: const Color(0xFF2563EB),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
      ),
    );
  }
}

class _PickerListTile extends StatelessWidget {
  const _PickerListTile({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: isSelected ? const Color(0xFFEFF4FF) : const Color(0xFFF8FAFC),
      leading: CircleAvatar(
        backgroundColor: isSelected
            ? const Color(0xFFDCE9FF)
            : const Color(0xFFEAECF0),
        child: Text(
          title.isEmpty ? '?' : title.characters.first.toUpperCase(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: const Color(0xFF2563EB),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2563EB))
          : null,
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.rows});

  final String title;
  final List<_SummaryRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 120,
                    child: Text(
                      row.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF667085),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      row.value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF101828),
                        fontWeight: FontWeight.w600,
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

class _SummaryRowData {
  const _SummaryRowData({required this.label, required this.value});

  final String label;
  final String value;
}
