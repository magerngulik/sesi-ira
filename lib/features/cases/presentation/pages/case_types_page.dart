import 'package:flutter/material.dart';

import '../../../../core/widgets/feature_support_widgets.dart';
import '../../data/models/case_type_model.dart';
import '../../data/repositories/case_types_repository.dart';

class CaseTypesPage extends StatefulWidget {
  const CaseTypesPage({super.key});

  static const String name = 'case-types';
  static const String path = '/case-types';

  @override
  State<CaseTypesPage> createState() => _CaseTypesPageState();
}

class _CaseTypesPageState extends State<CaseTypesPage> {
  final CaseTypesRepository _repository = const CaseTypesRepository();
  late Future<List<CaseTypeModel>> _caseTypesFuture;

  @override
  void initState() {
    super.initState();
    _caseTypesFuture = _repository.fetchCaseTypes();
  }

  Future<void> _reload() async {
    setState(() {
      _caseTypesFuture = _repository.fetchCaseTypes();
    });

    await _caseTypesFuture;
  }

  Future<void> _openCreateCaseTypeSheet() async {
    final shouldRefresh = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CaseTypeFormSheet(repository: _repository),
    );

    if (shouldRefresh == true) {
      await _reload();
    }
  }

  Future<void> _openEditCaseTypeSheet(CaseTypeModel caseType) async {
    final shouldRefresh = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CaseTypeFormSheet(
        repository: _repository,
        initialCaseType: caseType,
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
        title: const Text('Case Type'),
        actions: <Widget>[
          IconButton(
            onPressed: _reload,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateCaseTypeSheet,
        icon: const Icon(Icons.category_rounded),
        label: const Text('Tambah Case Type'),
      ),
      body: FutureBuilder<List<CaseTypeModel>>(
        future: _caseTypesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return StateMessage(
              title: 'Gagal memuat case type',
              subtitle: '${snapshot.error}',
              actionLabel: 'Coba Lagi',
              onPressed: _reload,
            );
          }

          final caseTypes = snapshot.data ?? <CaseTypeModel>[];
          if (caseTypes.isEmpty) {
            return StateMessage(
              title: 'Belum ada case type',
              subtitle:
                  'Tambahkan case type terlebih dahulu supaya bisa dipakai saat submit case.',
              actionLabel: 'Tambah Case Type',
              onPressed: _openCreateCaseTypeSheet,
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
              itemCount: caseTypes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = caseTypes[index];

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
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.category_outlined,
                              color: Color(0xFF1D4ED8),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              item.name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _openEditCaseTypeSheet(item),
                            tooltip: 'Edit Case Type',
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          _CaseTypeStatusChip(isActive: item.isActive),
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

class _CaseTypeStatusChip extends StatelessWidget {
  const _CaseTypeStatusChip({required this.isActive});

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

class _CaseTypeFormSheet extends StatefulWidget {
  const _CaseTypeFormSheet({required this.repository, this.initialCaseType});

  final CaseTypesRepository repository;
  final CaseTypeModel? initialCaseType;

  @override
  State<_CaseTypeFormSheet> createState() => _CaseTypeFormSheetState();
}

class _CaseTypeFormSheetState extends State<_CaseTypeFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  late bool _isActive;
  bool _isSubmitting = false;

  bool get _isEditMode => widget.initialCaseType != null;

  @override
  void initState() {
    super.initState();
    final initialCaseType = widget.initialCaseType;
    _nameController.text = initialCaseType?.name ?? '';
    _descriptionController.text = initialCaseType?.description ?? '';
    _isActive = initialCaseType?.isActive ?? true;
  }

  @override
  void dispose() {
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
                _isEditMode ? 'Update Case Type' : 'Tambah Case Type',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _isEditMode
                    ? 'Perbarui tipe case yang akan dipakai saat admin membuat atau submit case.'
                    : 'Isi tipe case yang nantinya akan dipilih saat admin membuat atau submit case baru.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF667085),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama case type',
                  hintText: 'Contoh: Konseling Individu',
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama case type wajib diisi.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  hintText: 'Jelaskan penggunaan case type ini.',
                ),
                maxLines: 3,
                textInputAction: TextInputAction.newline,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isActive,
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                title: const Text('Status aktif'),
                subtitle: const Text(
                  'Jika aktif, case type bisa langsung dipakai di form case.',
                ),
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
                        ? 'Update Case Type'
                        : 'Simpan Case Type',
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
        await widget.repository.updateCaseType(
          id: widget.initialCaseType!.id,
          name: _nameController.text,
          description: _descriptionController.text,
          isActive: _isActive,
        );
      } else {
        await widget.repository.createCaseType(
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
                  ? 'Case type berhasil diperbarui.'
                  : 'Case type baru berhasil dibuat.',
            ),
          ),
        );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Gagal memperbarui case type: $error'
                  : 'Gagal membuat case type: $error',
            ),
          ),
        );
    }
  }
}
