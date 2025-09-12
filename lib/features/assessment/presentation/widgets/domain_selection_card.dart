import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class DomainSelectionCard extends StatefulWidget {
  final String domain;
  final String description;
  final bool isSelected;
  final int? selectionOrder;
  final VoidCallback onTap;

  const DomainSelectionCard({
    super.key,
    required this.domain,
    required this.description,
    required this.isSelected,
    this.selectionOrder,
    required this.onTap,
  });

  @override
  State<DomainSelectionCard> createState() => _DomainSelectionCardState();
}

class _DomainSelectionCardState extends State<DomainSelectionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(DomainSelectionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getDomainColor(String domain) {
    // Use consistent dark blue theme for all domains
    return const Color(0xFF1E3A8A);
  }

  @override
  Widget build(BuildContext context) {
    final domainColor = _getDomainColor(widget.domain);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.isSelected
                      ? [
                          Colors.white.withOpacity(0.7),
                          Colors.white.withOpacity(0.5),
                        ]
                      : [
                          Colors.white.withOpacity(0.5),
                          Colors.white.withOpacity(0.3),
                        ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.isSelected
                      ? const Color(0xFF1E3A8A).withOpacity(0.8)
                      : Colors.white.withOpacity(0.7),
                  width: widget.isSelected ? 2 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    blurRadius: 15,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Domain Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? const Color(0xFF1E3A8A)
                          : const Color(0xFF1E3A8A).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getDomainIcon(widget.domain),
                      color: widget.isSelected
                          ? Colors.white
                          : const Color(0xFF1E3A8A),
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Domain Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.domain,
                                style: TextStyle(
                                  color: widget.isSelected
                                      ? const Color(0xFF1E3A8A)
                                      : const Color(0xFF000000),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  fontFamily: 'SF Pro Text',
                                ),
                              ),
                            ),
                            if (widget.isSelected &&
                                widget.selectionOrder != null)
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E3A8A),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    widget.selectionOrder.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.description,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            height: 1.4,
                            fontSize: 14,
                            fontFamily: 'SF Pro Text',
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Selection Indicator
                  Icon(
                    widget.isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: widget.isSelected
                        ? domainColor
                        : AppColors.textSecondary,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
}
