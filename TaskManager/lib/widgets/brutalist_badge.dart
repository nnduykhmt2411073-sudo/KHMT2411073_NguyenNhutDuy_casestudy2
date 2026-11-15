import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

/// Huy hiệu nhãn chuẩn Modern B2B SaaS (Frost-Obsidian: Bo góc tròn Pill 20px, nền nhạt tương phản thanh lịch)
class BrutalistBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final IconData? icon;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const BrutalistBadge({
    super.key,
    required this.text,
    this.backgroundColor = AppColors.frostBackground,
    this.textColor = AppColors.royalCobalt,
    this.borderColor,
    this.icon,
    this.fontSize = 11.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
    this.borderRadius = 20.0,
  });

  factory BrutalistBadge.priority(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const BrutalistBadge(
          text: 'HIGH',
          backgroundColor: AppColors.terracottaAlertLight,
          textColor: AppColors.terracottaAlert,
          borderColor: Color(0xFFF3C7C2),
          icon: Icons.priority_high,
        );
      case 'medium':
        return const BrutalistBadge(
          text: 'MEDIUM',
          backgroundColor: Color(0xFFFFF7E6),
          textColor: Color(0xFFD48806),
          borderColor: Color(0xFFFFE7BA),
        );
      case 'low':
      default:
        return const BrutalistBadge(
          text: 'LOW',
          backgroundColor: AppColors.frostBackground,
          textColor: AppColors.slateSteel,
          borderColor: AppColors.softIceBlue,
        );
    }
  }

  factory BrutalistBadge.status(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const BrutalistBadge(
          text: 'COMPLETED',
          backgroundColor: AppColors.successMintLight,
          textColor: AppColors.successMint,
          borderColor: Color(0xFFB7EB8F),
          icon: Icons.check_circle_outline,
        );
      case 'in_progress':
        return const BrutalistBadge(
          text: 'IN PROGRESS',
          backgroundColor: Color(0xFFE8F4FD),
          textColor: AppColors.skyAzure,
          borderColor: AppColors.softIceBlue,
          icon: Icons.timelapse,
        );
      case 'todo':
      default:
        return const BrutalistBadge(
          text: 'TODO',
          backgroundColor: AppColors.frostBackground,
          textColor: AppColors.slateSteel,
          borderColor: AppColors.softIceBlue,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? AppColors.softIceBlue.withValues(alpha: 0.6),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            text.toUpperCase(),
            style: GoogleFonts.jetBrainsMono(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
