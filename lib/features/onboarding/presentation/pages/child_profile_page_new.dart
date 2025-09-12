import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
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
  final _birthTimeController = TextEditingController();

  DateTime? _selectedDate;
  String _selectedGender = 'Girl';
  final List<String> _selectedDiagnoses = [];
  final List<String> _selectedConcerns = [];
  bool _isLoading = false;
  bool _isPremature = false;
  String _relationship = 'Parent';

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
    'Parent',
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

  final List<String> _concernOptions = [
    'Social Interaction',
    'Communication',
    'Behavior',
    'Learning',
    'Motor Skills',
    'Sensory Issues',
    'Sleep Problems',
    'Eating Issues',
    'None',
  ];

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
    _birthTimeController.dispose();
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
              primary: Color(0xFF6C63FF),
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
        birthTime: _birthTimeController.text.trim().isEmpty
            ? null
            : _birthTimeController.text.trim(),
        gender: _selectedGender,
        ageGroup: ageGroup,
        existingDiagnoses: _selectedDiagnoses,
        concerns: _selectedConcerns,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save child data
      ref.read(childNotifierProvider.notifier).setChild(child);

      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Navigate to parent signup
      if (mounted) {
        context.go('/parent-signup');
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: _BackgroundPainter(_backgroundAnimation.value),
            child: SafeArea(
              child: Column(
                children: [
                  // Header with close button
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 20),
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
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChildProfileForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header text
          Center(
            child: Text(
              'To give you the best personalized experience tell us about your child',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 40),

          // Add photo section
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    // TODO: Implement photo selection
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[100],
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4ECDC4),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Add photo',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Gender selection
          Text(
            'Gender',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF6C63FF)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF6C63FF)
                            : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          gender == 'Girl' ? Icons.face : Icons.face_2,
                          color: isSelected ? Colors.white : Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          gender,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // First name field
          _buildTextField(
            label: 'First name Or nickname',
            controller: _nameController,
            hintText: 'First name Or nickname',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your child\'s name';
              }
              return null;
            },
            icon: Icons.sentiment_satisfied,
          ),

          const SizedBox(height: 24),

          // Date of birth field
          _buildDateField(),

          if (_selectedDate != null && _ageGroup != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF6C63FF).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.cake,
                    color: const Color(0xFF6C63FF),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Age: ${_childAgeInMonths! ~/ 12} years ${_childAgeInMonths! % 12} months (${_ageGroup!})',
                    style: TextStyle(
                      color: const Color(0xFF6C63FF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Premature checkbox
          Row(
            children: [
              Checkbox(
                value: _isPremature,
                onChanged: (value) {
                  setState(() {
                    _isPremature = value ?? false;
                  });
                },
                activeColor: const Color(0xFF6C63FF),
              ),
              Text(
                'Baby born prematurely',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Relationship dropdown
          _buildDropdownField(
            label: 'I am the child\'s',
            value: _relationship,
            items: _relationshipOptions,
            onChanged: (value) {
              setState(() {
                _relationship = value!;
              });
            },
            icon: Icons.person,
          ),

          const SizedBox(height: 40),

          // Diagnosis section
          _buildMultiSelectSection(
            title: 'Existing Diagnosis (if any)',
            options: _diagnosisOptions,
            selectedOptions: _selectedDiagnoses,
            onChanged: (selected) {
              setState(() {
                _selectedDiagnoses.clear();
                _selectedDiagnoses.addAll(selected);
              });
            },
          ),

          const SizedBox(height: 32),

          // Concerns section
          _buildMultiSelectSection(
            title: 'Areas of Concern',
            options: _concernOptions,
            selectedOptions: _selectedConcerns,
            onChanged: (selected) {
              setState(() {
                _selectedConcerns.clear();
                _selectedConcerns.addAll(selected);
              });
            },
          ),

          const SizedBox(height: 40),

          // Next button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isLoading ? Colors.grey[300] : const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'NEXT',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
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
          child: TextFormField(
            controller: controller,
            validator: validator,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
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
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of birth',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'Date of birth',
                      style: TextStyle(
                        color: _selectedDate != null
                            ? Colors.grey[800]
                            : Colors.grey[500],
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                ],
              ),
            ),
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
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
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color:
                      isSelected ? const Color(0xFF6C63FF) : Colors.grey[100],
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF6C63FF)
                        : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double animationValue;

  _BackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Create the wavy header background
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF6C63FF),
          const Color(0xFF4ECDC4),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.3));

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.25);

    // Create wavy bottom edge
    final waveHeight = 20.0;
    final waveLength = size.width / 4;
    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height * 0.25 +
          waveHeight *
              (animationValue * 2 - 1) *
              (0.5 + 0.5 * (x / size.width)) *
              (0.5 + 0.5 * (animationValue * 2 - 1));
      path.lineTo(x, y);
    }

    path.lineTo(0, size.height * 0.25);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

