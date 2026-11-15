import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../utils/app_colors.dart';
import 'brutalist_avatar.dart';

/// Thẻ công việc chuẩn phong cách Modern B2B SaaS (Frost-Obsidian: Bo góc 18px, viền 1px softIceBlue, bóng mềm đa tầng)
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
        margin: const EdgeInsets.only(bottom: 14.0),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(18.0),
          border: Border.all(color: AppColors.softIceBlue, width: 1.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A03040B),
              offset: Offset(0, 4),
              blurRadius: 14,
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Scope Badge (Tôi tạo / Được chia sẻ RBAC - C5) + Priority Badge
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
            const SizedBox(height: 12),

            // Task Title
            Text(
              task.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.obsidianDark,
                height: 1.3,
              ),
            ),

            // Task Description (if any)
            if (task.description.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
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

            const SizedBox(height: 14),

            // Divider line mềm mại
            Container(
              height: 1.0,
              color: AppColors.softIceBlue.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 12),

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
                        size: 14,
                        color: isOverdue ? AppColors.terracottaAlert : AppColors.slateSteel,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('dd/MM/yyyy').format(task.dueDate!),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isOverdue ? AppColors.terracottaAlert : AppColors.slateSteel,
                        ),
                      ),
                      if (isOverdue) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.terracottaAlertLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFF3C7C2), width: 0.8),
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
                        size: 14,
                        color: AppColors.slateSteel,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'KHÔNG CÓ HẠN',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFEBF3FC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.softIceBlue, width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, size: 12, color: AppColors.royalCobalt),
            const SizedBox(width: 4),
            Text(
              'CHỦ SỞ HỮU',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isAdmin ? AppColors.terracottaAlertLight : const Color(0xFFF0F4FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAdmin ? const Color(0xFFF3C7C2) : AppColors.softIceBlue,
            width: 0.8,
          ),
        ),
        child: Text(
          'CHIA SẺ // $role',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isAdmin ? AppColors.terracottaAlert : AppColors.midnightIndigo,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.frostBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.softIceBlue, width: 0.8),
        ),
        child: Text(
          'ĐƯỢC PHÂN CÔNG',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F4FD),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.softIceBlue, width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sync_rounded, size: 13, color: AppColors.skyAzure),
              const SizedBox(width: 5),
              Text(
                'ĐANG LÀM',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.skyAzure,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.skyAzure),
            ],
          ),
        );
      case 'completed':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.successMintLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFB7EB8F), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, size: 13, color: AppColors.successMint),
              const SizedBox(width: 5),
              Text(
                'HOÀN THÀNH',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.successMint,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.successMint),
            ],
          ),
        );
      case 'cancelled':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.terracottaAlertLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF3C7C2), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cancel_outlined, size: 13, color: AppColors.terracottaAlert),
              const SizedBox(width: 5),
              Text(
                'ĐÃ HỦY',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.terracottaAlert,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.terracottaAlert),
            ],
          ),
        );
      case 'todo':
      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.frostBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.softIceBlue, width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.hourglass_empty_rounded, size: 13, color: AppColors.slateSteel),
              const SizedBox(width: 5),
              Text(
                'CHỜ XỬ LÝ',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slateSteel,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.slateSteel),
            ],
          ),
        );
    }
  }

  Widget _buildPriorityBadge(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.terracottaAlertLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF3C7C2), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.priority_high_rounded, size: 12, color: AppColors.terracottaAlert),
              const SizedBox(width: 3),
              Text(
                'ƯU TIÊN CAO',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.terracottaAlert,
                ),
              ),
            ],
          ),
        );
      case 'medium':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7E6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFE7BA), width: 0.8),
          ),
          child: Text(
            'TRUNG BÌNH',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFD48806),
            ),
          ),
        );
      case 'low':
      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.frostBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.softIceBlue, width: 0.8),
          ),
          child: Text(
            'THẤP',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
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
          size: 24,
          backgroundColor: AppColors.midnightIndigo,
        ),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 120),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.obsidianDark,
            ),
          ),
        ),
      ],
    );
  }
}
