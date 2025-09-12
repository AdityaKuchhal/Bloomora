import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

class ActivityCard extends StatelessWidget {
  final String activityId;
  final String title;
  final String description;
  final String duration;
  final String difficulty;
  final String domain;
  final bool isCompact;

  const ActivityCard({
    super.key,
    required this.activityId,
    required this.title,
    required this.description,
    required this.duration,
    required this.difficulty,
    required this.domain,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final domainColor = _getDomainColor(domain);

    if (isCompact) {
      return GestureDetector(
        onTap: () => context.go('/activity/$activityId'),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: domainColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getDomainIcon(domain),
                      color: domainColor,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      domain,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: domainColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 12,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    duration,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => context.go('/activity/$activityId'),
      child: Container(
        padding: EdgeInsets.all(isCompact ? 12 : 20),
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
                Container(
                  width: isCompact ? 32 : 48,
                  height: isCompact ? 32 : 48,
                  decoration: BoxDecoration(
                    color: domainColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getDomainIcon(domain),
                    color: domainColor,
                    size: isCompact ? 16 : 24,
                  ),
                ),
                SizedBox(width: isCompact ? 8 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        domain,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: domainColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      SizedBox(height: isCompact ? 2 : 4),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(difficulty).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    difficulty,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getDifficultyColor(difficulty),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isCompact ? 8 : 16),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
            ),
            SizedBox(height: isCompact ? 8 : 16),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  duration,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.play_arrow,
                        color: AppColors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Start',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getDomainColor(String domain) {
    switch (domain) {
      case 'Fine Motor Skills':
        return AppColors.domainFineMotor;
      case 'Gross Motor Skills':
        return AppColors.domainGrossMotor;
      case 'Communication':
        return AppColors.domainCommunication;
      case 'Social-Emotional':
        return AppColors.domainSocialEmotional;
      case 'Cognitive':
        return AppColors.domainCognitive;
      case 'Adaptive Skills':
        return AppColors.domainAdaptive;
      case 'Sensory Processing':
        return AppColors.domainSensory;
      default:
        return AppColors.primary;
    }
  }

  IconData _getDomainIcon(String domain) {
    switch (domain) {
      case 'Fine Motor Skills':
        return Icons.touch_app;
      case 'Gross Motor Skills':
        return Icons.directions_run;
      case 'Communication':
        return Icons.chat_bubble_outline;
      case 'Social-Emotional':
        return Icons.people_outline;
      case 'Cognitive':
        return Icons.psychology;
      case 'Adaptive Skills':
        return Icons.self_improvement;
      case 'Sensory Processing':
        return Icons.hearing;
      default:
        return Icons.help_outline;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'hard':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
