import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerPlaceholderField extends StatefulWidget {
  const ImagePickerPlaceholderField({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onChanged,
    this.file,
    this.isCircular = false,
    this.source = ImageSource.gallery,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final XFile? file;
  final bool isCircular;
  final ImageSource source;
  final ValueChanged<XFile?> onChanged;

  @override
  State<ImagePickerPlaceholderField> createState() =>
      _ImagePickerPlaceholderFieldState();
}

class _ImagePickerPlaceholderFieldState
    extends State<ImagePickerPlaceholderField> {
  final ImagePicker _picker = ImagePicker();
  bool _isPicking = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isPicking ? null : _pickImage,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE3DCE8)),
          ),
          child: Column(
            children: <Widget>[
              _PickerPreview(
                file: widget.file,
                icon: widget.icon,
                isCircular: widget.isCircular,
                isLoading: _isPicking,
              ),
              const SizedBox(height: 14),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1D1C2A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF7F7A8E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    setState(() {
      _isPicking = true;
    });

    try {
      final file = await _picker.pickImage(source: widget.source);
      widget.onChanged(file);
    } finally {
      if (mounted) {
        setState(() {
          _isPicking = false;
        });
      }
    }
  }
}

class _PickerPreview extends StatelessWidget {
  const _PickerPreview({
    required this.file,
    required this.icon,
    required this.isCircular,
    required this.isLoading,
  });

  final XFile? file;
  final IconData icon;
  final bool isCircular;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final borderRadius = isCircular ? null : BorderRadius.circular(18);

    return Container(
      width: isCircular ? 92 : double.infinity,
      height: 92,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F2F8),
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: borderRadius,
        border: Border.all(color: const Color(0xFFD9D2E1)),
      ),
      child: file != null
          ? Image.file(
              File(file!.path),
              fit: BoxFit.cover,
            )
          : Center(
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(icon, color: const Color(0xFFA6A1B7), size: 36),
            ),
    );
  }
}
