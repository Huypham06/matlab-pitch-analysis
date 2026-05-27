% ========================================================================
% BƯỚC 3: HIỆN THỰC PHƯƠNG TRÌNH SAI PHÂN TIẾNG VỌNG ECHO VÀ VẼ ĐỒ THỊ 
% ========================================================================
clear all; close all; clc;

% Tải dữ liệu sạch đầu ra từ Bước 2
if ~exist('step2_output.mat', 'file')
    error('Không tìm thấy file step2_output.mat! Hãy chạy file bước 2 trước.');
end
load('step2_output.mat');

N_samples = length(voice_sach);
t = (0:N_samples-1)' / fs;

a = 0.6;               % Hệ số suy hao Echo đặt trước
tau = 0.15           % Thời gian trễ vật lý (150 ms)
d = round(tau * fs);   % Số mẫu trễ rời rạc tương ứng

% Hiện thực toán tử trễ tuyến tính tuần hoàn theo vòng lặp
echo_out = zeros(N_samples, 1);
for n = 1:N_samples
    if n - d > 0
        echo_out(n) = voice_sach(n) + a * voice_sach(n - d);
    else
        echo_out(n) = voice_sach(n);
    end
end

% Chuẩn hóa tự động biên độ đỉnh để tránh méo tiếng
peak = max(abs(echo_out));
if peak > 0.98
    echo_out = echo_out / peak * 0.95;
end

% --- ĐỒ THỊ 4: SO SÁNH TRƯỚC VÀ SAU KHI TẠO HIỆU ỨNG ECHO ---
figure(4);
subplot(2,1,1);
plot(t, voice_sach, 'b-', 'LineWidth', 0.8); grid on;
xlim([0.8 1.8]);
ylabel('Biên độ'); ylim([-0.7 0.7]);
title('Hình 4a: Tín hiệu trước Echo (Tín hiệu sạch sau khi lọc nhiễu)');

subplot(2,1,2);
plot(t, echo_out, 'm-', 'LineWidth', 0.8); grid on;
xlim([0.8 1.8]);
xlabel('Thời gian (giây)'); ylabel('Biên độ'); ylim([-0.7 0.7]);
title(sprintf('Hình 4b: Tín hiệu ngõ ra Echo y[n] hoàn thiện (Hệ số a=%.1f, Độ trễ τ=%d ms)', a, round(tau*1000)));

print('-dpng', '-r300', 'echo_result.png');

% Kết xuất sản phẩm ra file .wav vật lý để nghe thử
audiowrite('voice_echo_output.wav', echo_out, fs);

disp('=== ĐÃ HOÀN THÀNH BƯỚC 3: Xuất ảnh echo_result.png và file voice_echo_output.wav ===');
disp('=== TOÀN BỘ HỆ THỐNG DỰ ÁN 3 BƯỚC ĐÃ ĐƯỢC THỰC THI HOÀN HẢO TỐI ƯU ===');
