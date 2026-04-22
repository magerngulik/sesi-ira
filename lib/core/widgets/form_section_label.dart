import 'package:flutter/material.dart';

class FormSectionLabel extends StatelessWidget {
  const FormSectionLabel(
    this.title, {
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D1C2A),
          ),
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...<Widget>[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6D6A79),
            ),
          ),
        ],
      ],
    );
  }
}
