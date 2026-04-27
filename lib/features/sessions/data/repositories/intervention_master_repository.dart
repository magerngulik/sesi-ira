import '../../../../core/services/supabase_service.dart';
import '../models/intervention_model.dart';

class InterventionMasterRepository {
  const InterventionMasterRepository();

  Future<List<InterventionModel>> fetchInterventions() async {
    final response = await SupabaseService.client
        .from('intervention_master')
        .select('id, code, name, description, is_active, created_at')
        .order('name');

    return response
        .map<InterventionModel>((item) => InterventionModel.fromMap(item))
        .toList();
  }

  Future<void> createIntervention({
    required String code,
    required String name,
    String? description,
    required bool isActive,
  }) {
    return SupabaseService.client
        .from('intervention_master')
        .insert(<String, dynamic>{
          'code': code.trim(),
          'name': name.trim(),
          'description': (description ?? '').trim().isEmpty
              ? null
              : description!.trim(),
          'is_active': isActive,
        });
  }

  Future<void> updateIntervention({
    required String id,
    required String code,
    required String name,
    String? description,
    required bool isActive,
  }) async {
    final response = await SupabaseService.client
        .from('intervention_master')
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
        'Row intervention_master tidak ditemukan atau diblokir policy.',
      );
    }
  }
}
