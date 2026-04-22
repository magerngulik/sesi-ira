import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    required this.controller,
    required this.labelText,
    super.key,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.inputFormatters,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      inputFormatters: inputFormatters,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        suffixIcon: suffixIcon,
        counterText: maxLength == null ? null : '',
      ),
    );
  }
}

class AppDropdownFormField<T> extends StatelessWidget {
  const AppDropdownFormField({
    required this.labelText,
    required this.items,
    super.key,
    this.initialValue,
    this.hintText,
    this.onChanged,
    this.validator,
  });

  final String labelText;
  final List<DropdownMenuItem<T>> items;
  final T? initialValue;
  final String? hintText;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: initialValue,
      items: items,
      onChanged: onChanged,
      validator: validator,
      isExpanded: true,
      decoration: InputDecoration(labelText: labelText, hintText: hintText),
    );
  }
}

class AppDatePickerFormField extends StatelessWidget {
  const AppDatePickerFormField({
    required this.controller,
    required this.labelText,
    required this.onTap,
    super.key,
    this.hintText,
    this.validator,
  });

  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final VoidCallback onTap;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return AppTextFormField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      readOnly: true,
      onTap: onTap,
      validator: validator,
      suffixIcon: const Icon(Icons.calendar_today_outlined),
    );
  }
}

class AppPhoneNumberFormField extends StatelessWidget {
  const AppPhoneNumberFormField({
    required this.controller,
    required this.labelText,
    super.key,
    this.hintText,
    this.required = false,
    this.emptyMessage = 'Nomor HP wajib diisi.',
    this.validator,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final bool required;
  final String emptyMessage;
  final String? Function(String?)? validator;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return AppTextFormField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      readOnly: readOnly,
      keyboardType: TextInputType.phone,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
      ],
      validator:
          validator ??
          (value) => validatePhoneNumber(
            value,
            required: required,
            emptyMessage: emptyMessage,
          ),
    );
  }
}

class AppMultilineTextFormField extends StatelessWidget {
  const AppMultilineTextFormField({
    required this.controller,
    required this.labelText,
    super.key,
    this.hintText,
    this.minLines = 2,
    this.maxLines = 4,
    this.validator,
  });

  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final int minLines;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return AppTextFormField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: TextInputType.multiline,
      validator: validator,
    );
  }
}

String? validatePhoneNumber(
  String? value, {
  bool required = false,
  String emptyMessage = 'Nomor HP wajib diisi.',
}) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return required ? emptyMessage : null;
  }

  if (!RegExp(r'^\+?\d+$').hasMatch(trimmed)) {
    return 'Nomor HP hanya boleh berisi angka.';
  }

  if (!trimmed.startsWith('0') && !trimmed.startsWith('+62')) {
    return 'Nomor HP harus diawali 0 atau +62.';
  }

  final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');
  if (digitsOnly.length < 10 || digitsOnly.length > 15) {
    return 'Nomor HP harus terdiri dari 10-15 digit.';
  }

  return null;
}
