class ClientModel {
  const ClientModel({
    required this.id,
    required this.fullName,
    this.gender,
    this.birthDate,
    this.phone,
    this.address,
    this.nik,
    this.birthOrder,
    this.lastEducation,
    this.maritalStatus,
    this.occupation,
    this.occupationOther,
    this.emergencyContact,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.isStudent,
    this.guardianName,
    this.guardianPhone,
    this.notes,
    this.createdAt,
  });

  final String id;
  final String fullName;
  final String? gender;
  final DateTime? birthDate;
  final String? phone;
  final String? address;
  final String? nik;
  final int? birthOrder;
  final String? lastEducation;
  final String? maritalStatus;
  final String? occupation;
  final String? occupationOther;
  final String? emergencyContact;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final bool? isStudent;
  final String? guardianName;
  final String? guardianPhone;
  final String? notes;
  final DateTime? createdAt;

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      id: map['id'] as String,
      fullName: map['full_name'] as String? ?? '-',
      gender: map['gender'] as String?,
      birthDate: _tryParseDate(map['birth_date']),
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      nik: map['nik'] as String?,
      birthOrder: _tryParseInt(map['birth_order']),
      lastEducation: map['last_education'] as String?,
      maritalStatus: map['marital_status'] as String?,
      occupation: map['occupation'] as String?,
      occupationOther: map['occupation_other'] as String?,
      emergencyContact: map['emergency_contact'] as String?,
      emergencyContactName: map['emergency_contact_name'] as String?,
      emergencyContactPhone: map['emergency_contact_phone'] as String?,
      isStudent: _tryParseBool(map['is_student']),
      guardianName: map['guardian_name'] as String?,
      guardianPhone: map['guardian_phone'] as String?,
      notes: map['notes'] as String?,
      createdAt: _tryParseDateTime(map['created_at']),
    );
  }

  String? get emergencyContactSummary {
    final name = _trimOrNull(emergencyContactName);
    final phoneNumber = _trimOrNull(emergencyContactPhone);
    if (name != null && phoneNumber != null) {
      return '$name - $phoneNumber';
    }

    return name ?? phoneNumber ?? _trimOrNull(emergencyContact);
  }

  static DateTime? _tryParseDate(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  static DateTime? _tryParseDateTime(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  static int? _tryParseInt(Object? value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String && value.isNotEmpty) {
      return int.tryParse(value);
    }

    return null;
  }

  static bool? _tryParseBool(Object? value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    if (value is String) {
      switch (value.toLowerCase()) {
        case 'true':
        case 't':
        case '1':
          return true;
        case 'false':
        case 'f':
        case '0':
          return false;
      }
    }

    return null;
  }

  static String? _trimOrNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }
}
