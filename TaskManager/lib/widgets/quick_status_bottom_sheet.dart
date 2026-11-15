import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../utils/app_colors.dart';

/// Modal chuyển trạng thái nhanh chuẩn phong cách Modern B2B SaaS (Frost-Obsidian: Bo góc 24px, viền mảnh softIceBlue)
class QuickStatusBottomSheet {
  static void show({
    required BuildContext context,
    required Task task,
    required Function(Task updatedTask) onUpdated,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _QuickStatusModalContent(
        task: task,
        onUpdated: onUpdated,
      ),
    );
  }
}

class _QuickStatusModalContent extends StatefulWidget {
  final Task task;
  final Function(Task updatedTask) onUpdated;

  const _QuickStatusModalContent({
    required this.task,
    required this.onUpdated,
  });

  @override
  State<_QuickStatusModalContent> createState() => _QuickStatusModalContentState();
}

class _QuickStatusModalContentState extends State<_QuickStatusModalContent> {
  final _taskService = TaskService();
  bool _isLoading = false;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.task.status;
  }

  Future<void> _updateStatus(String status) async {
    if (status == widget.task.status) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isLoading = true;
      _selectedStatus = status;
    });

    try {
      final updated = await _taskService.updateTaskStatus(widget.task.id, status);
      if (!mounted) return;

      widget.onUpdated(updated);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ĐÃ ĐỔI TRẠNG THÁI THÀNH CÔNG',
            style: GoogleFonts.jetBrainsMono(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.royalCobalt,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'LỖI: ${e.toString().replaceAll('Exception: ', '')}',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppColors.terracottaAlert,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Drag handle bar
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
            'CHUYỂN TRẠNG THÁI NHANH (B4)',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.obsidianDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.task.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.slateSteel,
            ),
          ),
          const SizedBox(height: 18),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.royalCobalt,
                  strokeWidth: 2.5,
                ),
              ),
            )
          else ...[
            _buildStatusOption(
              status: 'todo',
              title: 'CHỜ XỬ LÝ (TODO)',
              subtitle: 'Công việc mới tiếp nhận hoặc chưa bắt đầu',
              activeBg: AppColors.frostBackground,
              accentColor: AppColors.slateSteel,
              icon: Icons.hourglass_empty_rounded,
            ),
            const SizedBox(height: 10),
            _buildStatusOption(
              status: 'in_progress',
              title: 'ĐANG LÀM (IN PROGRESS)',
              subtitle: 'Đang trong quá trình triển khai thực hiện',
              activeBg: const Color(0xFFE8F4FD),
              accentColor: AppColors.skyAzure,
              icon: Icons.sync_rounded,
            ),
            const SizedBox(height: 10),
            _buildStatusOption(
              status: 'completed',
              title: 'HOÀN THÀNH (COMPLETED)',
              subtitle: 'Đã hoàn tất toàn bộ yêu cầu công việc',
              activeBg: AppColors.successMintLight,
              accentColor: AppColors.successMint,
              icon: Icons.check_circle_rounded,
            ),
            const SizedBox(height: 10),
            _buildStatusOption(
              status: 'cancelled',
              title: 'ĐÃ HỦY (CANCELLED)',
              subtitle: 'Hủy bỏ không tiếp tục thực hiện',
              activeBg: AppColors.terracottaAlertLight,
              accentColor: AppColors.terracottaAlert,
              icon: Icons.cancel_outlined,
            ),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildStatusOption({
    required String status,
    required String title,
    required String subtitle,
    required Color activeBg,
    required Color accentColor,
    required IconData icon,
  }) {
    final isCurrent = _selectedStatus == status;

    return GestureDetector(
      onTap: () => _updateStatus(status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isCurrent ? activeBg : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCurrent ? accentColor : AppColors.softIceBlue,
            width: isCurrent ? 1.5 : 1.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0603040B),
              offset: Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCurrent ? accentColor : AppColors.frostBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 16,
                color: isCurrent ? Colors.white : AppColors.slateSteel,
              ),
            ),
            const SizedBox(width: 12),
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
            if (isCurrent)
              Icon(
                Icons.check_circle_rounded,
                color: accentColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
