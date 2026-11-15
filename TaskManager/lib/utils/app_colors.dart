import 'package:flutter/material.dart';

/// Bảng màu chuẩn Modern B2B SaaS (Soft Tone Pastel: Nhạt nhạt, êm dịu, bảo vệ mắt, dễ đọc)
class AppColors {
  AppColors._();

  // --- 1. TOKENS NỀN & MÀU SẮC CHÍNH (SOFT TONE) ---

  /// Màu nền chính toàn ứng dụng: Soft Cloud Ice Blue nhạt dịu mắt, sạch sẽ
  static const Color frostBackground = Color(0xFFF4F7FC);

  /// Nền thẻ nội dung, ô nhập liệu, card: Trắng tinh khôi
  static const Color cardWhite = Color(0xFFFFFFFF);

  /// Chữ tiêu đề chính & Icon chính: Xanh than Slate tối thanh lịch, không bị đen gắt
  static const Color obsidianDark = Color(0xFF1E293B);

  /// Màu nền Hero card điểm cuối & Avatar phụ trách chính: Navy Indigo dịu
  static const Color midnightIndigo = Color(0xFF1E325C);

  /// Màu thương hiệu chính: Xanh hoàng gia hiện đại dịu mắt (Primary)
  static const Color royalCobalt = Color(0xFF3563E9);

  /// Màu nhấn phụ: Xanh da trời pastel (Accent progress)
  static const Color skyAzure = Color(0xFF38BDF8);

  /// Viền thẻ 1px, đường chia tách: Màu xanh băng nhạt êm dịu, không gắt
  static const Color softIceBlue = Color(0xFFE2E8F0);

  /// Chữ phụ (subtitle), ngày tháng, placeholder, icon chưa chọn: Xám Slate nhạt
  static const Color slateSteel = Color(0xFF64748B);

  /// Trạng thái hoàn thành: Xanh lá Mint pastel dịu mắt
  static const Color successMint = Color(0xFF16A34A);
  static const Color successMintLight = Color(0xFFEDFBF2);
  static const Color successMintBorder = Color(0xFFBBF7D0);

  /// Cảnh báo quá hạn / Ưu tiên cao / Lỗi: Đỏ hồng pastel dịu mắt
  static const Color terracottaAlert = Color(0xFFDC2626);
  static const Color terracottaAlertLight = Color(0xFFFEF2F2);
  static const Color terracottaAlertBorder = Color(0xFFFECACA);

  /// Mức ưu tiên trung bình: Vàng cam hổ phách pastel
  static const Color warningAmber = Color(0xFFD97706);
  static const Color warningAmberLight = Color(0xFFFFFBEB);
  static const Color warningAmberBorder = Color(0xFFFDE68A);

  /// Trạng thái đang làm: Xanh biển pastel
  static const Color inProgressBlue = Color(0xFF2563EB);
  static const Color inProgressBlueLight = Color(0xFFEFF6FF);
  static const Color inProgressBlueBorder = Color(0xFFBFDBFE);

  // --- 2. CÁC ALIAS TƯƠNG THÍCH HỆ THỐNG GIAO DIỆN ---
  static const Color scaffoldBackground = frostBackground;
  static const Color primaryAccent = royalCobalt;
  static const Color primaryInk = obsidianDark;
  static const Color danger = terracottaAlert;
  static const Color success = successMint;
  static const Color secondarySurface = Color(0xFFF1F5F9);
  static const Color secondaryText = slateSteel;
  static const Color divider = Color(0xFFE2E8F0);

  // --- 3. QUY CHUẨN ĐỘ DÀY VIỀN & ĐỔ BÓNG SAAS LAYERED ---
  static const double borderWidth = 1.0;

  /// Đổ bóng thẻ phẳng hiện đại êm dịu (Soft Shadow)
  static const List<BoxShadow> hardShadow = [
    BoxShadow(
      color: Color(0x080F172A),
      offset: Offset(0, 3),
      blurRadius: 10,
      spreadRadius: 0,
    ),
  ];

  /// Đổ bóng cho Hero Card hoặc Dialog nổi (Elevated Soft Shadow)
  static const List<BoxShadow> heavyHardShadow = [
    BoxShadow(
      color: Color(0x140F172A),
      offset: Offset(0, 6),
      blurRadius: 18,
      spreadRadius: 0,
    ),
  ];

  /// Gradient cho Thẻ Hero Tổng quan (Xanh Navy dịu mắt, không bị đen ngòm)
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF284893), // Xanh Navy thanh lịch
      Color(0xFF1B326B), // Xanh chàm sâu dịu mắt
    ],
  );
}
