import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/brutalist_button.dart';
import '../../widgets/brutalist_text_field.dart';

/// Màn hình chỉnh sửa công việc chuẩn Modern B2B SaaS (Frost Blue & Deep Obsidian)
/// Tuân thủ quy chuẩn skill flutter-saas-builder: Form Validation, Bo góc 14-20px, Viền mảnh 1px softIceBlue
class TaskEditScreen extends StatefulWidget {
  final Task task;

  const TaskEditScreen({
    super.key,
    required this.task,
  });

  @override
  State<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _taskService = TaskService();

  late TextEditingController _titleController;
  late TextEditingController _descController;

  DateTime? _startDate;
  DateTime? _dueDate;
  late String _priority;
  late String _status;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description);
    _startDate = widget.task.startDate;
    _dueDate = widget.task.dueDate;
    _priority = widget.task.priority;
    _status = widget.task.status;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.royalCobalt,
            onPrimary: Colors.white,
            surface: AppColors.cardWhite,
            onSurface: AppColors.obsidianDark,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? (_startDate ?? DateTime.now()).add(const Duration(days: 1)),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.royalCobalt,
            onPrimary: Colors.white,
            surface: AppColors.cardWhite,
            onSurface: AppColors.obsidianDark,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final updatedTask = await _taskService.updateTask(
        widget.task.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        startDate: _startDate,
        dueDate: _dueDate,
        priority: _priority,
        status: _status,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ĐÃ CẬP NHẬT CÔNG VIỆC THÀNH CÔNG',
            style: GoogleFonts.jetBrainsMono(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.royalCobalt,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: AppColors.frostBackground,
      appBar: AppBar(
        backgroundColor: AppColors.frostBackground,
        elevation: 0,
        title: Text(
          'Chỉnh sửa công việc',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.obsidianDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                        const Icon(Icons.edit_note_rounded, size: 14, color: AppColors.royalCobalt),
                        const SizedBox(width: 4),
                        Text(
                          'EDIT MODE // B4',
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
                    '#${widget.task.id.length > 6 ? widget.task.id.substring(widget.task.id.length - 6).toUpperCase() : widget.task.id}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slateSteel,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.terracottaAlertLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFF3C7C2), width: 1.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.terracottaAlert, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.terracottaAlert,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Card Form
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
                    // Tiêu đề
                    BrutalistTextField(
                      label: 'Tiêu đề công việc *',
                      controller: _titleController,
                      hintText: 'Nhập tiêu đề công việc...',
                      prefixIcon: const Icon(Icons.title_rounded, color: AppColors.slateSteel),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Tiêu đề không được để trống';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Mô tả
                    BrutalistTextField(
                      label: 'Mô tả chi tiết',
                      controller: _descController,
                      hintText: 'Nhập mô tả chi tiết yêu cầu công việc...',
                      prefixIcon: const Icon(Icons.notes_rounded, color: AppColors.slateSteel),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 20),

                    // Trạng thái hiện tại
                    Text(
                      'TRẠNG THÁI TIẾN ĐỘ',
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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatusOption('completed', 'HOÀN THÀNH'),
                        const SizedBox(width: 8),
                        _buildStatusOption('cancelled', 'ĐÃ HỦY'),
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
                        _buildPriorityOption('high', 'CAO', AppColors.terracottaAlertLight, AppColors.terracottaAlert),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Thời gian bắt đầu & hạn chót
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
                            onTap: _pickStartDate,
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
                            onTap: _pickDueDate,
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
                    const SizedBox(height: 28),

                    // Submit & Cancel buttons
                    BrutalistButton(
                      text: 'LƯU THAY ĐỔI',
                      icon: Icons.check_rounded,
                      backgroundColor: AppColors.royalCobalt,
                      textColor: Colors.white,
                      isLoading: _isLoading,
                      onPressed: _submitUpdate,
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'HỦY BỎ',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.slateSteel,
                          ),
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
    );
  }

  Widget _buildStatusOption(String value, String label) {
    final isSelected = _status == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _status = value),
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

  Widget _buildPriorityOption(String value, String label, Color bgLight, Color accentColor) {
    final isSelected = _priority == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _priority = value),
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
}
