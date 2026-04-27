import '../../../../core/services/supabase_service.dart';
import '../models/assessment_type_model.dart';

class AssessmentTypesRepository {
  const AssessmentTypesRepository();

  Future<List<AssessmentTypeModel>> fetchAssessmentTypes() async {
    final response = await SupabaseService.client
        .from('assessment_types')
        .select('id, code, name, description, is_active')
        .order('name');

    return response
        .map<AssessmentTypeModel>((item) => AssessmentTypeModel.fromMap(item))
        .toList();
  }

  Future<void> createAssessmentType({
    required String code,
    required String name,
    String? description,
    required bool isActive,
  }) {
    return SupabaseService.client
        .from('assessment_types')
        .insert(<String, dynamic>{
          'code': code.trim(),
          'name': name.trim(),
          'description': (description ?? '').trim().isEmpty
              ? null
              : description!.trim(),
          'is_active': isActive,
        });
  }

  Future<void> updateAssessmentType({
    required String id,
    required String code,
    required String name,
    String? description,
    required bool isActive,
  }) async {
    final response = await SupabaseService.client
        .from('assessment_types')
        .update(<String, dynamic>{
          'code': code.trim(),
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
        'Row assessment_types tidak ditemukan atau diblokir policy.',
      );
    }
  }
}
