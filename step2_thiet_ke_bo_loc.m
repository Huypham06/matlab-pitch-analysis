% ========================================================================
% BƯỚC 2: THIẾT KẾ BỘ LỌC FIR VÀ PHÂN RÃ CẤU TRÚC CASCADE SOS
% ========================================================================
clear all; close all; clc;

load('voice_raw.mat', 'fs');

fprintf('--- Thiết kế bộ lọc FIR dải thông Hamming ---\n');
N = 40;                     % Bậc của bộ lọc FIR
f_cut = [300 3400];         % Dải thông tần số tiếng nói đích
Wn = f_cut / (fs/2);        % Chuẩn hóa theo tần số Nyquist của file gốc
b = fir1(N, Wn, 'bandpass', hamming(N+1)); 

% Phân rã cấu trúc trực tiếp thành cấu trúc nối tiếp Cascade SOS (Chương 4)
[sos, g] = tf2sos(b, 1);

save('filter_coefficients.mat', 'b', 'sos', 'g');

figure(2);
[H, f] = freqz(b, 1, 512, fs);
subplot(2,1,1);
plot(f, 20*log10(abs(H)), 'r-', 'LineWidth', 1.5); grid on;
xlabel('Tần số (Hz)'); ylabel('Biên độ (dB)');
title('Hình 3.2a: Đặc tính đáp ứng biên độ bộ lọc FIR dải thông');
xlim([0 fs/2]);

subplot(2,1,2);
plot(f, unwrap(angle(H))*180/pi, 'g-', 'LineWidth', 1.5); grid on;
xlabel('Tần số (Hz)'); ylabel('Pha (độ)');
title('Hình 3.2b: Đặc tính đáp ứng pha bộ lọc FIR dải thông');
xlim([0 fs/2]);

print('-dpng', '-r300', 'fir_freqz.png');
disp('=> Đã xuất ảnh fir_freqz.png');