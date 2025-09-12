import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class GlassmorphismAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showAppName;
  final double scrollOffset;

  const GlassmorphismAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showAppName = false,
    this.scrollOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final double opacity = (scrollOffset / 80).clamp(0.0, 0.9);
    final double blurRadius = (scrollOffset / 30).clamp(0.0, 25.0);
    final double backgroundOpacity = 0.95 + (opacity * 0.05);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A).withOpacity(backgroundOpacity),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF1E3A8A).withOpacity(0.6 + (opacity * 0.2)),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05 + (opacity * 0.1)),
            blurRadius: blurRadius,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: const Color(0xFF1E3A8A).withOpacity(0.2 + (opacity * 0.3)),
            blurRadius: blurRadius * 0.5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurRadius,
            sigmaY: blurRadius,
          ),
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              bottom: 12,
            ),
            child: Stack(
              children: [
                // Center content - App Name only
                Center(
                  child: showAppName
                      ? Text(
                          AppConstants.appName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color:
                                Colors.white.withOpacity(0.9 + (opacity * 0.1)),
                            letterSpacing: -0.5,
                            fontFamily: 'SF Pro Display',
                          ),
                        )
                      : Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color:
                                Colors.white.withOpacity(0.9 + (opacity * 0.1)),
                            letterSpacing: -0.3,
                            fontFamily: 'SF Pro Display',
                          ),
                        ),
                ),

                // Left side - Leading widget (back button)
                if (leading != null)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: leading!,
                    ),
                  ),

                // Right side - Actions
                if (actions != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: actions!,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);
}

// Scrollable App Bar that responds to scroll offset
class ScrollableGlassmorphismAppBar extends StatefulWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showAppName;
  final Widget child;

  const ScrollableGlassmorphismAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showAppName = false,
    required this.child,
  });

  @override
  State<ScrollableGlassmorphismAppBar> createState() =>
      _ScrollableGlassmorphismAppBarState();
}

class _ScrollableGlassmorphismAppBarState
    extends State<ScrollableGlassmorphismAppBar> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GlassmorphismAppBar(
            title: widget.title,
            leading: widget.leading,
            actions: widget.actions,
            showAppName: widget.showAppName,
            scrollOffset: _scrollOffset,
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
