class SpecializationModel {
  const SpecializationModel({
    required this.id,
    required this.name,
    required this.iconKey,
  });

  final String id;
  final String name;
  final String iconKey;

  factory SpecializationModel.fromMap(Map<String, dynamic> map) {
    return SpecializationModel(
      id: map['id'] as String,
      name: map['name'] as String? ?? '-',
      iconKey: map['icon_key'] as String? ?? '',
    );
  }
}
