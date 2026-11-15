import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/task.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/task_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/brutalist_button.dart';
import '../../widgets/brutalist_card.dart';
import '../../widgets/brutalist_task_card.dart';
import '../../widgets/brutalist_avatar.dart';
import '../../widgets/quick_status_bottom_sheet.dart';
import '../auth/welcome_screen.dart';
import '../profile/profile_screen.dart';
import '../notifications/notification_screen.dart';
import '../stats/statistics_screen.dart';
import '../../services/notification_service.dart';
import 'task_create_screen.dart';
import 'task_detail_screen.dart';

/// Màn hình danh sách công việc & Dashboard điều hành chuẩn Modern B2B SaaS (Frost Blue & Deep Obsidian)
/// Tuân thủ quy chuẩn skill flutter-saas-builder: Top Header, Hero Summary Card, Three Numbers Overview, Flat Layered UI
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _authService = AuthService();
  final _taskService = TaskService();
  final _notificationService = NotificationService.instance;
  int _unreadNotificationCount = 0;

  User? _currentUser;
  List<Task> _tasks = [];
  bool _isLoadingTasks = true;
  String? _errorMessage;

  // Search & Filters (B6 & C5)
  final TextEditingController _searchController = TextEditingController();
  String _selectedScopeFilter = 'all'; // all, created_by_me, assigned_to_me, shared_with_me
  String _selectedStatusFilter = 'all'; // all, todo, in_progress, completed, cancelled
  String _selectedPriorityFilter = 'all'; // all, high, medium, low
  String _selectedSortBy = 'createdAt'; // createdAt, dueDate, priority, title
  String _selectedOrder = 'desc'; // desc, asc
  String _sortLabel = 'MỚI NHẤT';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadUser(),
      _fetchTasks(),
      _fetchUnreadNotificationCount(),
    ]);
  }

  Future<void> _fetchUnreadNotificationCount() async {
    try {
      final res = await _notificationService.getNotifications(isRead: false, limit: 1);
      if (mounted) {
        setState(() {
          _unreadNotificationCount = res.unreadCount;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadUser() async {
    try {
      final cachedUser = await _authService.getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUser = cachedUser;
        });
      }

      final latestUser = await _authService.getProfile();
      if (mounted) {
        setState(() {
          _currentUser = latestUser;
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchTasks() async {
    setState(() {
      _isLoadingTasks = true;
      _errorMessage = null;
    });

    try {
      final tasks = await _taskService.getTasks(
        status: _selectedStatusFilter == 'all' ? null : _selectedStatusFilter,
        priority: _selectedPriorityFilter == 'all' ? null : _selectedPriorityFilter,
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        sortBy: _selectedSortBy,
        order: _selectedOrder,
        filterType: _selectedScopeFilter == 'all' ? null : _selectedScopeFilter,
      );
      if (mounted) {
        setState(() {
          _tasks = tasks;
          _isLoadingTasks = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoadingTasks = false;
        });
      }
    }
  }

  void _onScopeFilterSelected(String scope) {
    if (_selectedScopeFilter == scope) return;
    setState(() {
      _selectedScopeFilter = scope;
    });
    _fetchTasks();
  }

  void _onStatusFilterSelected(String filter) {
    if (_selectedStatusFilter == filter) return;
    setState(() {
      _selectedStatusFilter = filter;
    });
    _fetchTasks();
  }

  void _onPriorityFilterSelected(String filter) {
    if (_selectedPriorityFilter == filter) return;
    setState(() {
      _selectedPriorityFilter = filter;
    });
    _fetchTasks();
  }

  void _showSortBottomSheet() {
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
              'SẮP XẾP CÔNG VIỆC (B6)',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.obsidianDark,
              ),
            ),
            const SizedBox(height: 14),
            _buildSortOption('createdAt', 'desc', 'MỚI NHẤT (NGÀY TẠO GIẢM DẦN)'),
            const SizedBox(height: 8),
            _buildSortOption('createdAt', 'asc', 'CŨ NHẤT (NGÀY TẠO TĂNG DẦN)'),
            const SizedBox(height: 8),
            _buildSortOption('dueDate', 'asc', 'HẠN CHÓT GẦN NHẤT'),
            const SizedBox(height: 8),
            _buildSortOption('dueDate', 'desc', 'HẠN CHÓT XA NHẤT'),
            const SizedBox(height: 8),
            _buildSortOption('priority', 'desc', 'MỨC ƯU TIÊN CAO ĐẾN THẤP'),
            const SizedBox(height: 8),
            _buildSortOption('title', 'asc', 'THEO TIÊU ĐỀ (A ➔ Z)'),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String sortBy, String order, String label) {
    final isSelected = _selectedSortBy == sortBy && _selectedOrder == order;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSortBy = sortBy;
          _selectedOrder = order;
          _sortLabel = label.split(' (')[0];
        });
        Navigator.of(context).pop();
        _fetchTasks();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEBF3FC) : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.royalCobalt : AppColors.softIceBlue,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? AppColors.royalCobalt : AppColors.obsidianDark,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.royalCobalt),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.softIceBlue, width: 1.0),
        ),
        title: Text(
          'XÁC NHẬN ĐĂNG XUẤT',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.obsidianDark,
          ),
        ),
        content: Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi hệ thống Task Manager?',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.slateSteel,
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'HỦY',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.slateSteel,
              ),
            ),
          ),
          BrutalistButton(
            text: 'ĐĂNG XUẤT',
            icon: Icons.logout_rounded,
            backgroundColor: AppColors.terracottaAlert,
            textColor: Colors.white,
            height: 42,
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _authService.logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationScreen()),
    );
    if (mounted) {
      _fetchUnreadNotificationCount();
      _fetchTasks();
    }
  }

  Future<void> _openStatistics() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StatisticsScreen()),
    );
  }

  Future<void> _openProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
    _loadUser();
  }

  Future<void> _openCreateTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TaskCreateScreen()),
    );
    if (result == true) {
      _fetchTasks();
    }
  }

  Future<void> _openTaskDetail(Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskDetailScreen(
          taskId: task.id,
          initialTask: task,
        ),
      ),
    );
    if (result == true || mounted) {
      _fetchTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Thống kê nhanh từ danh sách tác vụ hiện tại
    final totalCount = _tasks.length;
    final todoCount = _tasks.where((t) => t.status == 'todo').length;
    final inProgressCount = _tasks.where((t) => t.status == 'in_progress').length;
    final completedCount = _tasks.where((t) => t.status == 'completed').length;
    final progressRatio = totalCount > 0 ? (completedCount / totalCount) : 0.0;
    final progressPercent = (progressRatio * 100).toInt();

    return Scaffold(
      backgroundColor: AppColors.frostBackground,
      // 1. Top Header chuẩn B2B SaaS
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.frostBackground,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            GestureDetector(
              onTap: _openProfile,
              child: BrutalistAvatar(
                avatarUrl: _currentUser?.avatarUrl,
                name: _currentUser?.fullName ?? 'U',
                size: 38,
                backgroundColor: AppColors.midnightIndigo,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xin chào, ${_currentUser?.fullName ?? "Người dùng"}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.obsidianDark,
                    ),
                  ),
                  Text(
                    'KHMT2411073 • Workspace OS',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.slateSteel,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          _buildHeaderIconButton(
            icon: Icons.bar_chart_rounded,
            tooltip: 'Thống kê & Báo cáo',
            onPressed: _openStatistics,
          ),
          const SizedBox(width: 6),
          Stack(
            clipBehavior: Clip.none,
            children: [
              _buildHeaderIconButton(
                icon: Icons.notifications_none_rounded,
                tooltip: 'Thông báo',
                onPressed: _openNotifications,
              ),
              if (_unreadNotificationCount > 0)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: AppColors.terracottaAlert,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      _unreadNotificationCount > 99 ? '99+' : '$_unreadNotificationCount',
                      style: GoogleFonts.jetBrainsMono(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 6),
          _buildHeaderIconButton(
            icon: Icons.logout_rounded,
            tooltip: 'Đăng xuất',
            onPressed: _showLogoutConfirmDialog,
          ),
          const SizedBox(width: 14),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.royalCobalt,
        backgroundColor: Colors.white,
        onRefresh: () async {
          await Future.wait([
            _loadUser(),
            _fetchTasks(),
            _fetchUnreadNotificationCount(),
          ]);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 2. Hero Summary Card (Thẻ tổng quan tương phản cao)
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        gradient: AppColors.heroGradient,
                        borderRadius: BorderRadius.circular(24.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x2203040B),
                            offset: Offset(0, 8),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.royalCobalt,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.bolt_rounded, size: 13, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text(
                                      'TỔNG QUAN TIẾN ĐỘ',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '$totalCount Công việc',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.softIceBlue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '$progressPercent%',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: Text(
                                  '($completedCount / $totalCount hoàn tất)',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.softIceBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          // Linear progress indicator bo tròn mềm mại
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progressRatio,
                              minHeight: 8,
                              backgroundColor: Colors.white.withValues(alpha: 0.15),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.skyAzure),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 3. "Three Numbers Overview" (Hàng 3 thẻ chỉ số ngang)
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            label: 'Chờ xử lý',
                            count: todoCount,
                            color: AppColors.slateSteel,
                            bgLight: AppColors.frostBackground,
                            icon: Icons.hourglass_empty_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMetricCard(
                            label: 'Đang làm',
                            count: inProgressCount,
                            color: AppColors.skyAzure,
                            bgLight: const Color(0xFFE8F4FD),
                            icon: Icons.sync_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMetricCard(
                            label: 'Hoàn thành',
                            count: completedCount,
                            color: AppColors.successMint,
                            bgLight: AppColors.successMintLight,
                            icon: Icons.check_circle_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 4. Scope Filter Tabs (Lọc theo quyền/phạm vi: Tất cả / Tôi tạo / Giao cho tôi / Được chia sẻ)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildScopeFilterChip('all', 'Tất cả (All)'),
                          const SizedBox(width: 8),
                          _buildScopeFilterChip('created_by_me', 'Tôi tạo'),
                          const SizedBox(width: 8),
                          _buildScopeFilterChip('assigned_to_me', 'Giao cho tôi'),
                          const SizedBox(width: 8),
                          _buildScopeFilterChip('shared_with_me', 'Được chia sẻ'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 5. Search Bar mềm mại chuẩn SaaS
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.softIceBlue, width: 1.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0603040B),
                            offset: Offset(0, 2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (_) => _fetchTasks(),
                        onChanged: (text) {
                          if (text.isEmpty) {
                            _fetchTasks();
                          }
                        },
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.obsidianDark,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm công việc theo tiêu đề, mô tả...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppColors.slateSteel,
                          ),
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.slateSteel),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, color: AppColors.slateSteel),
                                  onPressed: () {
                                    _searchController.clear();
                                    _fetchTasks();
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 6. Status Filter Chips
                    Row(
                      children: [
                        Text(
                          'TRẠNG THÁI',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slateSteel,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildSoftFilterChip('all', 'Tất cả', _selectedStatusFilter, _onStatusFilterSelected),
                          const SizedBox(width: 8),
                          _buildSoftFilterChip('todo', 'Chờ xử lý', _selectedStatusFilter, _onStatusFilterSelected),
                          const SizedBox(width: 8),
                          _buildSoftFilterChip('in_progress', 'Đang làm', _selectedStatusFilter, _onStatusFilterSelected),
                          const SizedBox(width: 8),
                          _buildSoftFilterChip('completed', 'Hoàn thành', _selectedStatusFilter, _onStatusFilterSelected),
                          const SizedBox(width: 8),
                          _buildSoftFilterChip('cancelled', 'Đã hủy', _selectedStatusFilter, _onStatusFilterSelected),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 7. Priority Filter Chips
                    Row(
                      children: [
                        Text(
                          'MỨC ĐỘ ƯU TIÊN',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slateSteel,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildSoftFilterChip('all', 'Tất cả', _selectedPriorityFilter, _onPriorityFilterSelected),
                          const SizedBox(width: 8),
                          _buildSoftFilterChip('high', 'Ưu tiên cao', _selectedPriorityFilter, _onPriorityFilterSelected),
                          const SizedBox(width: 8),
                          _buildSoftFilterChip('medium', 'Trung bình', _selectedPriorityFilter, _onPriorityFilterSelected),
                          const SizedBox(width: 8),
                          _buildSoftFilterChip('low', 'Thấp', _selectedPriorityFilter, _onPriorityFilterSelected),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 8. Section Header & Sort Action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'DANH SÁCH NHIỆM VỤ',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: AppColors.obsidianDark,
                          ),
                        ),
                        GestureDetector(
                          onTap: _showSortBottomSheet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.cardWhite,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.softIceBlue, width: 1.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0603040B),
                                  offset: Offset(0, 1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.sort_rounded, size: 14, color: AppColors.royalCobalt),
                                const SizedBox(width: 4),
                                Text(
                                  _sortLabel,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.royalCobalt,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 9. Danh sách Task hoặc các trạng thái rỗng/lỗi
            if (_isLoadingTasks)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.royalCobalt,
                    strokeWidth: 2.5,
                  ),
                ),
              )
            else if (_errorMessage != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: BrutalistCard(
                    backgroundColor: AppColors.cardWhite,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 44, color: AppColors.terracottaAlert),
                        const SizedBox(height: 12),
                        Text(
                          'KHÔNG THỂ TẢI CÔNG VIỆC',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.obsidianDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.slateSteel,
                          ),
                        ),
                        const SizedBox(height: 16),
                        BrutalistButton(
                          text: 'THỬ LẠI',
                          icon: Icons.refresh_rounded,
                          backgroundColor: AppColors.royalCobalt,
                          textColor: Colors.white,
                          onPressed: _fetchTasks,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_tasks.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.softIceBlue, width: 1.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0803040B),
                          offset: Offset(0, 4),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F1FC),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.assignment_outlined,
                            size: 32,
                            color: AppColors.royalCobalt,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'CHƯA CÓ CÔNG VIỆC NÀO',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.obsidianDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchController.text.isNotEmpty ||
                                  _selectedStatusFilter != 'all' ||
                                  _selectedPriorityFilter != 'all'
                              ? 'Không tìm thấy công việc nào phù hợp với bộ lọc hoặc từ khóa tìm kiếm.'
                              : 'Bạn chưa tạo hoặc chưa được phân công công việc nào. Hãy khởi tạo công việc đầu tiên ngay!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppColors.slateSteel,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        BrutalistButton(
                          text: 'TẠO CÔNG VIỆC MỚI',
                          icon: Icons.add_rounded,
                          backgroundColor: AppColors.royalCobalt,
                          textColor: Colors.white,
                          onPressed: _openCreateTask,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final task = _tasks[index];
                      return BrutalistTaskCard(
                        task: task,
                        currentUserId: _currentUser?.id,
                        onTap: () => _openTaskDetail(task),
                        onStatusTap: () {
                          QuickStatusBottomSheet.show(
                            context: context,
                            task: task,
                            onUpdated: (_) => _fetchTasks(),
                          );
                        },
                      );
                    },
                    childCount: _tasks.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
      // 10. FAB mềm mại bo góc 16px màu royalCobalt, đổ bóng mờ thanh lịch
      floatingActionButton: GestureDetector(
        onTap: _openCreateTask,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.royalCobalt,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.royalCobalt.withValues(alpha: 0.35),
                offset: const Offset(0, 6),
                blurRadius: 16,
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, size: 28, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softIceBlue, width: 1.0),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: AppColors.obsidianDark),
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required int count,
    required Color color,
    required Color bgLight,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.softIceBlue, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0603040B),
            offset: Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: bgLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              Text(
                '$count',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.obsidianDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.slateSteel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScopeFilterChip(String value, String label) {
    final isSelected = _selectedScopeFilter == value;

    return GestureDetector(
      onTap: () => _onScopeFilterSelected(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.royalCobalt : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.royalCobalt : AppColors.softIceBlue,
            width: 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.royalCobalt.withValues(alpha: 0.25),
                    offset: const Offset(0, 3),
                    blurRadius: 8,
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color(0x0403040B),
                    offset: Offset(0, 1),
                    blurRadius: 4,
                  ),
                ],
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.slateSteel,
          ),
        ),
      ),
    );
  }

  Widget _buildSoftFilterChip(
    String value,
    String label,
    String selectedValue,
    Function(String) onSelected,
  ) {
    final isSelected = selectedValue == value;

    return GestureDetector(
      onTap: () => onSelected(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.royalCobalt : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.royalCobalt : AppColors.softIceBlue,
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.slateSteel,
          ),
        ),
      ),
    );
  }
}
