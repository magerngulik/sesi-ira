import 'specialization_model.dart';

class PsychologistModel {
  const PsychologistModel({
    required this.id,
    required this.name,
    required this.specializations,
    this.phone,
    this.email,
    this.notes,
    required this.isActive,
  });

  final String id;
  final String name;
  final List<SpecializationModel> specializations;
  final String? phone;
  final String? email;
  final String? notes;
  final bool isActive;

  String? get specializationSummary {
    if (specializations.isEmpty) {
      return null;
    }

    return specializations.map((item) => item.name).join(', ');
  }

  factory PsychologistModel.fromMap(Map<String, dynamic> map) {
    final pivotRows =
        map['psychologist_specializations'] as List<dynamic>? ?? <dynamic>[];
    final specializations = pivotRows
        .map((item) {
          final pivotMap = item as Map<String, dynamic>;
          final specializationMap =
              pivotMap['specialization'] as Map<String, dynamic>?;
          if (specializationMap == null) {
            return null;
          }

          return SpecializationModel.fromMap(specializationMap);
        })
        .whereType<SpecializationModel>()
        .toList();

    return PsychologistModel(
      id: map['id'] as String,
      name: map['name'] as String? ?? '-',
      specializations: specializations,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      notes: map['notes'] as String?,
      isActive: map['is_active'] as bool? ?? true,
    );
  }
}
