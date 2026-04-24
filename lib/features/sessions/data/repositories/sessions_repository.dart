import '../../../../core/services/supabase_service.dart';
import '../models/intervention_model.dart';
import '../models/session_model.dart';

class CreateSessionAssessmentInput {
  const CreateSessionAssessmentInput({
    required this.assessmentType,
    this.assessmentName,
    this.description,
  });

  final String assessmentType;
  final String? assessmentName;
  final String? description;
}

class CreateSessionDiagnosisInput {
  const CreateSessionDiagnosisInput({
    required this.diagnosisText,
    this.diagnosisOrder,
  });

  final String diagnosisText;
  final int? diagnosisOrder;
}

class CreateSessionInterventionInput {
  const CreateSessionInterventionInput({
    required this.interventionId,
    this.note,
  });

  final String interventionId;
  final String? note;
}

class CreateSessionInterventionPlanInput {
  const CreateSessionInterventionPlanInput({
    required this.phase,
    this.planDate,
    this.beforeCondition,
    this.afterCondition,
  });

  final String phase;
  final String? planDate;
  final String? beforeCondition;
  final String? afterCondition;
}

class CaseSessionContext {
  const CaseSessionContext({
    this.caseTypeName,
    this.tagNames = const <String>[],
  });

  final String? caseTypeName;
  final List<String> tagNames;
}

class SessionsRepository {
  const SessionsRepository();

  Future<List<SessionModel>> fetchSessions({
    String? caseId,
    String? psychologistId,
  }) async {
    var query = SupabaseService.client
        .from('sessions')
        .select('''
          id,
          case_id,
          psychologist_id,
          session_number,
          session_date,
          start_time,
          end_time,
          status,
          complaint,
          summary,
          result,
          recommendation,
          next_plan,
          is_locked,
          locked_at,
          created_at,
          updated_at,
          deleted_at,
          follow_up_type,
          follow_up_note,
          duration_minutes,
          special_note,
          message
        ''')
        .isFilter('deleted_at', null);

    if (caseId != null && caseId.trim().isNotEmpty) {
      query = query.eq('case_id', caseId);
    }

    if (psychologistId != null && psychologistId.trim().isNotEmpty) {
      query = query.eq('psychologist_id', psychologistId);
    }

    final response = await query
        .order('session_date', ascending: false)
        .order('session_number', ascending: false);

    return response
        .map<SessionModel>((item) => SessionModel.fromMap(item))
        .toList();
  }

  Future<SessionModel> fetchSessionDetail(String sessionId) async {
    final response = await SupabaseService.client
        .from('sessions')
        .select('''
          id,
          case_id,
          psychologist_id,
          session_number,
          session_date,
          start_time,
          end_time,
          status,
          complaint,
          summary,
          result,
          recommendation,
          next_plan,
          is_locked,
          locked_at,
          created_at,
          updated_at,
          deleted_at,
          follow_up_type,
          follow_up_note,
          duration_minutes,
          special_note,
          message,
          session_diagnoses(
            id,
            session_id,
            diagnosis_order,
            diagnosis_text,
            created_at
          ),
          session_assessments(
            id,
            session_id,
            assessment_type,
            assessment_name,
            description,
            created_at,
            updated_at
          ),
          session_interventions(
            id,
            session_id,
            intervention_id,
            note,
            created_at,
            intervention_master:intervention_id(
              id,
              code,
              name,
              description,
              is_active,
              created_at
            )
          ),
          session_intervention_plans(
            id,
            session_id,
            plan_date,
            phase,
            before_condition,
            after_condition,
            created_at
          ),
          session_attachments(
            id,
            session_id,
            file_url,
            file_name,
            file_type,
            note,
            uploaded_at,
            deleted_at
          )
        ''')
        .eq('id', sessionId)
        .single();

    return SessionModel.fromMap(response);
  }

  Future<CaseSessionContext> fetchCaseSessionContext(String caseId) async {
    final results = await Future.wait<dynamic>(<Future<dynamic>>[
      SupabaseService.client
          .from('cases')
          .select('''
            case_type_id,
            case_types:case_type_id(name)
          ''')
          .eq('id', caseId)
          .maybeSingle(),
      SupabaseService.client
          .from('case_tag_relations')
          .select('''
            tag_id,
            case_tags:tag_id(name)
          ''')
          .eq('case_id', caseId),
    ]);

    final caseMap = results[0] as Map<String, dynamic>?;
    final tagRows = results[1] as List<dynamic>? ?? <dynamic>[];
    final caseTypeMap = caseMap?['case_types'] as Map<String, dynamic>?;
    final tagNames = tagRows
        .map((item) => item as Map<String, dynamic>)
        .map((item) => item['case_tags'] as Map<String, dynamic>?)
        .whereType<Map<String, dynamic>>()
        .map((item) => item['name'] as String?)
        .whereType<String>()
        .where((item) => item.trim().isNotEmpty)
        .toList();

    return CaseSessionContext(
      caseTypeName: caseTypeMap?['name'] as String?,
      tagNames: tagNames,
    );
  }

