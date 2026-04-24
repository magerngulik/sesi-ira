class SessionInterventionPlanModel {
  const SessionInterventionPlanModel({
    required this.id,
    required this.sessionId,
    this.planDate,
    required this.phase,
    this.beforeCondition,
    this.afterCondition,
    this.createdAt,
  });

  final String id;
  final String sessionId;
  final DateTime? planDate;
  final String phase;
  final String? beforeCondition;
  final String? afterCondition;
  final DateTime? createdAt;

  factory SessionInterventionPlanModel.fromMap(Map<String, dynamic> map) {
    return SessionInterventionPlanModel(
      id: map['id'] as String,
      sessionId: map['session_id'] as String? ?? '',
      planDate: _tryParseDate(map['plan_date']),
      phase: map['phase'] as String? ?? '-',
      beforeCondition: map['before_condition'] as String?,
      afterCondition: map['after_condition'] as String?,
      createdAt: _tryParseDateTime(map['created_at']),
    );
  }

  static DateTime? _tryParseDate(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  static DateTime? _tryParseDateTime(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }
}
