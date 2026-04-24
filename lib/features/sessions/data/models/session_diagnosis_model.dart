class SessionDiagnosisModel {
  const SessionDiagnosisModel({
    required this.id,
    required this.sessionId,
    required this.diagnosisOrder,
    required this.diagnosisText,
    this.createdAt,
  });

  final String id;
  final String sessionId;
  final int diagnosisOrder;
  final String diagnosisText;
  final DateTime? createdAt;

  factory SessionDiagnosisModel.fromMap(Map<String, dynamic> map) {
    return SessionDiagnosisModel(
      id: map['id'] as String,
      sessionId: map['session_id'] as String? ?? '',
      diagnosisOrder: _tryParseInt(map['diagnosis_order']) ?? 0,
      diagnosisText: map['diagnosis_text'] as String? ?? '-',
      createdAt: _tryParseDateTime(map['created_at']),
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

  static DateTime? _tryParseDateTime(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }
}
