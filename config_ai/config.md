# Tài liệu Đặc tả Yêu cầu & Tính năng (PRD) - Dự án Ứng dụng Piano MIDI & Smart Learning
**Phiên bản:** 1.0.0
**Nền tảng:** iOS, Android
**Tech Stack:** Flutter (Client), Supabase (Database, Auth, Storage), Firebase (Analytics, Crashlytics), Isar/SQLite (Local DB).
**Kiến trúc đề xuất:** Clean Architecture, MVVM, BLoC/Riverpod.

---

## GIAI ĐOẠN 1: MVP - Cốt lõi Jukebox & Auto-Piano
*Mục tiêu: Xây dựng nền tảng kết nối phần cứng ổn định, quản lý thư viện nội bộ và phát nhạc liên tục cho hệ thống đàn tự động.*

### 1. Quản lý Kết nối Thiết bị (Device Connection Module)
*   **Pair Bluetooth MIDI (BLE):**
    *   *Mô tả:* Quét và kết nối với các thiết bị phát sóng chuẩn BLE MIDI.
    *   *Kỹ thuật:* Lọc UUID `03B80E5A-EDE8-4B33-A751-6CE34EC4C700`.
*   **Auto Reconnect:**
    *   *Mô tả:* Tự động kết nối lại với thiết bị MIDI gần nhất đã lưu khi mở app hoặc khi thiết bị vào vùng phủ sóng.
    *   *Kỹ thuật:* Lưu MAC Address vào Local Storage. Chạy background observer lắng nghe trạng thái Bluetooth.
*   **Hỗ trợ đa giao thức kết nối:**
    *   *USB MIDI:* Nhận diện kết nối qua cáp OTG/Lightning.
    *   *Wi-Fi IP MIDI:* Gửi gói tin MIDI qua mạng nội bộ cho các hệ thống đàn tự động như Yamaha ENSPIRE, PianoDisc.
*   **Công cụ chẩn đoán (Diagnostic):**
    *   *Mô tả:* Màn hình hiển thị trạng thái kết nối, ping/latency và nút "Test MIDI" (gửi 1 nốt Middle C để test âm thanh).

### 2. Trình phát MIDI (Core Playback Engine)
*   **Phát nhạc cơ bản:** Play, Pause, Resume, Stop, Next, Previous.
*   **Seek Timeline:**
    *   *Mô tả:* Kéo thanh trượt để tua bài hát.
    *   *Kỹ thuật:* Tính toán lại tick/timestamp của sequencer để đồng bộ vị trí phát hiện tại, không gây treo luồng chính (Nên dùng Isolate).
*   **Background Jukebox Playback:**
    *   *Mô tả:* Cho phép app tiếp tục phát MIDI ngay cả khi khóa màn hình hoặc chạy ngầm (đặc biệt quan trọng cho hệ thống đàn tự động).
*   **Điều khiển thông số thời gian thực:**
    *   *Tempo Control:* Thay đổi tốc độ bài hát (từ 10% đến 200% so với tempo gốc) mà không làm méo cao độ.
    *   *Transpose Key:* Dịch cung (lên/xuống tối đa 12 semitones). Bằng cách cộng/trừ giá trị pitch vào mỗi event Note On/Off.
    *   *Master Volume & Normalize Velocity:* Cân bằng lực đánh (Velocity) giữa các bài hát trong playlist để âm thanh đàn tự động không bị lúc to lúc nhỏ.
*   **Repeat & Shuffle:** Lặp lại 1 bài, lặp toàn bộ, hoặc phát ngẫu nhiên.

### 3. Quản lý Thư viện Nội bộ (Offline Library)
*   **Import File:** Hỗ trợ lấy file `.mid` từ File Manager, Google Drive, Dropbox. Tự động quét các thư mục được cấp quyền.
*   **Metadata Parser:**
    *   *Mô tả:* Đọc Track 0 của file MIDI để bóc tách các Meta Events (Title, Composer, Copyright, Duration).
    *   *Fallback:* Nếu file thiếu metadata, sử dụng tên file làm Title mặc định.
*   **Offline Cache & Database:**
    *   *Mô tả:* Lưu trữ toàn bộ thông tin bài hát vào Local Database (Khuyên dùng Isar) để truy xuất cực nhanh. Không phụ thuộc vào Internet.
*   **Search & Sort:** Tìm kiếm full-text theo tên bài, tác giả. Sắp xếp theo A-Z, Ngày thêm, Lượt nghe.

### 4. Hệ thống Playlist
*   **CRUD Playlist:** Tạo, Đổi tên, Xóa playlist.
*   **Quản lý danh sách phát:** Thêm/Bớt bài hát vào playlist, vuốt để xóa, sử dụng `ReorderableListView` để kéo thả thay đổi thứ tự phát.
*   **Queue System:** Chèn "Phát tiếp theo" (Play Next) vào luồng phát hiện tại mà không làm hỏng playlist gốc.

