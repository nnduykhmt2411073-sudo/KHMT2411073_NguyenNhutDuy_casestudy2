import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import '../models/user.dart';
import '../services/task_service.dart';
import '../utils/app_colors.dart';
import 'brutalist_button.dart';
import 'brutalist_user_picker.dart';

class BrutalistShareModal {
  static Future<Task?> show({
    required BuildContext context,
    required Task task,
  }) {
    return showModalBottomSheet<Task>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ShareModalContent(task: task),
    );
  }
}

class _ShareModalContent extends StatefulWidget {
  final Task task;

  const _ShareModalContent({required this.task});

  @override
  State<_ShareModalContent> createState() => _ShareModalContentState();
}

class _ShareModalContentState extends State<_ShareModalContent> {
  final _taskService = TaskService();
  final _emailController = TextEditingController();

  User? _selectedUser;
  String _selectedRole = 'viewer'; // viewer, editor, admin
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickUser() async {
    final results = await BrutalistUserPicker.show(
      context: context,
      title: 'CHỌN NGƯỜI DÙNG ĐỂ CHIA SẺ',
      isMultiSelect: false,
    );

    if (results != null && results.isNotEmpty) {
      setState(() {
        _selectedUser = results.first;
        _emailController.text = _selectedUser!.email;
        _errorMessage = null;
      });
    }
  }

  Future<void> _submitShare() async {
    final email = _emailController.text.trim();
    if (_selectedUser == null && email.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng chọn người dùng hoặc nhập email!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final updatedTask = await _taskService.shareTask(
        widget.task.id,
        userId: _selectedUser?.id,
        email: _selectedUser == null ? email : null,
        role: _selectedRole,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ĐÃ CHIA SẺ CÔNG VIỆC VỚI QUYỀN ${_selectedRole.toUpperCase()}',
            style: GoogleFonts.jetBrainsMono(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.primaryInk,
        ),
      );

      Navigator.of(context).pop(updatedTask);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A03040B),
            offset: Offset(0, -4),
            blurRadius: 20,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.softIceBlue,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CHIA SẺ CÔNG VIỆC // C3 (RBAC)',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.obsidianDark,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.slateSteel),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.terracottaAlertLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.terracottaAlertBorder, width: 0.8),
              ),
              child: Text(
                _errorMessage!,
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.terracottaAlert, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Chọn người dùng
          Text(
            'CHỌN NGƯỜI ĐƯỢC CHIA SẺ',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.slateSteel,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _pickUser,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.softIceBlue, width: 1.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0603040B),
                    offset: Offset(0, 2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_search_rounded, color: AppColors.royalCobalt, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedUser != null
                          ? '${_selectedUser!.fullName} (${_selectedUser!.email})'
                          : (_emailController.text.isNotEmpty
                              ? _emailController.text
                              : 'Nhấn để tìm kiếm hoặc chọn thành viên...'),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _selectedUser != null || _emailController.text.isNotEmpty
                            ? AppColors.obsidianDark
                            : AppColors.slateSteel,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.slateSteel),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Chọn quyền RBAC
          Text(
            'VAI TRÒ & PHÂN QUYỀN (RBAC)',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.slateSteel,
            ),
          ),
          const SizedBox(height: 8),

          _buildRoleOption(
            role: 'viewer',
            title: 'VIEWER (CHỈ XEM)',
            subtitle: 'Chỉ có quyền xem tiến độ và chi tiết, không được chỉnh sửa hay đổi trạng thái.',
            selectedBg: const Color(0xFFF1F5F9),
            selectedBorder: AppColors.slateSteel,
            textColor: AppColors.obsidianDark,
          ),
          const SizedBox(height: 8),
          _buildRoleOption(
            role: 'editor',
            title: 'EDITOR (CHỈNH SỬA)',
            subtitle: 'Được quyền cập nhật nội dung, hạn chót và đổi trạng thái tiến độ công việc.',
            selectedBg: const Color(0xFFEFF6FF),
            selectedBorder: AppColors.royalCobalt,
            textColor: AppColors.royalCobalt,
          ),
          const SizedBox(height: 8),
          _buildRoleOption(
            role: 'admin',
            title: 'ADMIN (QUẢN TRỊ VIÊN)',
            subtitle: 'Toàn quyền quản trị công việc: chỉnh sửa, phân công, chia sẻ thêm hoặc xóa.',
            selectedBg: AppColors.terracottaAlertLight,
            selectedBorder: AppColors.terracottaAlert,
            textColor: AppColors.terracottaAlert,
          ),
          const SizedBox(height: 20),

          // Submit button
          BrutalistButton(
            text: 'XÁC NHẬN CHIA SẺ',
            icon: Icons.share_rounded,
            backgroundColor: AppColors.royalCobalt,
            textColor: Colors.white,
            isLoading: _isLoading,
            onPressed: _submitShare,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption({
    required String role,
    required String title,
    required String subtitle,
    required Color selectedBg,
    required Color selectedBorder,
    required Color textColor,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? selectedBorder : AppColors.softIceBlue,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0603040B),
              offset: Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? textColor : AppColors.slateSteel,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? textColor : AppColors.obsidianDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.slateSteel,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
