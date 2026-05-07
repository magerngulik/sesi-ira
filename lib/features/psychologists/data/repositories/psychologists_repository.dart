import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/psychologist_model.dart';
import '../models/specialization_model.dart';

class PsychologistLoginAccountInput {
  const PsychologistLoginAccountInput({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}

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
    PsychologistLoginAccountInput? loginAccount,
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

    if (loginAccount != null) {
      await _createLoginAccount(
        psychologistId: psychologistId,
        psychologistName: name,
        psychologistEmail: email,
        phone: phone,
        input: loginAccount,
      );
    }

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

  Future<void> _createLoginAccount({
    required String psychologistId,
    required String psychologistName,
    required String? psychologistEmail,
    required String? phone,
    required PsychologistLoginAccountInput input,
  }) async {
    if (!SupabaseService.isConfigured) {
      throw AppException(
        'Supabase belum dikonfigurasi, jadi akun login psikolog belum bisa dibuat.',
      );
    }

    final authClient = SupabaseClient(
      SupabaseConfig.url,
      SupabaseConfig.anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.implicit,
        autoRefreshToken: false,
        localStorage: EmptyLocalStorage(),
        detectSessionInUri: false,
      ),
    );

    try {
      await authClient.auth.signUp(
        email: input.email.trim(),
        password: input.password,
        data: <String, dynamic>{
          'role': 'psychologist',
          'psychologist_id': psychologistId,
          'display_name': psychologistName.trim(),
          'psychologist_email': _emptyToNull(psychologistEmail),
          'phone': _emptyToNull(phone),
        },
      );
    } on AuthException catch (error) {
      throw AppException(error.message);
    } finally {
      await authClient.dispose();
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
