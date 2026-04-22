import '../../../../core/services/supabase_service.dart';
import '../models/psychologist_model.dart';
import '../models/specialization_model.dart';

class PsychologistsRepository {
  const PsychologistsRepository();

  Future<List<PsychologistModel>> fetchPsychologists() async {
    final response = await SupabaseService.client
        .from('psychologists')
        .select('''
          id,
          name,
          phone,
          email,
          notes,
          is_active,
          psychologist_specializations(
            specialization:specializations(
              id,
              name,
              icon_key
            )
          )
        ''')
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false);

    return response
        .map<PsychologistModel>((item) => PsychologistModel.fromMap(item))
        .toList();
  }

  Future<List<SpecializationModel>> fetchSpecializations() async {
    final response = await SupabaseService.client
        .from('specializations')
        .select('id, name, icon_key')
        .order('name');

    return response
        .map<SpecializationModel>((item) => SpecializationModel.fromMap(item))
        .toList();
  }

  Future<void> createPsychologist({
    required String name,
    required List<String> specializationIds,
    String? phone,
    String? email,
    String? notes,
  }) async {
    final psychologist = await SupabaseService.client
        .from('psychologists')
        .insert(<String, dynamic>{
          'name': name.trim(),
          'phone': _emptyToNull(phone),
          'email': _emptyToNull(email),
          'notes': _emptyToNull(notes),
        })
        .select('id')
        .single();

    final psychologistId = psychologist['id'] as String;
    if (specializationIds.isEmpty) {
      return;
    }

    await SupabaseService.client
        .from('psychologist_specializations')
        .insert(
          specializationIds.map((specializationId) {
            return <String, dynamic>{
              'psychologist_id': psychologistId,
              'specialization_id': specializationId,
            };
          }).toList(),
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
