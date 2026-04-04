# KỊCH BẢN QUAY VIDEO DEMO & BÁO CÁO ĐỒ ÁN
**Tên đồ án:** Ứng dụng phát trực tuyến âm nhạc và Podcast đa nền tảng.
**Công nghệ sử dụng:** Flutter (Frontend), C# ASP.NET Core 9.0 Web API (Backend), Supabase (Database).

---

## PHẦN 1: TỔNG QUAN VÀ LÝ THUYẾT KIẾN TRÚC HỆ THỐNG
*(Lưu ý: Bạn dùng phần này để đọc lúc bắt đầu slide giới thiệu hoặc đoạn đầu video)*

**1. Kiến trúc hệ thống là gì?**
Đồ án sử dụng mô hình kiến trúc **Client - Server (RESTful API)**. 
- **Frontend (Client):** Xây dựng bằng Framework Flutter. Đảm nhiệm việc hiển thị giao diện (UI) và tương tác với người dùng (UX). 
- **Backend (Server):** Xây dựng bằng C# ASP.NET Core 9.0 Web API nằm tập trung ở thư mục `Backend`. Đóng vai trò là "người trung gian" tiếp nhận các request từ thư viện `dio` (bắn ra từ file `api_client.dart` phía App) qua giao thức HTTP (GET, POST), xử lý logic, phân quyền bảo mật.
- **Database:** Sử dụng Supabase (Nền tảng Database đám mây kết hợp Storage), kết nối với Backend C# thông qua Entity Framework Core (`AppDbContext`).

