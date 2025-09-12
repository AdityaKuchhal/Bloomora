import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glassmorphism_app_bar.dart';
import '../widgets/domain_selection_card.dart';
import '../providers/priority_selection_provider.dart';

class PrioritySelectionPage extends ConsumerStatefulWidget {
  const PrioritySelectionPage({super.key});

  @override
  ConsumerState<PrioritySelectionPage> createState() =>
      _PrioritySelectionPageState();
}

class _PrioritySelectionPageState extends ConsumerState<PrioritySelectionPage> {
  final List<String> _selectedPriorities = [];

  @override
  void initState() {
    super.initState();
    // Initialize with empty priorities
  }

  void _togglePriority(String domain) {
    setState(() {
      if (_selectedPriorities.contains(domain)) {
        _selectedPriorities.remove(domain);
      } else if (_selectedPriorities.length < 3) {
        _selectedPriorities.add(domain);
      } else {
        // Replace the first selected priority
        _selectedPriorities.removeAt(0);
        _selectedPriorities.add(domain);
      }
    });
  }

  Future<void> _handleContinue() async {
    if (_selectedPriorities.length != 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select exactly 3 priorities'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      // Save selected priorities
      ref
          .read(prioritySelectionNotifierProvider.notifier)
          .setPriorities(_selectedPriorities);

      // Navigate to loading analysis page
      if (mounted) {
        context.go('/loading-analysis');
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: GlassmorphismAppBar(
        title: 'Select Priorities',
        showAppName: false,
        leading: GestureDetector(
          onTap: () => context.go('/questionnaire'),
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
                color: Color(0xFF000000),
                size: 20,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'Choose Your Top 3 Priorities',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF000000),
                    fontFamily: 'SF Pro Display',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Select the developmental areas you\'d like to focus on first',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                    fontFamily: 'SF Pro Text',
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Selection Counter
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF1E3A8A).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: const Color(0xFF1E3A8A),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Selected ${_selectedPriorities.length} of 3 priorities',
                          style: const TextStyle(
                            color: Color(0xFF1E3A8A),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            fontFamily: 'SF Pro Text',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Domain Selection Cards
                Expanded(
                  child: ListView.builder(
                    itemCount: AppConstants.domains.length,
                    itemBuilder: (context, index) {
                      final domain = AppConstants.domains[index];
                      final isSelected = _selectedPriorities.contains(domain);
                      final selectionOrder =
                          _selectedPriorities.indexOf(domain) + 1;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: DomainSelectionCard(
                          domain: domain,
                          description:
                              AppConstants.domainDescriptions[domain] ?? '',
                          isSelected: isSelected,
                          selectionOrder: isSelected ? selectionOrder : null,
                          onTap: () => _togglePriority(domain),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Continue Button
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _selectedPriorities.length == 3
                        ? const Color(0xFF1E3A8A)
                        : const Color(0xFFD1D5DB),
                  ),
                  child: TextButton(
                    onPressed: _selectedPriorities.length == 3
                        ? _handleContinue
                        : null,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Continue to Analysis',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'SF Pro Text',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
