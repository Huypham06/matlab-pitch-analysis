% ========================================================================
% BƯỚC 1: NẠP FILE MẪU START.AU VÀ PHÂN TÍCH PITCH (Mục 8.3 Giáo trình)
% ========================================================================
clear all; close all; clc;

% Đổi tên file đích thành file .au bạn vừa tải lên
file_name = 'start.au'; 

if ~exist(file_name, 'file')
    error('Không tìm thấy file %s! Hãy bỏ file vào cùng thư mục với code.', file_name);
end

% Hàm audioread của MATLAB hỗ trợ đọc trực tiếp file .au cực kỳ chuẩn xác
[voice_raw, fs] = audioread(file_name);

% Nếu file có nhiều kênh (Stereo), chỉ lấy 1 kênh đầu tiên để xử lý
if size(voice_raw, 2) > 1
    voice_raw = voice_raw(:, 1);
end

% ========================================================================
% CHUẨN HÓA BIÊN ĐỘ (Ép biên độ trồi sụt về dải chuẩn -0.5 đến 0.5)
% ========================================================================
voice = 0.5 * (voice_raw / max(abs(voice_raw)));

% Lưu dữ liệu chuẩn hóa rời rạc để các file kịch bản sau đọc chung
save('voice_raw.mat', 'voice', 'fs');

% --- TRÍCH XUẤT PHÂN ĐOẠN LÕI VOICED ---
start_sample = 3500; 
end_sample = start_sample + 2000;
voiced_segment = voice(start_sample:end_sample);

% Thuật toán tìm đỉnh Pitch tự động tính khoảng cách mẫu dựa trên fs của file .au
min_distance = round(fs * 0.0025); 
[pks, locs] = findpeaks(voiced_segment, 'MinPeakDistance', min_distance, 'MinPeakHeight', max(voiced_segment)*0.3);

% Tính toán chu kỳ cơ bản miền thời gian rời rạc
Ts = 1 / fs; 
khoang_cach_mau = mean(diff(locs));
pitch_period_ms = khoang_cach_mau * Ts * 1000; 
F0 = fs / khoang_cach_mau;

fprintf('\n[KẾT QUẢ ĐO ĐẠC HÌNH 3.1 TỪ FILE KHÁCH QUAN]:\n');
fprintf('Tần số lấy mẫu mặc định của file (fs): %d Hz\n', fs);
fprintf('Khoảng cách mẫu trung bình giữa các đỉnh Pitch: %.2f mẫu\n', khoang_cach_mau);
fprintf('Chu kỳ Pitch kết quả (T0): %.2f ms\n', pitch_period_ms);
fprintf('Tần số cơ bản hệ thống (F0): %.2f Hz\n', F0);

if pitch_period_ms > 5.5 && pitch_period_ms <= 10
    disp('=> Đặc điểm hệ thống phân loại: GIỌNG NAM (Chu kỳ dài)');
elseif pitch_period_ms > 2 && pitch_period_ms <= 5.5
    disp('=> Đặc điểm hệ thống phân loại: GIỌNG NỮ (Chu kỳ ngắn)');
else
    disp('=> Phân đoạn sóng âm học phức tạp.');
end

% --- ĐỒ THỊ ĐỒNG BỘ BÁO CÁO ---
figure(1);
subplot(2, 1, 1); 
plot(voice, 'b'); 
title('Hình 3.1a: Toàn bộ dạng sóng tín hiệu từ file mẫu x[n]');
xlabel('Số mẫu (Samples)'); ylabel('Biên độ'); grid on;
ylim([-0.6 0.6]);

subplot(2, 1, 2);
plot(voiced_segment, 'b-'); hold on;
plot(locs, pks, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 5); 
title('Hình 3.1b: Phân đoạn Voiced trích xuất và các đỉnh Pitch tuần hoàn');
xlabel('Số mẫu (Samples)'); ylabel('Biên độ'); grid on;
ylim([-0.6 0.6]);
hold off;

drawnow;
print('-dpng', '-r300', 'pitch_plot.png');
disp('=> Đã lưu ảnh pitch_plot.png hoàn hảo!');