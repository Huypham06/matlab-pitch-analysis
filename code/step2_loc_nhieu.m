% ========================================================================
% BƯỚC 2: THỰC HIỆN LỌC SỐ, VẼ ĐỒ THỊ MIỀN THỜI GIAN VÀ PHỔ TẦN SỐ (FFT)
% ========================================================================
clear all; close all; clc;

% Tải dữ liệu đầu ra từ Bước 1
if ~exist('step1_output.mat', 'file')
    error('Không tìm thấy file step1_output.mat! Hãy chạy file bước 1 trước.');
end
load('step1_output.mat');

% Lọc nhiễu bằng bộ cấu trúc nối tiếp Cascade SOS
voice_sach = sosfilt(sos, voice_nhieu) * g;

% Cấu hình vector thời gian và chọn phân đoạn 60ms để quan sát rõ gai nhiễu
N_samples = length(voice_nhieu);
t = (0:N_samples-1)' / fs;
seg_start = round(0.35 * N_samples);
seg_end   = seg_start + round(fs * 0.06); 
seg = seg_start:seg_end;

% --- ĐỒ THỊ 2: SO SÁNH DẠNG SÓNG MIỀN THỜI GIAN ---
figure(2);
subplot(2,1,1);
plot(t(seg), voice_nhieu(seg), 'r-', 'LineWidth', 1); grid on;
ylabel('Biên độ'); ylim([-0.8 0.8]);
title('Hình 2a: Dạng sóng miền thời gian trước lọc (Bị nhiễm nhiễu nặng)');

subplot(2,1,2);
plot(t(seg), voice_sach(seg), 'k-', 'LineWidth', 1.2); grid on;
xlabel('Thời gian (giây)'); ylabel('Biên độ'); ylim([-0.8 0.8]);
title('Hình 2b: Dạng sóng miền thời gian sau lọc số FIR Cascade SOS');

print('-dpng', '-r300', 'waveform_comparison.png');

% --- ĐỒ THỊ 3: SO SÁNH PHỔ TẦN SỐ BIÊN ĐỘ (FFT) ---
NFFT = 2048;
f_axis = (0:NFFT/2) * fs / NFFT;
S_noisy = abs(fft(voice_nhieu, NFFT)); S_noisy = S_noisy(1:NFFT/2+1);
S_clean = abs(fft(voice_sach,  NFFT)); S_clean = S_clean(1:NFFT/2+1);
eps_val = 1e-10; 

figure(3);
subplot(2,1,1);
plot(f_axis, 20*log10(S_noisy + eps_val), 'r'); grid on; xlim([0 fs/2]); ylim([-60 60]);
ylabel('Biên độ (dB)'); title('Hình 3a: Phổ Tần số trước lọc (Xuất hiện các gai nhiễu ngoài băng)');
xline(300, '--k', '300 Hz'); xline(3400, '--k', '3400 Hz');

subplot(2,1,2);
plot(f_axis, 20*log10(S_clean + eps_val), 'k'); grid on; xlim([0 fs/2]); ylim([-60 60]);
xlabel('Tần số (Hz)'); ylabel('Biên độ (dB)'); title('Hình 3b: Phổ Tần số sau lọc (Nhiễu dải chặn đã bị loại bỏ)');
xline(300, '--k', '300 Hz'); xline(3400, '--k', '3400 Hz');

print('-dpng', '-r300', 'spectrum_comparison.png');
audiowrite('voice_filtered_output.wav', voice_sach, fs);
save('step2_output.mat', 'voice_sach', 'fs');

disp('=== ĐÃ HOÀN THÀNH BƯỚC 2 ===');
disp('=> Đã lưu đồ thị thời gian: waveform_comparison.png');
disp('=> Đã lưu đồ thị phổ FFT  : spectrum_comparison.png');
disp('=> Đã xuất file nghe thử   : voice_filtered_output.wav (Tín hiệu sạch sau lọc)');
