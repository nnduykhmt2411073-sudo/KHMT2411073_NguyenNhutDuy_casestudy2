import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';
import '../../utils/app_colors.dart';
import '../../utils/validators.dart';
import '../../widgets/brutalist_badge.dart';
import '../../widgets/brutalist_button.dart';
import '../../widgets/brutalist_card.dart';
import '../../widgets/brutalist_text_field.dart';
import 'login_screen.dart';

/// Màn hình Đăng ký tài khoản (A1) - B2B SaaS Frost-Obsidian Design
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.register(
        fullName: _fullNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.successMint,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Đăng ký thành công tài khoản ${user.fullName}!',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      // Chuyển hướng sang màn hình đăng nhập
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(initialEmail: user.email),
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
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.frostBackground,
      appBar: AppBar(
        backgroundColor: AppColors.frostBackground,
        elevation: 0,
        title: Text(
          'TASK MANAGER',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppColors.obsidianDark,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: BrutalistBadge(
              text: 'B2B SAAS',
              backgroundColor: Color(0xFFD6E4F0),
              textColor: AppColors.royalCobalt,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tag & Badge
                Row(
                  children: [
                    BrutalistBadge(
                      text: 'MODULE A // AUTHENTICATION',
                      backgroundColor: AppColors.frostBackground,
                      textColor: AppColors.royalCobalt,
                      icon: Icons.shield_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Main Title
                Text(
                  'Tạo tài khoản mới',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: AppColors.obsidianDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Đăng ký thành viên để bắt đầu quản lý và phân công công việc nhóm.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.slateSteel,
                  ),
                ),
                const SizedBox(height: 24),

                // Error Banner nếu có
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.terracottaAlertLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.terracottaAlert.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.terracottaAlert, size: 20),
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

                // Input Card Form
                BrutalistCard(
                  padding: const EdgeInsets.all(22.0),
                  borderRadius: 18.0,
                  child: Column(
                    children: [
                      // Họ và tên
                      BrutalistTextField(
                        label: 'Họ và tên',
                        hintText: 'VD: Nguyễn Nhựt Duy',
                        controller: _fullNameController,
                        prefixIcon: const Icon(Icons.person_outline, color: AppColors.slateSteel, size: 20),
                        validator: (val) => Validators.required(val, 'Họ và tên'),
                      ),
                      const SizedBox(height: 18),

                      // Email
                      BrutalistTextField(
                        label: 'Địa chỉ Email',
                        hintText: 'VD: duy.khmt2411073@gmail.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.mail_outline, color: AppColors.slateSteel, size: 20),
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 18),

                      // Mật khẩu
                      BrutalistTextField(
                        label: 'Mật khẩu',
                        hintText: 'Tối thiểu 6 ký tự',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.slateSteel, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: AppColors.slateSteel,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: Validators.password,
                      ),
                      const SizedBox(height: 18),

                      // Xác nhận mật khẩu
                      BrutalistTextField(
                        label: 'Xác nhận mật khẩu',
                        hintText: 'Nhập lại mật khẩu ở trên',
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        prefixIcon: const Icon(Icons.lock_reset_outlined, color: AppColors.slateSteel, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: AppColors.slateSteel,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                        validator: (val) => Validators.confirmPassword(val, _passwordController.text),
                      ),
                      const SizedBox(height: 26),

                      // Nút Đăng ký
                      BrutalistButton(
                        text: 'ĐĂNG KÝ TÀI KHOẢN',
                        icon: Icons.arrow_forward_rounded,
                        isLoading: _isLoading,
                        width: double.infinity,
                        height: 50,
                        backgroundColor: AppColors.royalCobalt,
                        textColor: Colors.white,
                        onPressed: _handleRegister,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Link chuyển sang Đăng nhập
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Đã có tài khoản? ',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.slateSteel,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                        child: Text(
                          'Đăng nhập ngay',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.royalCobalt,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
