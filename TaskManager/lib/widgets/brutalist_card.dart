import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Thẻ Card chuẩn Modern B2B SaaS (Frost-Obsidian: Bo góc 18px, viền mảnh 1px softIceBlue, bóng đổ phẳng đa tầng)
class BrutalistCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderWidth;
  final double borderRadius;
  final Offset? shadowOffset;
  final List<BoxShadow>? customShadow;
  final VoidCallback? onTap;

  const BrutalistCard({
    super.key,
    required this.child,
    this.backgroundColor = AppColors.cardWhite,
    this.borderColor,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.borderWidth = AppColors.borderWidth,
    this.borderRadius = 18.0,
    this.shadowOffset,
    this.customShadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? AppColors.softIceBlue,
          width: borderWidth,
        ),
        boxShadow: customShadow ?? AppColors.hardShadow,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}
