import 'assessment_type_model.dart';

class SessionAssessmentModel {
  const SessionAssessmentModel({
    required this.id,
    required this.sessionId,
    required this.assessmentTypeId,
    this.assessmentName,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.assessmentType,
  });

  final String id;
  final String sessionId;
  final String assessmentTypeId;
  final String? assessmentName;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final AssessmentTypeModel? assessmentType;

  factory SessionAssessmentModel.fromMap(Map<String, dynamic> map) {
    final assessmentTypeMap = map['assessment_type'] as Map<String, dynamic>?;

    return SessionAssessmentModel(
      id: map['id'] as String,
      sessionId: map['session_id'] as String? ?? '',
      assessmentTypeId: map['assessment_type_id'] as String? ?? '',
      assessmentName: map['assessment_name'] as String?,
      description: map['description'] as String?,
      createdAt: _tryParseDateTime(map['created_at']),
      updatedAt: _tryParseDateTime(map['updated_at']),
      assessmentType: assessmentTypeMap == null
          ? null
          : AssessmentTypeModel.fromMap(assessmentTypeMap),
    );
  }

  static DateTime? _tryParseDateTime(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }
}
