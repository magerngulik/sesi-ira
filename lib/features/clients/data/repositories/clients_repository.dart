import '../../../../core/services/supabase_service.dart';
import '../models/client_model.dart';

class ClientsRepository {
  const ClientsRepository();

  Future<List<ClientModel>> fetchClients() async {
    final response = await SupabaseService.client
        .from('clients')
        .select()
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false);

    return response
        .map<ClientModel>((item) => ClientModel.fromMap(item))
        .toList();
  }

  Future<void> createClient({
    required String fullName,
    String? gender,
    String? birthDate,
    String? phone,
    String? address,
    String? nik,
    int? birthOrder,
    String? lastEducation,
    String? maritalStatus,
    String? occupation,
    String? occupationOther,
    String? emergencyContactName,
    String? emergencyContactPhone,
    required bool isStudent,
    String? guardianName,
    String? guardianPhone,
    String? notes,
  }) {
    final payload = <String, dynamic>{
      'full_name': fullName,
      'gender': _emptyToNull(gender),
      'birth_date': _emptyToNull(birthDate),
      'phone': _emptyToNull(phone),
      'address': _emptyToNull(address),
      'nik': _emptyToNull(nik),
      'birth_order': birthOrder,
      'last_education': _emptyToNull(lastEducation),
      'marital_status': _emptyToNull(maritalStatus),
      'occupation': _emptyToNull(occupation),
      'is_student': isStudent,
      'notes': _emptyToNull(notes),
    };

    final emergencyName = _emptyToNull(emergencyContactName);
    final emergencyPhone = _emptyToNull(emergencyContactPhone);
    final emergencyContact = _buildEmergencyContactSummary(
      emergencyName,
      emergencyPhone,
    );

    if (emergencyName != null) {
      payload['emergency_contact_name'] = emergencyName;
    }

    if (emergencyPhone != null) {
      payload['emergency_contact_phone'] = emergencyPhone;
    }

    if (emergencyContact != null) {
      payload['emergency_contact'] = emergencyContact;
    }

    final occupationOtherValue = _emptyToNull(occupationOther);
    if (_emptyToNull(occupation) == 'Lainnya' && occupationOtherValue != null) {
      payload['occupation_other'] = occupationOtherValue;
    }

    if (isStudent) {
      final guardianNameValue = _emptyToNull(guardianName);
      final guardianPhoneValue = _emptyToNull(guardianPhone);

      if (guardianNameValue != null) {
        payload['guardian_name'] = guardianNameValue;
      }

      if (guardianPhoneValue != null) {
        payload['guardian_phone'] = guardianPhoneValue;
      }
    }

    return SupabaseService.client.from('clients').insert(payload);
  }

  String? _emptyToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }

  String? _buildEmergencyContactSummary(String? name, String? phone) {
    if (name != null && phone != null) {
      return '$name - $phone';
    }

    return name ?? phone;
  }
}
