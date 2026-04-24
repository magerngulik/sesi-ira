class CaseTagModel {
  const CaseTagModel({required this.id, required this.name});

  final String id;
  final String name;

  factory CaseTagModel.fromMap(Map<String, dynamic> map) {
    return CaseTagModel(
      id: map['id'] as String,
      name: map['name'] as String? ?? '-',
    );
  }
}
