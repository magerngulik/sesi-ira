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

class PsychologistPortalMockData {
  const PsychologistPortalMockData._();

  static const String psychologistName = 'Dr. Ira Meilani';
  static const String psychologistTitle = 'Clinical Psychologist';
  static const String psychologistEmail = 'ira.meilani@example.com';
  static const String psychologistPhone = '+62 812-3456-7890';

  static const List<PsychologistSchedulePreview> todaySchedule =
      <PsychologistSchedulePreview>[
        PsychologistSchedulePreview(
          timeLabel: '10:00',
          clientName: 'Andi Saputra',
          sessionLabel: 'Session 2',
          statusLabel: 'Upcoming',
        ),
        PsychologistSchedulePreview(
          timeLabel: '13:00',
          clientName: 'Budi Santoso',
          sessionLabel: 'Session 1',
          statusLabel: 'Upcoming',
        ),
        PsychologistSchedulePreview(
          timeLabel: '15:00',
          clientName: 'Citra Lestari',
          sessionLabel: 'Session 2',
          statusLabel: 'Upcoming',
        ),
      ];

  static const List<PsychologistActivityPreview> recentActivities =
      <PsychologistActivityPreview>[
        PsychologistActivityPreview(
          title: 'Session dengan Andi selesai',
          timeLabel: '2 jam yang lalu',
        ),
        PsychologistActivityPreview(
          title: 'Case baru Budi Santoso dibuat',
          timeLabel: '3 jam yang lalu',
        ),
        PsychologistActivityPreview(
          title: 'Catatan session diperbarui',
          timeLabel: 'Kemarin',
        ),
      ];

  static const List<PsychologistClientPreview> clients =
      <PsychologistClientPreview>[
        PsychologistClientPreview(
          name: 'Andi Saputra',
          age: 25,
          gender: 'Pria',
          caseCount: 2,
          lastSessionLabel: 'Last session 2 hari lalu',
          accent: Color(0xFFFFC8D7),
        ),
        PsychologistClientPreview(
          name: 'Budi Santoso',
          age: 30,
          gender: 'Pria',
          caseCount: 1,
          lastSessionLabel: 'Last session 1 hari lalu',
          accent: Color(0xFFFFD9A8),
        ),
        PsychologistClientPreview(
          name: 'Citra Lestari',
          age: 28,
          gender: 'Wanita',
          caseCount: 1,
          lastSessionLabel: 'Last session 5 hari lalu',
          accent: Color(0xFFD9C7FF),
        ),
        PsychologistClientPreview(
          name: 'Dewi Anggraini',
          age: 22,
          gender: 'Wanita',
          caseCount: 1,
          lastSessionLabel: 'Belum ada session',
          accent: Color(0xFFFFD6E9),
        ),
        PsychologistClientPreview(
          name: 'Fajar Nugroho',
          age: 27,
          gender: 'Pria',
          caseCount: 1,
          lastSessionLabel: 'Last session 1 minggu lalu',
          accent: Color(0xFFBFE3FF),
        ),
      ];

  static const List<PsychologistCasePreview> activeCases =
      <PsychologistCasePreview>[
        PsychologistCasePreview(
          clientName: 'Andi Saputra',
          topic: 'Anxiety',
          sessionCount: 3,
          statusLabel: 'On Progress',
          statusTone: Color(0xFFFFA450),
        ),
        PsychologistCasePreview(
          clientName: 'Budi Santoso',
          topic: 'Burnout',
          sessionCount: 1,
          statusLabel: 'New',
          statusTone: Color(0xFFFF5DAF),
        ),
        PsychologistCasePreview(
          clientName: 'Citra Lestari',
          topic: 'Low Self-Esteem',
          sessionCount: 2,
          statusLabel: 'On Progress',
          statusTone: Color(0xFFFFA450),
        ),
        PsychologistCasePreview(
          clientName: 'Dewi Anggraini',
          topic: 'Relationship Issue',
          sessionCount: 1,
          statusLabel: 'New',
          statusTone: Color(0xFFFF5DAF),
        ),
      ];

  static const List<PsychologistCasePreview> completedCases =
      <PsychologistCasePreview>[
        PsychologistCasePreview(
          clientName: 'Rina Permata',
          topic: 'Work Stress',
          sessionCount: 5,
          statusLabel: 'Done',
          statusTone: Color(0xFF30B990),
        ),
        PsychologistCasePreview(
          clientName: 'Ilham Prakoso',
          topic: 'Parenting',
          sessionCount: 4,
          statusLabel: 'Done',
          statusTone: Color(0xFF30B990),
        ),
      ];

  static const List<PsychologistSessionPreview> caseSessions =
      <PsychologistSessionPreview>[
        PsychologistSessionPreview(
          title: 'Session 1',
          dateLabel: '6 Mei 2024',
          statusLabel: 'Done',
          statusTone: Color(0xFF30B990),
        ),
        PsychologistSessionPreview(
          title: 'Session 2',
          dateLabel: '10 Mei 2024',
          statusLabel: 'Done',
          statusTone: Color(0xFF30B990),
        ),
        PsychologistSessionPreview(
          title: 'Session 3',
          dateLabel: '14 Mei 2024',
          statusLabel: 'Upcoming',
          statusTone: Color(0xFFFF5DAF),
        ),
      ];

  static const List<String> interventions = <String>[
    'Cognitive Behavioral Therapy (CBT)',
    'Psychoeducation',
    'Relaxation Technique',
    'Mindfulness',
    'Problem Solving',
    'Lainnya',
  ];

  static const List<String> selectedInterventions = <String>[
    'Cognitive Behavioral Therapy (CBT)',
    'Psychoeducation',
    'Mindfulness',
  ];

  static const Map<String, List<PsychologistNotificationPreview>>
  notifications = <String, List<PsychologistNotificationPreview>>{
    'Hari ini': <PsychologistNotificationPreview>[
      PsychologistNotificationPreview(
        title: 'Pengingat Session',
        message: 'Anda memiliki session dengan Andi Saputra jam 10:00',
        timeLabel: '08:00',
        icon: Icons.notifications_active_rounded,
        accent: Color(0xFFFFA450),
      ),
      PsychologistNotificationPreview(
        title: 'Case Baru',
        message: 'Case baru Budi Santoso telah ditambahkan',
        timeLabel: '07:30',
        icon: Icons.note_add_rounded,
        accent: Color(0xFFFF4E98),
      ),
    ],
    'Kemarin': <PsychologistNotificationPreview>[
      PsychologistNotificationPreview(
        title: 'Session Selesai',
        message: 'Session dengan Andi Saputra telah selesai',
        timeLabel: '15:20',
        icon: Icons.check_circle_rounded,
        accent: Color(0xFF30B990),
      ),
      PsychologistNotificationPreview(
        title: 'Catatan Diupdate',
        message: 'Catatan session Citra Lestari telah diperbarui',
        timeLabel: '12:10',
        icon: Icons.edit_note_rounded,
        accent: Color(0xFFFF4E98),
      ),
    ],
  };
}
