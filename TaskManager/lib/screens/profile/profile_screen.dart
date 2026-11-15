import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';
import '../../utils/app_colors.dart';
import '../../utils/validators.dart';
import '../../widgets/brutalist_button.dart';
import '../../widgets/brutalist_card.dart';
import '../../widgets/brutalist_text_field.dart';
import '../../widgets/brutalist_avatar.dart';
import '../auth/login_screen.dart';
import '../auth/welcome_screen.dart';

/// Màn hình Hồ sơ cá nhân & Bảo mật (A3 & A4) - B2B SaaS Frost-Obsidian
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final _fullNameController = TextEditingController();
  final _avatarUrlController = TextEditingController();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  bool _obscureCurrentPw = true;
  bool _obscureNewPw = true;
  bool _obscureConfirmNewPw = true;

  User? _user;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isChangingPassword = false;
  String? _errorMessage;
  String? _passwordErrorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _avatarUrlController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.getProfile();
      setState(() {
        _user = user;
        _fullNameController.text = user.fullName;
        _avatarUrlController.text = user.avatarUrl ?? '';
      });
    } catch (e) {
      final cachedUser = await _authService.getCurrentUser();
      setState(() {
        _user = cachedUser;
        if (cachedUser != null) {
          _fullNameController.text = cachedUser.fullName;
          _avatarUrlController.text = cachedUser.avatarUrl ?? '';
        }
        _errorMessage = e is ApiException ? e.message : e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Cập nhật thông tin cá nhân (A3)
  Future<void> _handleSave() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_profileFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedUser = await _authService.updateProfile(
        fullName: _fullNameController.text,
        avatarUrl: _avatarUrlController.text,
      );

      setState(() {
        _user = updatedUser;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.successMint,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Cập nhật thông tin cá nhân thành công!',
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e is ApiException ? e.message : e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// Đổi mật khẩu tài khoản (A4)
  Future<void> _handleChangePassword() async {
    setState(() {
      _passwordErrorMessage = null;
    });

    if (!_passwordFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isChangingPassword = true;
    });

    try {
      await _authService.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (!mounted) return;

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmNewPasswordController.clear();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.cardWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFA5C7EE), width: 1.2),
          ),
          title: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: AppColors.successMint, size: 24),
              const SizedBox(width: 10),
              Text(
                'Đổi mật khẩu thành công',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          content: Text(
            'Mật khẩu của bạn đã được cập nhật an toàn. Vì lý do bảo mật, phiên làm việc đã kết thúc. Vui lòng đăng nhập lại bằng mật khẩu mới.',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF475569)),
          ),
          actions: [
            BrutalistButton(
              text: 'ĐĂNG NHẬP NGAY',
              borderRadius: 14,
              backgroundColor: AppColors.royalCobalt,
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _passwordErrorMessage = e is ApiException ? e.message : e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isChangingPassword = false;
        });
      }
    }
  }

  /// Hộp thoại xác nhận đăng xuất (A3)
  void _showLogoutConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFA5C7EE), width: 1.2),
        ),
        title: Text(
          'Xác nhận đăng xuất',
          style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
        ),
        content: Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi hệ thống Task Manager?',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'HỦY BỎ',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF64748B)),
            ),
          ),
          BrutalistButton(
            text: 'ĐĂNG XUẤT',
            icon: Icons.logout_rounded,
            backgroundColor: AppColors.terracottaAlert,
            textColor: Colors.white,
            borderRadius: 12,
            height: 42,
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _authService.logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final String createdDateStr = _user?.createdAt != null
        ? dateFormat.format(_user!.createdAt!.toLocal())
        : 'Chưa có thông tin';

    return Scaffold(
      backgroundColor: AppColors.frostBackground,
      appBar: AppBar(
        backgroundColor: AppColors.frostBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Hồ sơ cá nhân & Bảo mật',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: const Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.terracottaAlert),
            tooltip: 'Đăng xuất',
            onPressed: _showLogoutConfirmDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.royalCobalt, strokeWidth: 3),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Error Banner hồ sơ nếu có
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.terracottaAlertLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.terracottaAlert.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.error_outline_rounded, color: AppColors.terracottaAlert, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: GoogleFonts.inter(
                                  color: AppColors.terracottaAlert,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Profile Hero Card (A3)
                    BrutalistCard(
                      backgroundColor: AppColors.cardWhite,
                      borderRadius: 22.0,
                      borderWidth: 1.2,
                      borderColor: const Color(0xFFA5C7EE),
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          BrutalistAvatar(
                            avatarUrl: _avatarUrlController.text.isNotEmpty
                                ? _avatarUrlController.text
                                : _user?.avatarUrl,
                            name: _user?.fullName ?? 'U',
                            size: 68,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _user?.fullName ?? 'Chưa cập nhật',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _user?.email ?? '',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF475569),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'NGÀY TẠO: $createdDateStr',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Form Chỉnh sửa thông tin cá nhân (A3)
                    Form(
                      key: _profileFormKey,
                      child: BrutalistCard(
                        padding: const EdgeInsets.all(22.0),
                        borderRadius: 22.0,
                        borderWidth: 1.2,
                        borderColor: const Color(0xFFA5C7EE),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.edit_note_rounded, color: AppColors.royalCobalt, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  'Cập nhật thông tin cá nhân',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // Họ và tên
                            BrutalistTextField(
                              label: 'Họ và tên',
                              hintText: 'Nhập họ và tên đầy đủ',
                              controller: _fullNameController,
                              prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF64748B), size: 20),
                              validator: (val) => Validators.required(val, 'Họ và tên'),
                            ),
                            const SizedBox(height: 18),

                            // Email (Read only)
                            BrutalistTextField(
                              label: 'Địa chỉ Email (Cố định)',
                              hintText: _user?.email ?? '',
                              enabled: false,
                              controller: TextEditingController(text: _user?.email ?? ''),
                              prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF94A3B8), size: 20),
                            ),
                            const SizedBox(height: 18),

                            // Chọn nhanh Preset Avatar
                            Text(
                              'CHỌN AVATAR NHANH (HOẶC NHẬP LINK WEB)',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF475569),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: BrutalistAvatar.presets.entries.map((entry) {
                                  final isSelected = _avatarUrlController.text.trim() == entry.key;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 12.0),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _avatarUrlController.text = entry.key;
                                        });
                                      },
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isSelected ? AppColors.royalCobalt : Colors.transparent,
                                                width: 2.5,
                                              ),
                                            ),
                                            child: BrutalistAvatar(
                                              avatarUrl: entry.key,
                                              name: entry.value.label,
                                              size: 44,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            entry.value.label,
                                            style: GoogleFonts.jetBrainsMono(
                                              fontSize: 10,
                                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                              color: isSelected ? AppColors.royalCobalt : const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // URL Ảnh đại diện
                            BrutalistTextField(
                              label: 'Đường dẫn ảnh đại diện (Tùy chọn)',
                              hintText: 'https://example.com/avatar.jpg',
                              controller: _avatarUrlController,
                              prefixIcon: const Icon(Icons.image_outlined, color: Color(0xFF64748B), size: 20),
                            ),
                            const SizedBox(height: 24),

                            // Nút lưu thay đổi hồ sơ
                            BrutalistButton(
                              text: 'LƯU THAY ĐỔI HỒ SƠ',
                              icon: Icons.save_rounded,
                              isLoading: _isSaving,
                              width: double.infinity,
                              height: 52,
                              borderRadius: 16,
                              backgroundColor: AppColors.royalCobalt,
                              textColor: Colors.white,
                              onPressed: _handleSave,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section Đổi Mật Khẩu (A4)
                    Form(
                      key: _passwordFormKey,
                      child: BrutalistCard(
                        padding: const EdgeInsets.all(22.0),
                        borderRadius: 22.0,
                        borderWidth: 1.2,
                        borderColor: const Color(0xFFA5C7EE),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.lock_reset_rounded, color: AppColors.royalCobalt, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  'Đổi mật khẩu tài khoản',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Nhập mật khẩu hiện tại và tạo mật khẩu mới tối thiểu 6 ký tự.',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Error Banner đổi mật khẩu nếu có
                            if (_passwordErrorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.terracottaAlertLight,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.terracottaAlert.withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline_rounded, color: AppColors.terracottaAlert, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _passwordErrorMessage!,
                                        style: GoogleFonts.inter(
                                          color: AppColors.terracottaAlert,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Mật khẩu hiện tại
                            BrutalistTextField(
                              label: 'Mật khẩu hiện tại',
                              hintText: 'Nhập mật khẩu đang dùng',
                              controller: _currentPasswordController,
                              obscureText: _obscureCurrentPw,
                              prefixIcon: const Icon(Icons.lock_clock_outlined, color: Color(0xFF64748B), size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureCurrentPw ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: const Color(0xFF64748B),
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _obscureCurrentPw = !_obscureCurrentPw),
                              ),
                              validator: (val) => Validators.required(val, 'Mật khẩu hiện tại'),
                            ),
                            const SizedBox(height: 18),

                            // Mật khẩu mới
                            BrutalistTextField(
                              label: 'Mật khẩu mới',
                              hintText: 'Tối thiểu 6 ký tự',
                              controller: _newPasswordController,
                              obscureText: _obscureNewPw,
                              prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF64748B), size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureNewPw ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: const Color(0xFF64748B),
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _obscureNewPw = !_obscureNewPw),
                              ),
                              validator: Validators.password,
                            ),
                            const SizedBox(height: 18),

                            // Xác nhận mật khẩu mới
                            BrutalistTextField(
                              label: 'Xác nhận mật khẩu mới',
                              hintText: 'Nhập lại mật khẩu mới',
                              controller: _confirmNewPasswordController,
                              obscureText: _obscureConfirmNewPw,
                              prefixIcon: const Icon(Icons.lock_reset_outlined, color: Color(0xFF64748B), size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmNewPw ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: const Color(0xFF64748B),
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _obscureConfirmNewPw = !_obscureConfirmNewPw),
                              ),
                              validator: (val) => Validators.confirmPassword(val, _newPasswordController.text),
                            ),
                            const SizedBox(height: 24),

                            // Nút Đổi mật khẩu
                            BrutalistButton(
                              text: 'CẬP NHẬT MẬT KHẨU',
                              icon: Icons.key_rounded,
                              isLoading: _isChangingPassword,
                              width: double.infinity,
                              height: 52,
                              borderRadius: 16,
                              backgroundColor: AppColors.royalCobalt,
                              textColor: Colors.white,
                              onPressed: _handleChangePassword,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section Nút Đăng Xuất (A3)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: AppColors.terracottaAlert.withValues(alpha: 0.5), width: 1.2),
                      ),
                      child: BrutalistButton(
                        text: 'ĐĂNG XUẤT KHỎI HỆ THỐNG',
                        icon: Icons.logout_rounded,
                        height: 52,
                        borderRadius: 16.0,
                        backgroundColor: AppColors.terracottaAlertLight,
                        textColor: AppColors.terracottaAlert,
                        onPressed: _showLogoutConfirmDialog,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }
}
