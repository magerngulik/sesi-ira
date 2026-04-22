import 'package:flutter/material.dart';

class MultiSelectOption<T> {
  const MultiSelectOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final T value;
  final String label;
  final IconData icon;
  final Color color;
}

class MultiSelectChipGroup<T> extends StatelessWidget {
  const MultiSelectChipGroup({
    required this.options,
    required this.selectedValues,
    required this.onChanged,
    super.key,
  });

  final List<MultiSelectOption<T>> options;
  final Set<T> selectedValues;
  final ValueChanged<Set<T>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final isSelected = selectedValues.contains(option.value);

        return InkWell(
          onTap: () => _toggle(option.value),
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? option.color.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? option.color.withValues(alpha: 0.55)
                    : const Color(0xFFE1DBE6),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(option.icon, color: option.color, size: 20),
                const SizedBox(width: 8),
                Text(
                  option.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF1D1C2A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isSelected) ...<Widget>[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF2F9E73),
                    size: 18,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _toggle(T value) {
    final next = Set<T>.from(selectedValues);
    if (next.contains(value)) {
      next.remove(value);
    } else {
      next.add(value);
    }
    onChanged(next);
  }
}
