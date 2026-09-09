import 'package:flutter/material.dart';

import '../../../core/services/supabase_service.dart';
import 'psychologist_portal_models.dart';

class PsychologistPortalRepository {
  const PsychologistPortalRepository();

  Future<List<PsychologistClientPreview>> fetchClientsForPsychologist(
    String psychologistId,
  ) async {
    final trimmedPsychologistId = psychologistId.trim();
    if (trimmedPsychologistId.isEmpty) {
      throw Exception(
        'Akun psikolog belum memiliki psychologist_id. Cek metadata user login ini.',
      );
    }

    final response = await SupabaseService.client
        .from('cases')
        .select('''
          id,
          client_id,
          clients:client_id(
            full_name,
            gender,
            birth_date
          ),
          sessions(
            id,
            session_date
          )
        ''')
        .eq('assigned_psychologist_id', trimmedPsychologistId)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false);

    final Map<String, _ClientAggregate> aggregates =
        <String, _ClientAggregate>{};

    for (final row in response) {
      final map = row;
      final clientId = map['client_id'] as String?;
      final clientMap = map['clients'] as Map<String, dynamic>?;
      if (clientId == null || clientId.isEmpty || clientMap == null) {
        continue;
      }

      final sessions = map['sessions'] as List<dynamic>? ?? <dynamic>[];
      final latestSession = _resolveLatestSessionDate(sessions);

      final current = aggregates[clientId];
      if (current == null) {
        aggregates[clientId] = _ClientAggregate(
          id: clientId,
          name: (clientMap['full_name'] as String? ?? '-').trim(),
          gender: (clientMap['gender'] as String? ?? 'Belum diisi').trim(),
          birthDate: _tryParseDate(clientMap['birth_date']),
          caseCount: 1,
          latestSession: latestSession,
        );
        continue;
      }

      aggregates[clientId] = current.copyWith(
        caseCount: current.caseCount + 1,
        latestSession: _pickLatest(current.latestSession, latestSession),
      );
    }

    final clients = aggregates.values.toList()
      ..sort((a, b) {
        final aDate = a.latestSession;
        final bDate = b.latestSession;
        if (aDate == null && bDate == null) {
          return a.name.compareTo(b.name);
        }
        if (aDate == null) {
          return 1;
        }
        if (bDate == null) {
          return -1;
        }
        return bDate.compareTo(aDate);
      });

    return clients.map((item) {
      return PsychologistClientPreview(
        name: item.name,
        age: _calculateAge(item.birthDate),
        gender: _normalizeGender(item.gender),
        caseCount: item.caseCount,
        lastSessionLabel: _buildLastSessionLabel(item.latestSession),
        accent: _resolveAccent(item.name),
      );
    }).toList();
  }

  DateTime? _resolveLatestSessionDate(List<dynamic> sessions) {
    DateTime? latest;
    for (final item in sessions) {
      final map = item as Map<String, dynamic>;
      final parsed = _tryParseDate(map['session_date']);
      latest = _pickLatest(latest, parsed);
    }
    return latest;
  }

  DateTime? _pickLatest(DateTime? first, DateTime? second) {
    if (first == null) {
      return second;
    }
    if (second == null) {
      return first;
    }
    return first.isAfter(second) ? first : second;
  }

  DateTime? _tryParseDate(Object? value) {
    if (value is! String || value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  int _calculateAge(DateTime? birthDate) {
    if (birthDate == null) {
      return 0;
    }

    final now = DateTime.now();
    var age = now.year - birthDate.year;
    final hasNotHadBirthday =
        now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day);
    if (hasNotHadBirthday) {
      age -= 1;
    }
    return age < 0 ? 0 : age;
  }

  String _normalizeGender(String gender) {
    final normalized = gender.trim().toLowerCase();
    switch (normalized) {
      case 'male':
      case 'laki-laki':
      case 'pria':
        return 'Pria';
      case 'female':
      case 'perempuan':
      case 'wanita':
        return 'Wanita';
      default:
        return gender.trim().isEmpty ? 'Belum diisi' : gender.trim();
    }
  }

  String _buildLastSessionLabel(DateTime? latestSession) {
    if (latestSession == null) {
      return 'Belum ada session';
    }

    final sessionDate = DateTime(
      latestSession.year,
      latestSession.month,
      latestSession.day,
    );
    final today = DateTime.now();
    final currentDate = DateTime(today.year, today.month, today.day);
    final difference = currentDate.difference(sessionDate).inDays;

    if (difference <= 0) {
      return 'Last session hari ini';
    }
    if (difference == 1) {
      return 'Last session 1 hari lalu';
    }
    if (difference < 7) {
      return 'Last session $difference hari lalu';
    }
    if (difference < 30) {
      final weeks = (difference / 7).floor();
      return 'Last session $weeks minggu lalu';
    }
    final months = (difference / 30).floor();
    return 'Last session $months bulan lalu';
  }

  Color _resolveAccent(String seed) {
    const palette = <Color>[
      Color(0xFFFFC8D7),
      Color(0xFFFFD9A8),
      Color(0xFFD9C7FF),
      Color(0xFFFFD6E9),
      Color(0xFFBFE3FF),
    ];
    final index =
        seed.codeUnits.fold<int>(0, (sum, char) => sum + char) % palette.length;
    return palette[index];
  }
}

class _ClientAggregate {
  const _ClientAggregate({
    required this.id,
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.caseCount,
    required this.latestSession,
  });

  final String id;
  final String name;
  final String gender;
  final DateTime? birthDate;
  final int caseCount;
  final DateTime? latestSession;

  _ClientAggregate copyWith({int? caseCount, DateTime? latestSession}) {
    return _ClientAggregate(
      id: id,
      name: name,
      gender: gender,
      birthDate: birthDate,
      caseCount: caseCount ?? this.caseCount,
      latestSession: latestSession ?? this.latestSession,
    );
  }
}
