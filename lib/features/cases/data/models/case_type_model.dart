class CaseTypeModel {
  const CaseTypeModel({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
  });

  final String id;
  final String name;
  final String? description;
  final bool isActive;

  factory CaseTypeModel.fromMap(Map<String, dynamic> map) {
    return CaseTypeModel(
      id: map['id'] as String,
      name: map['name'] as String? ?? '-',
      description: map['description'] as String?,
      isActive: map['is_active'] as bool? ?? true,
    );
  }
}
