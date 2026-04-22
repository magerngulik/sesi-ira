import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/feature_support_widgets.dart';
import '../../data/models/psychologist_model.dart';
import '../../data/repositories/psychologists_repository.dart';
import 'create_psychologist_page.dart';

class PsychologistsPage extends StatefulWidget {
  const PsychologistsPage({super.key});

  static const String name = 'psychologists';
  static const String path = '/psychologists';

  @override
  State<PsychologistsPage> createState() => _PsychologistsPageState();
}

class _PsychologistsPageState extends State<PsychologistsPage> {
  final PsychologistsRepository _repository = const PsychologistsRepository();
  late Future<List<PsychologistModel>> _psychologistsFuture;

  @override
  void initState() {
    super.initState();
    _psychologistsFuture = _repository.fetchPsychologists();
  }

  Future<void> _reload() async {
    setState(() {
      _psychologistsFuture = _repository.fetchPsychologists();
    });

    await _psychologistsFuture;
  }

  Future<void> _openCreatePsychologistPage() async {
    final shouldRefresh = await context.push<bool>(CreatePsychologistPage.path);

    if (!mounted) {
      return;
    }

    if (shouldRefresh == true) {
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Psikolog'),
        actions: <Widget>[
          IconButton(
            onPressed: _reload,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreatePsychologistPage,
        icon: const Icon(Icons.medical_information_rounded),
        label: const Text('Tambah Psikolog'),
      ),
      body: FutureBuilder<List<PsychologistModel>>(
        future: _psychologistsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return StateMessage(
              title: 'Gagal memuat psikolog',
              subtitle: '${snapshot.error}',
              actionLabel: 'Coba Lagi',
              onPressed: _reload,
            );
          }

          final psychologists = snapshot.data ?? <PsychologistModel>[];
          if (psychologists.isEmpty) {
            return StateMessage(
              title: 'Belum ada psikolog',
              subtitle:
                  'Tambahkan data psikolog agar case bisa langsung di-assign.',
              actionLabel: 'Tambah Psikolog',
              onPressed: _openCreatePsychologistPage,
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
              itemCount: psychologists.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final psychologist = psychologists[index];

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
                              psychologist.name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          _PsychologistStatusChip(
                            label: psychologist.isActive ? 'Aktif' : 'Nonaktif',
                            isActive: psychologist.isActive,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: <Widget>[
                          InfoBadge(
                            icon: Icons.psychology_alt_outlined,
                            value:
                                psychologist.specializationSummary ??
                                'Spesialisasi belum diisi',
                          ),
                          InfoBadge(
                            icon: Icons.call_outlined,
                            value: psychologist.phone ?? 'No. HP belum diisi',
                          ),
                          InfoBadge(
                            icon: Icons.mail_outline_rounded,
                            value: psychologist.email ?? 'Email belum diisi',
                          ),
                        ],
                      ),
                      if ((psychologist.notes ?? '').isNotEmpty) ...<Widget>[
                        const SizedBox(height: 12),
                        Text('Catatan: ${psychologist.notes!}'),
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

class _PsychologistStatusChip extends StatelessWidget {
  const _PsychologistStatusChip({required this.label, required this.isActive});

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE6F5F2) : const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: isActive ? const Color(0xFF0F766E) : const Color(0xFFB42318),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
