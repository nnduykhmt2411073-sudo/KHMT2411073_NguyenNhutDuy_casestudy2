import 'package:flutter/material.dart';

/// Bảng màu chuẩn Modern B2B SaaS / CRM Dashboard (Frost Blue & Deep Obsidian)
/// Tuân thủ quy chuẩn thiết kế theo skill flutter-saas-builder
class AppColors {
  AppColors._();

  // --- 1. TOKENS CHÍNH CỦA HỆ THỐNG FROST-OBSIDIAN SAAS ---

  /// Màu nền chính toàn ứng dụng (Scaffold Background)
  static const Color frostBackground = Color(0xFFE6EFFB);

  /// Nền thẻ nội dung, ô nhập liệu, BottomNavigation
  static const Color cardWhite = Color(0xFFFFFFFF);

  /// Điểm đầu gradient thẻ Hero tổng quan & chữ tiêu đề chính
  static const Color obsidianDark = Color(0xFF03040B);

  /// Điểm cuối gradient thẻ Hero & màu nền Avatar người phụ trách chính
  static const Color midnightIndigo = Color(0xFF2A3261);

  /// Màu thương hiệu chính (Primary): nút CTA, tab đang chọn, icon active
  static const Color royalCobalt = Color(0xFF2A4EBB);

  /// Màu nhấn phụ (Accent): thanh tiến độ, trạng thái đang chạy
  static const Color skyAzure = Color(0xFF39A8F2);

  /// Viền thẻ 1px, viền ô nhập liệu, đường phân cách
  static const Color softIceBlue = Color(0xFFB5D3F4);

  /// Chữ phụ (subtitle), ngày tháng, placeholder, icon chưa chọn
  static const Color slateSteel = Color(0xFF6F8EAE);

  /// Trạng thái hoàn thành / khoản thu
  static const Color successMint = Color(0xFF1F9D68);
  static const Color successMintLight = Color(0xFFE3F7EE);

  /// Cảnh báo quá hạn / ưu tiên cao / lỗi
  static const Color terracottaAlert = Color(0xFFAD5A4D);
  static const Color terracottaAlertLight = Color(0xFFFBEAE8);

  // --- 2. CÁC ALIAS TƯƠNG THÍCH HỆ THỐNG GIAO DIỆN ---
  static const Color scaffoldBackground = frostBackground;
  static const Color primaryAccent = royalCobalt;
  static const Color primaryInk = obsidianDark;
  static const Color danger = terracottaAlert;
  static const Color success = successMint;
  static const Color secondarySurface = Color(0xFFDCE8F7);
  static const Color secondaryText = slateSteel;
  static const Color divider = softIceBlue;

  // --- 3. QUY CHUẨN ĐỘ DÀY VIỀN & ĐỔ BÓNG SAAS LAYERED ---
  static const double borderWidth = 1.0;

  /// Đổ bóng thẻ phẳng hiện đại (Flat Layered UI)
  static const List<BoxShadow> hardShadow = [
    BoxShadow(
      color: Color(0x1203040B),
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  /// Đổ bóng cho Hero Card hoặc Dialog nổi
  static const List<BoxShadow> heavyHardShadow = [
    BoxShadow(
      color: Color(0x2003040B),
      offset: Offset(0, 8),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];

  /// Gradient cho Thẻ Hero Tổng quan (Dark Obsidian to Midnight Indigo)
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [obsidianDark, midnightIndigo],
  );
}
