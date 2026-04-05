# KỊCH BẢN QUAY VIDEO DEMO & BÁO CÁO ĐỒ ÁN (PHIÊN BẢN CẬP NHẬT)
**Tên đồ án:** Ứng dụng phát trực tuyến âm nhạc và Podcast đa nền tảng.
**Công nghệ:** Flutter (Frontend), C# ASP.NET Core 9.0 (Backend), PostgreSQL/Supabase (Database).

---

## PHẦN 1: TỔNG QUAN KIẾN TRÚC (Dùng để giới thiệu đầu video)

"Chào thầy, em xin phép demo đồ án Music App. Điểm đặc biệt của đồ án này là em đã xây dựng một hệ thống **Backend hoàn chỉnh bằng C# .NET 9.0**.

Thay vì gọi trực tiếp vào Database, App Flutter sẽ giao tiếp qua một lớp trung gian API. Điều này giúp hệ thống đạt được:
1. **Tính bảo mật:** Mọi logic kiểm tra quyền hạn, hashing mật khẩu đều nằm ở Server.
2. **Khả năng mở rộng:** Server có thể phục vụ cả bản Mobile, Web và Desktop cùng lúc.
3. **Database Migration:** Em đã viết code tự động khởi tạo và chuẩn hóa Schema Database ngay khi Server khởi động, đảm bảo dữ liệu luôn nhất quán giữa môi trường phát triển và thực tế."

---

## PHẦN 2: KỊCH BẢN DEMO TỪNG BƯỚC (Dành cho quay màn hình)

### Bước 1: Khởi động và Trang Chủ (Home Screen)
- **Hành động:** Mở App, cuộn qua các mục: Dành cho bạn, Album mới, Nghệ sĩ nổi bật.
- **Lời dẫn:** "Ngay khi mở App, hệ thống sẽ thực hiện các request GET đến API để lấy dữ liệu. Quá trình này được xử lý bất đồng bộ, kết hợp với các Shimmer loading tạo trải nghiệm mượt mà. Giao diện được thiết kế theo phong cách Dark Mode hiện đại, tối ưu cho việc trải nghiệm âm nhạc buổi đêm."

### Bước 2: Tìm kiếm thông minh (Search Fix)
- **Hành động:** Vào Tab Tìm kiếm, gõ thử tên bài hát hoặc nghệ sĩ (ví dụ: "Sơn Tùng", "B Ray").
- **Lời dẫn:** "Phần tìm kiếm đã được tối ưu hóa bằng thuật toán `ILike` của PostgreSQL thông qua Entity Framework Core. Điều này cho phép tìm kiếm không phân biệt hoa thường và trả về kết quả chính xác ngay lập tức từ hàng ngàn bản ghi trong database."

### Bước 3: Trình phát nhạc & Fix Visual (Player Experience)
- **Hành động:** Bấm phát một bài hát -> Mở Full Player -> Quay lại trang tìm kiếm khi nhạc vẫn đang chạy.
- **Lời dẫn:** "Trình phát nhạc sử dụng Riverpod để quản lý trạng thái toàn cục. Em đã fix hoàn toàn lỗi tràn màu (background bleed) bằng cách xử lý ảnh bìa thông qua các fallback trung tính. Giờ đây, dù ảnh bìa bài hát có bị lỗi hoặc chưa tải xong, giao diện vẫn giữ được nét tinh tế, không bị nhòe màu đỏ ra toàn ứng dụng."

### Bước 4: Tính năng dành cho Nghệ sĩ (Artist Dashboard)
- **Hành động:** Vào Thư viện -> Chọn Profile Nghệ sĩ (hoặc Dashboard). Bấm "Phát hành âm nhạc".
- **Lời dẫn:** "Đây là tính năng dành cho cộng đồng nghệ sĩ. Người dùng có thể tự tải lên các sản phẩm âm nhạc của mình lên hệ thống."

### Bước 5: Upload bài hát với Progress Bar (Real-time Upload)
- **Hành động:** Chọn 1 file MP3 và 1 ảnh bìa -> Bấm "Phát hành ngay" -> Chỉ vào THANH LOADING ĐANG CHẠY (%).
- **Lời dẫn:** "Để đảm bảo tính ổn định, em đã tích hợp Thanh tiến trình tải lên (Upload Progress Bar). Hệ thống sẽ báo cáo chính xác bao nhiêu phần trăm dữ liệu đã được gửi lên Server qua Dio. Khi đạt 100%, Backend mới bắt đầu lưu vào Database và Storage, giúp bài hát luôn được tải lên toàn vẹn trước khi phát hành."

### Bước 6: Tổng kết
- **Lời dẫn:** "Với sự kết hợp giữa Flutter mượt mà và Backend .NET 9.0 mạnh mẽ, đồ án của em đã giải quyết được trọn vẹn bài toán vận hành một nền tảng Music Streaming chuyên nghiệp. Em xin kết thúc phần demo, cảm ơn thầy đã chú ý theo dõi ạ!"
