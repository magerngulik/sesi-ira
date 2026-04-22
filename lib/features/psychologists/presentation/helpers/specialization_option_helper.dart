import 'package:flutter/material.dart';

import '../../../../core/widgets/multi_select_chip_group.dart';
import '../../data/models/specialization_model.dart';

class SpecializationOptionHelper {
  const SpecializationOptionHelper._();

  static MultiSelectOption<String> toOption(
    SpecializationModel specialization,
  ) {
    return MultiSelectOption<String>(
      value: specialization.id,
      label: specialization.name,
      icon: iconForKey(specialization.iconKey),
      color: colorForKey(specialization.iconKey),
    );
  }

  static IconData iconForKey(String iconKey) {
    switch (iconKey) {
      case 'anxiety':
        return Icons.check_circle_rounded;
      case 'depression':
        return Icons.cloud_rounded;
      case 'burnout':
        return Icons.local_fire_department_rounded;
      case 'overthinking':
        return Icons.psychology_alt_rounded;
      case 'self_improvement':
        return Icons.auto_awesome_rounded;
      case 'trauma':
        return Icons.favorite_rounded;
      case 'stress_management':
        return Icons.nights_stay_rounded;
      case 'sleep_disorder':
        return Icons.bedtime_rounded;
      case 'relationship':
        return Icons.handshake_rounded;
      case 'family':
        return Icons.groups_rounded;
      case 'career':
        return Icons.work_rounded;
      case 'parenting':
        return Icons.child_care_rounded;
      case 'self_esteem':
        return Icons.sentiment_satisfied_alt_rounded;
      case 'loneliness':
        return Icons.person_outline_rounded;
      case 'grief':
        return Icons.heart_broken_rounded;
      default:
        return Icons.psychology_rounded;
    }
  }

  static Color colorForKey(String iconKey) {
    switch (iconKey) {
      case 'anxiety':
        return const Color(0xFFF5B94A);
      case 'depression':
        return const Color(0xFF60A5FA);
      case 'burnout':
        return const Color(0xFFF97316);
      case 'overthinking':
        return const Color(0xFF7C83FD);
      case 'self_improvement':
        return const Color(0xFF2F9E73);
      case 'trauma':
        return const Color(0xFFCC5B76);
      case 'stress_management':
        return const Color(0xFF60A5FA);
      case 'sleep_disorder':
        return const Color(0xFF4F46E5);
      case 'relationship':
        return const Color(0xFF9CA3AF);
      case 'family':
        return const Color(0xFF8B5CF6);
      case 'career':
        return const Color(0xFF9CA3AF);
      case 'parenting':
        return const Color(0xFF14B8A6);
      case 'self_esteem':
        return const Color(0xFFE879F9);
      case 'loneliness':
        return const Color(0xFF64748B);
      case 'grief':
        return const Color(0xFFB45309);
      default:
        return const Color(0xFF2F7B63);
    }
  }
}
