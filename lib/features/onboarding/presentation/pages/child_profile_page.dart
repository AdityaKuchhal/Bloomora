import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glassmorphism_app_bar.dart';
import '../providers/onboarding_provider.dart';
import '../../domain/models/child_model.dart';

class ChildProfilePageNew extends ConsumerStatefulWidget {
  const ChildProfilePageNew({super.key});

  @override
  ConsumerState<ChildProfilePageNew> createState() =>
      _ChildProfilePageNewState();
}

class _ChildProfilePageNewState extends ConsumerState<ChildProfilePageNew>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  // final _birthTimeController = TextEditingController(); // TODO: Uncomment if birth time is needed

  DateTime? _selectedDate;
  String _selectedGender = 'Girl';
  final List<String> _selectedDiagnoses = [];
  // final List<String> _selectedConcerns = []; // TODO: Uncomment if concerns are needed
  bool _isLoading = false;
  // bool _isPremature = false; // TODO: Uncomment if premature option is needed
  String _relationship = 'Mother';

  // Age calculation variables
  int? _childAgeInMonths;
  String? _ageGroup;
  bool _isAgeValid = true;

  late AnimationController _backgroundAnimationController;
  late AnimationController _formAnimationController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _formAnimation;

  final List<String> _genderOptions = ['Girl', 'Boy'];
  final List<String> _relationshipOptions = [
    'Mother',
    'Father',
    'Guardian',
    'Grandparent',
    'Other'
  ];

  final List<String> _diagnosisOptions = [
    'Autism Spectrum Disorder (ASD)',
    'Attention Deficit Hyperactivity Disorder (ADHD)',
    'Developmental Delay',
    'Speech Delay',
    'Motor Delay',
    'Sensory Processing Disorder',
    'Learning Disability',
    'None',
  ];

  // TODO: Uncomment if concerns are needed
  // final List<String> _concernOptions = [
  //   'Social Interaction',
  //   'Communication',
  //   'Behavior',
  //   'Learning',
  //   'Motor Skills',
  //   'Sensory Issues',
  //   'Sleep Problems',
  //   'Eating Issues',
  //   'None',
  // ];

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundAnimationController,
      curve: Curves.linear,
    ));

    _formAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _formAnimationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    // _birthTimeController.dispose(); // TODO: Uncomment if birth time is needed
    _backgroundAnimationController.dispose();
    _formAnimationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 6)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E3A8A), // Sophisticated muted green
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _calculateAge();
      });
    }
  }

  void _calculateAge() {
    if (_selectedDate == null) return;

    final now = DateTime.now();
    final ageInMonths = ((now.year - _selectedDate!.year) * 12) +
        (now.month - _selectedDate!.month);

    setState(() {
      _childAgeInMonths = ageInMonths;

      if (ageInMonths >= 12 && ageInMonths < 24) {
        _ageGroup = '1-2 years';
        _isAgeValid = true;
      } else if (ageInMonths >= 24 && ageInMonths < 36) {
        _ageGroup = '2-3 years';
        _isAgeValid = true;
      } else if (ageInMonths >= 36 && ageInMonths < 48) {
        _ageGroup = '3-4 years';
        _isAgeValid = true;
      } else if (ageInMonths >= 48 && ageInMonths < 60) {
        _ageGroup = '4-5 years';
        _isAgeValid = true;
      } else {
        _ageGroup = null;
        _isAgeValid = false;
      }
    });
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select your child\'s date of birth'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
      return;
    }

    // Check age validity
    if (!_isAgeValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'We currently only provide services for children aged 1-5 years'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Use calculated age group
      final ageGroup = _ageGroup!.replaceAll(' years', '');

      // Create child model
      final child = ChildModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        parentId: 'parent_id', // TODO: Get from parent data
        name: _nameController.text.trim(),
        dateOfBirth: _selectedDate!,
        birthTime: null, // TODO: Add birth time if needed
        gender: _selectedGender,
        ageGroup: ageGroup,
        existingDiagnoses: _selectedDiagnoses,
        concerns: [], // TODO: Add concerns if needed
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save child data
      ref.read(childNotifierProvider.notifier).setChild(child);

      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Navigate to email verification for parent authentication
      if (mounted) {
        context.go('/email-verification');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScrollableGlassmorphismAppBar(
      title: '',
      showAppName: true,
      leading: GestureDetector(
        onTap: () => context.go('/intro'),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF000000), // Black
              size: 20,
            ),
          ),
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC), // Light blue-gray background
        ),
        child: AnimatedBuilder(
          animation: _backgroundAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: _BackgroundPainter(_backgroundAnimation.value),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: AnimatedBuilder(
                  animation: _formAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - _formAnimation.value)),
                      child: Opacity(
                        opacity: _formAnimation.value.clamp(0.0, 1.0),
                        child: _buildChildProfileForm(context),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChildProfileForm(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          // Header Section
          _buildHeader(context),

          const SizedBox(height: 30),

          // Glassmorphism Form Container
          _buildGlassmorphismForm(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // Header text with glassmorphism effect
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.3),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            'To give you the best personalized experience tell us about your child',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF000000), // Black
              height: 1.4,
              fontWeight: FontWeight.w500,
              fontFamily: 'SF Pro Text',
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 30),

        // Add photo section with morphism
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  // TODO: Implement photo selection
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.3),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.child_care,
                          size: 40,
                          color: const Color(0xFF000000), // Black
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(
                                0xFF1E3A8A), // Sophisticated muted green
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Add photo',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666), // Soft gray
                  fontWeight: FontWeight.w500,
                  fontFamily: 'SF Pro Text',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGlassmorphismForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.3),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // First name field
            _buildGlassmorphismTextField(
              controller: _nameController,
              label: 'First name Or nickname',
              hint: 'First name Or nickname',
              prefixIcon: Icons.sentiment_satisfied_alt,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your child\'s name';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Date of birth field
            _buildDateOfBirthField(),

            const SizedBox(height: 20),

            // Gender selection with morphism
            _buildGenderSection(),

            const SizedBox(height: 20),

            // Relationship dropdown
            _buildRelationshipField(),

            const SizedBox(height: 24),

            // Existing Diagnoses
            _buildMultiSelectSection(
              title: 'Existing Diagnoses (if any)',
              options: _diagnosisOptions,
              selectedOptions: _selectedDiagnoses,
              onChanged: (selected) {
                setState(() {
                  _selectedDiagnoses.clear();
                  _selectedDiagnoses.addAll(selected);
                });
              },
            ),

            // TODO: Uncomment these sections if needed in the future
            // const SizedBox(height: 20),
            //
            // // Birth Time Field (Optional)
            // _buildGlassmorphismTextField(
            //   controller: _birthTimeController,
            //   label: 'Birth Time (Optional)',
            //   hint: 'HH:MM AM/PM',
            //   prefixIcon: Icons.access_time_rounded,
            // ),
            //
            // const SizedBox(height: 20),
            //
            // // Premature checkbox with morphism
            // _buildPrematureCheckbox(),
            //
            // const SizedBox(height: 24),
            //
            // // Current Concerns
            // _buildMultiSelectSection(
            //   title: 'Areas of Concern',
            //   options: _concernOptions,
            //   selectedOptions: _selectedConcerns,
            //   onChanged: (selected) {
            //     setState(() {
            //       _selectedConcerns.clear();
            //       _selectedConcerns.addAll(selected);
            //     });
            //   },
            // ),

            const SizedBox(height: 32),

            // Continue Button
            _buildNeumorphismButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: const TextStyle(
            color: Color(0xFF000000), // Black
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'SF Pro Text',
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: _genderOptions.map((gender) {
            final isSelected = _selectedGender == gender;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGender = gender;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected
                        ? const Color(0xFF1E3A8A) // Sophisticated muted green
                        : Colors.white.withOpacity(0.3),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1E3A8A) // Sophisticated muted green
                          : Colors.white.withOpacity(0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        gender == 'Girl' ? Icons.face_2 : Icons.face,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF666666), // Soft gray
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        gender,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF666666), // Soft gray
                          fontWeight: FontWeight.w500,
                          fontFamily: 'SF Pro Text',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGlassmorphismTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF000000), // Black
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'SF Pro Text',
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFFAFAFA), // Crisp light gray background
            border: Border.all(
              color: const Color(0xFFD1D5DB), // Cleaner gray border
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            validator: validator,
            style: const TextStyle(
              color: Color(0xFF000000), // Black
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'SF Pro Text',
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF666666), // Soft gray
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontFamily: 'SF Pro Text',
              ),
              prefixIcon: Icon(
                prefixIcon,
                color: const Color(0xFF1E3A8A), // Sophisticated muted green
                size: 22,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateOfBirthField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of Birth',
          style: const TextStyle(
            color: Color(0xFF000000), // Black
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'SF Pro Text',
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFFAFAFA), // Crisp light gray background
              border: Border.all(
                color: const Color(0xFFD1D5DB), // Cleaner gray border
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: const Color(0xFF1E3A8A), // Sophisticated muted green
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'Select your child\'s date of birth',
                      style: TextStyle(
                        color: _selectedDate != null
                            ? const Color(0xFF000000) // Black
                            : const Color(0xFF666666), // Soft gray
                        fontSize: 16,
                        fontWeight: _selectedDate != null
                            ? FontWeight.w500
                            : FontWeight.w400,
                        fontFamily: 'SF Pro Text',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Age Display with morphism
        if (_selectedDate != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: _isAgeValid
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              border: Border.all(
                color: _isAgeValid
                    ? Colors.green.withOpacity(0.3)
                    : Colors.red.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isAgeValid ? Icons.check_circle : Icons.warning,
                  color: _isAgeValid ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isAgeValid
                        ? 'Age: ${_childAgeInMonths! ~/ 12} years ${_childAgeInMonths! % 12} months (${_ageGroup!})'
                        : 'We currently only provide services for children aged 1-5 years',
                    style: TextStyle(
                      color: _isAgeValid ? Colors.green[700] : Colors.red[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'SF Pro Text',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // TODO: Uncomment if premature option is needed
  // Widget _buildPrematureCheckbox() {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(12),
  //       color: Colors.white.withOpacity(0.1),
  //       border: Border.all(
  //         color: Colors.white.withOpacity(0.2),
  //         width: 1,
  //       ),
  //     ),
  //     child: Row(
  //       children: [
  //         Transform.scale(
  //           scale: 1.2,
  //           child: Checkbox(
  //             value: _isPremature,
  //             onChanged: (value) {
  //               setState(() {
  //                 _isPremature = value ?? false;
  //               });
  //             },
  //             activeColor: const Color(0xFF6C63FF),
  //             checkColor: Colors.white,
  //             side: BorderSide(
  //               color: Colors.white.withOpacity(0.5),
  //               width: 2,
  //             ),
  //           ),
  //         ),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: Text(
  //             'Baby born prematurely',
  //             style: TextStyle(
  //               fontSize: 16,
  //               color: Colors.white.withOpacity(0.9),
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildRelationshipField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I am the child\'s',
          style: const TextStyle(
            color: Color(0xFF000000), // Black
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'SF Pro Text',
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFFAFAFA), // Crisp light gray background
            border: Border.all(
              color: const Color(0xFFD1D5DB), // Cleaner gray border
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: _relationship,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            ),
            style: const TextStyle(
              color: Color(0xFF000000), // Black
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'SF Pro Text',
            ),
            dropdownColor: Colors.white,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF1E3A8A),
              size: 20,
            ),
            menuMaxHeight: 200,
            isExpanded: true,
            items: _relationshipOptions.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'SF Pro Text',
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _relationship = newValue!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: icon != null
                  ? Icon(
                      icon,
                      color: Colors.grey[400],
                      size: 20,
                    )
                  : null,
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 16,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelectSection({
    required String title,
    required List<String> options,
    required List<String> selectedOptions,
    required Function(List<String>) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF000000), // Black
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'SF Pro Text',
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedOptions.contains(option);
            return GestureDetector(
              onTap: () {
                final newSelected = List<String>.from(selectedOptions);
                if (isSelected) {
                  newSelected.remove(option);
                } else {
                  newSelected.add(option);
                }
                onChanged(newSelected);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isSelected
                      ? const Color(0xFF1E3A8A) // Sophisticated muted green
                      : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF1E3A8A) // Sophisticated muted green
                        : const Color(0xFFE5E5E5), // Clean light gray border
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : const Color(
                            0xFF333333), // Darker gray for better readability
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontFamily: 'SF Pro Text',
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNeumorphismButton(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF1E3A8A), // Sophisticated muted green
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _isLoading ? null : _handleContinue,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _isLoading
                  ? const Color(0xFF1E3A8A).withOpacity(
                      0.7) // Sophisticated muted green with opacity
                  : const Color(0xFF1E3A8A), // Sophisticated muted green
            ),
            child: Center(
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Continue to Parent Signup',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        fontFamily: 'SF Pro Text',
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double animationValue;

  _BackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Subtle floating circles for morphism effect
    for (int i = 0; i < 3; i++) {
      final circleX = (size.width * 0.3 * (i + 1)) +
          (30 * (i + 1) * (animationValue * 2 - 1));
      final circleY = (size.height * 0.3 * (i + 1)) +
          (20 * (i + 1) * (animationValue * 2 - 1));
      final radius = 60 + (15 * i) + (8 * (animationValue * 2 - 1));

      canvas.drawCircle(
        Offset(circleX, circleY),
        radius,
        Paint()
          ..color = const Color(0xFF3B82F6)
              .withOpacity(0.08) // Light blue with very low opacity
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
