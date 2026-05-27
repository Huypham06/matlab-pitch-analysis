% ========================================================================
% BƯỚC 1: NẠP TÍN HIỆU ĐẦU VÀO VÀ THIẾT KẾ BỘ LỌC DẢI THÔNG (VẼ ĐỒ THỊ BỘ LỌC)
% ========================================================================
clear all; close all; clc;

file_in = 'voice_noisy_input.wav';
if ~exist(file_in, 'file')
    error('Không tìm thấy file %s! Hãy đặt file vào cùng thư mục với code.', file_in);
end

% Nạp trực tiếp tín hiệu nhiễm nhiễu đầu vào
[voice_nhieu, fs] = audioread(file_in);
if size(voice_nhieu, 2) > 1
    voice_nhieu = voice_nhieu(:, 1); % Ép về 1 kênh Mono để xử lý
end

% Thiết kế bộ lọc FIR dải thông dùng cửa sổ Hamming (Bậc N=40, dải thông 300 - 3400 Hz)
N = 40;
f_cut = [300 3400];
Wn = f_cut / (fs / 2); % Chuẩn hóa tần số theo Nyquist
b = fir1(N, Wn, 'bandpass', hamming(N + 1));

% Phân rã trực tiếp thành cấu trúc nối tiếp Cascade SOS để tăng độ ổn định
[sos, g] = tf2sos(b, 1);

% --- ĐỒ THỊ 1: ĐẶC TÍNH ĐÁP ỨNG TẦN SỐ CỦA BỘ LỌC (HÀM freqz) ---
figure(1);
[H, f] = freqz(b, 1, 512, fs);

subplot(2,1,1);
plot(f, 20*log10(abs(H)), 'r-', 'LineWidth', 1.5); grid on;
xlabel('Tần số (Hz)'); ylabel('Biên độ (dB)');
title('Hình 1a: Đặc tính đáp ứng biên độ bộ lọc FIR dải thông');
xlim([0 fs/2]);

subplot(2,1,2);
plot(f, unwrap(angle(H))*180/pi, 'g-', 'LineWidth', 1.5); grid on;
xlabel('Tần số (Hz)'); ylabel('Pha (độ)');
title('Hình 1b: Đặc tính đáp ứng pha bộ lọc FIR dải thông');
xlim([0 fs/2]);

% Tự động lưu ảnh bộ lọc phục vụ báo cáo
print('-dpng', '-r300', 'fir_freqz.png');

% Lưu dữ liệu để Bước 2 gọi ra sử dụng
save('step1_output.mat', 'voice_nhieu', 'fs', 'sos', 'g');

disp('=== ĐÃ HOÀN THÀNH BƯỚC 1: Thiết kế bộ lọc và xuất ảnh fir_freqz.png ===');
