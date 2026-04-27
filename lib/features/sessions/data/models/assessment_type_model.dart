class AssessmentTypeModel {
  const AssessmentTypeModel({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.isActive,
  });

  final String id;
  final String code;
  final String name;
  final String? description;
  final bool isActive;

  factory AssessmentTypeModel.fromMap(Map<String, dynamic> map) {
    return AssessmentTypeModel(
      id: map['id'] as String,
      code: map['code'] as String? ?? '-',
      name: map['name'] as String? ?? '-',
      description: map['description'] as String?,
      isActive: map['is_active'] as bool? ?? true,
    );
  }
}
