import 'package:flutter/material.dart';

class PsychologistClientPreview {
  const PsychologistClientPreview({
    required this.name,
    required this.age,
    required this.gender,
    required this.caseCount,
    required this.lastSessionLabel,
    required this.accent,
  });

  final String name;
  final int age;
  final String gender;
  final int caseCount;
  final String lastSessionLabel;
  final Color accent;
}

class PsychologistCasePreview {
  const PsychologistCasePreview({
    required this.clientName,
    required this.topic,
    required this.sessionCount,
    required this.statusLabel,
    required this.statusTone,
  });

  final String clientName;
  final String topic;
  final int sessionCount;
  final String statusLabel;
  final Color statusTone;
}

class PsychologistSessionPreview {
  const PsychologistSessionPreview({
    required this.title,
    required this.dateLabel,
    required this.statusLabel,
    required this.statusTone,
  });

  final String title;
  final String dateLabel;
  final String statusLabel;
  final Color statusTone;
}

class PsychologistSchedulePreview {
  const PsychologistSchedulePreview({
    required this.timeLabel,
    required this.clientName,
    required this.sessionLabel,
    required this.statusLabel,
  });

  final String timeLabel;
  final String clientName;
  final String sessionLabel;
  final String statusLabel;
}

class PsychologistActivityPreview {
  const PsychologistActivityPreview({
    required this.title,
    required this.timeLabel,
  });

  final String title;
  final String timeLabel;
}

class PsychologistNotificationPreview {
  const PsychologistNotificationPreview({
    required this.title,
    required this.message,
    required this.timeLabel,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String message;
  final String timeLabel;
  final IconData icon;
  final Color accent;
}