### 5. Thu âm & Xuất file (Basic Recording)
*   **MIDI Capture:**
    *   *Mô tả:* Thu lại các thao tác đánh đàn từ thiết bị MIDI (Note On/Off, Velocity, Sustain Pedal).
    *   *Kỹ thuật:* Lắng nghe luồng dữ liệu đầu vào (MIDI IN), gắn timestamp cho từng sự kiện.
*   **Export to `.mid`:** Đóng gói mảng dữ liệu đã thu thành định dạng chuẩn Standard MIDI File (SMF) và lưu vào thư mục máy hoặc chia sẻ.

---

## GIAI ĐOẠN 2: Smart Learning & Visualization
*Mục tiêu: Đưa các tính năng tương tác hình ảnh và "Gia sư ảo" vào hỗ trợ việc học đàn và phân tích kỹ năng người dùng.*

### 6. Cảm hứng Thị giác (Piano Visualization)
*   **Virtual Keyboard:** Bàn phím ảo mô phỏng 88 phím ở cạnh dưới màn hình.
*   **Highlight Key:** Đổi màu phím ảo khi có sự kiện Note On (Màu A cho tay trái, Màu B cho tay phải).
*   **Falling Notes (Synthesia Style):**
    *   *Mô tả:* Các khối nốt nhạc rơi từ trên xuống khớp với bàn phím.
    *   *Kỹ thuật:* Sử dụng `CustomPaint` và Canvas API để render 60fps. Chỉ vẽ các nốt nằm trong Viewport hiện tại.

### 7. Interactive Learning (Chế độ Học tập)
*   **Wait Mode (Chờ nốt):**
    *   *Mô tả:* Nhạc (và nốt rơi) tạm dừng lại ở vị trí hiện tại. Cần lắng nghe luồng `MIDI IN`, nếu người dùng đánh đúng phím, nhạc mới tiếp tục chạy.
*   **Hands Separate (Tách tay):**
    *   *Mô tả:* Mute (Tắt tiếng) Track/Channel của tay trái hoặc tay phải để người dùng tự luyện bè còn lại.
*   **Loop Đoạn A-B:**
    *   *Mô tả:* Kéo thả thanh trượt để chọn điểm đầu (A) và điểm cuối (B). Trình phát sẽ chỉ lặp đi lặp lại vòng lặp này.
*   **Tempo Trainer:**
    *   *Mô tả:* Cài đặt tốc độ khởi điểm (ví dụ: 50%). Nếu user hoàn thành đoạn nhạc với độ chính xác > 90%, tốc độ tự tăng lên 5% trong lần lặp tiếp theo.

### 8. Analytics & Advanced Recording (Phân tích & Thu âm Nâng cao)
*   **Velocity Map (Bản đồ lực đánh):**
    *   *Mô tả:* Sau khi kết thúc bài luyện tập, hiển thị biểu đồ so sánh lực đánh (Velocity) của bản gốc và bản thu của user. Highlight đỏ những nốt đánh sai nhịp hoặc sai lực.
*   **Acoustic Audio-to-MIDI Conversion (Thu âm qua Mic):**
    *   *Mô tả:* Dành cho piano cơ không có cổng MIDI. Dùng Microphone của thiết bị để thu âm thanh trực tiếp.
    *   *Kỹ thuật:* Sử dụng mô hình AI (nhạy với dải tần piano) chạy local (TFLite) để phân tích tần số âm thanh (FFT), nhận diện phím đàn và chuyển đổi tín hiệu analog thành file `.mid` tự động.

---

## GIAI ĐOẠN 3: Cloud, Social & CMS (Tương lai)
*Mục tiêu: Kết nối hệ sinh thái, đồng bộ dữ liệu đa nền tảng và cung cấp kho nội dung khổng lồ.*

### 9. Cloud Sync & Authentication (Tích hợp Supabase)
*   **User Management:** Đăng nhập qua Email, Google, Apple ID.
*   **Database Sync:** Lắng nghe thay đổi từ Isar Local DB và đồng bộ hai chiều với PostgreSQL của Supabase. Trạng thái playlist, bài hát yêu thích được giữ nguyên trên mọi thiết bị.
*   **Online MIDI Library:**
    *   *Mô tả:* Kho nhạc được lưu trữ trên Supabase Storage, phân loại theo Thể loại (Classical, Jazz, Pop).
    *   *Luồng xử lý:* User tải file `.mid` từ Server -> Lưu vào Cache -> Thêm metadata vào Local DB -> Phát nhạc Offline.

### 10. Monitoring & App Configuration (Tích hợp Firebase)
*   **Crashlytics & Error Logs:** Ghi nhận các lỗi phát sinh (đặc biệt trong khâu parsing file MIDI hỏng hoặc mất kết nối Bluetooth đột ngột).
*   **Analytics:** Theo dõi "Most played songs", "Playback history", thời lượng luyện tập trung bình để xây dựng Daily Streaks.

### 11. Admin CMS (Quản trị nội dung)
*   *Nền tảng:* Xây dựng bằng Flutter Web hoặc ReactJS.
*   *Tính năng:* Quản lý User, phân quyền, Upload file MIDI hàng loạt lên server, chỉnh sửa metadata (thêm cover image, tên tác giả) và quản lý các Playlist Public.