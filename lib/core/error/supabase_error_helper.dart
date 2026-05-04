import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_exception.dart';

class SupabaseErrorHelper {
  const SupabaseErrorHelper._();

  static AppException toAppException(
    Object error, {
    required String action,
    String? table,
    String? recordId,
  }) {
    if (error is AppException) {
      return error;
    }

    if (error is PostgrestException) {
      return _mapPostgrestException(
        error,
        action: action,
        table: table,
        recordId: recordId,
      );
    }

    if (error is AuthException) {
      return AppException('Gagal $action: ${error.message}');
    }

    return AppException('Gagal $action: ${_stringify(error)}');
  }

  static AppException noRowsAffected({
    required String action,
    required String table,
    String? recordId,
  }) {
    final target = recordId == null ? 'data' : 'data dengan id $recordId';
    return AppException(
      'Gagal $action. Tidak ada baris yang berubah di tabel $table untuk '
      '$target. Kemungkinan data tidak ditemukan atau diblokir policy/RLS.',
    );
  }

  static AppException _mapPostgrestException(
    PostgrestException error, {
    required String action,
    String? table,
    String? recordId,
  }) {
    final code = error.code?.trim();
    final message = error.message.trim();
    final details = error.details?.toString().trim();
    final tableLabel = table == null ? 'data' : 'tabel $table';
    final targetSuffix = recordId == null ? '' : ' (id: $recordId)';

    if (code == 'PGRST116' ||
        _containsZeroRows(details) ||
        _containsZeroRows(message)) {
      return AppException(
        'Gagal $action. Query ke $tableLabel$targetSuffix tidak '
        'mengembalikan row. Kemungkinan data tidak ditemukan atau akses '
        'ditolak oleh policy/RLS.',
      );
    }

    if (code == '42501' ||
        message.toLowerCase().contains('row-level security')) {
      return AppException(
        'Gagal $action. Akses ke $tableLabel$targetSuffix ditolak oleh '
        'policy/RLS. Cek policy SELECT/UPDATE untuk role user ini.',
      );
    }

    if (_isPsychologistScheduleConflict(code: code, message: message)) {
      return AppException(
        'Psikolog sudah memiliki jadwal lain pada waktu tersebut. '
        'Silakan pilih jam yang berbeda.',
      );
    }

    final extra = <String>[
      if (code != null && code.isNotEmpty) 'code=$code',
      if (details != null && details.isNotEmpty && details != 'null')
        'details=$details',
    ].join(', ');

    final suffix = extra.isEmpty ? '' : ' ($extra)';
    return AppException('Gagal $action: $message$suffix');
  }

  static bool _containsZeroRows(String? value) {
    if (value == null) {
      return false;
    }

    return value.toLowerCase().contains('0 rows');
  }

  static bool _isPsychologistScheduleConflict({
    required String? code,
    required String message,
  }) {
    final normalizedMessage = message.toLowerCase();

    if (code != 'P0001') {
      return false;
    }

    return normalizedMessage.contains(
          'psychologist already has another session',
        ) &&
        normalizedMessage.contains('time range');
  }

  static String _stringify(Object error) {
    final text = error.toString().trim();
    return text.isEmpty
        ? 'Terjadi kesalahan yang belum teridentifikasi.'
        : text;
  }
}
