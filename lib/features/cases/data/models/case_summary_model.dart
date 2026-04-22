class CaseSummaryModel {
  const CaseSummaryModel({
    required this.id,
    required this.title,
    required this.status,
    required this.startDate,
    this.category,
    this.complaint,
    this.goal,
    this.clientName,
    this.psychologistName,
  });

  final String id;
  final String title;
  final String status;
  final DateTime startDate;
  final String? category;
  final String? complaint;
  final String? goal;
  final String? clientName;
  final String? psychologistName;

  factory CaseSummaryModel.fromMap(Map<String, dynamic> map) {
    final clientMap = map['clients'] as Map<String, dynamic>?;
    final psychologistMap = map['psychologists'] as Map<String, dynamic>?;

    return CaseSummaryModel(
      id: map['id'] as String,
      title: map['title'] as String? ?? '-',
      status: map['status'] as String? ?? 'active',
      startDate: DateTime.parse(map['start_date'] as String),
      category: map['category'] as String?,
      complaint: map['complaint'] as String?,
      goal: map['goal'] as String?,
      clientName: clientMap?['full_name'] as String?,
      psychologistName: psychologistMap?['name'] as String?,
    );
  }
}
