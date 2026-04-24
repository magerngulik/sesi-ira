import 'session_assessment_model.dart';
import 'session_attachment_model.dart';
import 'session_diagnosis_model.dart';
import 'session_intervention_model.dart';
import 'session_intervention_plan_model.dart';

class SessionModel {
  const SessionModel({
    required this.id,
    required this.caseId,
    required this.psychologistId,
    required this.sessionNumber,
    required this.sessionDate,
    this.startTime,
    this.endTime,
    required this.status,
    this.complaint,
    this.summary,
    this.result,
    this.recommendation,
    this.nextPlan,
    required this.isLocked,
    this.lockedAt,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.followUpType,
    this.followUpNote,
    this.durationMinutes,
    this.specialNote,
    this.message,
    this.diagnoses = const <SessionDiagnosisModel>[],
    this.assessments = const <SessionAssessmentModel>[],
    this.interventions = const <SessionInterventionModel>[],
    this.interventionPlans = const <SessionInterventionPlanModel>[],
    this.attachments = const <SessionAttachmentModel>[],
  });

  final String id;
  final String caseId;
  final String psychologistId;
  final int sessionNumber;
  final DateTime sessionDate;
  final String? startTime;
  final String? endTime;
  final String status;
  final String? complaint;
  final String? summary;
  final String? result;
  final String? recommendation;
  final String? nextPlan;
  final bool isLocked;
  final DateTime? lockedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String? followUpType;
  final String? followUpNote;
  final int? durationMinutes;
  final String? specialNote;
  final String? message;
  final List<SessionDiagnosisModel> diagnoses;
  final List<SessionAssessmentModel> assessments;
  final List<SessionInterventionModel> interventions;
  final List<SessionInterventionPlanModel> interventionPlans;
  final List<SessionAttachmentModel> attachments;

  factory SessionModel.fromMap(Map<String, dynamic> map) {
    final diagnosisRows =
        map['session_diagnoses'] as List<dynamic>? ?? <dynamic>[];
    final assessmentRows =
        map['session_assessments'] as List<dynamic>? ?? <dynamic>[];
    final interventionRows =
        map['session_interventions'] as List<dynamic>? ?? <dynamic>[];
    final interventionPlanRows =
        map['session_intervention_plans'] as List<dynamic>? ?? <dynamic>[];
    final attachmentRows =
        map['session_attachments'] as List<dynamic>? ?? <dynamic>[];

    return SessionModel(
      id: map['id'] as String,
      caseId: map['case_id'] as String? ?? '',
      psychologistId: map['psychologist_id'] as String? ?? '',
      sessionNumber: _tryParseInt(map['session_number']) ?? 0,
      sessionDate:
          DateTime.tryParse(map['session_date'] as String? ?? '') ??
          DateTime.now(),
      startTime: map['start_time'] as String?,
      endTime: map['end_time'] as String?,
      status: map['status'] as String? ?? 'scheduled',
      complaint: map['complaint'] as String?,
      summary: map['summary'] as String?,
      result: map['result'] as String?,
      recommendation: map['recommendation'] as String?,
      nextPlan: map['next_plan'] as String?,
      isLocked: map['is_locked'] as bool? ?? false,
      lockedAt: _tryParseDateTime(map['locked_at']),
      createdAt: _tryParseDateTime(map['created_at']),
      updatedAt: _tryParseDateTime(map['updated_at']),
      deletedAt: _tryParseDateTime(map['deleted_at']),
      followUpType: map['follow_up_type'] as String?,
      followUpNote: map['follow_up_note'] as String?,
      durationMinutes: _tryParseInt(map['duration_minutes']),
      specialNote: map['special_note'] as String?,
      message: map['message'] as String?,
      diagnoses: diagnosisRows
          .map<SessionDiagnosisModel>(
            (item) =>
                SessionDiagnosisModel.fromMap(item as Map<String, dynamic>),
          )
          .toList(),
      assessments: assessmentRows
          .map<SessionAssessmentModel>(
            (item) =>
                SessionAssessmentModel.fromMap(item as Map<String, dynamic>),
          )
          .toList(),
      interventions: interventionRows
          .map<SessionInterventionModel>(
            (item) =>
                SessionInterventionModel.fromMap(item as Map<String, dynamic>),
          )
          .toList(),
      interventionPlans: interventionPlanRows
          .map<SessionInterventionPlanModel>(
            (item) => SessionInterventionPlanModel.fromMap(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      attachments: attachmentRows
          .map<SessionAttachmentModel>(
            (item) =>
                SessionAttachmentModel.fromMap(item as Map<String, dynamic>),
          )
          .toList(),
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
