import '../../../../core/services/supabase_service.dart';
import '../models/case_type_model.dart';

class CaseTypesRepository {
  const CaseTypesRepository();

  Future<List<CaseTypeModel>> fetchCaseTypes() async {
    final response = await SupabaseService.client
        .from('case_types')
        .select('id, name, description, is_active')
        .order('name');

    return response
        .map<CaseTypeModel>((item) => CaseTypeModel.fromMap(item))
        .toList();
  }

  Future<void> createCaseType({
    required String name,
    String? description,
    required bool isActive,
  }) {
    return SupabaseService.client.from('case_types').insert(<String, dynamic>{
      'name': name.trim(),
      'description': (description ?? '').trim().isEmpty
          ? null
          : description!.trim(),
      'is_active': isActive,
    });
  }

  Future<void> updateCaseType({
    required String id,
    required String name,
    String? description,
    required bool isActive,
  }) async {
    final response = await SupabaseService.client
        .from('case_types')
        .update(<String, dynamic>{
          'name': name.trim(),
          'description': (description ?? '').trim().isEmpty
              ? null
              : description!.trim(),
          'is_active': isActive,
        })
        .eq('id', id)
        .select('id');

    if (response.isEmpty) {
      final currentUser = SupabaseService.client.auth.currentUser;
      throw Exception(
        'Update gagal. User aktif: ${currentUser?.id ?? 'null'}. '
        'Row case_types tidak ditemukan atau diblokir policy.',
      );
    }
  }
}
