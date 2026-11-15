import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

/// Ô nhập liệu chuẩn Modern B2B SaaS (Frost-Obsidian: Bo góc 14px, viền 1px softIceBlue, nền cardWhite)
class BrutalistTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  const BrutalistTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
  });

  @override
  State<BrutalistTextField> createState() => _BrutalistTextFieldState();
}

class _BrutalistTextFieldState extends State<BrutalistTextField> {
  String? _errorText;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.obsidianDark,
          ),
        ),
        const SizedBox(height: 6),
        // Input Box
        Focus(
          onFocusChange: (focused) => setState(() => _isFocused = focused),
          child: Container(
            decoration: BoxDecoration(
              color: widget.enabled ? AppColors.cardWhite : AppColors.frostBackground,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: _errorText != null
                    ? AppColors.terracottaAlert
                    : (_isFocused ? AppColors.royalCobalt : AppColors.softIceBlue),
                width: _isFocused ? 1.5 : 1.0,
              ),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: AppColors.royalCobalt.withValues(alpha: 0.12),
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              enabled: widget.enabled,
              maxLines: widget.maxLines,
              onChanged: (val) {
                if (widget.validator != null) {
                  setState(() {
                    _errorText = widget.validator!(val);
                  });
                }
                if (widget.onChanged != null) {
                  widget.onChanged!(val);
                }
              },
              validator: (val) {
                final err = widget.validator?.call(val);
                setState(() {
                  _errorText = err;
                });
                return err;
              },
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.obsidianDark,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.slateSteel.withValues(alpha: 0.8),
                ),
                prefixIcon: widget.prefixIcon,
                suffixIcon: widget.suffixIcon,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: InputBorder.none,
                errorStyle: const TextStyle(height: 0, fontSize: 0),
              ),
            ),
          ),
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.error_outline, size: 14, color: AppColors.terracottaAlert),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _errorText!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.terracottaAlert,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
