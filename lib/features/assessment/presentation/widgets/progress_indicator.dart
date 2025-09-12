import 'package:flutter/material.dart';

class CustomProgressIndicator extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;
  final String currentDomain;

  const CustomProgressIndicator({
    super.key,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.currentDomain,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentQuestion / totalQuestions;

    return Column(
      children: [
        // Progress Bar
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 8,
                width: MediaQuery.of(context).size.width * progress,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Progress Text
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question $currentQuestion of $totalQuestions',
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
                fontSize: 14,
                fontFamily: 'SF Pro Text',
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: const TextStyle(
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.w600,
                fontSize: 14,
                fontFamily: 'SF Pro Text',
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Current Domain
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF1E3A8A).withOpacity(0.3),
            ),
          ),
          child: Text(
            currentDomain,
            style: const TextStyle(
              color: Color(0xFF1E3A8A),
              fontWeight: FontWeight.w600,
              fontSize: 12,
              fontFamily: 'SF Pro Text',
            ),
          ),
        ),
      ],
    );
  }
}