  Future<List<InterventionModel>> fetchInterventions({
    bool activeOnly = true,
  }) async {
    var query = SupabaseService.client
        .from('intervention_master')
        .select('id, code, name, description, is_active, created_at');

    if (activeOnly) {
      query = query.eq('is_active', true);
    }

    final response = await query.order('name');

    return response
        .map<InterventionModel>((item) => InterventionModel.fromMap(item))
        .toList();
  }

  Future<void> createSession({
    required String caseId,
    required String psychologistId,
    required int sessionNumber,
    required String sessionDate,
    required String status,
    String? startTime,
    String? endTime,
    String? complaint,
    String? summary,
    String? result,
    String? recommendation,
    String? nextPlan,
    bool isLocked = false,
    String? followUpType,
    String? followUpNote,
    int? durationMinutes,
    String? specialNote,
    String? message,
    List<CreateSessionDiagnosisInput> diagnoses =
        const <CreateSessionDiagnosisInput>[],
    List<CreateSessionAssessmentInput> assessments =
        const <CreateSessionAssessmentInput>[],
    List<CreateSessionInterventionInput> interventions =
        const <CreateSessionInterventionInput>[],
    List<CreateSessionInterventionPlanInput> interventionPlans =
        const <CreateSessionInterventionPlanInput>[],
  }) async {
    final insertedSession = await SupabaseService.client
        .from('sessions')
        .insert(<String, dynamic>{
          'case_id': caseId,
          'psychologist_id': psychologistId,
          'session_number': sessionNumber,
          'session_date': sessionDate,
          'start_time': _emptyToNull(startTime),
          'end_time': _emptyToNull(endTime),
          'status': status,
          'complaint': _emptyToNull(complaint),
          'summary': _emptyToNull(summary),
          'result': _emptyToNull(result),
          'recommendation': _emptyToNull(recommendation),
          'next_plan': _emptyToNull(nextPlan),
          'is_locked': isLocked,
          'locked_at': isLocked ? DateTime.now().toIso8601String() : null,
          'follow_up_type': _emptyToNull(followUpType),
          'follow_up_note': _emptyToNull(followUpNote),
          'duration_minutes': durationMinutes,
          'special_note': _emptyToNull(specialNote),
          'message': _emptyToNull(message),
        })
        .select('id')
        .single();

    final sessionId = insertedSession['id'] as String;

    if (diagnoses.isNotEmpty) {
      await SupabaseService.client
          .from('session_diagnoses')
          .insert(
            diagnoses.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              return <String, dynamic>{
                'session_id': sessionId,
                'diagnosis_order': item.diagnosisOrder ?? index + 1,
                'diagnosis_text': item.diagnosisText.trim(),
              };
            }).toList(),
          );
    }

    if (assessments.isNotEmpty) {
      await SupabaseService.client
          .from('session_assessments')
          .insert(
            assessments.map((item) {
              return <String, dynamic>{
                'session_id': sessionId,
                'assessment_type': item.assessmentType.trim(),
                'assessment_name': _emptyToNull(item.assessmentName),
                'description': _emptyToNull(item.description),
              };
            }).toList(),
          );
    }

    if (interventions.isNotEmpty) {
      await SupabaseService.client
          .from('session_interventions')
          .insert(
            interventions.map((item) {
              return <String, dynamic>{
                'session_id': sessionId,
                'intervention_id': item.interventionId,
                'note': _emptyToNull(item.note),
              };
            }).toList(),
          );
    }

    if (interventionPlans.isNotEmpty) {
      await SupabaseService.client
          .from('session_intervention_plans')
          .insert(
            interventionPlans.map((item) {
              return <String, dynamic>{
                'session_id': sessionId,
                'plan_date': item.planDate,
                'phase': item.phase.trim(),
                'before_condition': _emptyToNull(item.beforeCondition),
                'after_condition': _emptyToNull(item.afterCondition),
              };
            }).toList(),
          );
    }
  }

  String? _emptyToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }
}
