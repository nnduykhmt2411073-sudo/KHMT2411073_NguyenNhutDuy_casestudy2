# CASE STUDY 2: ỨNG DỤNG QUẢN LÝ VÀ GIAO CÔNG VIỆC NHÓM
> **Đồ án môn học / Case Study 2:** Xây dựng ứng dụng di động Flutter và hệ thống Backend REST API quản lý công việc, phân công nhiệm vụ nhóm và theo dõi tiến độ thời gian thực.

---

## 👤 THÔNG TIN SINH VIÊN THỰC HIỆN
- **Họ và tên:** Nguyễn Nhựt Duy
- **Mã số sinh viên (MSSV):** KHMT2411073
- **Chuyên ngành:** Khoa học Máy tính (KHMT)
- **Repository GitHub:** [https://github.com/nnduykhmt2411073-sudo/KHMT2411073_NguyenNhutDuy_casestudy2.git](https://github.com/nnduykhmt2411073-sudo/KHMT2411073_NguyenNhutDuy_casestudy2.git)

---

## 🎨 THIẾT KẾ GIAO DIỆN: B2B SAAS DASHBOARD (FROST BLUE & DEEP OBSIDIAN)
Ứng dụng được thiết kế theo phong cách **Modern B2B SaaS / CRM Dashboard** (`flutter-saas-builder`), tập trung vào trải nghiệm một tay và các chỉ số trạng thái công việc cốt lõi:
- **Màu nền chính (`frostBackground`):** `#E6EFFB` (Xanh băng dịu mắt).
- **Màu thẻ & ô nhập liệu (`cardWhite`):** `#FFFFFF` viền mảnh `1px` `#B5D3F4`.
- **Màu tiêu đề & Hero Card (`obsidianDark` & `midnightIndigo`):** Gradient `#03040B` ➔ `#2A3261`.
- **Màu thương hiệu chính (`royalCobalt`):** `#2A4EBB` cho nút CTA chính và tab active.
- **Màu nhấn tiến độ (`skyAzure`):** `#39A8F2` cho thanh tiến độ và viền avatar người phụ trách chính.
- **Màu cảnh báo & khẩn cấp (`terracottaAlert`):** `#AD5A4D` cho hạn chót quá hạn, mức ưu tiên cao.
- **Bố cục màn hình chuẩn:**
  1. Top Header: Lời chào + Chuông thông báo gắn badge đỏ.
  2. Hero Summary Card: Thẻ tiến độ gradient tương phản cao.
  3. **Three Numbers Overview:** 3 thẻ chỉ số cốt lõi (Chưa làm – Đang làm – Hoàn thành).
  4. Search & Filter Bar: Ô tìm kiếm bo góc 14px + ChoiceChips cuộn ngang.
  5. Danh sách thẻ công việc bo góc 18px kèm Avatar Stack thành viên.

---

## 🛠 CÔNG NGHỆ SỬ DỤNG (TECH STACK)

### 1. Frontend (Mobile App - Flutter)
- **Thư mục:** `TaskManager/`
- **Framework:** Flutter SDK (Dart 3.x).
- **Quản lý trạng thái:** Stateful Lifecycle & Clean Architecture.
- **Mạng & Lưu trữ:** `package:http`, `shared_preferences` (Lưu trữ JWT & User Session).
- **Phông chữ & Định dạng:** `google_fonts` (Space Grotesk, Inter, JetBrains Mono), `intl` (Định dạng ngày giờ Việt Nam).

### 2. Backend (RESTful API - Node.js)
- **Thư mục:** `api/`
- **Runtime & Framework:** Node.js, Express.js.
- **Cơ sở dữ liệu:** MongoDB (với thư viện ODM `mongoose`).
- **Xác thực & Bảo mật:** JSON Web Token (`jsonwebtoken`), mã hóa mật khẩu 1 chiều (`bcryptjs`), CORS.
- **Dịch vụ Email & Nhắc nhở:** `nodemailer` với mẫu HTML thông báo, Background Cron Job nhắc nhở hạn chót công việc trước 24h.

---

## 📁 CẤU TRÚC DỰ ÁN

```text
KHMT2411073_NguyenNhutDuy_casestudy2/
├── README.md                           # Thông tin sinh viên & tài liệu dự án
├── .gitignore                          # Cấu hình bỏ qua tệp tạm, node_modules, build
│
├── api/                                # BACKEND NODE.JS & EXPRESS REST API
│   ├── package.json                    # Cấu hình dependencies backend
│   ├── .env.example                    # Mẫu biến môi trường
│   └── src/
│       ├── server.js                   # Khởi chạy server & background reminder cron
│       ├── app.js                      # Cấu hình Express app & routes
│       ├── config/                     # Kết nối MongoDB & Nodemailer
│       ├── models/                     # User, Task, TaskShare, Notification, EmailLog, TaskActivity
│       ├── controllers/                # Auth, Task, Assignment, Share, Stats, Notification, User
│       ├── routes/                     # Định tuyến API
│       ├── middleware/                 # JWT Auth, Phân quyền RBAC, Validation, Error Handling
│       ├── services/                   # EmailService, NotificationService, TaskService, ReminderService
│       ├── utils/                      # Email templates
│       └── validators/                 # Validator kiểm tra dữ liệu đầu vào
│
└── TaskManager/                        # FRONTEND MOBILE APP (FLUTTER)
    ├── pubspec.yaml                    # Cấu hình dependencies Flutter
    └── lib/
        ├── main.dart                   # Điểm khởi chạy app & nạp phiên đăng nhập
        ├── app.dart                    # MaterialApp & Theme
        ├── models/                     # Data models (User, Task, TaskShare, Notification, TaskStats)
        ├── services/                   # ApiClient, AuthService, TaskService, NotificationService...
        ├── utils/                      # AppColors, AppTheme, Validators, DateFormatter, Constants
        ├── widgets/                    # Reusable widgets (Cards, Badges, AvatarStack, Modals)
        └── screens/                    # Màn hình giao diện (Auth, Tasks, Notifications, Profile, Stats)
```

---

## 🚀 HƯỚNG DẪN KHỞI CHẠY HỆ THỐNG

### 1. Khởi chạy Backend (Node.js & MongoDB)
```bash
cd api
npm install
npm run dev # Hoặc: node src/server.js
```
Server chạy tại: `http://localhost:5000/api`

### 2. Khởi chạy Frontend (Flutter TaskManager)
```bash
cd TaskManager
flutter pub get
flutter run
```
