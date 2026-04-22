import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/feature_support_widgets.dart';
import '../../../clients/data/models/client_model.dart';
import '../../../clients/data/repositories/clients_repository.dart';
import '../../../psychologists/data/models/psychologist_model.dart';
import '../../../psychologists/data/repositories/psychologists_repository.dart';
import '../../data/models/case_summary_model.dart';
import '../../data/repositories/cases_repository.dart';

class CasesPage extends StatefulWidget {
  const CasesPage({super.key});

  static const String name = 'cases';
  static const String path = '/cases';

  @override
  State<CasesPage> createState() => _CasesPageState();
}

class _CasesPageState extends State<CasesPage> {
  final CasesRepository _repository = const CasesRepository();
  late Future<List<CaseSummaryModel>> _casesFuture;

  @override
  void initState() {
    super.initState();
    _casesFuture = _repository.fetchCases();
  }

  Future<void> _reload() async {
    setState(() {
      _casesFuture = _repository.fetchCases();
    });

    await _casesFuture;
  }

  Future<void> _openCreateCaseSheet() async {
    final shouldRefresh = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CreateCaseSheet(repository: _repository),
    );

    if (shouldRefresh == true) {
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Case'),
        actions: <Widget>[
          IconButton(
            onPressed: _reload,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateCaseSheet,
        icon: const Icon(Icons.add_chart_rounded),
        label: const Text('Buat Case'),
      ),
      body: FutureBuilder<List<CaseSummaryModel>>(
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

          final cases = snapshot.data ?? <CaseSummaryModel>[];
          if (cases.isEmpty) {
            return StateMessage(
              title: 'Belum ada case',
              subtitle:
                  'Buat case pertama untuk mulai menghubungkan klien dan psikolog.',
              actionLabel: 'Buat Case',
              onPressed: _openCreateCaseSheet,
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
              itemCount: cases.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = cases[index];

                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              item.title,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          _CaseStatusChip(status: item.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: <Widget>[
                          InfoBadge(
                            icon: Icons.person_outline_rounded,
                            value: item.clientName ?? 'Klien tidak ditemukan',
                          ),
                          InfoBadge(
                            icon: Icons.psychology_alt_outlined,
                            value: item.psychologistName ?? 'Psikolog tidak ditemukan',
                          ),
                          InfoBadge(
                            icon: Icons.calendar_today_outlined,
                            value: DateFormat('dd MMM yyyy').format(item.startDate),
                          ),
                          InfoBadge(
                            icon: Icons.category_outlined,
                            value: item.category ?? 'Kategori belum diisi',
                          ),
                        ],
                      ),
                      if ((item.complaint ?? '').isNotEmpty) ...<Widget>[
                        const SizedBox(height: 12),
                        Text('Keluhan: ${item.complaint!}'),
                      ],
                      if ((item.goal ?? '').isNotEmpty) ...<Widget>[
                        const SizedBox(height: 8),
                        Text('Tujuan: ${item.goal!}'),
                      ],
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CreateCaseSheet extends StatefulWidget {
  const _CreateCaseSheet({required this.repository});

  final CasesRepository repository;

  @override
  State<_CreateCaseSheet> createState() => _CreateCaseSheetState();
}

class _CreateCaseSheetState extends State<_CreateCaseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _clientsRepository = const ClientsRepository();
  final _psychologistsRepository = const PsychologistsRepository();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _startDateController = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );
  final _complaintController = TextEditingController();
  final _goalController = TextEditingController();
  late Future<_CaseFormOptions> _optionsFuture;
  String? _selectedClientId;
  String? _selectedPsychologistId;
  String _selectedStatus = 'active';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _optionsFuture = _loadOptions();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _startDateController.dispose();
    _complaintController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<_CaseFormOptions> _loadOptions() async {
    final clients = await _clientsRepository.fetchClients();
    final psychologists = await _psychologistsRepository.fetchPsychologists();

    return _CaseFormOptions(clients: clients, psychologists: psychologists);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
      child: FutureBuilder<_CaseFormOptions>(
        future: _optionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            );
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
                  'Sebelum membuat case, pastikan minimal sudah ada 1 klien dan 1 psikolog.',
              actionLabel: 'Tutup',
              onPressed: () => Navigator.of(context).pop(),
            );
          }

          _selectedClientId ??= options.clients.first.id;
          _selectedPsychologistId ??= options.psychologists.first.id;

          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Buat Case Baru',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedClientId,
                    decoration: const InputDecoration(labelText: 'Klien'),
                    items: options.clients
                        .map(
                          (client) => DropdownMenuItem<String>(
                            value: client.id,
                            child: Text(client.fullName),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedClientId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedPsychologistId,
                    decoration: const InputDecoration(labelText: 'Psikolog'),
                    items: options.psychologists
                        .map(
                          (psychologist) => DropdownMenuItem<String>(
                            value: psychologist.id,
                            child: Text(psychologist.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPsychologistId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Judul case'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Judul case wajib diisi.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _startDateController,
                    decoration: const InputDecoration(
                      labelText: 'Tanggal mulai',
                      hintText: 'YYYY-MM-DD',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Tanggal mulai wajib diisi.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const <DropdownMenuItem<String>>[
                      DropdownMenuItem(value: 'active', child: Text('active')),
                      DropdownMenuItem(value: 'on_hold', child: Text('on_hold')),
                      DropdownMenuItem(value: 'completed', child: Text('completed')),
                      DropdownMenuItem(value: 'cancelled', child: Text('cancelled')),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _complaintController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Keluhan'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _goalController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Tujuan'),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: Text(_isSubmitting ? 'Menyimpan...' : 'Simpan Case'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final clientId = _selectedClientId;
    final psychologistId = _selectedPsychologistId;
    if (clientId == null || psychologistId == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.repository.createCase(
        clientId: clientId,
        psychologistId: psychologistId,
        title: _titleController.text,
        startDate: _startDateController.text,
        category: _categoryController.text,
        complaint: _complaintController.text,
        goal: _goalController.text,
        status: _selectedStatus,
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

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Gagal membuat case: $error')),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

class _CaseStatusChip extends StatelessWidget {
  const _CaseStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'completed' => const Color(0xFF0F766E),
      'cancelled' => const Color(0xFFB42318),
      'on_hold' => const Color(0xFFB54708),
      _ => const Color(0xFF175CD3),
    };

    final background = switch (status) {
      'completed' => const Color(0xFFE6F5F2),
      'cancelled' => const Color(0xFFFDECEC),
      'on_hold' => const Color(0xFFFFF3E8),
      _ => const Color(0xFFEAF2FF),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CaseFormOptions {
  const _CaseFormOptions({
    required this.clients,
    required this.psychologists,
  });

  final List<ClientModel> clients;
  final List<PsychologistModel> psychologists;
}
