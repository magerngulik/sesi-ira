class InterventionModel {
  const InterventionModel({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.isActive,
    this.createdAt,
  });

  final String id;
  final String code;
  final String name;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;

  factory InterventionModel.fromMap(Map<String, dynamic> map) {
    return InterventionModel(
      id: map['id'] as String,
      code: map['code'] as String? ?? '-',
      name: map['name'] as String? ?? '-',
      description: map['description'] as String?,
      isActive: map['is_active'] as bool? ?? true,
      createdAt: _tryParseDateTime(map['created_at']),
    );
  }

  static DateTime? _tryParseDateTime(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }
}
