import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';
import '../../widgets/brutalist_badge.dart';
import '../../widgets/brutalist_button.dart';
import '../../widgets/brutalist_card.dart';
import 'login_screen.dart';
import 'register_screen.dart';

/// Màn hình Chào đón (Welcome Screen) - Phong cách Modern B2B SaaS mềm mại & thanh lịch
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
              // 1. Top Badges: Soft Status Pills
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BrutalistBadge(
                    text: 'WORKSPACE OS',
                    backgroundColor: const Color(0xFFDCEAF9),
                    textColor: AppColors.royalCobalt,
                    icon: Icons.auto_awesome,
                    fontSize: 11,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    borderRadius: 20,
                  ),
                  BrutalistBadge(
                    text: 'CLOUD READY',
                    backgroundColor: AppColors.successMintLight,
                    textColor: AppColors.successMint,
                    icon: Icons.fiber_manual_record,
                    fontSize: 10,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    borderRadius: 20,
                  ),
                ],
              ),
              const Spacer(flex: 2),

              // 2. Modern SaaS App Icon (Soft gradient & subtle glow)
              Center(
                child: Container(
                  width: 88,
                  height: 88,
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
                        color: AppColors.skyAzure.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Họa tiết nền mờ tạo chiều sâu
                        Positioned(
                          right: 18,
                          bottom: 18,
                          child: Icon(
                            Icons.check_circle_rounded,
                            size: 20,
                            color: AppColors.skyAzure.withValues(alpha: 0.7),
                          ),
                        ),
                        const Icon(
                          Icons.dashboard_customize_rounded,
                          size: 46,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // 3. Tiêu đề thương hiệu thanh lịch
              Text(
                'Task Manager',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  height: 1.1,
                  color: AppColors.obsidianDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hệ thống quản lý công việc và phân công nhiệm vụ nhóm',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.slateSteel,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // 4. Feature Highlights Card (Mềm mại, bo góc 22px, icon pastel)
              BrutalistCard(
                backgroundColor: AppColors.cardWhite,
                borderRadius: 22.0,
                borderWidth: 1.0,
                borderColor: AppColors.softIceBlue,
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20.0),
                customShadow: [
                  BoxShadow(
                    color: AppColors.obsidianDark.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
                child: Column(
                  children: [
                    _buildSoftFeatureRow(
                      icon: Icons.people_alt_rounded,
                      iconColor: AppColors.royalCobalt,
                      bgColor: const Color(0xFFEAF2FD),
                      title: 'Giao việc & Phân quyền RBAC',
                      subtitle: 'Chỉ định phụ trách chính, cấp quyền Viewer / Editor',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      child: Divider(color: Color(0xFFEDF2F9), height: 1, thickness: 1),
                    ),
                    _buildSoftFeatureRow(
                      icon: Icons.mark_email_unread_rounded,
                      iconColor: const Color(0xFFE2831B),
                      bgColor: const Color(0xFFFFF4E5),
                      title: 'Thông báo In-App & Email',
                      subtitle: 'Nhận email và thông báo tức thời khi có thay đổi',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      child: Divider(color: Color(0xFFEDF2F9), height: 1, thickness: 1),
                    ),
                    _buildSoftFeatureRow(
                      icon: Icons.insights_rounded,
                      iconColor: AppColors.successMint,
                      bgColor: AppColors.successMintLight,
                      title: 'Theo dõi tiến độ & Thống kê',
                      subtitle: 'Cảnh báo hạn chót, mức ưu tiên và báo cáo KPI',
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // 5. Action Buttons: ĐĂNG NHẬP & ĐĂNG KÝ (Bo góc 16px)
              BrutalistButton(
                text: 'Đăng nhập hệ thống',
                icon: Icons.login_rounded,
                height: 52,
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
                  border: Border.all(color: AppColors.softIceBlue, width: 1.2),
                ),
                child: BrutalistButton(
                  text: 'Tạo tài khoản mới',
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

              // 6. Student Footer Info (Thanh lịch)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.softIceBlue.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'KHMT2411073 • NGUYỄN NHỰT DUY',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppColors.slateSteel,
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
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 22, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.obsidianDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.slateSteel,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
