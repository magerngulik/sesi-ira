import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/app_form_fields.dart';
import '../../../../core/widgets/form_section_label.dart';
import '../../data/repositories/clients_repository.dart';

class CreateClientPage extends StatefulWidget {
  const CreateClientPage({super.key});

  static const String name = 'create-client';
  static const String path = '/clients/create';

  @override
  State<CreateClientPage> createState() => _CreateClientPageState();
}

class _CreateClientPageState extends State<CreateClientPage> {
  static const List<String> _genderOptions = <String>['Laki-laki', 'Perempuan'];
  static const List<String> _educationOptions = <String>[
    'SD',
    'SMP',
    'SMA',
    'S1',
    'S2',
    'S3',
  ];
  static const List<String> _maritalStatusOptions = <String>[
    'Belum Menikah',
    'Menikah',
    'Janda/Duda',
  ];
  static const List<String> _occupationOptions = <String>[
    'Pelajar',
    'Mahasiswa',
    'Karyawan',
    'Wiraswasta',
    'Ibu Rumah Tangga',
    'Guru',
    'Dokter',
    'PNS',
    'Freelancer',
    'Lainnya',
  ];
  static const String _occupationOtherOption = 'Lainnya';
  static const String _studentNoOption = 'No';
  static const String _studentYesOption = 'Yes';

