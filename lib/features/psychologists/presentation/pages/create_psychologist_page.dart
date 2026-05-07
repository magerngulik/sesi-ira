import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/error/app_exception.dart';
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
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _countryCodes = const <String>['+62', '+60', '+65'];

  late Future<List<SpecializationModel>> _specializationsFuture;
  Set<String> _selectedSpecializations = <String>{};
  String _selectedCountryCode = '+62';
  XFile? _profileImage;
  XFile? _bannerImage;
  bool _isSubmitting = false;
  bool _createLoginAccount = false;
  bool _obscureLoginPassword = true;

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
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
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
                        const SizedBox(height: 18),
                        _LoginAccountCard(
                          value: _createLoginAccount,
                          loginEmailController: _loginEmailController,
                          loginPasswordController: _loginPasswordController,
                          obscurePassword: _obscureLoginPassword,
                          onChanged: (value) {
                            setState(() {
                              _createLoginAccount = value;
                              if (value &&
                                  _loginEmailController.text.trim().isEmpty) {
                                _loginEmailController.text = _emailController
                                    .text
                                    .trim();
                              }
                            });
                          },
                          onTogglePasswordVisibility: () {
                            setState(() {
                              _obscureLoginPassword = !_obscureLoginPassword;
                            });
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
        loginAccount: _createLoginAccount
            ? PsychologistLoginAccountInput(
                email: _loginEmailController.text,
                password: _loginPasswordController.text,
              )
            : null,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              _createLoginAccount
                  ? 'Psikolog baru berhasil ditambahkan dan akun login sudah dibuat.'
                  : 'Psikolog baru berhasil ditambahkan tanpa akun login.',
            ),
          ),
        );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(_formatSubmitError(error))));
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

  String _formatSubmitError(Object error) {
    if (error is AppException) {
      return error.message;
    }

    final text = error.toString().trim();
    if (text.startsWith('Exception: ')) {
      return text.substring('Exception: '.length);
    }

    return 'Gagal menambahkan psikolog: $text';
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

class _LoginAccountCard extends StatelessWidget {
  const _LoginAccountCard({
    required this.value,
    required this.loginEmailController,
    required this.loginPasswordController,
    required this.obscurePassword,
    required this.onChanged,
    required this.onTogglePasswordVisibility,
  });

  final bool value;
  final TextEditingController loginEmailController;
  final TextEditingController loginPasswordController;
  final bool obscurePassword;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTogglePasswordVisibility;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE1DBE6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Akun Login Psikolog',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1D1C2A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value
                          ? 'Akun login akan dibuat bersamaan dengan data psikolog.'
                          : 'Kalau belum dicentang, sistem hanya menyimpan profil psikolog tanpa akses login.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6D6A79),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Switch(value: value, onChanged: onChanged),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: value ? const Color(0xFFEEF7F3) : const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              value
                  ? 'Admin sedang membuat akun login awal untuk psikolog ini. Simpan password awal dengan aman karena psikolog akan memakainya untuk login pertama.'
                  : 'Tindakan berikutnya kalau akun belum dibuat: data psikolog tetap masuk, tapi psikolog belum bisa login sampai admin membuatkan akun di tahap berikutnya.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF475467),
                height: 1.45,
              ),
            ),
          ),
          if (value) ...<Widget>[
            const SizedBox(height: 16),
            const FormSectionLabel('Email Login *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: loginEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Masukkan email login psikolog',
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return 'Email login wajib diisi.';
                }
                if (!trimmed.contains('@')) {
                  return 'Format email login belum valid.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            const FormSectionLabel('Password Awal *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: loginPasswordController,
              obscureText: obscurePassword,
              decoration: InputDecoration(
                hintText: 'Minimal 6 karakter',
                suffixIcon: IconButton(
                  onPressed: onTogglePasswordVisibility,
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return 'Password awal wajib diisi.';
                }
                if (trimmed.length < 6) {
                  return 'Password awal minimal 6 karakter.';
                }
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }
}
