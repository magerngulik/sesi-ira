class SessionSummaryModel {
  const SessionSummaryModel({
    required this.id,
    required this.sessionNumber,
    required this.sessionDate,
    required this.status,
  });

  final String id;
  final int sessionNumber;
  final DateTime sessionDate;
  final String status;

  factory SessionSummaryModel.fromMap(Map<String, dynamic> map) {
    return SessionSummaryModel(
      id: map['id'] as String,
      sessionNumber: _tryParseInt(map['session_number']) ?? 0,
      sessionDate:
          DateTime.tryParse(map['session_date'] as String? ?? '') ??
          DateTime.now(),
      status: map['status'] as String? ?? 'scheduled',
    );
  }

  static int? _tryParseInt(Object? value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String && value.isNotEmpty) {
      return int.tryParse(value);
    }

    return null;
  }
}
