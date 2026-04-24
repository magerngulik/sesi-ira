class SessionAssessmentModel {
  const SessionAssessmentModel({
    required this.id,
    required this.sessionId,
    required this.assessmentType,
    this.assessmentName,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String sessionId;
  final String assessmentType;
  final String? assessmentName;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory SessionAssessmentModel.fromMap(Map<String, dynamic> map) {
    return SessionAssessmentModel(
      id: map['id'] as String,
      sessionId: map['session_id'] as String? ?? '',
      assessmentType: map['assessment_type'] as String? ?? '-',
      assessmentName: map['assessment_name'] as String?,
      description: map['description'] as String?,
      createdAt: _tryParseDateTime(map['created_at']),
      updatedAt: _tryParseDateTime(map['updated_at']),
    );
  }

  static DateTime? _tryParseDateTime(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }
}
