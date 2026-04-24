import '../../../../core/services/supabase_service.dart';
import '../models/case_tag_model.dart';

class CaseTagsRepository {
  const CaseTagsRepository();

  Future<List<CaseTagModel>> fetchCaseTags() async {
    final response = await SupabaseService.client
        .from('case_tags')
        .select('id, name')
        .order('name');

    return response
        .map<CaseTagModel>((item) => CaseTagModel.fromMap(item))
        .toList();
  }

  Future<void> createCaseTag({required String name}) {
    return SupabaseService.client.from('case_tags').insert(<String, dynamic>{
      'name': name.trim(),
    });
  }
}
