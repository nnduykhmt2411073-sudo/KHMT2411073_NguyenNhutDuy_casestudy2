import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/user.dart';
import '../../services/task_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/validators.dart';
import '../../widgets/brutalist_button.dart';
import '../../widgets/brutalist_text_field.dart';
import '../../widgets/brutalist_user_picker.dart';

/// Màn hình khởi tạo công việc chuẩn Modern B2B SaaS (Frost Blue & Deep Obsidian)
/// Tuân thủ quy chuẩn skill flutter-saas-builder: Form Validation, Bo góc 14-20px, Viền mảnh 1px softIceBlue
class TaskCreateScreen extends StatefulWidget {
  const TaskCreateScreen({super.key});

  @override
  State<TaskCreateScreen> createState() => _TaskCreateScreenState();
}

class _TaskCreateScreenState extends State<TaskCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _taskService = TaskService();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _startDate;
  DateTime? _dueDate;
  String _priority = 'medium'; // low, medium, high
  String _status = 'todo'; // todo, in_progress

  // Assignment (C2)
  User? _primaryAssignee;
  List<User> _collaborators = [];

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initialDate = isStart
        ? (_startDate ?? now)
        : (_dueDate ?? _startDate ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.royalCobalt,
              onPrimary: Colors.white,
              surface: AppColors.cardWhite,
              onSurface: AppColors.obsidianDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_dueDate != null && _dueDate!.isBefore(_startDate!)) {
            _dueDate = _startDate;
          }
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  Future<void> _pickPrimaryAssignee() async {
    final results = await BrutalistUserPicker.show(
      context: context,
      title: 'NGƯỜI PHỤ TRÁCH CHÍNH // C2',
      isMultiSelect: false,
      initialSelected: _primaryAssignee != null ? [_primaryAssignee!] : [],
    );

    if (results != null && results.isNotEmpty) {
      setState(() {
        _primaryAssignee = results.first;
        if (!_collaborators.any((u) => u.id == _primaryAssignee!.id)) {
          _collaborators.add(_primaryAssignee!);
        }
      });
    }
  }

  Future<void> _pickCollaborators() async {
    final results = await BrutalistUserPicker.show(
      context: context,
      title: 'THÀNH VIÊN THAM GIA // C2',
      isMultiSelect: true,
      initialSelected: _collaborators,
    );

    if (results != null) {
      setState(() {
        _collaborators = results;
      });
    }
  }

  Future<void> _handleCreateTask() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate != null && _dueDate != null && _dueDate!.isBefore(_startDate!)) {
      setState(() {
        _errorMessage = 'Hạn hoàn thành không thể trước ngày bắt đầu!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final task = await _taskService.createTask(
        title: _titleController.text,
        description: _descriptionController.text,
        startDate: _startDate,
        dueDate: _dueDate,
        priority: _priority,
        status: _status,
        primaryAssigneeId: _primaryAssignee?.id,
        assigneeIds: _collaborators.map((u) => u.id).toList(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.royalCobalt,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Đã tạo công việc: "${task.title}"',
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

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
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
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: AppColors.frostBackground,
      appBar: AppBar(
        backgroundColor: AppColors.frostBackground,
        elevation: 0,
        title: Text(
          'Tạo công việc mới',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.obsidianDark,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF3FC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.softIceBlue, width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_task_rounded, size: 14, color: AppColors.royalCobalt),
                          const SizedBox(width: 5),
                          Text(
                            'TASK OPS // B1 & C2',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.royalCobalt,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'KHMT2411073',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slateSteel,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Error Banner nếu có
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.terracottaAlertLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFF3C7C2), width: 1.0),
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
                  const SizedBox(height: 14),
                ],

                // Form Card chính
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: AppColors.softIceBlue, width: 1.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A03040B),
                        offset: Offset(0, 4),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tên công việc
                      BrutalistTextField(
                        label: 'Tên công việc *',
                        hintText: 'VD: Hoàn thiện báo cáo đồ án Case Study 2',
                        controller: _titleController,
                        prefixIcon: const Icon(Icons.title_rounded, color: AppColors.slateSteel),
                        validator: (val) => Validators.required(val, 'Tên công việc'),
                      ),
                      const SizedBox(height: 16),

                      // Mô tả
                      BrutalistTextField(
                        label: 'Mô tả chi tiết',
                        hintText: 'Nhập nội dung, yêu cầu cụ thể của công việc...',
                        controller: _descriptionController,
                        maxLines: 4,
                        prefixIcon: const Icon(Icons.notes_rounded, color: AppColors.slateSteel),
                      ),
                      const SizedBox(height: 20),

                      // PHÂN CÔNG NHÂN SỰ (C2)
                      Text(
                        'PHÂN CÔNG NHÂN SỰ (C2)',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppColors.slateSteel,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Người phụ trách chính
                      GestureDetector(
                        onTap: _pickPrimaryAssignee,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.frostBackground.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.softIceBlue, width: 1.0),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: AppColors.midnightIndigo,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _primaryAssignee != null && _primaryAssignee!.fullName.isNotEmpty
                                      ? _primaryAssignee!.fullName[0].toUpperCase()
                                      : '★',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'NGƯỜI PHỤ TRÁCH CHÍNH',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.slateSteel,
                                      ),
                                    ),
                                    Text(
                                      _primaryAssignee?.fullName ?? 'Mặc định (Bạn)',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.obsidianDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.slateSteel),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Thành viên tham gia
                      GestureDetector(
                        onTap: _pickCollaborators,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.frostBackground.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.softIceBlue, width: 1.0),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F1FC),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.group_add_rounded, color: AppColors.royalCobalt, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'THÀNH VIÊN CÙNG THAM GIA',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.slateSteel,
                                      ),
                                    ),
                                    Text(
                                      _collaborators.isEmpty
                                          ? 'Nhấn để chọn thành viên...'
                                          : 'Đã chọn ${_collaborators.length} thành viên',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: _collaborators.isEmpty
                                            ? AppColors.slateSteel
                                            : AppColors.obsidianDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, size: 22, color: AppColors.slateSteel),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Ngày bắt đầu & Hạn hoàn thành
                      Text(
                        'THỜI GIAN THỰC HIỆN',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppColors.slateSteel,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _pickDate(isStart: true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.cardWhite,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.softIceBlue, width: 1.0),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.skyAzure),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'BẮT ĐẦU',
                                            style: GoogleFonts.jetBrainsMono(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.slateSteel,
                                            ),
                                          ),
                                          Text(
                                            _startDate != null ? dateFormat.format(_startDate!) : 'Chọn ngày',
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: _startDate != null ? AppColors.obsidianDark : AppColors.slateSteel,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _pickDate(isStart: false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.cardWhite,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.softIceBlue, width: 1.0),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.event_available_rounded, size: 16, color: AppColors.terracottaAlert),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'HẠN CHÓT',
                                            style: GoogleFonts.jetBrainsMono(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.terracottaAlert,
                                            ),
                                          ),
                                          Text(
                                            _dueDate != null ? dateFormat.format(_dueDate!) : 'Chọn hạn',
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: _dueDate != null ? AppColors.obsidianDark : AppColors.slateSteel,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Mức độ ưu tiên
                      Text(
                        'MỨC ĐỘ ƯU TIÊN',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppColors.slateSteel,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildPriorityOption('low', 'THẤP', AppColors.frostBackground, AppColors.slateSteel),
                          const SizedBox(width: 8),
                          _buildPriorityOption('medium', 'TRUNG BÌNH', const Color(0xFFFFF7E6), const Color(0xFFD48806)),
                          const SizedBox(width: 8),
                          _buildPriorityOption('high', 'CAO / KHẨN', AppColors.terracottaAlertLight, AppColors.terracottaAlert),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Trạng thái ban đầu
                      Text(
                        'TRẠNG THÁI BAN ĐẦU',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppColors.slateSteel,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildStatusOption('todo', 'CHỜ XỬ LÝ'),
                          const SizedBox(width: 8),
                          _buildStatusOption('in_progress', 'ĐANG LÀM'),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Nút Tạo công việc
                      BrutalistButton(
                        text: 'TẠO CÔNG VIỆC MỚI',
                        icon: Icons.check_circle_outline_rounded,
                        isLoading: _isLoading,
                        width: double.infinity,
                        height: 50,
                        backgroundColor: AppColors.royalCobalt,
                        textColor: Colors.white,
                        onPressed: _handleCreateTask,
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

  Widget _buildPriorityOption(String value, String label, Color bgLight, Color accentColor) {
    final isSelected = _priority == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _priority = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? bgLight : AppColors.cardWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? accentColor : AppColors.softIceBlue,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? accentColor : AppColors.slateSteel,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusOption(String value, String label) {
    final isSelected = _status == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _status = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.royalCobalt : AppColors.cardWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.royalCobalt : AppColors.softIceBlue,
              width: 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.slateSteel,
            ),
          ),
        ),
      ),
    );
  }
}
