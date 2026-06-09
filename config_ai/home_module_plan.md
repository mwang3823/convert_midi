# Kế hoạch cập nhật Home Module (Home Screen & Home Bloc) - [ĐÃ HOÀN THÀNH]

## 1. Trạng thái kết nối Bluetooth (`AppBadge`)
*   **Hiện tại:** Nút `AppBadge` cho phần kết nối Bluetooth đang bị hardcode chỉ hiển thị một trạng thái "CONNECTED".
*   **Chỉnh sửa / Thêm mới:**
    *   Sử dụng biến `isConnected` được lắng nghe thông qua `Globals.bluetoothService.connectionState`.
    *   Cập nhật UI `HomeScreen` với toán tử 3 ngôi (ternary) để tự động chuyển trạng thái.
*   **Thực tế triển khai:** 
    *   Tạo `MockBluetoothService` và tự động sử dụng trên máy ảo (Đề xuất 2).
    *   Giao diện tự chuyển đổi linh hoạt.

## 2. Ẩn/Hiện thông tin bài nhạc đang tập (`CurrentFocusCard`)
*   **Đề xuất được chọn:** **Gợi ý ngẫu nhiên (Smart Suggestion)** thay vì ẩn hoàn toàn thẻ.
*   **Thực tế triển khai:** 
    *   Tải dữ liệu từ `SharedPreferences`. Nếu không có bài đang tập, `HomeBloc` sẽ chọn ngẫu nhiên một bài hát trong danh sách MIDI.
    *   `CurrentFocusCard` được bổ sung cờ `isSuggestion`, khi đó huy hiệu nhỏ trên thẻ sẽ chuyển màu vàng hổ phách (Amber) và ghi "SUGGESTION" để phân biệt với "CURRENT FOCUS".

## 3. Danh sách File MIDI và chức năng Import (`_buildMidiSection`)
*   **Thực tế triển khai:**
    *   Tích hợp gói `file_picker` và `path_provider` để gọi trình chọn file của điện thoại và copy file `.mid` / `.midi` vào bộ nhớ ứng dụng `ApplicationDocumentsDirectory`.
    *   Cập nhật mảng màu sắc `iconColors` thành 5 màu lấy từ theme hệ thống (`neonCyan`, `magenta`, `emerald`, `amber`, `tertiaryFixed`) giúp danh sách hiển thị sống động và giảm trùng lặp.
