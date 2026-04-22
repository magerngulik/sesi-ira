import '../../../../core/services/supabase_service.dart';
import '../models/case_summary_model.dart';

class CasesRepository {
  const CasesRepository();

  Future<List<CaseSummaryModel>> fetchCases() async {
    final response = await SupabaseService.client
        .from('cases')
        .select('''
          id,
          title,
          category,
          complaint,
          goal,
          status,
          start_date,
          clients:client_id(full_name),
          psychologists:assigned_psychologist_id(name)
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
    required String title,
    required String startDate,
    String? category,
    String? complaint,
    String? goal,
    String status = 'active',
  }) {
    return SupabaseService.client.from('cases').insert(<String, dynamic>{
      'client_id': clientId,
      'assigned_psychologist_id': psychologistId,
      'title': title,
      'category': _emptyToNull(category),
      'complaint': _emptyToNull(complaint),
      'goal': _emptyToNull(goal),
      'status': status,
      'start_date': startDate,
    });
  }

  String? _emptyToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }
}
