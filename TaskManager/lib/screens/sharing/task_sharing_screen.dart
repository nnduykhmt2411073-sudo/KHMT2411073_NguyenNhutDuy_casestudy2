import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../utils/app_colors.dart';
import '../../widgets/brutalist_manage_members_modal.dart';
import '../../widgets/brutalist_share_modal.dart';

/// Màn hình quản lý chia sẻ & phân quyền RBAC (Sharing Screen - C3/C4)
/// Khớp chuẩn cấu trúc thư mục lib/screens/sharing/task_sharing_screen.dart
class TaskSharingScreen extends StatefulWidget {
  final Task task;
  final VoidCallback? onShared;

  const TaskSharingScreen({
    super.key,
    required this.task,
    this.onShared,
  });

  @override
  State<TaskSharingScreen> createState() => _TaskSharingScreenState();
}

class _TaskSharingScreenState extends State<TaskSharingScreen> {
  late Task _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  Future<void> _openShareModal() async {
    final updated =
        await BrutalistShareModal.show(context: context, task: _task);
    if (updated != null && mounted) {
      setState(() => _task = updated);
      widget.onShared?.call();
    }
  }

  Future<void> _openManageMembersModal() async {
    final updated =
        await BrutalistManageMembersModal.show(context: context, task: _task);
    if (updated != null && mounted) {
      setState(() => _task = updated);
      widget.onShared?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final shares = _task.sharedWith;

    return Scaffold(
      backgroundColor: AppColors.frostBackground,
      appBar: AppBar(
        title: const Text('QUẢN LÝ CHIA SẺ & PHÂN QUYỀN'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.obsidianDark,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _task.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.obsidianDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Đã chia sẻ cho: ${shares.length} thành viên',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.slateSteel,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openShareModal,
              icon: const Icon(Icons.share_rounded),
              label: const Text('CHIA SẺ CHO NGƯỜI MỚI (VIEWER / EDITOR)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.royalCobalt,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _openManageMembersModal,
              icon: const Icon(Icons.manage_accounts_rounded),
              label: const Text('QUẢN LÝ VAI TRÒ & THU HỒI QUYỀN'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.royalCobalt,
                side: const BorderSide(color: AppColors.royalCobalt),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: shares.isEmpty
                  ? const Center(
                      child: Text(
                        'Chưa có người nào được chia sẻ.',
                        style: TextStyle(color: AppColors.slateSteel),
                      ),
                    )
                  : ListView.separated(
                      itemCount: shares.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final share = shares[index];
                        final user = share.user;
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.secondarySurface,
                                child: Text(
                                  user.fullName.isNotEmpty
                                      ? user.fullName[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.royalCobalt,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.fullName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      user.email,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.slateSteel,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: share.role == 'editor'
                                      ? AppColors.skyAzure.withValues(alpha: 0.15)
                                      : AppColors.secondarySurface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  share.role.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: share.role == 'editor'
                                        ? AppColors.royalCobalt
                                        : AppColors.slateSteel,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