**2. Tại sao lại dùng kiến trúc bóc tách này?**
- Việc "Bóc tách - Decoupling" Front-end ra khỏi Database (Xây riêng một API Backend C# ở giữa) mang lại **3 lợi ích to lớn**:
  1. **Bảo mật cao hơn:** App Flutter không còn ôm các logic truy vấn hay các Key Auth siêu quyền hạn của Database nữa. 
  2. **Khả năng mở rộng (Scalability):** Nếu sau này có thêm phiên bản Web (React) hoặc App SmartTV, chúng chỉ việc tái sử dụng lại các API C# đã viết sẵn.
  3. **Abstraction:** Phía Flutter chỉ cần "Gọi API" ➡️ "Nhận JSON" ➡️ "Vẽ UI". Backend sẽ đảm nhiệm load balancing, cache dữ liệu, giúp ứng dụng nhẹ hơn.

**3. Công nghệ xương sống bên trong Flutter**
- **State Management (Riverpod):** Dùng để quản lý trạng thái phức tạp. Điển hình nhất là **Mini Player** (trình phát nhỏ dưới đáy màn hình) luôn chạy bài hát liên tục và đồng bộ trạng thái dù User có chuyển tab qua lại.
- **GoRouter:** Quản lý đường dẫn điều hướng, có hỗ trợ tính năng `ShellRoute` giúp thiết kế "Thanh điều hướng dưới đáy" (BottomNavigationBar) giữ nguyên không bị gián đoạn mỗi khi chuyển trang.
- **Just_Audio & Just_Audio_Background:** Xử lý luồng Audio mượt mà, hỗ trợ phát nhạc khi ấn tắt màn hình, có hiển thị Widget Controls ở màn hình khóa ngoài (Lock screen media controls).

---

## PHẦN 2: KỊCH BẢN DEMO LÊN VIDEO (TỪNG BƯỚC)

*(Thời lượng đề xuất: ~ 5-7 phút)*

### Bước 1: Mở ngỏ và Đăng nhập (Auth Flow)
- **Hành động & Lời dẫn:** "Mở đầu ứng dụng là màn hình Đăng nhập hiện đại, hỗ trợ chuẩn xác thực cao cấp. Người dùng nếu quên mật khẩu có thể khôi phục qua mã OTP gửi về Email. Em xin demo đăng nhập bằng một tài khoản đã có sẵn".
- Xoay màn hình hiển thị Toast báo thành công và app điều hướng vào trang Home.

### Bước 2: Khám phá Trang Chủ (Home & Khám phá)
- **Hành động:** Vuốt cuộn mượt mà các Sections trên trang chủ (Trending, Playlist gợi ý, Nghệ sĩ nổi bật, Podcast mới).
- **Lời dẫn:** "Trang chủ mang âm hưởng thiết kế Glassmorphism và Gam màu tối (Dark Theme) tối ưu thị giác như Spotify. Data hiển thị qua các Carousel trượt dọc/ngang được móc nối trực tiếp từ C# Backend API cực kỳ nhanh, giao diện load bằng Shimmer Animation tạo cảm giác chuyên nghiệp không bị giật lác".

### Bước 3: Tìm kiếm (Search & Khám phá)
- **Hành động:** Bấm sang Tab Tìm kiếm. Gõ vào từ khóa bài hát hoặc Nghệ sĩ. Xóa thử lịch sử tìm kiếm.
- **Lời dẫn:** "Thuật toán tìm kiếm tương đối toàn diện, trả về kết quả gần như tức thời. Em cũng có viết Helper lưu lại mục 'Tìm kiếm gần đây' dựa vào Local Storage để tăng tốc độ truy xuất cho người dùng ngay cả khi không có mạng".

### Bước 4: Demo Core Feature - Trình Phát Nhạc (Audio Player)
- **Hành động:** 
  1. Chạm vào 1 bài hát bất kỳ.
  2. Để Mini Player dưới rốn màn hình nhảy xuất hiện. Bấm Play/Pause trên MiniPlayer.
  3. Chuyển hướng sang Tab Thư viện (Nhấn mạnh việc Nhạc vẫn tiếp tục hát, MiniPlayer không bị biến mất).
  4. Chạm vào MiniPlayer để trượt giao diện lên Full-Screen Player. Quẹt băng chuyền bài hát (Seek bar).
- **Lời dẫn:** "Phần cốt lõi và phức tạp nhất chính là Trình phát nhạc toàn cục. Dù người dùng lang thang ở bất cứ Screen nào, cấu trúc `ShellRouter` kết hợp `PlayerProvider` (của Riverpod) luôn đảm bảo nhạc vẫn đang chạy và các Icon trạng thái luôn được đồng bộ real-time".

### Bước 5: Lời bài hát đồng bộ (Synched Lyrics)
- **Hành động:** Tại góc trên của Full-Screen Player, vuốt sang trang (hoặc bấm nút) để mở Lời bài hát. 
- **Lời dẫn:** "Tương tự các App Streaming chuyên nghiệp, đồ án tích hợp hệ thống đồng bộ hóa Lyrics (`lyrics_sync_provider.dart`). Trạng thái thời gian thực của Audio sẽ tương tác với Lời nhạc, tự động cuộn chữ và tô sáng Highlight ngay khoảnh khắc ca sĩ cất lời".

### Bước 6: Thử nghiệm Background Play (Ra ngoài màn hình chính)
- **Hành động:** Trượt vuốt trở lại Home screen của điện thoại (Thu nhỏ App). Vuốt thanh Notification bar (Trung tâm thông báo) xuống để khoe Media Widget của bài hát.
- **Lời dẫn:** "Nhờ cấu hình `Just Audio Background` sâu bên trong nền tảng Native Code (Android/iOS), ứng dụng được cấp quyền chạy dưới dạng Background Media Service. Người dùng tắt màn hình vẫn có nhạc nghe và có thể Pause hay Next bài bằng Hardware button của thiết bị".

### Bước 7: Quản lý Thư viện & Thêm Playlist (CRUD)
- **Hành động:** Quay lại App, vào Tab **Thư Viện** (Library). Bấm tạo Playlist mới qua Menu Create, đặt tên, và thêm thử một bài nhạc vào đó bằng BottomSheet.
- **Lời dẫn:** "Về đặc thù cá nhân hóa, hệ thống hỗ trợ User thả 'Tim' (Thích) bài hát, theo dõi (Follow) ca sĩ, hay Tạo lập các Playlist gom nhóm cá nhân. Các thao tác Thêm/Sửa/Xóa này tương tác mượt mà lên Backend API giúp Database Supabase tự động cập nhật thống nhất".

### Bước 8: Podcast và Ngoại Tuyến (Offline Mode)
- **Hành động:** Mở nhanh giao diện chi tiết kênh Podcast (`podcast_channel_screen.dart`), sau đó bấm vào Tab mục Downloads âm thanh.
- **Lời dẫn:** "Không dừng lại ở âm nhạc, đồ án tích hợp thêm phân mảng Podcast giải trí, đi kèm công năng Save/Download cho phép lưu nhạc về bộ nhớ vật lý thiết bị để phát lại khi điện thoại ở trạng thái Không có mạng (Offline mode)".

### Bước 9: Tổng kết & Kết luận
- **Lời dẫn:** "Tổng kết lại, đồ án đã giải quyết trọn vẹn nghiệp vụ của một Hệ thống Streaming Media đa nền tảng đương đại. Chinh phục về mặt Giao diện UX mượt mà bên Flutter, làm chủ luồng logic âm thanh bất đồng bộ phức tạp bằng Riverpod, và sở hữu quy mô Client/Server hoàn thiện rắn chắc đằng sau với cụm công nghệ Backend C# .NET. Em xin kết thúc phần Review đồ án ạ, xin cảm ơn thầy!"
