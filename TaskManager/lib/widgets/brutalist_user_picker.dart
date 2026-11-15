import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../utils/app_colors.dart';
import 'brutalist_button.dart';
import 'brutalist_card.dart';
import 'brutalist_avatar.dart';

class BrutalistUserPicker {
  /// Hiển thị modal chọn người dùng (C1)
  static Future<List<User>?> show({
    required BuildContext context,
    String title = 'TÌM KIẾM THÀNH VIÊN // C1',
    bool isMultiSelect = true,
    List<User> initialSelected = const [],
  }) {
    return showModalBottomSheet<List<User>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _UserPickerModal(
        title: title,
        isMultiSelect: isMultiSelect,
        initialSelected: initialSelected,
      ),
    );
  }
}

class _UserPickerModal extends StatefulWidget {
  final String title;
  final bool isMultiSelect;
  final List<User> initialSelected;

  const _UserPickerModal({
    required this.title,
    required this.isMultiSelect,
    required this.initialSelected,
  });

  @override
  State<_UserPickerModal> createState() => _UserPickerModalState();
}

class _UserPickerModalState extends State<_UserPickerModal> {
  final _userService = UserService();
  final _searchController = TextEditingController();

  List<User> _users = [];
  final List<User> _selectedUsers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedUsers.addAll(widget.initialSelected);
    _loadInitialUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final users = await _userService.getSuggestedUsers();
      if (mounted) {
        setState(() {
          _users = users;
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

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      _loadInitialUsers();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _userService.searchUsers(query.trim());
      if (mounted) {
        setState(() {
          _users = results;
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

  void _toggleUser(User user) {
    setState(() {
      final exists = _selectedUsers.any((u) => u.id == user.id);
      if (widget.isMultiSelect) {
        if (exists) {
          _selectedUsers.removeWhere((u) => u.id == user.id);
        } else {
          _selectedUsers.add(user);
        }
      } else {
        _selectedUsers.clear();
        _selectedUsers.add(user);
      }
    });

    if (!widget.isMultiSelect) {
      Navigator.of(context).pop(_selectedUsers);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      margin: EdgeInsets.only(bottom: bottomInset),
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
                widget.title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.obsidianDark,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.slateSteel),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Search Field (SaaS soft style)
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
              onChanged: _searchUsers,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.obsidianDark,
              ),
              decoration: InputDecoration(
                hintText: 'Nhập email hoặc họ tên để tìm...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondaryText,
                ),
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryInk),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.primaryInk),
                        onPressed: () {
                          _searchController.clear();
                          _loadInitialUsers();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // List of users
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryInk,
                      strokeWidth: 3,
                    ),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.inter(color: AppColors.danger),
                        ),
                      )
                    : _users.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.person_search, size: 48, color: AppColors.secondaryText),
                                const SizedBox(height: 10),
                                Text(
                                  'KHÔNG TÌM THẤY NGƯỜI DÙNG',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryInk,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Hãy kiểm tra lại từ khóa tìm kiếm email hoặc họ tên.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: _users.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final user = _users[index];
                              final isSelected = _selectedUsers.any((u) => u.id == user.id);

                              return GestureDetector(
                                onTap: () => _toggleUser(user),
                                child: BrutalistCard(
                                  backgroundColor: isSelected
                                      ? AppColors.primaryAccent
                                      : AppColors.cardWhite,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  child: Row(
                                    children: [
                                      // Avatar initials / image
                                      BrutalistAvatar(
                                        avatarUrl: user.avatarUrl,
                                        name: user.fullName,
                                        size: 36,
                                        backgroundColor: isSelected
                                            ? AppColors.cardWhite
                                            : AppColors.secondarySurface,
                                      ),
                                      const SizedBox(width: 12),

                                      // User info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user.fullName,
                                              style: GoogleFonts.spaceGrotesk(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.primaryInk,
                                              ),
                                            ),
                                            Text(
                                              user.email,
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.secondaryText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Check indicator
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.royalCobalt
                                              : AppColors.cardWhite,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isSelected ? AppColors.royalCobalt : AppColors.softIceBlue,
                                            width: 1.0,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: isSelected
                                            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),

          // Multi-select confirm button
          if (widget.isMultiSelect) ...[
            const SizedBox(height: 14),
            BrutalistButton(
              text: 'XÁC NHẬN CHỌN (${_selectedUsers.length})',
              icon: Icons.check_rounded,
              backgroundColor: AppColors.royalCobalt,
              textColor: Colors.white,
              onPressed: () => Navigator.of(context).pop(_selectedUsers),
            ),
          ],
        ],
      ),
    );
  }
}
