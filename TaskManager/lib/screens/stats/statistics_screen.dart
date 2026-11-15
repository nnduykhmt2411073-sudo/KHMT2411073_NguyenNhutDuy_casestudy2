import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/task_stats.dart';
import '../../services/stats_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/brutalist_badge.dart';
import '../../widgets/brutalist_button.dart';
import '../../widgets/brutalist_card.dart';
import '../../widgets/brutalist_avatar.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final StatsService _statsService = StatsService.instance;

  TaskStatsData? _stats;
  bool _isLoading = true;
  String? _errorMessage;

  String _selectedTimeRange = 'all'; // all, today, week, month
  String _selectedScope = 'all'; // all, created_by_me, assigned_to_me

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _statsService.getTaskStats(
        timeRange: _selectedTimeRange,
        scope: _selectedScope,
      );

      if (mounted) {
        setState(() {
          _stats = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _exportReport() {
    if (_stats == null) return;
    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm - dd/MM/yyyy').format(now);

    final buffer = StringBuffer();
    buffer.writeln('====================================================');
    buffer.writeln('TASK MANAGER // BÁO CÁO TIẾN ĐỘ & HIỆU SUẤT CÔNG VIỆC');
    buffer.writeln('Thời gian lập báo cáo: $timeStr');
    buffer.writeln('Khoảng thời gian: ${_selectedTimeRange.toUpperCase()}');
    buffer.writeln('Phạm vi: ${_selectedScope.toUpperCase()}');
    buffer.writeln('----------------------------------------------------');
    buffer.writeln('📊 TỔNG QUAN CHỈ SỐ KPI:');
    buffer.writeln('- Tổng số công việc: ${_stats!.summary.totalTasks}');
    buffer.writeln('- Đã hoàn thành: ${_stats!.byStatus.completed.count} (${_stats!.summary.completionRate}%)');
    buffer.writeln('- Đang thực hiện: ${_stats!.byStatus.inProgress.count} (${_stats!.byStatus.inProgress.percentage}%)');
    buffer.writeln('- Chờ xử lý: ${_stats!.byStatus.todo.count} (${_stats!.byStatus.todo.percentage}%)');
    buffer.writeln('- Đã hủy: ${_stats!.byStatus.cancelled.count}');
    buffer.writeln('- Tỷ lệ hoàn thành đúng hạn: ${_stats!.summary.completedOnTimeRate}%');
    buffer.writeln('----------------------------------------------------');
    buffer.writeln('⚠️ GIÁM SÁT HẠN CHÓT (DEADLINES):');
    buffer.writeln('- Quá hạn: ${_stats!.deadlines.overdue}');
    buffer.writeln('- Sắp tới hạn (trong 24h): ${_stats!.deadlines.dueSoon}');
    buffer.writeln('- Đã xong đúng hạn: ${_stats!.deadlines.completedOnTime}');
    buffer.writeln('----------------------------------------------------');
    buffer.writeln('👥 KHỐI LƯỢNG CÔNG VIỆC THÀNH VIÊN:');
    for (int i = 0; i < _stats!.memberWorkloads.length; i++) {
      final m = _stats!.memberWorkloads[i];
      buffer.writeln('${i + 1}. ${m.user.fullName} (${m.user.email}) - Xong: ${m.completedCount}/${m.taskCount} (${m.completionRate}%)');
    }
    buffer.writeln('====================================================');
    buffer.writeln('Hệ thống Quản lý công việc nhóm - Case Study 2');

    final reportText = buffer.toString();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.softIceBlue, width: 1.0),
        ),
        title: Text(
          'XUẤT BÁO CÁO TỔNG HỢP',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.obsidianDark,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.frostBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.softIceBlue, width: 1.0),
              ),
              child: Text(
                reportText,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.obsidianDark,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'ĐÓNG',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.slateSteel,
              ),
            ),
          ),
          BrutalistButton(
            text: 'SAO CHÉP BÁO CÁO',
            icon: Icons.copy_rounded,
            height: 42,
            backgroundColor: AppColors.royalCobalt,
            textColor: Colors.white,
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final nav = Navigator.of(ctx);
              await Clipboard.setData(ClipboardData(text: reportText));
              nav.pop();
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    'Đã sao chép báo cáo tóm tắt vào bộ nhớ tạm!',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: AppColors.obsidianDark,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _onTimeRangeChanged(String range) {
    if (_selectedTimeRange == range) return;
    setState(() {
      _selectedTimeRange = range;
    });
    _fetchStats();
  }

  void _showMemberPerformanceDialog(TaskMemberWorkload member) {
    final rate = member.completionRate;
    String ratingText = 'XUẤT SẮC 🌟';
    Color ratingBg = AppColors.successMintLight;
    Color ratingColor = AppColors.successMint;
    Color ratingBorder = AppColors.successMintBorder;

    if (rate < 50) {
      ratingText = 'CẦN ĐẨY NHANH ⚠️';
      ratingBg = AppColors.terracottaAlertLight;
      ratingColor = AppColors.terracottaAlert;
      ratingBorder = AppColors.terracottaAlertBorder;
    } else if (rate < 80) {
      ratingText = 'ĐẠT TIẾN ĐỘ 🚀';
      ratingBg = AppColors.inProgressBlueLight;
      ratingColor = AppColors.royalCobalt;
      ratingBorder = AppColors.inProgressBlueBorder;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.softIceBlue, width: 1.0),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        title: Row(
          children: [
            BrutalistAvatar(
              avatarUrl: member.user.avatarUrl,
              name: member.user.fullName,
              size: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.user.fullName,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.obsidianDark,
                    ),
                  ),
                  Text(
                    member.user.email,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.slateSteel,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Divider(color: AppColors.softIceBlue, thickness: 1.0),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ĐÁNH GIÁ HIỆU SUẤT:',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slateSteel,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: ratingBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: ratingBorder, width: 1.0),
                    ),
                    child: Text(
                      ratingText,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: ratingColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.frostBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.softIceBlue, width: 1.0),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${member.taskCount}',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.obsidianDark,
                            ),
                          ),
                          Text(
                            'ĐƯỢC GIAO',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slateSteel,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.successMintLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.successMintBorder, width: 1.0),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${member.completedCount}',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.successMint,
                            ),
                          ),
                          Text(
                            'HOÀN THÀNH',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.successMint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: member.overdueCount > 0
                            ? AppColors.terracottaAlertLight
                            : AppColors.frostBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: member.overdueCount > 0
                              ? AppColors.terracottaAlertBorder
                              : AppColors.softIceBlue,
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${member.overdueCount}',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: member.overdueCount > 0
                                  ? AppColors.terracottaAlert
                                  : AppColors.obsidianDark,
                            ),
                          ),
                          Text(
                            'QUÁ HẠN',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: member.overdueCount > 0
                                  ? AppColors.terracottaAlert
                                  : AppColors.slateSteel,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tỷ lệ hoàn thành:',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.obsidianDark,
                    ),
                  ),
                  Text(
                    '$rate%',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.royalCobalt,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  final barWidth = (constraints.maxWidth * (rate / 100.0)).clamp(0.0, constraints.maxWidth);
                  return Container(
                    height: 10,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.secondarySurface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: barWidth,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.royalCobalt,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              BrutalistButton(
                text: 'ĐÓNG',
                backgroundColor: AppColors.royalCobalt,
                textColor: Colors.white,
                height: 40,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onScopeChanged(String scope) {
    if (_selectedScope == scope) return;
    setState(() {
      _selectedScope = scope;
    });
    _fetchStats();
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.royalCobalt : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(12),
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
            letterSpacing: 0.3,
            color: isSelected ? Colors.white : AppColors.slateSteel,
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String label,
    required String value,
    required String subtitle,
    required Color backgroundColor,
    required Color textColor,
    IconData? icon,
    bool isAlert = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAlert ? AppColors.terracottaAlertLight : AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAlert ? AppColors.terracottaAlertBorder : AppColors.softIceBlue,
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0603040B),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: isAlert ? AppColors.terracottaAlert : AppColors.slateSteel,
                ),
              ),
              if (icon != null)
                Icon(
                  icon,
                  size: 16,
                  color: isAlert ? AppColors.terracottaAlert : AppColors.royalCobalt,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: isAlert ? AppColors.terracottaAlert : textColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isAlert ? AppColors.terracottaAlert : AppColors.slateSteel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar({
    required String label,
    required int count,
    required int percentage,
    required Color fillColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.obsidianDark,
                ),
              ),
              Text(
                '$count ($percentage%)',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slateSteel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.secondarySurface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (percentage / 100.0).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.frostBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardWhite,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'THỐNG KÊ & BÁO CÁO',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: AppColors.obsidianDark,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.obsidianDark),
            tooltip: 'Xuất báo cáo tóm tắt',
            onPressed: _exportReport,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.obsidianDark),
            tooltip: 'Làm mới số liệu',
            onPressed: _fetchStats,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.softIceBlue,
            height: 1,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.royalCobalt,
        backgroundColor: AppColors.cardWhite,
        onRefresh: _fetchStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Badge & Subtitle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BrutalistBadge(
                    text: 'MODULE E // KPI REPORT',
                    backgroundColor: AppColors.inProgressBlueLight,
                    textColor: AppColors.royalCobalt,
                    icon: Icons.pie_chart_outline_rounded,
                  ),
                  BrutalistBadge(
                    text: 'REAL-TIME DATA',
                    backgroundColor: AppColors.successMintLight,
                    textColor: AppColors.successMint,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Filter Controls Card
              BrutalistCard(
                backgroundColor: AppColors.cardWhite,
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KHOẢNG THỜI GIAN',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.slateSteel,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChip(
                          label: 'TẤT CẢ',
                          isSelected: _selectedTimeRange == 'all',
                          onTap: () => _onTimeRangeChanged('all'),
                        ),
                        _buildFilterChip(
                          label: 'HÔM NAY',
                          isSelected: _selectedTimeRange == 'today',
                          onTap: () => _onTimeRangeChanged('today'),
                        ),
                        _buildFilterChip(
                          label: '7 NGÀY QUA',
                          isSelected: _selectedTimeRange == 'week',
                          onTap: () => _onTimeRangeChanged('week'),
                        ),
                        _buildFilterChip(
                          label: 'THÁNG NÀY',
                          isSelected: _selectedTimeRange == 'month',
                          onTap: () => _onTimeRangeChanged('month'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: AppColors.softIceBlue, thickness: 1.0),
                    const SizedBox(height: 8),
                    Text(
                      'PHẠM VI CÔNG VIỆC',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.slateSteel,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChip(
                          label: 'TẤT CẢ LIÊN QUAN',
                          isSelected: _selectedScope == 'all',
                          onTap: () => _onScopeChanged('all'),
                        ),
                        _buildFilterChip(
                          label: 'TÔI TẠO',
                          isSelected: _selectedScope == 'created_by_me',
                          onTap: () => _onScopeChanged('created_by_me'),
                        ),
                        _buildFilterChip(
                          label: 'GIAO CHO TÔI',
                          isSelected: _selectedScope == 'assigned_to_me',
                          onTap: () => _onScopeChanged('assigned_to_me'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Loading / Error / Content
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.royalCobalt),
                  ),
                )
              else if (_errorMessage != null)
                BrutalistCard(
                  backgroundColor: AppColors.cardWhite,
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AppColors.terracottaAlert, size: 40),
                      const SizedBox(height: 10),
                      Text(
                        'LỖI TẢI THỐNG KÊ',
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
                      const SizedBox(height: 14),
                      BrutalistButton(
                        text: 'TẢI LẠI',
                        icon: Icons.refresh_rounded,
                        backgroundColor: AppColors.royalCobalt,
                        textColor: Colors.white,
                        onPressed: _fetchStats,
                      ),
                    ],
                  ),
                )
              else if (_stats != null) ...[
                // Top KPI Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard(
                        label: 'TỔNG CÔNG VIỆC',
                        value: '${_stats!.summary.totalTasks}',
                        subtitle: 'Phạm vi đang lọc',
                        backgroundColor: AppColors.cardWhite,
                        textColor: AppColors.obsidianDark,
                        icon: Icons.list_alt_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildKpiCard(
                        label: 'HOÀN THÀNH',
                        value: '${_stats!.byStatus.completed.count}',
                        subtitle: 'Tỷ lệ: ${_stats!.summary.completionRate}%',
                        backgroundColor: AppColors.cardWhite,
                        textColor: AppColors.successMint,
                        icon: Icons.task_alt_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard(
                        label: 'ĐANG LÀM',
                        value: '${_stats!.byStatus.inProgress.count}',
                        subtitle: 'Đang triển khai',
                        backgroundColor: AppColors.cardWhite,
                        textColor: AppColors.royalCobalt,
                        icon: Icons.hourglass_top_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildKpiCard(
                        label: 'QUÁ HẠN',
                        value: '${_stats!.deadlines.overdue}',
                        subtitle: _stats!.deadlines.overdue > 0
                            ? 'Cần xử lý khẩn cấp'
                            : 'Tiến độ rất tốt',
                        backgroundColor: _stats!.deadlines.overdue > 0
                            ? AppColors.terracottaAlertLight
                            : AppColors.cardWhite,
                        textColor: _stats!.deadlines.overdue > 0
                            ? AppColors.terracottaAlert
                            : AppColors.obsidianDark,
                        icon: Icons.warning_amber_rounded,
                        isAlert: _stats!.deadlines.overdue > 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Overall Completion Progress Meter
                BrutalistCard(
                  backgroundColor: AppColors.cardWhite,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'HIỆU SUẤT HOÀN THÀNH',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: AppColors.obsidianDark,
                            ),
                          ),
                          Text(
                            '${_stats!.summary.completionRate}%',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.royalCobalt,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.secondarySurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor:
                                (_stats!.summary.completionRate / 100.0).clamp(0.0, 1.0),
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.royalCobalt, AppColors.skyAzure],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tỷ lệ hoàn thành đúng hạn: ${_stats!.summary.completedOnTimeRate}%',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.slateSteel,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Breakdown by Status
                BrutalistCard(
                  backgroundColor: AppColors.cardWhite,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PHÂN BỔ THEO TRẠNG THÁI',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: AppColors.obsidianDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildProgressBar(
                        label: 'Chờ xử lý (TODO)',
                        count: _stats!.byStatus.todo.count,
                        percentage: _stats!.byStatus.todo.percentage,
                        fillColor: AppColors.slateSteel,
                      ),
                      _buildProgressBar(
                        label: 'Đang làm (IN PROGRESS)',
                        count: _stats!.byStatus.inProgress.count,
                        percentage: _stats!.byStatus.inProgress.percentage,
                        fillColor: AppColors.royalCobalt,
                      ),
                      _buildProgressBar(
                        label: 'Hoàn thành (COMPLETED)',
                        count: _stats!.byStatus.completed.count,
                        percentage: _stats!.byStatus.completed.percentage,
                        fillColor: AppColors.successMint,
                      ),
                      _buildProgressBar(
                        label: 'Đã hủy (CANCELLED)',
                        count: _stats!.byStatus.cancelled.count,
                        percentage: _stats!.byStatus.cancelled.percentage,
                        fillColor: AppColors.terracottaAlert,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Breakdown by Priority
                BrutalistCard(
                  backgroundColor: AppColors.cardWhite,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PHÂN BỔ THEO ĐỘ ƯU TIÊN',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: AppColors.obsidianDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildProgressBar(
                        label: 'Khẩn cấp / Cao (HIGH)',
                        count: _stats!.byPriority.high.count,
                        percentage: _stats!.byPriority.high.percentage,
                        fillColor: AppColors.terracottaAlert,
                      ),
                      _buildProgressBar(
                        label: 'Trung bình (MEDIUM)',
                        count: _stats!.byPriority.medium.count,
                        percentage: _stats!.byPriority.medium.percentage,
                        fillColor: AppColors.warningAmber,
                      ),
                      _buildProgressBar(
                        label: 'Thấp (LOW)',
                        count: _stats!.byPriority.low.count,
                        percentage: _stats!.byPriority.low.percentage,
                        fillColor: AppColors.royalCobalt,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Deadline Health Monitor
                BrutalistCard(
                  backgroundColor: AppColors.cardWhite,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GIÁM SÁT HẠN CHÓT (DEADLINES)',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: AppColors.obsidianDark,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _stats!.deadlines.overdue > 0
                                    ? AppColors.terracottaAlertLight
                                    : AppColors.frostBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _stats!.deadlines.overdue > 0
                                      ? AppColors.terracottaAlertBorder
                                      : AppColors.softIceBlue,
                                  width: 1.0,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '${_stats!.deadlines.overdue}',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: _stats!.deadlines.overdue > 0
                                          ? AppColors.terracottaAlert
                                          : AppColors.obsidianDark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'QUÁ HẠN',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: _stats!.deadlines.overdue > 0
                                          ? AppColors.terracottaAlert
                                          : AppColors.slateSteel,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _stats!.deadlines.dueSoon > 0
                                    ? AppColors.warningAmberLight
                                    : AppColors.frostBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _stats!.deadlines.dueSoon > 0
                                      ? AppColors.warningAmberBorder
                                      : AppColors.softIceBlue,
                                  width: 1.0,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '${_stats!.deadlines.dueSoon}',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: _stats!.deadlines.dueSoon > 0
                                          ? AppColors.warningAmber
                                          : AppColors.obsidianDark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'TRONG 24H',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: _stats!.deadlines.dueSoon > 0
                                          ? AppColors.warningAmber
                                          : AppColors.slateSteel,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.successMintLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.successMintBorder,
                                  width: 1.0,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '${_stats!.deadlines.completedOnTime}',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.successMint,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'ĐÚNG HẠN',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.successMint,
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
                const SizedBox(height: 16),

                // Team Workload Ranking (E3)
                if (_stats!.memberWorkloads.isNotEmpty) ...[
                  BrutalistCard(
                    backgroundColor: AppColors.cardWhite,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KHỐI LƯỢNG CÔNG VIỆC THÀNH VIÊN (E3)',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: AppColors.obsidianDark,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _stats!.memberWorkloads.length,
                          separatorBuilder: (context, index) => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Divider(color: AppColors.softIceBlue, thickness: 1.0),
                          ),
                          itemBuilder: (context, index) {
                            final member = _stats!.memberWorkloads[index];
                            final rate = member.taskCount > 0
                                ? Math.round((member.completedCount / member.taskCount) * 100)
                                : 0;

                            return InkWell(
                              onTap: () => _showMemberPerformanceDialog(member),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: index == 0
                                            ? AppColors.inProgressBlueLight
                                            : AppColors.frostBackground,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: index == 0
                                              ? AppColors.inProgressBlueBorder
                                              : AppColors.softIceBlue,
                                          width: 1.0,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '#${index + 1}',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: index == 0
                                              ? AppColors.royalCobalt
                                              : AppColors.slateSteel,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    BrutalistAvatar(
                                      avatarUrl: member.user.avatarUrl,
                                      name: member.user.fullName,
                                      size: 34,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            member.user.fullName,
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.obsidianDark,
                                            ),
                                          ),
                                          Text(
                                            member.user.email,
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: AppColors.slateSteel,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.frostBackground,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: AppColors.softIceBlue,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${member.completedCount}/${member.taskCount} XONG',
                                            style: GoogleFonts.jetBrainsMono(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.royalCobalt,
                                            ),
                                          ),
                                          Text(
                                            '$rate%',
                                            style: GoogleFonts.jetBrainsMono(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
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
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class Math {
  static int round(num value) => value.round();
}
