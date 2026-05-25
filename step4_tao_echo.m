% ========================================================================
% BƯỚC 4 (ĐÃ SỬA): HIỆN THỰC PHƯƠNG TRÌNH SAI PHÂN TIẾNG VỌNG ECHO
% y[n] = x[n] + a * x[n - d]
% ========================================================================
clear all; close all; clc;
 
load('voice_clean.mat');
 
fprintf('--- Hiện thực toán tử trễ tạo tiếng vọng Echo ---\n');
fprintf('Tần số lấy mẫu: %d Hz\n', fs);
 
a   = 0.6;               % Hệ số suy hao Echo
tau = 0.15;              % Thời gian trễ tiếng vọng (150 ms)
d   = round(tau * fs);   % Số mẫu trễ
 
fprintf('Hệ số suy hao Echo (a): %.2f\n', a);
fprintf('Thời gian trễ (tau): %.0f ms  →  %d mẫu\n', tau*1000, d);
 
% --- Phương trình sai phân ---
N = length(voice_sach);
echo_out = zeros(N, 1);
for n = 1:N
    if n - d > 0
        echo_out(n) = voice_sach(n) + a * voice_sach(n - d);
    else
        echo_out(n) = voice_sach(n);
    end
end
 
% Chuẩn hóa để tránh clipping khi xuất âm
peak = max(abs(echo_out));
if peak > 0.98
    echo_out = echo_out / peak * 0.95;
end
 
% --- Đồ thị ---
figure(4);
t = (0:N-1)/fs;
 
subplot(2,1,1);
plot(t, voice_sach, 'b-', 'LineWidth', 0.8); grid on;
xlabel('Thời gian (giây)'); ylabel('Biên độ');
title('Hình 3.4a: Tín hiệu sau lọc (trước Echo) x[n]');
ylim([-0.7 0.7]);
 
subplot(2,1,2);
plot(t, echo_out, 'm-', 'LineWidth', 0.8); grid on;
xlabel('Thời gian (giây)'); ylabel('Biên độ');
title(sprintf('Hình 3.4b: Tín hiệu ngõ ra Echo y[n]  (a=%.1f, τ=%d ms)', a, round(tau*1000)));
ylim([-0.7 0.7]);
 
print('-dpng', '-r300', 'echo_result.png');
disp('=> Đã xuất ảnh echo_result.png');
 
% Xuất file âm thanh
audiowrite('voice_echo_output.wav', echo_out, fs);
disp('=> Đã xuất file âm thanh: voice_echo_output.wav');
disp('');
disp('=== HOÀN THÀNH TOÀN BỘ HỆ THỐNG ===');
disp('File âm thanh để nghe thử:');
disp('  voice_noisy_output.wav    → tín hiệu bị nhiễu');
disp('  voice_filtered_output.wav → sau khi lọc (sạch nhiễu)');
disp('  voice_echo_output.wav     → hiệu ứng Echo cuối cùng');