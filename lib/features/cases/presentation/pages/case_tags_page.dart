import 'package:flutter/material.dart';

import '../../../../core/widgets/feature_support_widgets.dart';
import '../../data/models/case_tag_model.dart';
import '../../data/repositories/case_tags_repository.dart';

class CaseTagsPage extends StatefulWidget {
  const CaseTagsPage({super.key});

  static const String name = 'case-tags';
  static const String path = '/case-tags';

  @override
  State<CaseTagsPage> createState() => _CaseTagsPageState();
}

class _CaseTagsPageState extends State<CaseTagsPage> {
  final CaseTagsRepository _repository = const CaseTagsRepository();
  late Future<List<CaseTagModel>> _caseTagsFuture;

  @override
  void initState() {
    super.initState();
    _caseTagsFuture = _repository.fetchCaseTags();
  }

  Future<void> _reload() async {
    setState(() {
      _caseTagsFuture = _repository.fetchCaseTags();
    });

    await _caseTagsFuture;
  }

  Future<void> _openCreateTagSheet() async {
    final shouldRefresh = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CreateCaseTagSheet(repository: _repository),
    );

    if (shouldRefresh == true) {
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Case Tags'),
        actions: <Widget>[
          IconButton(
            onPressed: _reload,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateTagSheet,
        icon: const Icon(Icons.local_offer_rounded),
        label: const Text('Tambah Tag'),
      ),
      body: FutureBuilder<List<CaseTagModel>>(
        future: _caseTagsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return StateMessage(
              title: 'Gagal memuat case tag',
              subtitle: '${snapshot.error}',
              actionLabel: 'Coba Lagi',
              onPressed: _reload,
            );
          }

          final caseTags = snapshot.data ?? <CaseTagModel>[];
          if (caseTags.isEmpty) {
            return StateMessage(
              title: 'Belum ada case tag',
              subtitle:
                  'Tambahkan tag terlebih dahulu supaya nanti bisa dipakai saat menyusun case.',
              actionLabel: 'Tambah Tag',
              onPressed: _openCreateTagSheet,
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
              itemCount: caseTags.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = caseTags[index];

                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F3F1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.sell_outlined,
                          color: Color(0xFF0F766E),
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
                              'Tag siap dipakai untuk kategorisasi case.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: const Color(0xFF667085)),
                            ),
                          ],
                        ),
                      ),
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

class _CreateCaseTagSheet extends StatefulWidget {
  const _CreateCaseTagSheet({required this.repository});

  final CaseTagsRepository repository;

  @override
  State<_CreateCaseTagSheet> createState() => _CreateCaseTagSheetState();
}

class _CreateCaseTagSheetState extends State<_CreateCaseTagSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
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
                'Tambah Case Tag',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Isi nama tag yang nantinya akan dipakai untuk menandai atau mengelompokkan case.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF667085),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama tag',
                  hintText: 'Contoh: Anxiety, Parenting, Remaja',
                ),
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tag wajib diisi.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: Text(_isSubmitting ? 'Menyimpan...' : 'Simpan Tag'),
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
      await widget.repository.createCaseTag(name: _nameController.text);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Case tag baru berhasil dibuat.')),
        );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Gagal membuat case tag: $error')),
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
