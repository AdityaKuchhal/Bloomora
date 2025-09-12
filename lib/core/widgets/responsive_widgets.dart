import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';

/// A responsive container that adapts its padding and constraints based on screen size
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? maxWidth;
  final Alignment? alignment;
  final Color? color;
  final Decoration? decoration;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.maxWidth,
    this.alignment,
    this.color,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? ResponsiveUtils.getResponsivePadding(context),
      margin: margin,
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? ResponsiveUtils.getMaxContentWidth(context),
      ),
      alignment: alignment,
      color: color,
      decoration: decoration,
      child: child,
    );
  }
}

/// A responsive row that adapts its layout based on screen size
class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double? spacing;
  final bool wrap;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing,
    this.wrap = false,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveUtils.isMobile(context) && wrap) {
      return Wrap(
        spacing: spacing ?? ResponsiveUtils.getResponsiveSpacing(context, 16),
        runSpacing: ResponsiveUtils.getResponsiveSpacing(context, 16),
        children: children,
      );
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: _buildChildrenWithSpacing(context),
    );
  }

  List<Widget> _buildChildrenWithSpacing(BuildContext context) {
    if (children.isEmpty) return children;

    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(
          SizedBox(
              width:
                  spacing ?? ResponsiveUtils.getResponsiveSpacing(context, 16)),
        );
      }
    }
    return spacedChildren;
  }
}

/// A responsive column that adapts its layout based on screen size
class ResponsiveColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double? spacing;

  const ResponsiveColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: _buildChildrenWithSpacing(context),
    );
  }

  List<Widget> _buildChildrenWithSpacing(BuildContext context) {
    if (children.isEmpty) return children;

    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(
          SizedBox(
              height:
                  spacing ?? ResponsiveUtils.getResponsiveSpacing(context, 16)),
        );
      }
    }
    return spacedChildren;
  }
}

/// A responsive grid that adapts its column count based on screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final double? childAspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    final columnCount = ResponsiveUtils.getResponsiveColumnCount(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
        childAspectRatio: childAspectRatio ?? 1.0,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// A responsive text widget that adapts its font size based on screen size
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final baseFontSize = style?.fontSize ?? 14.0;
    final responsiveFontSize =
        ResponsiveUtils.getResponsiveFontSize(context, baseFontSize);

    return Text(
      text,
      style: style?.copyWith(fontSize: responsiveFontSize) ??
          TextStyle(fontSize: responsiveFontSize),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// A responsive icon widget that adapts its size based on screen size
class ResponsiveIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  const ResponsiveIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final baseSize = size ?? 24.0;
    final responsiveSize =
        ResponsiveUtils.getResponsiveIconSize(context, baseSize);

    return Icon(
      icon,
      size: responsiveSize,
      color: color,
      semanticLabel: semanticLabel,
    );
  }
}

/// A responsive card widget that adapts its padding and constraints based on screen size
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.shape,
    this.clipBehavior,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ??
          EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context, 8)),
      color: color,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      child: Padding(
        padding: padding ?? ResponsiveUtils.getResponsivePadding(context),
        child: child,
      ),
    );
  }
}

/// A responsive button that adapts its size and padding based on screen size
class ResponsiveButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final bool isLoading;
  final double? minWidth;
  final double? minHeight;

  const ResponsiveButton({
    super.key,
    required this.child,
    this.onPressed,
    this.style,
    this.isLoading = false,
    this.minWidth,
    this.minHeight,
  });

  @override
  Widget build(BuildContext context) {
    final responsivePadding = ResponsiveUtils.getResponsivePadding(context);

    return SizedBox(
      width: minWidth ?? ResponsiveUtils.getResponsiveWidth(context, 100),
      height: minHeight ?? ResponsiveUtils.getResponsiveSpacing(context, 48),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: style?.copyWith(
              padding: MaterialStateProperty.all(
                EdgeInsets.symmetric(
                  horizontal: responsivePadding.horizontal / 2,
                  vertical: responsivePadding.vertical / 2,
                ),
              ),
            ) ??
            ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: responsivePadding.horizontal / 2,
                vertical: responsivePadding.vertical / 2,
              ),
            ),
        child: isLoading
            ? SizedBox(
                width: ResponsiveUtils.getResponsiveIconSize(context, 20),
                height: ResponsiveUtils.getResponsiveIconSize(context, 20),
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : child,
      ),
    );
  }
}

/// A responsive app bar that adapts its height and content based on screen size
class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;

  const ResponsiveAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final responsivePadding = ResponsiveUtils.getResponsivePadding(context);
    final responsiveHeight = ResponsiveUtils.getResponsiveSpacing(context, 56);

    return AppBar(
      title: title != null ? ResponsiveText(title!) : null,
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      toolbarHeight: responsiveHeight,
      titleSpacing: responsivePadding.horizontal / 2,
    );
  }

  @override
  Size get preferredSize {
    // Default height for mobile, will be overridden by build method
    return const Size.fromHeight(56.0);
  }
}
