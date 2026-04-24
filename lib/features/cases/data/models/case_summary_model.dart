import 'session_summary_model.dart';

class CaseSummaryModel {
  const CaseSummaryModel({
    required this.id,
    required this.clientId,
    required this.assignedPsychologistId,
    required this.title,
    required this.status,
    required this.startDate,
    this.latestSession,
    this.category,
    this.complaint,
    this.goal,
    this.clientName,
    this.psychologistName,
  });

  final String id;
  final String clientId;
  final String assignedPsychologistId;
  final String title;
  final String status;
  final DateTime startDate;
  final SessionSummaryModel? latestSession;
  final String? category;
  final String? complaint;
  final String? goal;
  final String? clientName;
  final String? psychologistName;

  factory CaseSummaryModel.fromMap(Map<String, dynamic> map) {
    final clientMap = map['clients'] as Map<String, dynamic>?;
    final psychologistMap = map['psychologists'] as Map<String, dynamic>?;
    final sessionRows = map['sessions'] as List<dynamic>? ?? <dynamic>[];
    final sessions =
        sessionRows
            .map<SessionSummaryModel>(
              (item) =>
                  SessionSummaryModel.fromMap(item as Map<String, dynamic>),
            )
            .toList()
          ..sort((a, b) {
            final dateCompare = b.sessionDate.compareTo(a.sessionDate);
            if (dateCompare != 0) {
              return dateCompare;
            }

            return b.sessionNumber.compareTo(a.sessionNumber);
          });

    return CaseSummaryModel(
      id: map['id'] as String,
      clientId: map['client_id'] as String? ?? '',
      assignedPsychologistId: map['assigned_psychologist_id'] as String? ?? '',
      title: map['title'] as String? ?? '-',
      status: map['status'] as String? ?? 'active',
      startDate: DateTime.parse(map['start_date'] as String),
      latestSession: sessions.isEmpty ? null : sessions.first,
      category: map['category'] as String?,
      complaint: map['complaint'] as String?,
      goal: map['goal'] as String?,
      clientName: clientMap?['full_name'] as String?,
      psychologistName: psychologistMap?['name'] as String?,
    );
  }
}
