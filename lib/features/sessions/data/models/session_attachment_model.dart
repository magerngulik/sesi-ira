class SessionAttachmentModel {
  const SessionAttachmentModel({
    required this.id,
    required this.sessionId,
    required this.fileUrl,
    this.fileName,
    this.fileType,
    this.note,
    this.uploadedAt,
    this.deletedAt,
  });

  final String id;
  final String sessionId;
  final String fileUrl;
  final String? fileName;
  final String? fileType;
  final String? note;
  final DateTime? uploadedAt;
  final DateTime? deletedAt;

  factory SessionAttachmentModel.fromMap(Map<String, dynamic> map) {
    return SessionAttachmentModel(
      id: map['id'] as String,
      sessionId: map['session_id'] as String? ?? '',
      fileUrl: map['file_url'] as String? ?? '',
      fileName: map['file_name'] as String?,
      fileType: map['file_type'] as String?,
      note: map['note'] as String?,
      uploadedAt: _tryParseDateTime(map['uploaded_at']),
      deletedAt: _tryParseDateTime(map['deleted_at']),
    );
  }

  static DateTime? _tryParseDateTime(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }
}
