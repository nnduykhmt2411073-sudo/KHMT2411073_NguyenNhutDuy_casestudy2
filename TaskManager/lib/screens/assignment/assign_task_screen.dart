import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/brutalist_user_picker.dart';

/// Màn hình phân công công việc (Assignment Screen - C1/C2)
/// Khớp chuẩn cấu trúc thư mục lib/screens/assignment/assign_task_screen.dart
class AssignTaskScreen extends StatefulWidget {
  final Task task;
  final VoidCallback? onAssigned;

  const AssignTaskScreen({
    super.key,
    required this.task,
    this.onAssigned,
  });

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  final TaskService _taskService = TaskService();
  late Task _task;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  Future<void> _changePrimaryAssignee() async {
    final picked = await BrutalistUserPicker.show(
      context: context,
      title: 'ĐỔI NGƯỜI PHỤ TRÁCH CHÍNH',
      isMultiSelect: false,
      initialSelected:
          _task.primaryAssignee != null ? [_task.primaryAssignee!] : [],
    );

    if (picked != null && picked.isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        final updated = await _taskService.assignTask(
          _task.id,
          primaryAssigneeId: picked.first.id,
        );
        if (mounted) {
          setState(() {
            _task = updated;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã cập nhật người phụ trách chính!'),
              backgroundColor: AppColors.successMint,
            ),
          );
          widget.onAssigned?.call();
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: $e'),
              backgroundColor: AppColors.terracottaAlert,
            ),
          );
        }
      }
    }
  }

  Future<void> _manageAssignees() async {
    final picked = await BrutalistUserPicker.show(
      context: context,
      title: 'CHỌN THÀNH VIÊN THAM GIA',
      isMultiSelect: true,
      initialSelected: _task.assignees,
    );

    if (picked != null) {
      setState(() => _isLoading = true);
      try {
        final updated = await _taskService.assignTask(
          _task.id,
          assigneeIds: picked.map((u) => u.id).toList(),
        );
        if (mounted) {
          setState(() {
            _task = updated;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã cập nhật danh sách người được giao việc!'),
              backgroundColor: AppColors.successMint,
            ),
          );
          widget.onAssigned?.call();
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: $e'),
              backgroundColor: AppColors.terracottaAlert,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.frostBackground,
      appBar: AppBar(
        title: const Text('PHÂN CÔNG CÔNG VIỆC'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.obsidianDark,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                          'Số người tham gia: ${_task.assignees.length}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.slateSteel,
                          ),
                        ),
                        if (_task.primaryAssignee != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Phụ trách chính: ${_task.primaryAssignee!.fullName}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.royalCobalt,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _changePrimaryAssignee,
                    icon: const Icon(Icons.star_rounded),
                    label: const Text('ĐỔI NGƯỜI PHỤ TRÁCH CHÍNH'),
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
                    onPressed: _manageAssignees,
                    icon: const Icon(Icons.people_outline_rounded),
                    label: const Text('QUẢN LÝ TẤT CẢ THÀNH VIÊN ĐƯỢC GIAO'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.royalCobalt,
                      side: const BorderSide(color: AppColors.royalCobalt),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
