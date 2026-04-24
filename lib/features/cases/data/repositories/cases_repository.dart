import '../../../../core/services/supabase_service.dart';
import '../models/case_summary_model.dart';

class CasesRepository {
  const CasesRepository();

  Future<List<CaseSummaryModel>> fetchCases() async {
    final response = await SupabaseService.client
        .from('cases')
        .select('''
          id,
          client_id,
          assigned_psychologist_id,
          title,
          category,
          complaint,
          goal,
          status,
          start_date,
          clients:client_id(full_name),
          psychologists:assigned_psychologist_id(name),
          sessions(
            id,
            session_number,
            session_date,
            status
          )
        ''')
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false);

    return response
        .map<CaseSummaryModel>((item) => CaseSummaryModel.fromMap(item))
        .toList();
  }

  Future<void> createCase({
    required String clientId,
    required String psychologistId,
    required String caseTypeId,
    required String title,
    required String startDate,
    String? category,
    String? complaint,
    String? goal,
    String status = 'active',
    List<String> tagIds = const <String>[],
  }) async {
    final insertedCase = await SupabaseService.client
        .from('cases')
        .insert(<String, dynamic>{
          'client_id': clientId,
          'assigned_psychologist_id': psychologistId,
          'case_type_id': caseTypeId,
          'title': title,
          'category': _emptyToNull(category),
          'complaint': _emptyToNull(complaint),
          'goal': _emptyToNull(goal),
          'status': status,
          'start_date': startDate,
          'end_date': null,
        })
        .select('id')
        .single();

    if (tagIds.isEmpty) {
      return;
    }

    final caseId = insertedCase['id'] as String;
    await SupabaseService.client
        .from('case_tag_relations')
        .insert(
          tagIds
              .map(
                (tagId) => <String, dynamic>{
                  'case_id': caseId,
                  'tag_id': tagId,
                },
              )
              .toList(),
        );
  }

  String? _emptyToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }
}
