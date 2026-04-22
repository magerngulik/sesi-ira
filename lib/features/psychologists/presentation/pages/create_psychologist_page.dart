import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/widgets/form_section_label.dart';
import '../../../../core/widgets/image_picker_placeholder_field.dart';
import '../../../../core/widgets/multi_select_chip_group.dart';
import '../../data/models/specialization_model.dart';
import '../../data/repositories/psychologists_repository.dart';
import '../helpers/specialization_option_helper.dart';

class CreatePsychologistPage extends StatefulWidget {
  const CreatePsychologistPage({super.key});

  static const String name = 'create-psychologist';
  static const String path = '/psychologists/create';

  @override
  State<CreatePsychologistPage> createState() => _CreatePsychologistPageState();
}

class _CreatePsychologistPageState extends State<CreatePsychologistPage> {
  final PsychologistsRepository _repository = const PsychologistsRepository();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();
  final _countryCodes = const <String>['+62', '+60', '+65'];

  late Future<List<SpecializationModel>> _specializationsFuture;
  Set<String> _selectedSpecializations = <String>{};
  String _selectedCountryCode = '+62';
  XFile? _profileImage;
  XFile? _bannerImage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _specializationsFuture = _repository.fetchSpecializations();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Psychologist')),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFFF7F3F8), Color(0xFFF3F6FB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F4F9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 28,
                        offset: Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Fill out the form below to add a new psychologist to the platform.',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF6D6A79),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: ImagePickerPlaceholderField(
                                title: 'Upload Profile Picture',
                                subtitle: '1600 x 900px',
                                icon: Icons.camera_alt_rounded,
                                isCircular: true,
                                file: _profileImage,
                                onChanged: (file) {
                                  setState(() {
                                    _profileImage = file;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ImagePickerPlaceholderField(
                                title: 'Upload Banner Image',
                                subtitle: '800 x 800px',
                                icon: Icons.image_outlined,
                                file: _bannerImage,
                                onChanged: (file) {
                                  setState(() {
                                    _bannerImage = file;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const FormSectionLabel('Full Name *'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: 'Enter full name',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nama psikolog wajib diisi.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        const FormSectionLabel('Email Address *'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'Enter email address',
                          ),
                          validator: (value) {
                            final trimmed = value?.trim() ?? '';
                            if (trimmed.isEmpty) {
                              return 'Email wajib diisi.';
                            }
                            if (!trimmed.contains('@')) {
                              return 'Format email belum valid.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        const FormSectionLabel('Phone Number *'),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              width: 110,
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedCountryCode,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 18,
                                  ),
                                ),
                                items: _countryCodes.map((code) {
                                  return DropdownMenuItem<String>(
                                    value: code,
                                    child: Text(code),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value == null) {
                                    return;
                                  }

                                  setState(() {
                                    _selectedCountryCode = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  hintText: 'Enter phone number',
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Nomor HP wajib diisi.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const FormSectionLabel('Notes'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _notesController,
                          minLines: 1,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Additional notes or details (optional)',
                          ),
                        ),
                        const SizedBox(height: 18),
                        const FormSectionLabel(
                          'Specializations',
                          subtitle: 'Select all applicable specializations',
                        ),
                        const SizedBox(height: 14),
                        FutureBuilder<List<SpecializationModel>>(
                          future: _specializationsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const _SpecializationStateCard(
                                child: SizedBox(
                                  height: 72,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return _SpecializationStateCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Gagal memuat daftar spesialisasi.',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            color: const Color(0xFF1D1C2A),
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${snapshot.error}',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: const Color(0xFF6D6A79),
                                          ),
                                    ),
                                    const SizedBox(height: 14),
                                    OutlinedButton.icon(
                                      onPressed: _reloadSpecializations,
                                      icon: const Icon(Icons.refresh_rounded),
                                      label: const Text('Coba lagi'),
                                    ),
                                  ],
                                ),
                              );
                            }

                            final specializations =
                                snapshot.data ?? <SpecializationModel>[];
                            if (specializations.isEmpty) {
                              return _SpecializationStateCard(
                                child: Text(
                                  'Belum ada data spesialisasi di Supabase.',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: const Color(0xFF6D6A79),
                                  ),
                                ),
                              );
                            }

                            final options = specializations
                                .map(SpecializationOptionHelper.toOption)
                                .toList();
                            final availableIds = options
                                .map((option) => option.value)
                                .toSet();
                            final selectedValues = _selectedSpecializations
                                .intersection(availableIds);

                            return MultiSelectChipGroup<String>(
                              options: options,
                              selectedValues: selectedValues,
                              onChanged: (values) {
                                setState(() {
                                  _selectedSpecializations = values;
                                });
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _isSubmitting ? null : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF2F7B63),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              _isSubmitting
                                  ? 'Menyimpan...'
                                  : 'Add Psychologist',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _repository.createPsychologist(
        name: _nameController.text,
        specializationIds: _selectedSpecializations.toList(),
        phone: '$_selectedCountryCode ${_phoneController.text.trim()}',
        email: _emailController.text,
        notes: _notesController.text,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Psikolog baru berhasil ditambahkan.')),
        );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Gagal menambahkan psikolog: $error')),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _reloadSpecializations() {
    setState(() {
      _specializationsFuture = _repository.fetchSpecializations();
    });
  }
}

class _SpecializationStateCard extends StatelessWidget {
  const _SpecializationStateCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE1DBE6)),
      ),
      child: child,
    );
  }
}