  final ClientsRepository _repository = const ClientsRepository();
  final _formKey = GlobalKey<FormState>();
  final _displayDateFormat = DateFormat('dd MMM yyyy');
  final _submitDateFormat = DateFormat('yyyy-MM-dd');
  final _fullNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _nikController = TextEditingController();
  final _birthOrderController = TextEditingController();
  final _occupationOtherController = TextEditingController();
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactPhoneController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedGender;
  DateTime? _selectedBirthDate;
  String? _selectedLastEducation;
  String? _selectedMaritalStatus;
  String? _selectedOccupation;
  bool _isStudent = false;
  bool _guardianSameAsEmergencyContact = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _emergencyContactNameController.addListener(
      _syncGuardianWithEmergencyContact,
    );
    _emergencyContactPhoneController.addListener(
      _syncGuardianWithEmergencyContact,
    );
  }

  @override
  void dispose() {
    _emergencyContactNameController.removeListener(
      _syncGuardianWithEmergencyContact,
    );
    _emergencyContactPhoneController.removeListener(
      _syncGuardianWithEmergencyContact,
    );
    _fullNameController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _nikController.dispose();
    _birthOrderController.dispose();
    _occupationOtherController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Data Klien Baru')),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFFF4F7F3), Color(0xFFE9F3F1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FBF9),
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
                          'Lengkapi biodata dan informasi pendukung klien sebelum membuat case baru.',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF5D6F69),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 22),
                        const FormSectionLabel('Informasi Pribadi'),
                        const SizedBox(height: 12),
                        AppTextFormField(
                          controller: _fullNameController,
                          labelText: 'Nama lengkap',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nama lengkap wajib diisi.';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        AppDropdownFormField<String>(
                          labelText: 'Gender',
                          initialValue: _selectedGender,
                          items: _buildDropdownItems(_genderOptions),
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        AppDatePickerFormField(
                          controller: _birthDateController,
                          labelText: 'Tanggal lahir',
                          hintText: 'dd MMM yyyy',
                          onTap: _pickBirthDate,
                        ),
                        const SizedBox(height: 12),
                        AppPhoneNumberFormField(
                          controller: _phoneController,
                          labelText: 'No. HP',
                          required: true,
                        ),
                        const SizedBox(height: 12),
                        AppMultilineTextFormField(
                          controller: _addressController,
                          labelText: 'Alamat',
                          minLines: 2,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        AppTextFormField(
                          controller: _nikController,
                          labelText: 'NIK',
                          keyboardType: TextInputType.number,
                          maxLength: 16,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: _validateNik,
                        ),
                        const SizedBox(height: 20),
                        const FormSectionLabel('Informasi Tambahan'),
                        const SizedBox(height: 12),
                        AppTextFormField(
                          controller: _birthOrderController,
                          labelText: 'Urutan kelahiran',
                          hintText:
                              'Contoh: 1 untuk anak pertama, 2 untuk anak kedua',
                          keyboardType: TextInputType.number,
                          maxLength: 2,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: _validateBirthOrder,
                        ),
                        const SizedBox(height: 12),
                        AppDropdownFormField<String>(
                          labelText: 'Pendidikan terakhir',
                          initialValue: _selectedLastEducation,
                          items: _buildDropdownItems(_educationOptions),
                          onChanged: (value) {
                            setState(() {
                              _selectedLastEducation = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        AppDropdownFormField<String>(
                          labelText: 'Status pernikahan',
                          initialValue: _selectedMaritalStatus,
                          items: _buildDropdownItems(_maritalStatusOptions),
                          onChanged: (value) {
                            setState(() {
                              _selectedMaritalStatus = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        AppDropdownFormField<String>(
                          labelText: 'Pekerjaan',
                          initialValue: _selectedOccupation,
                          items: _buildDropdownItems(_occupationOptions),
                          onChanged: (value) {
                            setState(() {
                              _selectedOccupation = value;
                              if (value != _occupationOtherOption) {
                                _occupationOtherController.clear();
                              }
                            });
                          },
                        ),
                        if (_selectedOccupation ==
                            _occupationOtherOption) ...<Widget>[
                          const SizedBox(height: 12),
                          AppTextFormField(
                            controller: _occupationOtherController,
                            labelText: 'Masukkan pekerjaan',
                            validator: _validateOccupationOther,
                          ),
                        ],
                        const SizedBox(height: 20),
                        const FormSectionLabel('Kontak Darurat'),
                        const SizedBox(height: 12),
                        AppTextFormField(
                          controller: _emergencyContactNameController,
                          labelText: 'Nama kontak darurat',
                        ),
                        const SizedBox(height: 12),
                        AppPhoneNumberFormField(
                          controller: _emergencyContactPhoneController,
                          labelText: 'No. HP kontak darurat',
                        ),
                        const SizedBox(height: 20),
                        const FormSectionLabel('Anak Dalam Bimbingan'),
                        const SizedBox(height: 12),
                        AppDropdownFormField<String>(
                          labelText: 'Anak dalam bimbingan',
                          initialValue: _isStudent
                              ? _studentYesOption
                              : _studentNoOption,
                          items: _buildDropdownItems(const <String>[
                            _studentNoOption,
                            _studentYesOption,
                          ]),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }

                            final isStudent = value == _studentYesOption;
                            setState(() {
                              _isStudent = isStudent;
                              if (!isStudent) {
                                _guardianSameAsEmergencyContact = false;
                                _guardianNameController.clear();
                                _guardianPhoneController.clear();
                              }
                            });
                          },
                        ),
                        if (_isStudent) ...<Widget>[
                          const SizedBox(height: 12),
                          CheckboxListTile(
                            value: _guardianSameAsEmergencyContact,
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: const Text('Sama dengan kontak darurat'),
                            subtitle: const Text(
                              'Nama dan nomor HP wali akan diisi otomatis lalu dikunci.',
                            ),
                            onChanged: (value) {
                              setState(() {
                                _guardianSameAsEmergencyContact =
                                    value ?? false;
                                if (_guardianSameAsEmergencyContact) {
                                  _fillGuardianFromEmergencyContact();
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          AppTextFormField(
                            controller: _guardianNameController,
                            labelText: 'Nama wali',
                            validator: _validateGuardianName,
                            readOnly: _guardianSameAsEmergencyContact,
                          ),
                          const SizedBox(height: 12),
                          AppPhoneNumberFormField(
                            controller: _guardianPhoneController,
                            labelText: 'No. HP wali',
                            required: true,
                            emptyMessage: 'Nomor HP wali wajib diisi.',
                            readOnly: _guardianSameAsEmergencyContact,
                            validator: _validateGuardianPhone,
                          ),
                        ],
                        const SizedBox(height: 20),
                        const FormSectionLabel('Catatan'),
                        const SizedBox(height: 12),
                        AppMultilineTextFormField(
                          controller: _notesController,
                          labelText: 'Catatan',
                          minLines: 4,
                          maxLines: 6,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _isSubmitting ? null : _submit,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              _isSubmitting ? 'Menyimpan...' : 'Simpan Klien',
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

    final birthOrderValue = _birthOrderController.text.trim();
    final occupationValue = _selectedOccupation;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _repository.createClient(
        fullName: _fullNameController.text,
        gender: _selectedGender,
        birthDate: _selectedBirthDate == null
            ? null
            : _submitDateFormat.format(_selectedBirthDate!),
        phone: _phoneController.text,
        address: _addressController.text,
        nik: _nikController.text,
        birthOrder: birthOrderValue.isEmpty ? null : int.parse(birthOrderValue),
        lastEducation: _selectedLastEducation,
        maritalStatus: _selectedMaritalStatus,
        occupation: occupationValue,
        occupationOther: occupationValue == _occupationOtherOption
            ? _occupationOtherController.text
            : null,
        emergencyContactName: _emergencyContactNameController.text,
        emergencyContactPhone: _emergencyContactPhoneController.text,
        isStudent: _isStudent,
        guardianName: _isStudent ? _guardianNameController.text : null,
        guardianPhone: _isStudent ? _guardianPhoneController.text : null,
        notes: _notesController.text,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Klien baru berhasil ditambahkan.')),
        );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Gagal menambahkan klien: $error')),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initialDate =
        _selectedBirthDate ?? DateTime(now.year - 18, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _selectedBirthDate = pickedDate;
      _birthDateController.text = _displayDateFormat.format(pickedDate);
    });
  }

  List<DropdownMenuItem<String>> _buildDropdownItems(List<String> items) {
    return items
        .map((item) => DropdownMenuItem<String>(value: item, child: Text(item)))
        .toList();
  }

  String? _validateNik(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }

    if (trimmed.length != 16) {
      return 'NIK harus terdiri dari 16 digit';
    }

    return null;
  }

  String? _validateBirthOrder(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }

    final birthOrder = int.tryParse(trimmed);
    if (birthOrder == null) {
      return 'Urutan kelahiran hanya boleh berisi angka.';
    }

    if (birthOrder < 1 || birthOrder > 99) {
      return 'Urutan kelahiran harus antara 1 dan 99.';
    }

    return null;
  }

  String? _validateOccupationOther(String? value) {
    if (_selectedOccupation != _occupationOtherOption) {
      return null;
    }

    if (value == null || value.trim().isEmpty) {
      return 'Pekerjaan wajib diisi.';
    }

    return null;
  }

  String? _validateGuardianName(String? value) {
    if (!_isStudent) {
      return null;
    }

    if (_guardianSameAsEmergencyContact &&
        _emergencyContactNameController.text.trim().isEmpty) {
      return 'Nama kontak darurat wajib diisi jika menggunakan data yang sama.';
    }

    if (value == null || value.trim().isEmpty) {
      return 'Nama wali wajib diisi.';
    }

    return null;
  }

  String? _validateGuardianPhone(String? value) {
    if (!_isStudent) {
      return null;
    }

    if (_guardianSameAsEmergencyContact &&
        _emergencyContactPhoneController.text.trim().isEmpty) {
      return 'Nomor kontak darurat wajib diisi jika menggunakan data yang sama.';
    }

    return validatePhoneNumber(
      value,
      required: true,
      emptyMessage: 'Nomor HP wali wajib diisi.',
    );
  }

  void _syncGuardianWithEmergencyContact() {
    if (!_guardianSameAsEmergencyContact) {
      return;
    }

    _fillGuardianFromEmergencyContact();
  }

  void _fillGuardianFromEmergencyContact() {
    _guardianNameController.text = _emergencyContactNameController.text;
    _guardianPhoneController.text = _emergencyContactPhoneController.text;
  }
}
