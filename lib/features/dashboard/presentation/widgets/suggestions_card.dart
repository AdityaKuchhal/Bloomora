import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SuggestionsCard extends StatelessWidget {
  const SuggestionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.warning,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'AI Suggestions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSuggestionItem(
            context,
            'Try the "Sensory Play" activity - it\'s great for your child\'s current development stage',
            Icons.touch_app,
            AppColors.domainSensory,
          ),
          const SizedBox(height: 12),
          _buildSuggestionItem(
            context,
            'Consider scheduling activities at the same time each day for better consistency',
            Icons.schedule,
            AppColors.info,
          ),
          const SizedBox(height: 12),
          _buildSuggestionItem(
            context,
            'Your child is showing great progress in Fine Motor Skills! Keep it up!',
            Icons.celebration,
            AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
