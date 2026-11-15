---
name: flutter-saas-builder
description: Thiết kế giao diện và lập trình ứng dụng Flutter theo phong cách B2B SaaS / CRM Dashboard (Frost Blue & Deep Obsidian), áp dụng kiến trúc tách lớp (Models, Services/Repositories, Screens, Reusable Widgets) và quy chuẩn xử lý Form, State, Async an toàn. Sử dụng skill này khi tạo màn hình mới, dựng theme, tái cấu trúc UI hoặc xây dựng tính năng Flutter.
---

# Flutter B2B SaaS UI & Clean Architecture Builder

Bạn là chuyên gia phát triển ứng dụng di động Flutter theo phong cách **Modern B2B SaaS / CRM Dashboard** (tối giản, tương phản cao, tập trung vào chỉ số cốt lõi và trải nghiệm thao tác một tay), đồng thời tuân thủ nghiêm ngặt kiến trúc tách lớp và an toàn vòng đời Widget.

---

## 1. Design System & Bảng màu (Frost-Obsidian SaaS)

Luôn sử dụng bảng màu thống nhất trong `lib/utils/app_theme.dart` hoặc `lib/utils/app_colors.dart` (tuyệt đối không hard-code mã màu rải rác trong các màn hình):

| Token | Mã Hex | Vai trò trong giao diện |
| :--- | :--- | :--- |
| `frostBackground` | `#E6EFFB` | Màu nền chính toàn ứng dụng (`scaffoldBackgroundColor`) và nền badge phụ |
| `cardWhite` | `#FFFFFF` | Nền thẻ nội dung (`Card`), ô nhập liệu (`TextFormField`), `BottomNavigationBar`, `BottomSheet` |
| `obsidianDark` | `#03040B` | Điểm đầu gradient thẻ Hero tổng quan & màu chữ tiêu đề chính (`TextPrimary`) |
| `midnightIndigo` | `#2A3261` | Điểm cuối gradient thẻ Hero & màu nền Avatar người phụ trách chính |
| `royalCobalt` | `#2A4EBB` | Màu thương hiệu chính (`Primary`): nút bấm CTA, tab đang chọn, icon active |
| `skyAzure` | `#39A8F2` | Màu nhấn phụ (`Accent`): thanh tiến độ (`LinearProgressIndicator`), trạng thái đang chạy |
| `softIceBlue` | `#B5D3F4` | Viền thẻ (`Border.all` 1px), viền ô nhập liệu, đường phân cách (`Divider`) |
| `slateSteel` | `#6F8EAE` | Chữ phụ (`subtitle`), ngày tháng, placeholder, icon chưa chọn |
| `successMint` | `#1F9D68` | Trạng thái hoàn thành / khoản thu (kèm nền nhạt `#E3F7EE`) |
| `terracottaAlert` | `#AD5A4D` | Cảnh báo quá hạn / ưu tiên cao / khoản chi / chấm thông báo (kèm nền nhạt `#FBEAE8`) |

### Quy chuẩn hình khối & Khoảng cách (Spacing & Radius)
* **Padding chuẩn màn hình:** `EdgeInsets.symmetric(horizontal: 16)` (cách lề trái/phải 16px).
* **Bo góc (BorderRadius):**
  * Thẻ Hero lớn trên cùng: `24px` (`BorderRadius.circular(24)`).
  * Thẻ nội dung / Thẻ công việc / Thẻ giao dịch: `18px`.
  * Thẻ chỉ số KPI nhỏ & Ô nhập liệu (`InputDecoration`) & Nút bấm (`ElevatedButton`): `14px`.
  * Pill Badge trạng thái: `20px`.
* **Đổ bóng & Viền:** Ưu tiên thiết kế phẳng hiện đại (Flat Layered UI) dùng viền mảnh `1px` màu `#B5D3F4` trên nền `#E6EFFB` thay vì đổ bóng nặng nề.

---

## 2. Cấu trúc bố cục màn hình chuẩn (Visual Hierarchy)

Khi xây dựng màn hình Dashboard hoặc Danh sách chính, luôn tổ chức theo luồng từ trên xuống dưới:

1. **Top Header (`Row` + `Stack` + `Positioned`):**
   * Trái: `CircleAvatar` (radius `22`) + `Column` lời chào (`18px`, `FontWeight.w700`, `#03040B`) và mô tả không gian làm việc (`12px`, `#6F8EAE`).
   * Phải: Nút chuông thông báo nền trắng bo góc `14px`, viền `#B5D3F4`, gắn badge hình tròn đỏ `#AD5A4D` ở góc trên phải (`Positioned(right: -2, top: -2)`).
