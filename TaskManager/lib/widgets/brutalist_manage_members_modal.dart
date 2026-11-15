import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../utils/app_colors.dart';
import 'brutalist_button.dart';
import 'brutalist_avatar.dart';
import 'brutalist_share_modal.dart';

class BrutalistManageMembersModal {
  static Future<Task?> show({
    required BuildContext context,
    required Task task,
  }) {
    return showModalBottomSheet<Task>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ManageMembersContent(initialTask: task),
    );
  }
}

class _ManageMembersContent extends StatefulWidget {
  final Task initialTask;

  const _ManageMembersContent({required this.initialTask});

  @override
  State<_ManageMembersContent> createState() => _ManageMembersContentState();
}

class _ManageMembersContentState extends State<_ManageMembersContent> {
  final _taskService = TaskService();
  late Task _task;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _task = widget.initialTask;
  }

  Future<void> _updateRole(String memberId, String newRole) async {
    setState(() => _isLoading = true);

    try {
      final updated = await _taskService.updateMemberRole(_task.id, memberId, newRole);
      if (mounted) {
        setState(() {
          _task = updated;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ĐÃ CẬP NHẬT VAI TRÒ SANG ${newRole.toUpperCase()}'),
            backgroundColor: AppColors.primaryInk,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _confirmRevoke(String memberId, String memberName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.softIceBlue, width: 1.0),
        ),
        title: Text(
          'XÁC NHẬN THU HỒI QUYỀN',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.terracottaAlert,
          ),
        ),
        content: Text(
          'Bạn có chắc chắn muốn thu hồi quyền truy cập và xóa thành viên "$memberName" khỏi công việc này không?',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.slateSteel,
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'HỦY BỎ',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.slateSteel,
              ),
            ),
          ),
          BrutalistButton(
            text: 'THU HỒI',
            icon: Icons.person_remove_rounded,
            backgroundColor: AppColors.terracottaAlert,
            textColor: Colors.white,
            height: 42,
            onPressed: () async {
              Navigator.of(ctx).pop();
              setState(() => _isLoading = true);

              try {
                final updated = await _taskService.revokeTaskMember(_task.id, memberId);
                if (mounted) {
                  setState(() {
                    _task = updated;
                    _isLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('ĐÃ THU HỒI QUYỀN TRUY CẬP CỦA $memberName'),
                      backgroundColor: AppColors.royalCobalt,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
                      backgroundColor: AppColors.terracottaAlert,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showRoleSelector(String memberId, String currentRole) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
            Text(
              'THAY ĐỔI VAI TRÒ (C4)',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.obsidianDark,
              ),
            ),
            const SizedBox(height: 14),
            _buildRoleOptionTile('viewer', 'VIEWER (CHỈ XEM)', currentRole == 'viewer', () {
              Navigator.of(ctx).pop();
              _updateRole(memberId, 'viewer');
            }),
            const SizedBox(height: 8),
            _buildRoleOptionTile('editor', 'EDITOR (CHỈNH SỬA)', currentRole == 'editor', () {
              Navigator.of(ctx).pop();
              _updateRole(memberId, 'editor');
            }),
            const SizedBox(height: 8),
            _buildRoleOptionTile('admin', 'ADMIN (QUẢN TRỊ VIÊN)', currentRole == 'admin', () {
              Navigator.of(ctx).pop();
              _updateRole(memberId, 'admin');
            }),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleOptionTile(String role, String label, bool isSelected, VoidCallback onTap) {
    Color selectedBg = const Color(0xFFF1F5F9);
    Color selectedBorder = AppColors.slateSteel;
    Color textColor = AppColors.obsidianDark;

    if (role == 'admin') {
      selectedBg = AppColors.terracottaAlertLight;
      selectedBorder = AppColors.terracottaAlert;
      textColor = AppColors.terracottaAlert;
    } else if (role == 'editor') {
      selectedBg = const Color(0xFFEFF6FF);
      selectedBorder = AppColors.royalCobalt;
      textColor = AppColors.royalCobalt;
    }

    return GestureDetector(
      onTap: onTap,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? textColor : AppColors.obsidianDark,
              ),
            ),
            if (isSelected) Icon(Icons.check_circle_rounded, size: 18, color: textColor),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
                'QUẢN LÝ THÀNH VIÊN // C4',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.obsidianDark,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.primaryInk),
                onPressed: () => Navigator.of(context).pop(_task),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Members count summary
          Text(
            'DANH SÁCH THÀNH VIÊN (${_task.sharedWith.length + 1})',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 10),

          // List of members
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.royalCobalt,
                      strokeWidth: 2.5,
                    ),
                  )
                : ListView(
                    children: [
                      // Chủ sở hữu công việc (Owner)
                      if (_task.createdBy != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
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
                              BrutalistAvatar(
                                avatarUrl: _task.createdBy?.avatarUrl,
                                name: _task.createdBy?.fullName ?? 'O',
                                size: 36,
                                backgroundColor: AppColors.midnightIndigo,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _task.createdBy!.fullName,
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.obsidianDark,
                                      ),
                                    ),
                                    Text(
                                      _task.createdBy!.email,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.slateSteel,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFBFDBFE), width: 0.8),
                                ),
                                child: Text(
                                  'CHỦ SỞ HỮU',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.royalCobalt,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      // Danh sách thành viên được chia sẻ (sharedWith)
                      if (_task.sharedWith.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.group_outlined, size: 40, color: AppColors.slateSteel),
                                const SizedBox(height: 8),
                                Text(
                                  'CHƯA CHIA SẺ VỚI THÀNH VIÊN NÀO',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.obsidianDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Nhấn nút bên dưới để chia sẻ công việc cho đồng nghiệp.',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.slateSteel,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ..._task.sharedWith.map((member) {
                          final role = member.role;
                          Color roleBg = const Color(0xFFF1F5F9);
                          Color roleBorder = AppColors.softIceBlue;
                          Color roleText = AppColors.slateSteel;

                          if (role == 'admin') {
                            roleBg = AppColors.terracottaAlertLight;
                            roleBorder = AppColors.terracottaAlertBorder;
                            roleText = AppColors.terracottaAlert;
                          } else if (role == 'editor') {
                            roleBg = const Color(0xFFEFF6FF);
                            roleBorder = const Color(0xFFBFDBFE);
                            roleText = AppColors.royalCobalt;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
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
                                BrutalistAvatar(
                                  avatarUrl: member.user.avatarUrl,
                                  name: member.user.fullName,
                                  size: 36,
                                  backgroundColor: const Color(0xFF4A5568),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        member.user.fullName,
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.obsidianDark,
                                        ),
                                      ),
                                      Text(
                                        member.user.email,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.slateSteel,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Role changer button
                                GestureDetector(
                                  onTap: () => _showRoleSelector(member.user.id, member.role),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: roleBg,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: roleBorder, width: 0.8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          member.role.toUpperCase(),
                                          style: GoogleFonts.jetBrainsMono(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: roleText,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(Icons.arrow_drop_down_rounded, size: 14, color: roleText),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Revoke button
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.terracottaAlert, size: 20),
                                  tooltip: 'Thu hồi quyền truy cập',
                                  onPressed: () => _confirmRevoke(member.user.id, member.user.fullName),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
          ),
          const SizedBox(height: 12),

          // Add more button
          BrutalistButton(
            text: '+ CHIA SẺ THÊM THÀNH VIÊN',
            icon: Icons.person_add_rounded,
            backgroundColor: AppColors.royalCobalt,
            textColor: Colors.white,
            onPressed: () async {
              final updated = await BrutalistShareModal.show(context: context, task: _task);
              if (updated != null && mounted) {
                setState(() => _task = updated);
              }
            },
          ),
        ],
      ),
    );
  }
}
