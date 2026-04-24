import 'intervention_model.dart';

class SessionInterventionModel {
  const SessionInterventionModel({
    required this.id,
    required this.sessionId,
    required this.interventionId,
    this.note,
    this.createdAt,
    this.intervention,
  });

  final String id;
  final String sessionId;
  final String interventionId;
  final String? note;
  final DateTime? createdAt;
  final InterventionModel? intervention;

  factory SessionInterventionModel.fromMap(Map<String, dynamic> map) {
    final interventionMap = map['intervention_master'] as Map<String, dynamic>?;

    return SessionInterventionModel(
      id: map['id'] as String,
      sessionId: map['session_id'] as String? ?? '',
      interventionId: map['intervention_id'] as String? ?? '',
      note: map['note'] as String?,
      createdAt: _tryParseDateTime(map['created_at']),
      intervention: interventionMap == null
          ? null
          : InterventionModel.fromMap(interventionMap),
    );
  }

  static DateTime? _tryParseDateTime(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }
}
