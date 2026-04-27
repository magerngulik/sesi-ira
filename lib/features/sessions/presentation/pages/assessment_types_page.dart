import 'package:flutter/material.dart';

import '../../../../core/widgets/feature_support_widgets.dart';
import '../../data/models/assessment_type_model.dart';
import '../../data/repositories/assessment_types_repository.dart';

class AssessmentTypesPage extends StatefulWidget {
  const AssessmentTypesPage({super.key});

  static const String name = 'assessment-types';
  static const String path = '/assessment-types';

  @override
  State<AssessmentTypesPage> createState() => _AssessmentTypesPageState();
}

class _AssessmentTypesPageState extends State<AssessmentTypesPage> {
  final AssessmentTypesRepository _repository =
      const AssessmentTypesRepository();
  late Future<List<AssessmentTypeModel>> _assessmentTypesFuture;

  @override
  void initState() {
    super.initState();
    _assessmentTypesFuture = _repository.fetchAssessmentTypes();
  }

  Future<void> _reload() async {
    setState(() {
      _assessmentTypesFuture = _repository.fetchAssessmentTypes();
    });

    await _assessmentTypesFuture;
  }

  Future<void> _openCreateSheet() async {
    final shouldRefresh = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AssessmentTypeFormSheet(repository: _repository),
    );

    if (shouldRefresh == true) {
      await _reload();
    }
  }

  Future<void> _openEditSheet(AssessmentTypeModel assessmentType) async {
    final shouldRefresh = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AssessmentTypeFormSheet(
        repository: _repository,
        initialAssessmentType: assessmentType,
      ),
    );

    if (shouldRefresh == true) {
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Types'),
        actions: <Widget>[
          IconButton(
            onPressed: _reload,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateSheet,
        icon: const Icon(Icons.fact_check_rounded),
        label: const Text('Tambah Assessment'),
      ),
      body: FutureBuilder<List<AssessmentTypeModel>>(
        future: _assessmentTypesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return StateMessage(
              title: 'Gagal memuat assessment types',
              subtitle: '${snapshot.error}',
              actionLabel: 'Coba Lagi',
              onPressed: _reload,
            );
          }

          final assessmentTypes = snapshot.data ?? <AssessmentTypeModel>[];
          if (assessmentTypes.isEmpty) {
            return StateMessage(
              title: 'Belum ada assessment type',
              subtitle:
                  'Tambahkan assessment type dulu supaya referensi assessment sesi siap dipakai.',
              actionLabel: 'Tambah Assessment',
              onPressed: _openCreateSheet,
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
              itemCount: assessmentTypes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = assessmentTypes[index];

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
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.fact_check_outlined,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  item.name,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.code,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: const Color(0xFF667085),
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _openEditSheet(item),
                            tooltip: 'Edit Assessment Type',
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          _AssessmentTypeStatusChip(isActive: item.isActive),
                        ],
                      ),
                      if ((item.description ?? '')
                          .trim()
                          .isNotEmpty) ...<Widget>[
                        const SizedBox(height: 12),
                        Text(
                          item.description!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: const Color(0xFF667085)),
                        ),
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

class _AssessmentTypeStatusChip extends StatelessWidget {
  const _AssessmentTypeStatusChip({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isActive
        ? const Color(0xFF027A48)
        : const Color(0xFFB42318);
    final backgroundColor = isActive
        ? const Color(0xFFE7F6EC)
        : const Color(0xFFFEE4E2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isActive ? 'Aktif' : 'Nonaktif',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AssessmentTypeFormSheet extends StatefulWidget {
  const _AssessmentTypeFormSheet({
    required this.repository,
    this.initialAssessmentType,
  });

  final AssessmentTypesRepository repository;
  final AssessmentTypeModel? initialAssessmentType;

  @override
  State<_AssessmentTypeFormSheet> createState() =>
      _AssessmentTypeFormSheetState();
}

class _AssessmentTypeFormSheetState extends State<_AssessmentTypeFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  late bool _isActive;
  bool _isSubmitting = false;

  bool get _isEditMode => widget.initialAssessmentType != null;

  @override
  void initState() {
    super.initState();
    final initialAssessmentType = widget.initialAssessmentType;
    _codeController.text = initialAssessmentType?.code ?? '';
    _nameController.text = initialAssessmentType?.name ?? '';
    _descriptionController.text = initialAssessmentType?.description ?? '';
    _isActive = initialAssessmentType?.isActive ?? true;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _isEditMode
                    ? 'Update Assessment Type'
                    : 'Tambah Assessment Type',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Isi referensi assessment yang nanti bisa dipakai sebagai master data untuk modul session.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF667085),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Code',
                  hintText: 'Contoh: WISC, BAUM, HTP',
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Code wajib diisi.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama assessment',
                  hintText: 'Contoh: Wechsler Intelligence Scale for Children',
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama assessment wajib diisi.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  hintText: 'Tambahkan deskripsi singkat bila perlu',
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _isActive,
                title: const Text('Status aktif'),
                subtitle: Text(
                  _isActive
                      ? 'Assessment type bisa dipakai.'
                      : 'Assessment type disembunyikan dari pilihan aktif.',
                ),
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: Text(
                    _isSubmitting
                        ? 'Menyimpan...'
                        : _isEditMode
                        ? 'Simpan Perubahan'
                        : 'Simpan Assessment Type',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (_isEditMode) {
        await widget.repository.updateAssessmentType(
          id: widget.initialAssessmentType!.id,
          code: _codeController.text,
          name: _nameController.text,
          description: _descriptionController.text,
          isActive: _isActive,
        );
      } else {
        await widget.repository.createAssessmentType(
          code: _codeController.text,
          name: _nameController.text,
          description: _descriptionController.text,
          isActive: _isActive,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Assessment type berhasil diperbarui.'
                  : 'Assessment type baru berhasil dibuat.',
            ),
          ),
        );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Gagal menyimpan assessment type: $error')),
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
