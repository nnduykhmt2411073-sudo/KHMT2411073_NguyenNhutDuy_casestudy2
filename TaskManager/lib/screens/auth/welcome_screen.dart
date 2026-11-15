import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';
import '../../widgets/brutalist_badge.dart';
import '../../widgets/brutalist_button.dart';
import '../../widgets/brutalist_card.dart';
import 'login_screen.dart';
import 'register_screen.dart';

/// Màn hình Chào đón (Welcome Screen) - Phong cách Modern B2B SaaS sắc nét, rõ ràng & tương phản cao
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.frostBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Badges: Soft Status Pills với độ tương phản cao
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BrutalistBadge(
                    text: 'WORKSPACE OS',
                    backgroundColor: const Color(0xFFD0E3F8),
                    textColor: const Color(0xFF1E3A8A),
                    icon: Icons.auto_awesome,
                    fontSize: 11.5,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    borderRadius: 20,
                  ),
                  BrutalistBadge(
                    text: 'CLOUD READY',
                    backgroundColor: const Color(0xFFD1FAE5),
                    textColor: const Color(0xFF065F46),
                    icon: Icons.fiber_manual_record,
                    fontSize: 11,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    borderRadius: 20,
                  ),
                ],
              ),
              const Spacer(flex: 2),

              // 2. Modern SaaS App Icon (Soft gradient & glow)
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.obsidianDark,
                        AppColors.midnightIndigo,
                        AppColors.royalCobalt,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.royalCobalt.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: AppColors.skyAzure.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          right: 18,
                          bottom: 18,
                          child: Icon(
                            Icons.check_circle_rounded,
                            size: 22,
                            color: AppColors.skyAzure.withValues(alpha: 0.8),
                          ),
                        ),
                        const Icon(
                          Icons.dashboard_customize_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // 3. Tiêu đề thương hiệu: Đậm nét & Rõ ràng
              Text(
                'Task Manager',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                  height: 1.1,
                  color: AppColors.obsidianDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hệ thống quản lý công việc và phân công nhiệm vụ nhóm',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B), // Chữ đậm rõ nét
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // 4. Feature Highlights Card (Chữ to, đậm, tương phản cao)
              BrutalistCard(
                backgroundColor: AppColors.cardWhite,
                borderRadius: 22.0,
                borderWidth: 1.2,
                borderColor: const Color(0xFFA5C7EE),
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20.0),
                customShadow: [
                  BoxShadow(
                    color: AppColors.obsidianDark.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
                child: Column(
                  children: [
                    _buildSoftFeatureRow(
                      icon: Icons.people_alt_rounded,
                      iconColor: AppColors.royalCobalt,
                      bgColor: const Color(0xFFE8F1FC),
                      title: 'Giao việc & Phân quyền RBAC',
                      subtitle: 'Chỉ định phụ trách chính, cấp quyền Viewer / Editor',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      child: Divider(color: Color(0xFFE2E8F0), height: 1, thickness: 1),
                    ),
                    _buildSoftFeatureRow(
                      icon: Icons.mark_email_unread_rounded,
                      iconColor: const Color(0xFFD97706),
                      bgColor: const Color(0xFFFEF3C7),
                      title: 'Thông báo In-App & Email',
                      subtitle: 'Nhận email và thông báo tức thời khi có thay đổi',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      child: Divider(color: Color(0xFFE2E8F0), height: 1, thickness: 1),
                    ),
                    _buildSoftFeatureRow(
                      icon: Icons.insights_rounded,
                      iconColor: AppColors.successMint,
                      bgColor: const Color(0xFFDCFCE7),
                      title: 'Theo dõi tiến độ & Thống kê',
                      subtitle: 'Cảnh báo hạn chót, mức ưu tiên và báo cáo KPI',
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // 5. Action Buttons: ĐĂNG NHẬP & ĐĂNG KÝ (Chữ đậm, nút rõ nét)
              BrutalistButton(
                text: 'ĐĂNG NHẬP HỆ THỐNG',
                icon: Icons.login_rounded,
                height: 54,
                borderRadius: 16.0,
                backgroundColor: AppColors.royalCobalt,
                textColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: AppColors.royalCobalt.withValues(alpha: 0.4), width: 1.5),
                ),
                child: BrutalistButton(
                  text: 'TẠO TÀI KHOẢN MỚI',
                  icon: Icons.person_add_rounded,
                  height: 52,
                  borderRadius: 16.0,
                  backgroundColor: AppColors.cardWhite,
                  textColor: AppColors.royalCobalt,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),

              // 6. Student Footer Info (Khung rõ nét, chữ đậm)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF94A3B8), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'KHMT2411073 • NGUYỄN NHỰT DUY',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: const Color(0xFF0F172A), // Chữ đen đậm rõ nét
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoftFeatureRow({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 23, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: const Color(0xFF0F172A), // Tiêu đề đậm rõ nét
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF475569), // Chữ phụ sắc nét, không mờ nhạt
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