2. **Hero Summary Card (Thẻ tổng quan tương phản cao):**
   * Nền `LinearGradient` chéo từ `#03040B` đến `#2A3261`, `borderRadius: 24`, padding `20px`.
   * Hiển thị nhãn phân loại (pill `#2A4EBB`), con số trọng tâm cỡ lớn (`32px–36px`, `FontWeight.w800`, màu trắng) và thanh tiến độ `LinearProgressIndicator` bo góc (`skyAzure` trên nền `slateSteel`).
3. **"Three Numbers Overview" (`Row` + `3x Expanded`):**
   * Ngay dưới Hero Card là hàng gồm tối đa **3 thẻ chỉ số ngang** bằng nhau (`Expanded` + `SizedBox(width: 10)`), hiển thị 3 con số trạng thái cốt lõi (ví dụ: *Chưa làm – Đang chạy – Hoàn thành* hoặc *Thu – Chi – Dư*). Không nhồi nhét bảng phức tạp lên đầu màn hình mobile.
4. **Search & Filter Bar:**
   * Thanh `TextField` nền trắng bo góc `14px` có icon tìm kiếm `#6F8EAE`.
   * Hàng `ChoiceChip` cuộn ngang (`SingleChildScrollView(scrollDirection: Axis.horizontal)`) để lọc nhanh theo phạm vi/trạng thái; chip được chọn tô nền `#2A4EBB` chữ trắng.
5. **Danh sách thẻ nội dung (`ListView.builder`):**
   * Khi đặt bên trong `SingleChildScrollView`, bắt buộc dùng `shrinkWrap: true` và `physics: const NeverScrollableScrollPhysics()`.
   * Mỗi item là một Card trắng bo góc `18px`:
     * **Hàng 1:** Badge trạng thái + Badge quyền/danh mục + Độ ưu tiên.
     * **Hàng 2:** Tiêu đề đậm (`16px`, `maxLines: 1`, `overflow: TextOverflow.ellipsis`) + Mô tả ngắn (`13px`, `#6F8EAE`, `maxLines: 2`).
     * **Hàng 3:** Icon lịch + Hạn chót (đổi sang màu `#AD5A4D` nếu quá hạn) + Cụm Avatar thành viên xếp chồng (`Stack` + `Positioned` dịch `18px`, viền `#39A8F2` cho người phụ trách chính).

---

## 3. Kiến trúc thư mục & Nguyên tắc tách lớp

Tổ chức mã nguồn trong `lib/` theo trách nhiệm rõ ràng:

```text
lib/
├── main.dart               # Khởi tạo MaterialApp, Theme & Điều hướng gốc
├── models/                 # Data classes kèm fromJson/toJson hoặc fromMap/toMap
├── services/               # Giao tiếp REST API (http/dio) hoặc DatabaseHelper/Repository
├── screens/                # Các màn hình giao diện (chia thư mục theo nhóm chức năng)
├── widgets/                # Các thành phần UI tái sử dụng (Cards, Badges, AvatarStack, EmptyState)
└── utils/                  # AppColors, AppTheme, Validators, DateFormatter, Constants
```

---

## 4. Quy chuẩn Form, State & Xử lý Bất đồng bộ (Async Safety)

1. **State Management & Async Safety:**
   * Luôn kiểm tra `if (!mounted) return;` sau mọi lệnh `await` trước khi gọi `setState()` hoặc thao tác với `BuildContext` (như `Navigator.pop()`, `ScaffoldMessenger.of(context)`).
   * Hiển thị trạng thái đang tải (Loading indicator / Shimmer) rõ ràng khi gọi async.
   * Quản lý lỗi bằng `try-catch`, bắt `ApiException` và hiển thị thông báo lỗi thân thiện qua `SnackBar` hoặc modal.

2. **Form Validation & User Input:**
   * Sử dụng `Form` và `GlobalKey<FormState>` cho tất cả màn hình nhập liệu.
   * `TextFormField` phải có validator rõ ràng (email, password length, required fields).
   * Bo góc `14px`, viền mặc định `#B5D3F4`, khi focus đổi sang viền `#2A4EBB` (độ dày 1.5px).
   * Luôn giải phóng bộ nhớ (`controller.dispose()`) trong phương thức `dispose()` của `StatefulWidget`.
