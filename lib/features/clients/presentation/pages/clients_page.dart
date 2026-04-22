import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/feature_support_widgets.dart';
import '../../data/models/client_model.dart';
import '../../data/repositories/clients_repository.dart';
import 'create_client_page.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  static const String name = 'clients';
  static const String path = '/clients';

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  final ClientsRepository _repository = const ClientsRepository();
  late Future<List<ClientModel>> _clientsFuture;

  @override
  void initState() {
    super.initState();
    _clientsFuture = _repository.fetchClients();
  }

  Future<void> _reload() async {
    setState(() {
      _clientsFuture = _repository.fetchClients();
    });

    await _clientsFuture;
  }

  Future<void> _openCreateClientPage() async {
    final shouldRefresh = await context.push<bool>(CreateClientPage.path);

    if (shouldRefresh == true) {
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Klien'),
        actions: <Widget>[
          IconButton(
            onPressed: _reload,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateClientPage,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Tambah Klien'),
      ),
      body: FutureBuilder<List<ClientModel>>(
        future: _clientsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return StateMessage(
              title: 'Gagal memuat klien',
              subtitle: '${snapshot.error}',
              actionLabel: 'Coba Lagi',
              onPressed: _reload,
            );
          }

          final clients = snapshot.data ?? <ClientModel>[];
          if (clients.isEmpty) {
            return StateMessage(
              title: 'Belum ada data klien',
              subtitle: 'Tambahkan klien pertama untuk mulai membuat case.',
              actionLabel: 'Tambah Klien',
              onPressed: _openCreateClientPage,
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
              itemCount: clients.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final client = clients[index];
                final birthDate = client.birthDate == null
                    ? '-'
                    : DateFormat('dd MMM yyyy').format(client.birthDate!);

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
                              client.fullName,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          _StatusChip(
                            label: client.gender ?? 'Gender belum diisi',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: <Widget>[
                          InfoBadge(
                            icon: Icons.cake_outlined,
                            value: birthDate,
                          ),
                          InfoBadge(
                            icon: Icons.call_outlined,
                            value: client.phone ?? 'No. HP belum diisi',
                          ),
                          InfoBadge(
                            icon: Icons.emergency_outlined,
                            value:
                                client.emergencyContactSummary ??
                                'Kontak darurat belum diisi',
                          ),
                        ],
                      ),
                      if ((client.address ?? '').isNotEmpty) ...<Widget>[
                        const SizedBox(height: 12),
                        Text(
                          client.address!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                      if ((client.notes ?? '').isNotEmpty) ...<Widget>[
                        const SizedBox(height: 8),
                        Text(
                          'Catatan: ${client.notes!}',
                          style: Theme.of(context).textTheme.bodySmall,
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F5F2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: const Color(0xFF0F766E),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
