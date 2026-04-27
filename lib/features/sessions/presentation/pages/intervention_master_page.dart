import 'package:flutter/material.dart';

import '../../../../core/widgets/feature_support_widgets.dart';
import '../../data/models/intervention_model.dart';
import '../../data/repositories/intervention_master_repository.dart';

class InterventionMasterPage extends StatefulWidget {
  const InterventionMasterPage({super.key});

  static const String name = 'intervention-master';
  static const String path = '/intervention-master';

  @override
  State<InterventionMasterPage> createState() => _InterventionMasterPageState();
}

class _InterventionMasterPageState extends State<InterventionMasterPage> {
  final InterventionMasterRepository _repository =
      const InterventionMasterRepository();
  late Future<List<InterventionModel>> _interventionsFuture;

  @override
  void initState() {
    super.initState();
    _interventionsFuture = _repository.fetchInterventions();
  }

  Future<void> _reload() async {
    setState(() {
      _interventionsFuture = _repository.fetchInterventions();
    });

    await _interventionsFuture;
  }

  Future<void> _openCreateSheet() async {
    final shouldRefresh = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _InterventionFormSheet(repository: _repository),
    );

    if (shouldRefresh == true) {
      await _reload();
    }
  }

  Future<void> _openEditSheet(InterventionModel intervention) async {
    final shouldRefresh = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _InterventionFormSheet(
        repository: _repository,
        initialIntervention: intervention,
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
        title: const Text('Intervention Master'),
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
        icon: const Icon(Icons.healing_rounded),
        label: const Text('Tambah Intervensi'),
      ),
      body: FutureBuilder<List<InterventionModel>>(
        future: _interventionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return StateMessage(
              title: 'Gagal memuat intervention master',
              subtitle: '${snapshot.error}',
              actionLabel: 'Coba Lagi',
              onPressed: _reload,
            );
          }

          final interventions = snapshot.data ?? <InterventionModel>[];
          if (interventions.isEmpty) {
            return StateMessage(
              title: 'Belum ada intervention master',
              subtitle:
                  'Tambahkan data intervensi dulu supaya referensi tindakan sesi siap dipakai.',
              actionLabel: 'Tambah Intervensi',
              onPressed: _openCreateSheet,
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
              itemCount: interventions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = interventions[index];

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
                              color: const Color(0xFFFFF4E5),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.healing_outlined,
                              color: Color(0xFFD97706),
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
                            tooltip: 'Edit Intervention',
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          _InterventionStatusChip(isActive: item.isActive),
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

class _InterventionStatusChip extends StatelessWidget {
  const _InterventionStatusChip({required this.isActive});

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

class _InterventionFormSheet extends StatefulWidget {
  const _InterventionFormSheet({
    required this.repository,
    this.initialIntervention,
  });

  final InterventionMasterRepository repository;
  final InterventionModel? initialIntervention;

  @override
  State<_InterventionFormSheet> createState() => _InterventionFormSheetState();
}

class _InterventionFormSheetState extends State<_InterventionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  late bool _isActive;
  bool _isSubmitting = false;

  bool get _isEditMode => widget.initialIntervention != null;

  @override
  void initState() {
    super.initState();
    final initialIntervention = widget.initialIntervention;
    _codeController.text = initialIntervention?.code ?? '';
    _nameController.text = initialIntervention?.name ?? '';
    _descriptionController.text = initialIntervention?.description ?? '';
    _isActive = initialIntervention?.isActive ?? true;
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
                    ? 'Update Intervention Master'
                    : 'Tambah Intervention Master',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Isi referensi intervensi yang nanti bisa dipakai sebagai master data untuk modul session.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF667085),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Code',
                  hintText: 'Contoh: CBT, ART, PLAY',
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
                  labelText: 'Nama intervensi',
                  hintText: 'Contoh: Cognitive Behavioral Therapy',
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama intervensi wajib diisi.';
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
                      ? 'Intervensi bisa dipakai.'
                      : 'Intervensi disembunyikan dari pilihan aktif.',
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
                        : 'Simpan Intervention Master',
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
        await widget.repository.updateIntervention(
          id: widget.initialIntervention!.id,
          code: _codeController.text,
          name: _nameController.text,
          description: _descriptionController.text,
          isActive: _isActive,
        );
      } else {
        await widget.repository.createIntervention(
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
                  ? 'Intervention master berhasil diperbarui.'
                  : 'Intervention master baru berhasil dibuat.',
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
          SnackBar(
            content: Text('Gagal menyimpan intervention master: $error'),
          ),
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
