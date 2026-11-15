import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../utils/app_colors.dart';
import 'brutalist_avatar.dart';

/// Thẻ công việc chuẩn phong cách Modern B2B SaaS (Soft Tone Pastel: Nhạt nhạt, êm dịu, bảo vệ mắt, dễ đọc)
class BrutalistTaskCard extends StatelessWidget {
  final Task task;
  final String? currentUserId;
  final VoidCallback? onTap;
  final VoidCallback? onStatusTap;

  const BrutalistTaskCard({
    super.key,
    required this.task,
    this.currentUserId,
    this.onTap,
    this.onStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isOverdue = task.dueDate != null &&
        task.dueDate!.isBefore(now) &&
        task.status != 'completed';

    final isOwner = currentUserId != null && task.createdBy?.id == currentUserId;
    final sharedMember = currentUserId != null
        ? task.sharedWith.where((m) => m.user.id == currentUserId).firstOrNull
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: AppColors.softIceBlue, width: 1.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x060F172A),
              offset: Offset(0, 2),
              blurRadius: 10,
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Scope Badge (Tôi tạo / Được chia sẻ) + Priority Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentUserId != null)
                  _buildScopeBadge(isOwner, sharedMember)
                else
                  const SizedBox.shrink(),
                _buildPriorityBadge(task.priority),
              ],
            ),
            const SizedBox(height: 10),

            // Row 2: Status Badge (chạm để chuyển trạng thái nhanh)
            GestureDetector(
              onTap: onStatusTap,
              child: _buildStatusBadge(task.status),
            ),
            const SizedBox(height: 10),

            // Task Title
            Text(
              task.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.obsidianDark,
                height: 1.35,
              ),
            ),

            // Task Description (if any)
            if (task.description.trim().isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                task.description.trim(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.slateSteel,
                  height: 1.4,
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Divider line mềm mại mỏng 1px
            Container(
              height: 1.0,
              color: AppColors.softIceBlue,
            ),
            const SizedBox(height: 10),

            // Footer Row: Due Date & Assignees / Creator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Due date
                if (task.dueDate != null)
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 13,
                        color: isOverdue ? AppColors.terracottaAlert : AppColors.slateSteel,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        DateFormat('dd/MM/yyyy').format(task.dueDate!),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isOverdue ? AppColors.terracottaAlert : AppColors.slateSteel,
                        ),
                      ),
                      if (isOverdue) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.terracottaAlertLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.terracottaAlertBorder, width: 0.8),
                          ),
                          child: Text(
                            'QUÁ HẠN',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.terracottaAlert,
                            ),
                          ),
                        ),
                      ],
                    ],
                  )
                else
                  Row(
                    children: [
                      const Icon(
                        Icons.event_busy_outlined,
                        size: 13,
                        color: AppColors.slateSteel,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Không có hạn',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppColors.slateSteel,
                        ),
                      ),
                    ],
                  ),

                // Creator / Assignee info
                _buildAssigneeBadge(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScopeBadge(bool isOwner, dynamic sharedMember) {
    if (isOwner) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFBFDBFE), width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, size: 12, color: AppColors.royalCobalt),
            const SizedBox(width: 3),
            Text(
              'CHỦ SỞ HỮU',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.royalCobalt,
              ),
            ),
          ],
        ),
      );
    } else if (sharedMember != null) {
      final role = (sharedMember.role as String).toUpperCase();
      final isAdmin = role == 'ADMIN';
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
        decoration: BoxDecoration(
          color: isAdmin ? AppColors.terracottaAlertLight : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isAdmin ? AppColors.terracottaAlertBorder : AppColors.softIceBlue,
            width: 0.8,
          ),
        ),
        child: Text(
          'CHIA SẺ // $role',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: isAdmin ? AppColors.terracottaAlert : AppColors.slateSteel,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.softIceBlue, width: 0.8),
        ),
        child: Text(
          'ĐƯỢC PHÂN CÔNG',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppColors.slateSteel,
          ),
        ),
      );
    }
  }

  Widget _buildStatusBadge(String status) {
    switch (status) {
      case 'in_progress':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
          decoration: BoxDecoration(
            color: AppColors.inProgressBlueLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.inProgressBlueBorder, width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sync_rounded, size: 12, color: AppColors.inProgressBlue),
              const SizedBox(width: 4),
              Text(
                'ĐANG LÀM',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inProgressBlue,
                ),
              ),
              const SizedBox(width: 3),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 13, color: AppColors.inProgressBlue),
            ],
          ),
        );
      case 'completed':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
          decoration: BoxDecoration(
            color: AppColors.successMintLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.successMintBorder, width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, size: 12, color: AppColors.successMint),
              const SizedBox(width: 4),
              Text(
                'HOÀN THÀNH',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.successMint,
                ),
              ),
              const SizedBox(width: 3),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 13, color: AppColors.successMint),
            ],
          ),
        );
      case 'cancelled':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
          decoration: BoxDecoration(
            color: AppColors.terracottaAlertLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.terracottaAlertBorder, width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cancel_outlined, size: 12, color: AppColors.terracottaAlert),
              const SizedBox(width: 4),
              Text(
                'ĐÃ HỦY',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.terracottaAlert,
                ),
              ),
              const SizedBox(width: 3),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 13, color: AppColors.terracottaAlert),
            ],
          ),
        );
      case 'todo':
      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.softIceBlue, width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.hourglass_empty_rounded, size: 12, color: AppColors.slateSteel),
              const SizedBox(width: 4),
              Text(
                'CHỜ XỬ LÝ',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slateSteel,
                ),
              ),
              const SizedBox(width: 3),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 13, color: AppColors.slateSteel),
            ],
          ),
        );
    }
  }

  Widget _buildPriorityBadge(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
          decoration: BoxDecoration(
            color: AppColors.terracottaAlertLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.terracottaAlertBorder, width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.priority_high_rounded, size: 11, color: AppColors.terracottaAlert),
              const SizedBox(width: 2),
              Text(
                'ƯU TIÊN CAO',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.terracottaAlert,
                ),
              ),
            ],
          ),
        );
      case 'medium':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
          decoration: BoxDecoration(
            color: AppColors.warningAmberLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.warningAmberBorder, width: 0.8),
          ),
          child: Text(
            'TRUNG BÌNH',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.warningAmber,
            ),
          ),
        );
      case 'low':
      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.softIceBlue, width: 0.8),
          ),
          child: Text(
            'THẤP',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppColors.slateSteel,
            ),
          ),
        );
    }
  }

  Widget _buildAssigneeBadge() {
    final assignee = task.primaryAssignee ??
        (task.assignees.isNotEmpty ? task.assignees.first : task.createdBy);

    if (assignee == null || assignee.fullName.isEmpty) {
      return const SizedBox.shrink();
    }

    final name = assignee.fullName;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrutalistAvatar(
          avatarUrl: assignee.avatarUrl,
          name: name,
          size: 22,
          backgroundColor: AppColors.midnightIndigo,
        ),
        const SizedBox(width: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 120),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.obsidianDark,
            ),
          ),
        ),
      ],
    );
  }
}
